// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


/// @dev 100% in per-million
int256 constant INT_100PCT_PM = 100_0000;

/// @dev 100% in per-million
uint256 constant UINT_100PCT_PM = 100_0000;

/**
 * Extra SafeCast
 * ==============
 *
 * Here is the extra SafeCast functions that is not available from openzeppelin.
 *
 * Naming convention is consistent with openzeppelin, but using "free-range" functions.
 */

function toUint128(int96 value) pure returns (uint128) {
    require(value >= 0, "toUint128(int96)");
    return uint128(uint96(value));
}

function toUint256(int96 value) pure returns (uint256) {
    require(value >= 0, "toUint256(int96)");
    return uint256(uint96(value));
}

function toInt96(int256 value) pure returns (int96) {
    require(value >= int256(type(int96).min) &&
            value <= int256(type(int96).max), "toInt96(int256)");
    return int96(value);
}

function toInt96(uint256 value) pure returns (int96) {
    require(value <= uint256(uint96(type(int96).max)), "toInt96(uint256)");
    return int96(uint96(value));
}

function toUint96(uint256 value) pure returns (uint96) {
    require(value <= uint256(type(uint96).max), "toUint96(uint256)");
    return uint96(value);
}
