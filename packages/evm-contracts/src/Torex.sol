// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";

import {
    ISuperfluid, ISuperToken, ISuperfluidPool, PoolConfig
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { CFASuperAppBase } from "@superfluid-finance/ethereum-contracts/contracts/apps/CFASuperAppBase.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

import { ITwapObserver } from "./interfaces/torex/ITwapObserver.sol";
import {
    LiquidityMoveResult, ITorexController, ITorex
} from "./interfaces/torex/ITorex.sol";
import { DiscountFactor } from "./libs/DiscountFactor.sol";
import { toInt96, INT_100PCT_PM } from "../src/libs/MathExtra.sol";
import { Scaler } from "./libs/Scaler.sol";

import { TorexCore } from "./TorexCore.sol";


/**
 * @title A TOREX that is a super app, distributes fees, and has a controller.
 *
 * @notice Notes:
 *
 * - In addition to the TOREX core logic, this implementation uses super app framework to support cash flow automation.
 *
 * - It has hooks for flow update events and liquidity moved events, where its controller (ITorexController) can use to
 *   implement additional logic.
 *
 * - Further more, it has its own Superfluid pool for distributing fees. The admin of the pool is the controller and the
 *   controller controls the fee percent. Notably though, the TOREX protects its traders from rouge controller by having
 *   an immutable configuration of max allowed fee percent.
 *
 * TODO:
 *
 * - [] gas limit and error handling of controller.onInFlowChanged and controller.onLiquidityMoved to become truly
 *      robust and secure TOREX.
 *
 * CHANGELOG:
 *
 * [1.0.0-rc2] - 2024-04-12
 *
 * First tagged version.
 *
 * Fixes:
 * - Added TorexCore.availableInTokens in order to allow Torex implementation to reserve in-tokens in its discretion.
 * - Torex.availableInTokens to reserve minimum buffer requirement for _requestedFeeDistFlowRate.
 * - Torex stores _feeDistBuffer, in order to make better fee back adjustment.
 * - Torex uses SuperTokenV1Library.getGDAFlowInfo in _onInFlowChanged.
 */
contract Torex is TorexCore, CFASuperAppBase, ITorex {
    string public constant VERSION = "1.0.0-rc2";

    using SuperTokenV1Library for ISuperToken;

    /*******************************************************************************************************************
     * Definitions
     ******************************************************************************************************************/

    /// Configuration of the torex.
    struct Config {
        ISuperToken inToken;
        ISuperToken outToken;
        ITwapObserver observer;
        DiscountFactor discountFactor;
        Scaler twapScaler;
        Scaler outTokenDistributionPoolScaler;
        ITorexController controller;
        int256 maxAllowedFeePM;
    }

    /// Trader state.
    struct TraderState {
        /// A contribution flow is the flow rate that is accounted by the TOREX core logic.
        int96 contribFlowRate;
        /// A fee flow is the flow rate that is distributed through the `feeDistributionPool`.
        int96 feeFlowRate;
    }

    /// Context for the liquidity moved event.
    event LiquidityMoved(address indexed liquidityMover,
                         uint256 durationSinceLastLME, uint256 twapSinceLastLME,
                         uint256 inAmount, uint256 minOutAmount,
                         uint256 outAmount, uint256 actualOutAmount);

    /// Context for Torex flow updated event.
    event TorexFlowUpdated(address indexed sender,
                           int96 newFlowRate, int96 newContribFlowRate, int256 backAdjustment,
                           int96 requestedFeeDistFlowRate, int96 actualFeeDistFlowRate);

    /*******************************************************************************************************************
     * Configurations and Constructor
     ******************************************************************************************************************/

    /// Maximum fee (in Per Millions) allowed from the controller, in case of rogue controller.
    int256 public immutable MAX_ALLOWED_FEE_PM;

    /// @inheritdoc ITorex
    ITorexController public override immutable controller;

    /// @inheritdoc ITorex
    ISuperfluidPool public override immutable feeDistributionPool;

    /// View configuration.
    function getConfig() public view returns (Config memory) {
        return Config({
            controller: controller,
            inToken: _inToken,
            outToken: _outToken,
            observer: _observer,
            twapScaler: _twapScaler,
            discountFactor: _discountFactor,
            outTokenDistributionPoolScaler: _outTokenDistributionPoolScaler,
            maxAllowedFeePM: MAX_ALLOWED_FEE_PM
            });
    }

    constructor(Config memory config)
        CFASuperAppBase(ISuperfluid(config.inToken.getHost()))
        TorexCore(config.inToken, config.outToken,
                  config.observer, config.twapScaler, config.discountFactor,
                  config.outTokenDistributionPoolScaler) {
        assert(config.inToken.getHost() == config.outToken.getHost());
        assert(address(config.observer) != address(0));
        assert(config.maxAllowedFeePM <= INT_100PCT_PM);

        controller = config.controller;
        MAX_ALLOWED_FEE_PM = config.maxAllowedFeePM;

        feeDistributionPool = _inToken.createPool(address(controller), PoolConfig({
                transferabilityForUnitsOwner: false,
                distributionFromAnyAddress: true
                }));
    }

    /*******************************************************************************************************************
     * States
     ******************************************************************************************************************/

    /// Tracking current contribution flow rates of traders.
    mapping(address => TraderState) private traderStates;
    /// A view function for trader states that is struct-ABI-friendly.
    function getTraderState(address a) external view returns (TraderState memory) { return traderStates[a]; }

    /// Tracking current fee distribution flow rate requested.
    int96 private _requestedFeeDistFlowRate;
    /// Tracking the actual fee distribution rate.
    int96 private _actualFeeDistFlowRate;
    /// Buffer used by the fee flow distribution.
    uint256 private _feeDistBuffer;

    /*******************************************************************************************************************
     * Super App Hooks for Flow Life-Cycles
     ******************************************************************************************************************/

    /// @inheritdoc CFASuperAppBase
    function onFlowCreated(ISuperToken superToken, address sender, bytes calldata ctx) internal override
        returns (bytes memory newCtx)
    {
        return _onInFlowChanged(superToken, sender, 0, 0 /* lastUpdated */, ctx);
    }

    /// @inheritdoc CFASuperAppBase
    function onFlowUpdated(ISuperToken superToken, address sender,
                           int96 prevFlowRate, uint256 lastUpdated,
                           bytes calldata ctx) internal override
        returns (bytes memory newCtx)
    {
        return _onInFlowChanged(superToken, sender, prevFlowRate, lastUpdated, ctx);
    }

    /// @inheritdoc CFASuperAppBase
    function onFlowDeleted(ISuperToken superToken, address sender, address /*receiver*/,
                           int96 prevFlowRate, uint256 lastUpdated,
                           bytes calldata ctx) internal override
        returns (bytes memory newCtx)
    {
        return _onInFlowChanged(superToken, sender, prevFlowRate, lastUpdated, ctx);
    }

    function isAcceptedSuperToken(ISuperToken superToken) public view override returns (bool) {
        // We don't handle other token flows.
        return superToken == _inToken;
    }

    function availableInTokens() override internal view returns (uint256 amount) {
        uint256 minimumDeposit =  _inToken.getBufferAmountByFlowRate(_requestedFeeDistFlowRate);
        amount = _inToken.balanceOf(address(this));
        if (amount >= minimumDeposit) return amount - minimumDeposit; else return 0;
    }

    function _onInFlowChanged(ISuperToken superToken, address sender, int96 prevFlowRate, uint256 lastUpdated,
                              bytes memory ctx) internal
        returns (bytes memory newCtx)
    {
        newCtx = ctx;

        ISuperfluid.Context memory context = HOST.decodeCtx(ctx);
        TraderState storage senderState = traderStates[sender];

        int96 newFlowRate;
        int96 newContribFlowRate;
        int96 newFeeFlowRate;
        {
            newFlowRate = superToken.getFlowRate(sender, address(this));

            // FIXME this should be revert-safe
            newFeeFlowRate = controller.onInFlowChanged(sender,
                                                        prevFlowRate, senderState.feeFlowRate, lastUpdated,
                                                        newFlowRate, context.timestamp,
                                                        context.userData);

            // protect traders from rogue controllers.
            if (newFeeFlowRate > newFlowRate * MAX_ALLOWED_FEE_PM / INT_100PCT_PM) {
                newFeeFlowRate = 0;
            }

            newContribFlowRate = newFlowRate - newFeeFlowRate;
        }

        _requestedFeeDistFlowRate = _requestedFeeDistFlowRate + newFeeFlowRate - senderState.feeFlowRate;

        // back adjustments (back charge and back refund)
        int256 backAdjustment;
        {
            // invoke core logic to calculate back charge/refund
            uint256 durationSinceLastLME;
            (durationSinceLastLME, backAdjustment) =
                _onInFlowChanged(sender, senderState.contribFlowRate, newContribFlowRate);

            // in case of the flow rate going up
            if (newFlowRate > prevFlowRate) {
                // add back charge of fees
                if (newFeeFlowRate > senderState.feeFlowRate) {
                    int96 deltaFeeFlowRate = newFeeFlowRate - senderState.feeFlowRate;
                    backAdjustment += deltaFeeFlowRate * SafeCast.toInt256(durationSinceLastLME);
                }

                // fee distribution pool buffer is paid by the sender too
                uint256 feeDistBufferNew = _inToken.getBufferAmountByFlowRate(_requestedFeeDistFlowRate);
                if (feeDistBufferNew > _feeDistBuffer) {
                    backAdjustment += SafeCast.toInt256(feeDistBufferNew - _feeDistBuffer);
                }
            } // else:
            // however, in case of the flow rate going down, there is no refund for back charged fees.
            // this is due to that the fees is being distributed continuously.
        }

        // update sender states
        senderState.contribFlowRate = newContribFlowRate;
        senderState.feeFlowRate = newFeeFlowRate;

        // do back charge
        if (backAdjustment > 0) {
            // Under this branch, this should be true: newFlowRate > prevFlowRate >= 0
            // This could revert, if approvals not available.
            // However, due to newFlowRate > 0, the revert should never jail the app.
            _inToken.transferFrom(sender, address(this), SafeCast.toUint256(backAdjustment));
        }

        // update fee distribution flow rate, this requires the buffer cost taken as part of back adjustment.
        newCtx = _inToken.distributeFlowWithCtx(address(this), feeDistributionPool, _requestedFeeDistFlowRate, newCtx);
        (, _actualFeeDistFlowRate, _feeDistBuffer) = _inToken.getGDAFlowInfo(address(this), feeDistributionPool);

        // do back refund
        if (backAdjustment < 0) {
            // this should never revert
            _inToken.transfer(sender, SafeCast.toUint256(-backAdjustment));
        }

        emit TorexFlowUpdated(sender,
                              newFlowRate, newContribFlowRate, backAdjustment,
                              _requestedFeeDistFlowRate, _actualFeeDistFlowRate);
    }

    /*******************************************************************************************************************
     * Torex Interfaces
    `******************************************************************************************************************/

    /// @inheritdoc ITorex
    function getPairedTokens() external override view returns (ISuperToken inToken, ISuperToken outToken) {
        return (_inToken, _outToken);
    }

    /// @inheritdoc ITorex
    function outTokenDistributionPool() external override view returns (ISuperfluidPool) {
        return _outTokenDistributionPool;
    }

    /// @inheritdoc ITorex
    function estimateApprovalRequired(int96 flowRate) external override view returns (uint256 requiredApproval) {
        // We make the best effort of estimating the approvals required to create the torex flow of the required flow
        // rate. However, in order to keep things simple, extra approvals is always requested. Front-end may zero the
        // approval at the end of the batch call.
        (, int256 maxCoreBackAdjustment) = _requiredBackAdjustment(0, flowRate);
        int96 maxFeeDistRate = _requestedFeeDistFlowRate +
            toInt96(int256(flowRate) * MAX_ALLOWED_FEE_PM / INT_100PCT_PM);
        uint256 feeDistBufferNew = _inToken.getBufferAmountByFlowRate(maxFeeDistRate);
        return SafeCast.toUint256(maxCoreBackAdjustment) +
            (feeDistBufferNew > _feeDistBuffer ? feeDistBufferNew - _feeDistBuffer : 0);
    }

    /// @inheritdoc ITorex
    function moveLiquidity(bytes calldata moverData) external override returns (LiquidityMoveResult memory result) {
        result = _moveLiquidity(moverData);
        assert(controller.onLiquidityMoved(result));
        emit LiquidityMoved(msg.sender,
                            result.durationSinceLastLME, result.twapSinceLastLME,
                            result.inAmount, result.minOutAmount,
                            result.outAmount, result.actualOutAmount);
    }

    /*******************************************************************************************************************
     * Misc
     ******************************************************************************************************************/

    /// Additional debuggin details
    function debugCurrentDetails() external view
        returns (int96 requestedFeeDistFlowRate, int96 actualFeeDistFlowRate, uint256 feeDistBuffer)
    {
        return (_requestedFeeDistFlowRate, _actualFeeDistFlowRate, _feeDistBuffer);
    }
}
