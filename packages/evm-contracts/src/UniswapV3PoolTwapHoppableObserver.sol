// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { OracleLibrary } from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

import { ITwapObserver } from "./interfaces/torex/ITwapObserver.sol";

/**
 * @title TWAP observer implementation using a single Uniswap V3 Pool
 */
contract UniswapV3PoolTwapHoppableObserver is Ownable, ITwapObserver {

    error INVALID_HOPS_CONFIG();

    /**
     * @notice Uniswap V3 pool to Torex mapping configuration
     * @param pool Uniswap V3 pool to be used as price benchmark for liquidity moving.
     * @param inverseOrder Uniswap pool is bi-direction but torex is not. If false, inToken maps to token0, and vice versa.
     */
    struct UniV3PoolHop {
        IUniswapV3Pool pool;
        bool inverseOrder;
    }

    constructor(UniV3PoolHop[] memory hops_) {
        _validateHopsConfiguration(hops_);

        for(uint256 i = 0; i < hops_.length; ++i) {
            hops.push(hops_[i]);

            // initialize `_lastTickCumulatives` array size
            _lastTickCumulatives.push(0);
        }

        createCheckpoint(block.timestamp);
        _transferOwnership(msg.sender);
    }

    function _validateHopsConfiguration(UniV3PoolHop[] memory hops_) internal view {
        if(hops_.length > 1) {
            (, address prevOutToken) = _getTokensOrdered(hops_[0]);

            for (uint256 i = 1; i < hops_.length; ++i) {
                (address inToken, address outToken) = _getTokensOrdered(hops_[i]);
                if(inToken != prevOutToken) revert INVALID_HOPS_CONFIG();
                prevOutToken = outToken;
            }
        }
    }

    /// Uniswap V3 pool hops for obtaining benchmark pricing.
    // NOTE: too bad, it can'be be immutable
    UniV3PoolHop[] public hops;
    /// Timestamp at the last checkpoint.
    uint256 internal _lastCheckpointAt;
    /// Tick cumulative values of all hops at the last checkpoint.
    int56[] internal _lastTickCumulatives;

    /// @inheritdoc ITwapObserver
    function getTypeId() override external pure returns (bytes32) {
        return keccak256("UniswapV3PoolTwapHoppableObserver");
    }

    /// @inheritdoc ITwapObserver
    function getDurationSinceLastCheckpoint(uint256 time) public override view returns (uint256 duration) {
        duration = time - _lastCheckpointAt;
    }

    /// @inheritdoc ITwapObserver
    function createCheckpoint(uint256 time) public override onlyOwner returns (bool) {
        _lastCheckpointAt = time;

        for (uint256 i = 0; i < hops.length; ++i) {
            _lastTickCumulatives[i] = _getCurrentTickCumulative(i);
        }
        return true;
    }

    function getTwapSinceLastCheckpoint(uint256 time, uint256 inAmount) public override view
        returns (uint256 outAmount, uint256 duration)
    {
        uint256 newInAmount = inAmount;
        for (uint256 i = 0; i < hops.length; ++i) {
            (newInAmount, duration) = _getHopTwapSinceLastCheckpoint(i, time, newInAmount);
        }
        outAmount = newInAmount;
    }

    /**
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
    function _getHopTwapSinceLastCheckpoint(uint256 i, uint256 time, uint256 inAmount) internal view
        returns (uint256 outAmount, uint256 duration)
    {
        duration = getDurationSinceLastCheckpoint(time);

        // NOTE: see OracleLibrary.consult function
        int24 arithmeticMeanTick;
        if (duration > 0) {
            // calculating tick of the TWAP
            int56 currentTickCumulative = _getCurrentTickCumulative(i);
            int256 tickCumulativesDelta = int256(currentTickCumulative) - int256(_lastTickCumulatives[i]);
            arithmeticMeanTick = SafeCast.toInt24(tickCumulativesDelta / SafeCast.toInt256(duration));

            // To be inline OracleLibrary.consult function, and to be mathematically correctly, it always round to
            // negative infinity.
            if (tickCumulativesDelta < 0 && (tickCumulativesDelta % SafeCast.toInt256(duration) != 0))
                arithmeticMeanTick--;
        } else {
            // special case: when duration is zero, returning the current tick directly
            (/*sqrtPriceX96*/,arithmeticMeanTick,/*obsIdx*/,/*obsCrd*/,/*obsCrdNext*/,/*feeP*/,/*unlckd*/) =
                hops[i].pool.slot0();
        }

        // Note:
        //   1. OracleLibrary.getQuoteAtTick(int24 tick, uint128 baseAmount, address baseToken, address quoteToken)
        //       returns "quoteAmount Amount of quoteToken received for baseAmount of baseToken."
        //   1.1 TickMath.getSqrtRatioAtTick(int24 tick) returns (uint160 sqrtPriceX96)

        (address inToken, address outToken) = _getTokensOrdered(hops[i]);

        outAmount = OracleLibrary.getQuoteAtTick(
            arithmeticMeanTick,
            SafeCast.toUint128(inAmount),
            inToken,
            outToken
        );
    }

    /// @notice Helper function returning the in and out tokens of a given hop.
    function _getTokensOrdered(UniV3PoolHop memory hop) internal view returns (address inToken, address outToken) {
        if(hop.inverseOrder) {
            inToken = hop.pool.token1();
            outToken = hop.pool.token0();
        } else {
            inToken = hop.pool.token0();
            outToken = hop.pool.token1();
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
        returns (uint256 currentTime, uint256 duration, int56[] memory currentTickCumulative, int56[] memory lastTickCumulative)
    {
        currentTime = block.timestamp;
        duration = getDurationSinceLastCheckpoint(currentTime);

        currentTickCumulative = new int56[](hops.length);
        lastTickCumulative = new int56[](hops.length);

        for(uint256 i = 0; i < hops.length; ++i) {
            currentTickCumulative[i] = _getCurrentTickCumulative(i);
            lastTickCumulative[i] = _lastTickCumulatives[i];
        }
    }

    function _getCurrentTickCumulative(uint256 i) internal view returns (int56 currentTickCumulative) {
        // observe tick cumulative
        int56[] memory tickCumulatives;
        // implicitly: range[0] = 0;
        // Note:
        //   1. UniswapV3Pool.observe(uint32[] calldata secondsAgos)
        //        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s)
        //   1.1 Oracle.observe(...)
        //   1.1.1 [Oracle.observeSingle(...)]
        (tickCumulatives,) = hops[i].pool.observe(new uint32[](1));
        return tickCumulatives[0];
    }
}
