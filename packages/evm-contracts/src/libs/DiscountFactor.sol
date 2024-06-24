// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { UINT_100PCT_PM } from "./MathExtra.sol";

/*
 * About TOREX Discount Model
 * ==========================
 *
 * We need to solve the issue that benchmark price without discount over time may stall the exchanges over time.
 *
 * - TOREX's Max TWAP Time Window: due to int24 tick limitation of Uniswap V3 pool, we cannot have such time window more
 *   than, say, around 1 day or 2 days.
 *
 * - Initial Benchmark price: The TOREX TWAP Reading without applying any discount. Time window is the time since last
 *   LME until max TWAP Time Window is applicable.
 *
 * - Discount model: A function of time since last LME, that discounts the initial bench mark price.
 *
 * So the discount model has such properties:
 *
 *   1. When timeSinceLastLME is 0, the discount is 0%.
 *
 *   2. Predictably, at certain time in the future, say, τ seconds, the discount is ε.
 *
 *   3. Over time the discount monotonically grows, in another word, the discount number goes up, until but never
 *      reaches 100%.
 *
 * A curve that can fit the above properties perfectly is a "shifted reciprocal function". An example:If we want a
 * discount model that after 8 hours, it's 10% discount, then such a function is: discount(t) = 1 - 1 / (1 + t /
 * 259200). In this case τ is 8 * 3600 and ε is 10%, and when t is 0, discount is 0% t is 8*3600 (8 hours), the
 * discount is 10%.
 *
 * Read more about discount model from the Torex whitepaper.
 */

/// Discount factor custom type.
type DiscountFactor is uint256;

/**
 * @notice Get such discount factor, where at certain time in the future, say, τ seconds, the discount is ε.
 * @param tau       The τ seconds component of the discount model factor.
 * @param epsilonPM The ε component of the discount model factor, in per million (PM) unit.
 * @return The discount model factor.
 */
function getDiscountFactor(uint32 tau, uint32 epsilonPM) pure returns (DiscountFactor) {
    return DiscountFactor.wrap(uint256(tau) * uint256(UINT_100PCT_PM - epsilonPM) / uint256(epsilonPM));
}

/**
 * @notice Applying discount model to the full value at the relative time t.
 */
function getDiscountedValue(DiscountFactor factor, uint256 fullValue, uint256 t) pure
    returns (uint256 discountedValue)
{
    uint256 fv = DiscountFactor.unwrap(factor);
    if (fullValue == 0) {
        return 0;
    } else if (fv != 0) {
        return fullValue * fv / (fv + t);
    } else {
        return fullValue;
    }
}
