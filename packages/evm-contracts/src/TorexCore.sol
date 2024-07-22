// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {
    ISuperToken, ISuperfluidPool, PoolConfig
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

import { ILiquidityMover } from "./interfaces/torex/ILiquidityMover.sol";
import { ITwapObserver } from "./interfaces/torex/ITwapObserver.sol";
import { LiquidityMoveResult } from "./interfaces/torex/ITorex.sol";

import { DiscountFactor, getDiscountedValue } from "./libs/DiscountFactor.sol";
import { Scaler } from "./libs/Scaler.sol";

/**
 * @title Abstract contract for the core logic of TOREX
 *
 * @notice A TOREX swaps liquidity of *in-tokens* for liquidity of *out-tokens* for traders.
 *
 * To do so, each TOREX book keeps money streams from traders at *money flow events*, maintains a temporary liquidity
 * pool of in-tokens, and offers the liquidity to *liquidity movers* at a *benchmark quote* for an amount of out-tokens.
 *
 * At a *liquidity movement event*, the TOREX receives the quoted amount of out-tokens and distributes them to the
 * traders through Superfluid money distribution.
 *
 * Each TOREX is configured with a dedicated TWAP observer, through which TOREX can create checkpoints and query TWAP
 * since the last checkpoint. TOREX then discounts this TWAP through a discount model that ensures that TOREX should
 * never stall by offering the liquidity movers ever-greater incentives over time.
 *
 * For more details about torex core logic, read the Torex whitepaper.
 */
