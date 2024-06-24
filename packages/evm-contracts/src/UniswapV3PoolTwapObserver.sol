// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { OracleLibrary } from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

import { ITwapObserver } from "./interfaces/torex/ITwapObserver.sol";


/**
 * @title TWAP observer implementation using a single Uniswap V3 Pool
 */
contract UniswapV3PoolTwapObserver is Ownable, ITwapObserver {
    /// The Uniswap V3 pool to be used as price benchmark for liquidity moving.
    IUniswapV3Pool public immutable uniPool;
    /// Uniswap pool is bi-direction but torex is not. If false, inToken maps to token0, and vice versa.
    bool           public immutable inverseOrder;

    constructor(IUniswapV3Pool uniPool_, bool inverseOrder_) {
        uniPool = uniPool_;
        inverseOrder = inverseOrder_;

        createCheckpoint(block.timestamp);
        _transferOwnership(msg.sender);
    }

    /// Timestamp at the last checkpoint.
    uint256 internal _lastCheckpointAt;
    /// Tick cumulative value at the last checkpoint.
    int56   internal _lastTickCumulative;

    /// @inheritdoc ITwapObserver
    function getTypeId() override external pure returns (bytes32) {
        return keccak256("UniswapV3PoolTwapObserver");
    }

    /// @inheritdoc ITwapObserver
    function getDurationSinceLastCheckpoint(uint256 time) public override view returns (uint256 duration) {
        duration = time - _lastCheckpointAt;
    }

    /// @inheritdoc ITwapObserver
    function createCheckpoint(uint256 time) public override onlyOwner returns (bool) {
        _lastCheckpointAt = time;
        _lastTickCumulative = _getCurrentTickCumulative();
        return true;
    }

    /**
     * @inheritdoc ITwapObserver
     *
     * @dev Notes:
     * - Uniswap references:
     *   - https://docs.uniswap.org/contracts/v3/reference/core/libraries/Oracle
     *   - https://docs.uniswap.org/contracts/v3/reference/core/libraries/Tick
     *   - https://github.com/Uniswap/v3-core/blob/main/contracts/UniswapV3Pool.sol
     *   - https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/Oracle.sol
     *   - https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/TickMath.sol
     *   - https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/OracleLibrary.sol
     *
     */
    function getTwapSinceLastCheckpoint(uint256 time, uint256 inAmount) public override view
        returns (uint256 outAmount, uint256 duration)
    {
        duration = getDurationSinceLastCheckpoint(time);

        int24 tick;
        if (duration > 0) {
            // calculating tick of the TWAP
            int56 currentTickCumulative = _getCurrentTickCumulative();
            tick = SafeCast.toInt24((int256(currentTickCumulative) - int256(_lastTickCumulative))
                                    / SafeCast.toInt256(duration));
        } else {
            // special case: when duration is zero, returning the current tick directly
            (/*sqrtPriceX96*/,tick,/*obsIdx*/,/*obsCrd*/,/*obsCrdNext*/,/*feeP*/,/*unlckd*/) = uniPool.slot0();
        }

        // Note:
        //   1. OracleLibrary.getQuoteAtTick(int24 tick, uint128 baseAmount, address baseToken, address quoteToken)
        //       returns "quoteAmount Amount of quoteToken received for baseAmount of baseToken."
        //   1.1 TickMath.getSqrtRatioAtTick(int24 tick) returns (uint160 sqrtPriceX96)
        if (inverseOrder == false) {
            outAmount = OracleLibrary.getQuoteAtTick(tick, SafeCast.toUint128(inAmount),
                                                     uniPool.token0(), uniPool.token1());
        } else {
            outAmount = OracleLibrary.getQuoteAtTick(tick, SafeCast.toUint128(inAmount),
                                                     uniPool.token1(), uniPool.token0());
        }
    }

    /// @notice getTwapSinceLastCheckpoint with time equals to the current blocktime.
    function getTwapSinceLastCheckpointNow(uint256 inAmount) external view
        returns (uint256 outAmount, uint256 duration)
    {
        return getTwapSinceLastCheckpoint(block.timestamp, inAmount);
    }

    /// @notice Provide additional debugging details.
    function debugCurrentDetails() external view
        returns (uint256 currentTime, uint256 duration, int56 currentTickCumulative, int56 lastTickCumulative)
    {
        currentTime = block.timestamp;
        duration = getDurationSinceLastCheckpoint(currentTime);
        currentTickCumulative = _getCurrentTickCumulative();
        lastTickCumulative = _lastTickCumulative;
    }

    function _getCurrentTickCumulative() internal view returns (int56 currentTickCumulative) {
        // observe tick cumulative
        int56[] memory tickCumulatives;
        // implicitly: range[0] = 0;
        // Note:
        //   1. UniswapV3Pool.observe(uint32[] calldata secondsAgos)
        //        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s)
        //   1.1 Oracle.observe(...)
        //   1.1.1 [Oracle.observeSingle(...)]
        (tickCumulatives,) = uniPool.observe(new uint32[](1));
        return tickCumulatives[0];
    }
}
