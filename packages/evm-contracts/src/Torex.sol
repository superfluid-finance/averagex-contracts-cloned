// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";

import {
    ISuperfluid, ISuperToken, ISuperfluidPool, PoolConfig
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { CFASuperAppBase } from "@superfluid-finance/ethereum-contracts/contracts/apps/CFASuperAppBase.sol";
import { CallbackUtils } from "@superfluid-finance/ethereum-contracts/contracts/libs/CallbackUtils.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

import { ITwapObserver } from "./interfaces/torex/ITwapObserver.sol";
import {
    LiquidityMoveResult, ITorexController, ITorex
} from "./interfaces/torex/ITorex.sol";
import { DiscountFactor } from "./libs/DiscountFactor.sol";
import { toInt96, UINT_100PCT_PM, INT_100PCT_PM } from "../src/libs/MathExtra.sol";
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
 * CHANGELOG:
 *
 * [1.0.0-rc4.dev] - ...
 *
 * Changed:
 * - Requiring solc 0.8.26.
 * - ITorex interface now has VERSION function.
 * - New error Torex.LIQUIDITY_MOVER_NO_SAME_BLOCK for disallowing LMEs in the same block.
 *
 * Fixes:
 * - onLiquidityMoved was called twice.
 *
 * [1.0.0-rc3] - 2024-06-25
 *
 * Added:
 *
 * - Controller hooks error handling with "safe callback" technique.
 *
 * Changes:
 *
 * - maxAllowedFeePM is now unsigned.
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
    string public constant override VERSION = "1.0.0-rc4.dev";

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
        uint256 controllerSafeCallbackGasLimit;
        uint256 maxAllowedFeePM;
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

    /// Controller error event.
    event ControllerError(bytes reason);

    /*******************************************************************************************************************
     * Configurations and Constructor
     ******************************************************************************************************************/

    /// Gas limit used for safe callbacks to the controller.
    uint256 public immutable CONTROLLER_SAFE_CALLBACK_GAS_LIMIT;

    /// Maximum fee (in Per Millions) allowed from the controller, in case of rogue controller.
    uint256 public immutable MAX_ALLOWED_FEE_PM;

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
            controllerSafeCallbackGasLimit: CONTROLLER_SAFE_CALLBACK_GAS_LIMIT,
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
        assert(config.maxAllowedFeePM <= UINT_100PCT_PM);

        controller = config.controller;
        CONTROLLER_SAFE_CALLBACK_GAS_LIMIT = config.controllerSafeCallbackGasLimit;
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
    int96   private _requestedFeeDistFlowRate;
    /// Tracking the actual fee distribution rate.
    int96   private _actualFeeDistFlowRate;
    /// Buffer used by the fee flow distribution.
    uint256 private _feeDistBuffer;

    /// Counter of internal errors of the controller.
    uint256 public controllerInternalErrorCounter;

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

        // Note: a lot of nested brackets to fight the stack too deep trite

        int96 newFlowRate;
        int96 newContribFlowRate;
        int96 newFeeFlowRate;
        {
            newFlowRate = superToken.getFlowRate(sender, address(this));

            {
                bool requireSafeCallback = newFlowRate == 0; // do not revert in deleteFlow
                bytes memory callData = abi.encodeCall(controller.onInFlowChanged,
                                                       (sender,
                                                        prevFlowRate, senderState.feeFlowRate, lastUpdated,
                                                        newFlowRate, context.timestamp,
                                                        context.userData));
                (bool success, bytes memory returnedData) = _callControllerHook(requireSafeCallback, callData);
                if (success) {
                    newFeeFlowRate = _safeDecodeFeeFlowRate(requireSafeCallback, returnedData);
                }
            }

            // protect traders from rogue controllers.
            if (newFeeFlowRate > newFlowRate * int256(MAX_ALLOWED_FEE_PM) / INT_100PCT_PM) {
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
            toInt96(int256(flowRate) * int256(MAX_ALLOWED_FEE_PM) / INT_100PCT_PM);
        uint256 feeDistBufferNew = _inToken.getBufferAmountByFlowRate(maxFeeDistRate);
        return SafeCast.toUint256(maxCoreBackAdjustment) +
            (feeDistBufferNew > _feeDistBuffer ? feeDistBufferNew - _feeDistBuffer : 0);
    }

    /// @inheritdoc ITorex
    function moveLiquidity(bytes calldata moverData) external override returns (LiquidityMoveResult memory result) {
        result = _moveLiquidity(moverData);
        {
            bool requireSafeCallback = true; // always require safe callback to not block liquidity movements
            bytes memory callData = abi.encodeCall(controller.onLiquidityMoved, (result));
            _callControllerHook(requireSafeCallback, callData);
        }
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

    /*******************************************************************************************************************
     * Safe Controller Hook Functions
     ******************************************************************************************************************/

    /// Call controller hook and handle its potential errors.
    function _callControllerHook(bool safeCallback, bytes memory callData) internal
        returns (bool success, bytes memory returnedData)
    {
        if (safeCallback) {
            bool insufficientCallbackGasProvided;
            (success, insufficientCallbackGasProvided, returnedData) =
                CallbackUtils.externalCall(address(controller), callData, CONTROLLER_SAFE_CALLBACK_GAS_LIMIT);
            if (!success) {
                if (insufficientCallbackGasProvided) {
                    // This will consume all the reset of the gas, propagating the callback's out-of-gas error up.
                    CallbackUtils.consumeAllGas();
                } else {
                    _emitControllerError(returnedData);
                }
            }
        } else {
            // solhint-disable-next-line avoid-low-level-calls
            (success, returnedData) = address(controller).call(callData);
            if (!success) {
                revert(string(returnedData));
            }
        }
    }

    /// Safely decode onInFlowChanged hook result without reverting.
    function _safeDecodeFeeFlowRate(bool requireSafeCallback, bytes memory data) internal
        returns (int96 v)
    {
        if (requireSafeCallback) {
            if (data.length != 32) _emitControllerError("safeDecodeFeeFlowRate: 1");
            else {
                (uint256 vv) = abi.decode(data, (uint256));
                if (vv > uint256(int256(type(int96).max))) _emitControllerError("safeDecodeFeeFlowRate: 2");
                else v = int96(uint96(vv));
            }
        } else {
            return abi.decode(data, (int96));
        }
    }

    function _emitControllerError(bytes memory reason) internal {
        emit ControllerError(reason);
        ++controllerInternalErrorCounter;
    }
}