abstract contract TorexCore is ReentrancyGuard {
    using SuperTokenV1Library for ISuperToken;

    /*******************************************************************************************************************
     * Definitions
     ******************************************************************************************************************/

    error LIQUIDITY_MOVER_SENT_INSUFFICIENT_OUT_TOKENS();

    /*******************************************************************************************************************
     * Configurations and Constructor
     ******************************************************************************************************************/

    /// In token of the Torex.
    ISuperToken    internal immutable _inToken;
    /// Out token of the Torex.
    ISuperToken    internal immutable _outToken;
    /// Observer of the twap.
    ITwapObserver  internal immutable _observer;
    /// Scaler for the twap observed.
    Scaler         internal immutable _twapScaler;
    /// Discount factor for the twap.
    DiscountFactor internal immutable _discountFactor;
    /// Scaler for the out token distribution pool units.
    Scaler         internal immutable _outTokenDistributionPoolScaler;

    /// Out token distribution pool.
    ISuperfluidPool internal immutable _outTokenDistributionPool;

    constructor(ISuperToken inToken, ISuperToken outToken,
                ITwapObserver observer, Scaler twapScaler, DiscountFactor discountFactor,
                Scaler outTokenDistributionPoolScaler) {
        _inToken = inToken;
        _outToken = outToken;
        _observer = observer;
        _twapScaler = twapScaler;
        _discountFactor = discountFactor;
        _outTokenDistributionPoolScaler = outTokenDistributionPoolScaler;

        _outTokenDistributionPool = _outToken.createPool(address(this), PoolConfig({
                transferabilityForUnitsOwner: false,
                distributionFromAnyAddress: true
                }));
    }

    /*******************************************************************************************************************
     * Core Logic
     ******************************************************************************************************************/

    /**
     * @notice Calculate the required amount of in tokens for liquidity movement.
     */
    function availableInTokens() virtual internal view returns (uint256);

    /**
     * @notice Calculate required back adjustment for in-token flow rate change.
     */
    function _requiredBackAdjustment(int96 prevFlowRate, int96 newFlowRate) internal view
        returns (uint256 durationSinceLastLME, int256 backAdjustment)
    {
        durationSinceLastLME = getDurationSinceLastLME();
        backAdjustment = SafeCast.toInt256(durationSinceLastLME) * (newFlowRate - prevFlowRate);
    }

    /**
     * @notice Upon in-token flow changed from sender, calculate the required back adjustment and update the out-token
     *         distribution pool units for the sender.
     */
    function _onInFlowChanged(address sender, int96 prevFlowRate, int96 newFlowRate) internal
        returns (uint256 durationSinceLastLME, int256 backAdjustment)
    {
        // Take back charge from the sender is required so that the new units that we are about to give to the sender is
        // fair one everyone. Without it, attackers may game the system.
        //
        // Similar to the back charge on flow creation, we do a back refund. After that, we can then set the units to 0
        // fairly. This can also act as escape hatch in case a Torex for any reason gets stuck in the sense that no
        // liquidity moving takes place anymore. In that case, flow deletion auto-withdraws accumulated inTokens.
        (durationSinceLastLME, backAdjustment) = _requiredBackAdjustment(prevFlowRate, newFlowRate);

        // assigning new units
        uint128 newUnits = uint128(SafeCast.toInt128(_outTokenDistributionPoolScaler.scaleValue(newFlowRate)));
        _outTokenDistributionPool.updateMemberUnits(sender, newUnits);
    }

    /**
     * @notice Move liquidity, called by a liquidity mover.
     *
     * Note:
     * - The amount of in token disposable by the contract is called inAmount.
     * - Send inAmount inToken to msg.sender and request outAmount of out token from the msg.sender.
     * - The outAmount need to be satisfy the price threshold defined by getBenchmarkQuote(inAmount).
     */
    function _moveLiquidity(bytes memory moverData) internal
        nonReentrant
        returns (LiquidityMoveResult memory result)
    {
        (result.inAmount, result.minOutAmount, result.durationSinceLastLME, result.twapSinceLastLME) =
            getLiquidityEstimations();

        // Step 1: Transfer the inAmount of inToken liquidity to the liquidity mover.
        _inToken.transfer(msg.sender, result.inAmount);

        // Step 2: Ask liquidity mover to provide outAmount of outToken liquidity in exchange.
        assert((ILiquidityMover(msg.sender))
               .moveLiquidityCallback(_inToken, _outToken, result.inAmount, result.minOutAmount, moverData));
        // We distribute everything the contract has got from liquidity mover.
        result.outAmount = _outToken.balanceOf(address(this));
        if (result.outAmount < result.minOutAmount) revert LIQUIDITY_MOVER_SENT_INSUFFICIENT_OUT_TOKENS();

        // Step 3: Create new torex observer check point
        _observer.createCheckpoint(block.timestamp);

        // Step 4: Distribute all outToken liquidity to degens.
        // NOTE: This could be more than outAmount.
        result.actualOutAmount = _outToken
            .estimateDistributionActualAmount(address(this), _outTokenDistributionPool, result.outAmount);
        _outToken.distributeToPool(address(this), _outTokenDistributionPool, result.actualOutAmount);
    }

    /*******************************************************************************************************************
     * View Functions
     ******************************************************************************************************************/

    /**
     * @dev Get the benchmark price.
     * @param  inAmount  In token amount provided in 18 decimals.
     * @return minOutAmount Minimum out token discounting twapSinceLastLME.
     * @return durationSinceLastLME Result from `getDurationSinceLastLME()`.
     * @return twapSinceLastLME Result from `getTwapSinceLastLME(inAmount)`.
     *
     * Notes:
     *
     * - A benchmark price is discounted of the full price returned by `getTwapSinceLastCheckpoint`.
     */
    function getBenchmarkQuote(uint256 inAmount) public view
        returns (uint256 minOutAmount, uint256 durationSinceLastLME, uint256 twapSinceLastLME)
    {
        (twapSinceLastLME, durationSinceLastLME) = _observer.getTwapSinceLastCheckpoint(block.timestamp, inAmount);
        twapSinceLastLME = _twapScaler.scaleValue(twapSinceLastLME);
        minOutAmount = getDiscountedValue(_discountFactor, twapSinceLastLME, durationSinceLastLME);
    }

    /**
     * @dev Get the time duration since last LME until now. Synonym to getDurationSinceLastCheckpoint.
     */
    function getDurationSinceLastLME() public view returns (uint256) {
        return _observer.getDurationSinceLastCheckpoint(block.timestamp);
    }

    /**
     * @dev Estimate amount of tokens involved in the next liquidity movement.
     */
    function getLiquidityEstimations() public view
        returns (uint256 inAmount, uint256 minOutAmount, uint256 durationSinceLastLME, uint256 twapSinceLastLME)
    {
        inAmount = availableInTokens();
        (minOutAmount, durationSinceLastLME, twapSinceLastLME) = getBenchmarkQuote(inAmount);
    }
}
