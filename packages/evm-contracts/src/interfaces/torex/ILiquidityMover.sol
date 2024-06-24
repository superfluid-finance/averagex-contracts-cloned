// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

import { ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";


/**
 * @title Interface for the liquidity mover contract
 */
interface ILiquidityMover {
    /**
     * @notice A callback from torex requesting out token liquidity with in-token liquidity transferred.
     * @param inToken      The in token transferred to the contract.
     * @param outToken     The out token that is requested.
     * @param inAmount     The amount of in token that has been transferred to the contract.
     * @param minOutAmount The amount of out token that is requested.
     * @param moverData    The data that liquidity mover passes through `ITorex.moveLiquidity`.
     * @return It must always be true.
     */
    function moveLiquidityCallback(ISuperToken inToken, ISuperToken outToken,
                                   uint256 inAmount, uint256 minOutAmount,
                                   bytes calldata moverData)
        external returns (bool);
}
