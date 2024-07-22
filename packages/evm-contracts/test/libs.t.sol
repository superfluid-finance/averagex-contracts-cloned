pragma solidity ^0.8.26;

import { Test, console } from "forge-std/Test.sol";

import { DiscountFactor, getDiscountFactor, getDiscountedValue } from "../src/libs/DiscountFactor.sol";


contract DiscountFactorTest is Test {
    function testZeroDiscountFactor(uint128 x, uint32 t) external {
        DiscountFactor zf = DiscountFactor.wrap(0);
        assertEq(getDiscountedValue(zf, x, 0), x);
        assertEq(getDiscountedValue(zf, x, t), x);
    }

    function testNonZeroDiscountFactor(uint32 tau, uint32 epsilonPM, uint128 x, uint32 t) external {
        tau = uint32(bound(tau, 1, type(uint32).max));
        epsilonPM = uint32(bound(epsilonPM, 1, 1e6));
        DiscountFactor factor = getDiscountFactor(tau, epsilonPM);

        assertEq(getDiscountedValue(factor, x, 0), x, "At time 0, zero discount");
        assertTrue(getDiscountedValue(factor, x, t) <= x, "Discount grows monotonically");
    }

    function testDiscountFactorPredictability(uint32 tau, uint32 epsilonPM) external {
        // This is a test for demoing basic predictability. Since not tau/epsilon combinations produces good factor for
        // integral arithmetic, some values are filtered out so that the test is stable for its purpose.

        tau = uint32(bound(tau, 10 minutes, 52 weeks));
        epsilonPM = uint32(bound(epsilonPM, 1_000, 400_000)); // [0.1%, 40%]
        DiscountFactor factor = getDiscountFactor(tau, epsilonPM);
        uint256 x = type(uint128).max;

        uint256 x0 = (1e6 - epsilonPM) * x / 1e6;
        uint256 x1 = getDiscountedValue(factor, x, tau);
        console.log("x0", x0);
        console.log("x1", x1);
        assertTrue(x0 >= x1, "Discount model predictability 1");
        // margin of error < 0.5%
        assertTrue((x0 - x1) < x * 5/1000, "Discount model predictability 2");
    }
}

