// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

/**
 * @title Interface for TWAP observers
 * @notice TWAP observers can create check points and track the TWAP of since last check point.
 */
interface ITwapObserver {
    /**
     * @notice Get the type id of the observer.
     * @dev This is useful for safe down-casting to the actual implementation.
     */
    function getTypeId() external view returns (bytes32);

    /**
     * @notice Get the time of the check point.
     * @param time Current block timestamp.
     * @return duration The time duration since the last check point.
     */
    function getDurationSinceLastCheckpoint(uint256 time) external view returns (uint256 duration);

    /**
     * @notice Create a checkpoint for the next TWAP calculation.
     * @param time Current block timestamp.
     * @return true.
     */
    function createCheckpoint(uint256 time) external returns (bool);

    /**
     * @notice Calculate the TWAP since the last checkpoint.
     * @param time Current block timestamp.
     * @param inAmount The amount of in token used for quote.
     * @return outAmount The amount of out token quoted for `inAmount` of inToken.
     * @return duration The time duration since the last check point.
     */
    function getTwapSinceLastCheckpoint(uint256 time, uint256 inAmount) external view
        returns (uint256 outAmount, uint256 duration);
}
