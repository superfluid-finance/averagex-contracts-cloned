pragma solidity ^0.8.26;

import { TestToken } from "@superfluid-finance/ethereum-contracts/contracts/utils/TestToken.sol";

import { ITorex } from "../interfaces/torex/ITorex.sol";
import { ILiquidityMover, ISuperToken } from "../interfaces/torex/ILiquidityMover.sol";


// Assumption: outToken wraps a TestToken which we can mint
// This will fail if not the case.
contract FakeLiquidityMover is ILiquidityMover {
    function triggerLiquidityMovement(ITorex torex) external
    {
        torex.moveLiquidity(new bytes(0));
    }

    function moveLiquidityCallback(ISuperToken /* inToken */, ISuperToken outToken,
                                   uint256 /* inAmount */, uint256 minOutAmount,
                                   bytes calldata /*moverData*/)
        external override returns (bool)
    {
        // mint required underlying
        TestToken underlyingOutToken = TestToken(address(outToken.getUnderlyingToken()));
        underlyingOutToken.mint(address(this), minOutAmount);

        // upgrade outToken
        underlyingOutToken.approve(address(outToken), minOutAmount);
        outToken.upgrade(minOutAmount);

        outToken.transfer(msg.sender, minOutAmount);
        return true;
    }
}
