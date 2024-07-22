// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

import {
    ISuperToken, ISuperfluidPool
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";


/// @title Result of a liquidity move
struct LiquidityMoveResult {
    uint256 durationSinceLastLME;
    uint256 twapSinceLastLME;
    uint256 inAmount;
    uint256 minOutAmount;
    uint256 outAmount;
    uint256 actualOutAmount;
}

/**
 * @title Interface of torex controllers
 * @dev A Torex controller provides hooks to the Torex so that additional functionalities could be added.
 */
interface ITorexController {
    /// Get the type id of the controller.
    function getTypeId() external view returns (bytes32);

    /// A hook for in-token flow changed reported by torex.
    function onInFlowChanged(address flowUpdater,
                             int96 prevFlowRate, int96 preFeeFlowRate, uint256 lastUpdated,
                             int96 newFlowRate, uint256 now,
                             bytes calldata userData) external
        returns (int96 newFeeFlowRate);

    /// A hook for liquidity moved reported by torex.
    function onLiquidityMoved(LiquidityMoveResult calldata result) external returns (bool);
}

/**
 * @title Interface for torex
 */
interface ITorex {
    /// Return the TOREX version.
    // solhint-disable-next-line func-name-mixedcase
    function VERSION() external view returns (string memory);

    /// Torex controller that controls this torex.
    function controller() external view returns (ITorexController);

    /// Get token pairs of the Torex.
    function getPairedTokens() external view returns (ISuperToken inToken, ISuperToken outToken);

    /// GDA pool for distributing fees denominated in inTokens.
    function feeDistributionPool() external view returns (ISuperfluidPool);

    /// GDA pool for distributing out tokens.
    function outTokenDistributionPool() external view returns (ISuperfluidPool);

    /// Estimate amount of approval required for creating the torex flow.
    function estimateApprovalRequired(int96 flowRate) external view returns (uint256 requiredApproval);

    /// Let liquidity mover (contracts with ILiquidityMover interface) trigger a liquidity movement.
    function moveLiquidity(bytes calldata moverData) external returns (LiquidityMoveResult memory result);
}

/**
 * @title Metadata for a torex
 */
struct TorexMetadata {
    address     torexAddr;
    ISuperToken inToken;
    ISuperToken outToken;
}
