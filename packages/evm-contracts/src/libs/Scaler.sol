// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";


/**
 * @notice A custom type of a scaler value, where negative value is for downscaling and positive value is for
 *         upscaling. Trvially, zaero makes all value zeros.
 */
type Scaler is int256;

/**
 * @notice Get a downscaler or an upscaler that is a power of 10.
 * @param n Positive value for upscalers of 10^n, negative for downscalers of 10^(-n).
 * @return scaler The scaler.
 */
function getScaler10Pow(int8 n) pure returns (Scaler scaler) {
    if (n >= 0) {
        return Scaler.wrap(SafeCast.toInt256(10**uint8(n)));
    } else {
        return Scaler.wrap(-SafeCast.toInt256(10**uint8(-n)));
    }
}

library LibScaler {
    /**
     * @notice Scale a uint256 value.
     * @param s The scaler.
     * @param v The full value.
     * @param scaledValue Scaled value.
     */
    function scaleValue(Scaler s, uint256 v) internal pure returns (uint256 scaledValue) {
        int256 ss = Scaler.unwrap(s);
        if (ss >= 0) return v * uint256(ss); else return v / uint256(-ss);
    }

    /**
     * @notice Scale a int256 value.
     * @param s The scaler.
     * @param v The full value.
     * @param scaledValue Scaled value.
     */
    function scaleValue(Scaler s, int256 v) internal pure returns (int256 scaledValue) {
        int256 ss = Scaler.unwrap(s);
        if (ss >= 0) return v * ss; else return v / -ss;
    }

    /// Inverse the scaler
    function inverse(Scaler s) internal pure returns (Scaler inverseScaler) {
        return Scaler.wrap(-Scaler.unwrap(s));
    }
}

using LibScaler for Scaler global;
