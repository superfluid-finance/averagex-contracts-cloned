/* solhint-disable reentrancy */
pragma solidity 0.8.23;

import { console } from "forge-std/Test.sol";

import { Scaler } from "../src/libs/Scaler.sol";
import { getDiscountFactor } from "../src/libs/DiscountFactor.sol";
import { SuperTokenV1Library } from "../src/libs/SuperTokenExtra.sol";
import { Torex, TorexCore, ISuperToken, ISuperfluidPool } from "../src/Torex.sol";
import { TorexFactory } from "../src/TorexFactory.sol";
import { UnbridledX, TorexMetadata, LiquidityMoveResult } from "../src/UnbridledX.sol";

import { TorexTest } from "./TestCommon.sol";


using SuperTokenV1Library for ISuperToken;

contract UnbridledXHarness is UnbridledX {
    function updateFeeDistributionPoolUnits(Torex torex, uint128 units) external {
        _updateFeeDestUnits(torex, units);
    }
}

contract UnbridledTorexTest is TorexTest {
    TorexFactory      internal immutable _torexFactory = new TorexFactory();
    UnbridledXHarness internal immutable _unbridledX   = new UnbridledXHarness();

    function _createDefaultConfig() override internal returns (Torex.Config memory config) {
        config = super._createDefaultConfig();
        config.controller = _unbridledX;
    }

    function _registerTorex(Torex torex, int256 inTokenFeePM, address inTokenFeeDest) internal {
        _expectedFeePM = inTokenFeePM;
        _unbridledX.registerTorex(torex, inTokenFeePM, inTokenFeeDest);
    }
}

contract UnbridledXTest is UnbridledTorexTest {
    function testUnbridledTorexRegistry() public {
        assertEq(_unbridledX.getAllTorexesMetadata().length, 0);

        {
            UnbridledX badX = new UnbridledX();
            Torex.Config memory config = _createDefaultConfig();
            config.controller = badX;
            Torex torex = new Torex(config);
            vm.expectRevert("not my jurisdiction");
            _registerTorex(torex, DEFAULT_IN_TOKEN_FEE_PM, EU);
        }

        Torex torex0 = _torexFactory.createTorex(_createDefaultConfig());
        // only owner can register
        vm.startPrank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        _registerTorex(torex0, DEFAULT_IN_TOKEN_FEE_PM, EU);
        vm.stopPrank();
        // register
        _registerTorex(torex0, DEFAULT_IN_TOKEN_FEE_PM, EU);
        // fail on double registry
        vm.expectRevert("already registered");
        _registerTorex(torex0, DEFAULT_IN_TOKEN_FEE_PM, EU);
        // check fee config
        assertEq(_unbridledX.getFeeConfig(torex0).inTokenFeePM, DEFAULT_IN_TOKEN_FEE_PM, "wrong fee config");
        assertEq(_unbridledX.getFeeConfig(torex0).inTokenFeeDest, EU, "wrong fee config");

        Torex torex1 = _torexFactory.createTorex(_createDefaultConfig());
        _registerTorex(torex1, DEFAULT_IN_TOKEN_FEE_PM, EU);

        TorexMetadata[] memory metadataList = _unbridledX.getAllTorexesMetadata();
        assertEq(address(metadataList[0].torexAddr), address(torex0), "torex 0");
        assertEq(address(metadataList[1].torexAddr), address(torex1), "torex 1");

        _unbridledX.unregisterTorex(torex1);
        vm.expectRevert("not registered");
        _unbridledX.unregisterTorex(torex1);

        // only owner can update fee config
        vm.startPrank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        _unbridledX.updateFeeConfig(torex0, 0, alice);
        vm.stopPrank();
    }

    function testUnbridledXTypeId() public {
        assertEq(_unbridledX.getTypeId(), keccak256("BelowAverageX"));
    }

    function testUnbridledXControllerAccessControl() public {
        vm.expectRevert(UnbridledX.ONLY_REGISTERED_TOREX_ALLOWED.selector);
        _unbridledX.onInFlowChanged(address(0), 0, 0, 0, 0, 0, new bytes(0));

        vm.expectRevert(UnbridledX.ONLY_REGISTERED_TOREX_ALLOWED.selector);
        _unbridledX.onLiquidityMoved(LiquidityMoveResult(0,0,0,0,0,0));
    }
}

contract UnbridledDefaultTorexTest is UnbridledTorexTest {
    function setUp() override public {
        super.setUp();

        _torex = _torexFactory.createTorex(_createDefaultConfig());
        _registerTorex(_torex, DEFAULT_IN_TOKEN_FEE_PM, EU);
        _connectAllPools();
    }

    function testTorexViewFunctions() public {
        (ISuperToken inToken, ISuperToken outToken) = _torex.getPairedTokens();
        assertEq(address(inToken), address(_inToken), "paired tokens in");
        assertEq(address(outToken), address(_outToken), "paird token outs");
        assertEq(_torex.outTokenDistributionPool().admin(), address(_torex), "out-token pool admin");
        assertEq(_torex.MAX_ALLOWED_FEE_PM(), MAX_IN_TOKEN_FEE_PM, "MAX_IN_TOKEN_FEE_PM");
        assertEq(address(_torex.controller()), address(_unbridledX), "controller");
        assertEq(_torex.feeDistributionPool().admin(), address(_unbridledX), "fee pool admin");
    }

    // = Test case encoding:
    // F|C:    _testChangeFlow(_, _|0)
    // (F|C)n: _testChangeFlow(n, _|0)
    // t:      _doAdvanceTime(_)
    // L:      _testMoveLiquidity()
    // Z:      (nop)

    // == One streamer cases

    function testF0tLZ(int64 ps, uint24 dt0,
                       uint80 r, uint24 dt) public {
        _setPriceScaler(ps);
        _doAdvanceTime(dt0);

        _testChangeFlow(0, r);
        _doAdvanceTime(dt);

        _testMoveLiquidity();
    }

    function testF0tLtC0Z(int64 ps, uint24 dt0,
                          uint80 r, uint24 dt1,
                          uint24 dt2) public {
        _setPriceScaler(ps);
        _doAdvanceTime(dt0);

        _testChangeFlow(0, r);
        _doAdvanceTime(dt1);

        _testMoveLiquidity();
        _doAdvanceTime(dt2);

        _testChangeFlow(0, 0);

        assertEq(_torex.feeDistributionPool().getTotalFlowRate(), 0,
                 "Zero fee distribution rate when no one left");
    }

    function testF0tC0tLZ(int64 ps, uint24 dt0,
                          uint80 r, uint24 dt1,
                          uint24 dt2) public {
        _setPriceScaler(ps);
        _doAdvanceTime(dt0);

        _testChangeFlow(0, r);
        _doAdvanceTime(dt1);

        _testChangeFlow(0, 0);
        _doAdvanceTime(dt2);

        _testMoveLiquidity();
    }

    function testF0tF0tLtC0Z(int64 ps, uint24 dt0,
                             uint80 r1, uint24 dt1,
                             uint80 r2, uint24 dt2) public {
        _setPriceScaler(ps);
        _doAdvanceTime(dt0);

        _testChangeFlow(0, r1);
        _doAdvanceTime(dt1);

        _testChangeFlow(0, r2);
        _doAdvanceTime(dt2);

        _testMoveLiquidity();

        _testChangeFlow(0, 0);
    }

    // == Two-streamers cases

    function testFtFtLZ(int64 ps, uint24 dt0,
                        uint8 w1, uint80 r1, uint24 dt1,
                        uint8 w2, uint80 r2, uint24 dt2) public {
        _setPriceScaler(ps);
        _doAdvanceTime(dt0);

        _testChangeFlow(w1, r1);
        _doAdvanceTime(dt1);

        _testChangeFlow(w2, r2);
        _doAdvanceTime(dt2);

        _testMoveLiquidity();
    }

    function testFtLtFZ(int64 ps, uint24 dt0,
                        uint8 w1, uint80 r1, uint24 dt1,
                        uint24 dt2,
                        uint8 w2, uint80 r2) public {
        _setPriceScaler(ps);
        _doAdvanceTime(dt0);

        _testChangeFlow(w1, r1);
        _doAdvanceTime(dt1);

        _testMoveLiquidity();
        _doAdvanceTime(dt2);

        _testChangeFlow(w2, r2);
    }

    function testFtLtFtLZ(int64 ps, uint24 dt0,
                          uint8 w1, uint80 r1, uint24 dt1,
                          uint24 dt2,
                          uint8 w2, uint80 r2, uint24 dt3) public {
        _setPriceScaler(ps);
        _doAdvanceTime(dt0);

        _testChangeFlow(w1, r1);
        _doAdvanceTime(dt1);

        _testMoveLiquidity();
        _doAdvanceTime(dt2);

        _testChangeFlow(w2, r2);
        _doAdvanceTime(dt3);

        _testMoveLiquidity();
    }

    function testFtLtLtFZ(int64 ps, uint24 dt0,
                          uint8 w1, uint80 r1, uint24 dt1,
                          uint24 dt2,
                          uint24 dt3,
                          uint8 w2, uint80 r2) public {
        _setPriceScaler(ps);
        _doAdvanceTime(dt0);

        _testChangeFlow(w1, r1);
        _doAdvanceTime(dt1);

        _testMoveLiquidity();
        _doAdvanceTime(dt2);

        _testMoveLiquidity();
        _doAdvanceTime(dt3);

        _testChangeFlow(w2, r2);
    }

    // == Properties for back adjustment cases

    // This property about back-charge is that with in a LM-cycle, the amount of in-tokens paid-in is always the same as
    // if one joins at the beginning of the cycle.
    function testPropSameInTokensPaidIn(int64 ps, uint24 dt0,
                                        uint80 r, uint24 dt1, uint24 dt2) public {
        _setPriceScaler(ps);
        _doAdvanceTime(dt0);

        uint256 a0 = _inToken.balanceOf(_toTester(0));
        uint256 b0 = _inToken.balanceOf(_toTester(1));

        _testMoveLiquidity();

        _testChangeFlow(0, r);
        (int96 requestedFeeDistFlowRate0, , uint256 feeDistBuffer0) = _torex.debugCurrentDetails();
        uint256 feePaidBy0 = _expectedBufferFee(requestedFeeDistFlowRate0, 0);
        _doAdvanceTime(dt1);

        _testChangeFlow(1, r);
        (int96 requestedFeeDistFlowRate1, ,) = _torex.debugCurrentDetails();
        uint256 feePaidBy1 =  _expectedBufferFee(requestedFeeDistFlowRate1, feeDistBuffer0);
        _doAdvanceTime(dt2);

        uint256 a1 = _inToken.balanceOf(_toTester(0));
        uint256 b1 = _inToken.balanceOf(_toTester(1));

        assertEq(a0 - a1 - feePaidBy0,
                 b0 - b1 - feePaidBy1,
                 "Unexpected in-token paid-in divergence within a LM-cycle");
    }

    function testPropRefund(int64 ps, uint24 dt0,
                            uint24 dt1, uint80 r, uint24 dt2) public {
        _setPriceScaler(ps);
        _doAdvanceTime(dt0);

        uint256 a0 = _inToken.balanceOf(_toTester(0));

        _testMoveLiquidity();
        _doAdvanceTime(dt1);

        _testChangeFlow(0, r);
        int96 feeFlowRate = _torex.getTraderState(_toTester(0)).feeFlowRate;
        _doAdvanceTime(dt2);

        _testChangeFlow(0, 0);

        uint256 a1 = _inToken.balanceOf(_toTester(0));
        // in-token fee + distribution buffer fee
        uint256 feePaid = uint96(feeFlowRate) * (uint256(dt1) + uint256(dt2))
            + _inToken.getBufferAmountByFlowRate(feeFlowRate);

        assertEq(a0 - a1, feePaid,
                 "Unexpected contribution amount to be refunded before LM");
    }

    struct VarsTestProp2ndBackAdjustment {
        int96 fee1FlowRate;
        int96 fee2FlowRate;
        int96 requestedFeeDistFlowRate0;
        int96 requestedFeeDistFlowRate1;
        int96 requestedFeeDistFlowRate2;
        int96 requestedFeeDistFlowRate3;
        uint256 feeDistBufer0;
        uint256 feeDistBufer1;
        uint256 feeDistBufer2;
        uint256 feeDistBufer3;
        uint256 feePaidBy0;
        uint256 feePaidBy1;
    }
    function testProp2ndBackAdjustment(int64 ps, uint24 dt0,
                                       uint24 dt1,
                                       uint80 r1, uint24 dt2,
                                       uint80 r2, uint24 dt3, uint24 dt4) public {
        _setPriceScaler(ps);
        _doAdvanceTime(dt0);

        VarsTestProp2ndBackAdjustment memory vars;
        uint256 a0 = _inToken.balanceOf(_toTester(0));
        uint256 b0 = _inToken.balanceOf(_toTester(1));

        _testMoveLiquidity();
        _doAdvanceTime(dt1);

        _testChangeFlow(0, r1);
        vars.fee1FlowRate = _torex.getTraderState(_toTester(0)).feeFlowRate;
        (vars.requestedFeeDistFlowRate0, , vars.feeDistBufer0) = _torex.debugCurrentDetails();
        vars.feePaidBy0 = _expectedBufferFee(vars.requestedFeeDistFlowRate0, 0);

        _testChangeFlow(1, r1);
        assertEq(vars.fee1FlowRate, _torex.getTraderState(_toTester(1)).feeFlowRate, "Expect same fee1FlowRate");
        (vars.requestedFeeDistFlowRate1, , vars.feeDistBufer1) = _torex.debugCurrentDetails();
        vars.feePaidBy1 = _expectedBufferFee(vars.requestedFeeDistFlowRate1, vars.feeDistBufer0);
        _doAdvanceTime(dt2);

        _testChangeFlow(0, r2);
        vars.fee2FlowRate = _torex.getTraderState(_toTester(0)).feeFlowRate;
        (vars.requestedFeeDistFlowRate2, , vars.feeDistBufer2) = _torex.debugCurrentDetails();
        if (r2 > r1) {
            vars.feePaidBy0 += _expectedBufferFee(vars.requestedFeeDistFlowRate2, vars.feeDistBufer1);
        }
        _doAdvanceTime(dt3);

        _testChangeFlow(1, r2);
        assertEq(vars.fee2FlowRate, _torex.getTraderState(_toTester(1)).feeFlowRate, "Expect same fee2FlowRate");
        (vars.requestedFeeDistFlowRate3, , vars.feeDistBufer3) = _torex.debugCurrentDetails();
        if (r2 > r1) {
            vars.feePaidBy1 += _expectedBufferFee(vars.requestedFeeDistFlowRate3, vars.feeDistBufer2);
        }
        _doAdvanceTime(dt4);

        uint256 a1 = _inToken.balanceOf(_toTester(0));
        uint256 b1 = _inToken.balanceOf(_toTester(1));

        // see Torex._onInFlowChanged for fee back charge case analysis
        if (r2 > r1) {
            // for flow increases, it's a stronger property. Though buffer fee is still charged.
            assertEq(a0 - a1 - vars.feePaidBy0,
                     b0 - b1 - vars.feePaidBy1,
                     "Unexpected in-token paid-in divergence within the 2nd adjustment");
        } else {
            // for flow decreases, the property is weakened due to fees are never refunded.
            uint96 feeDelta = uint96(vars.fee1FlowRate - vars.fee2FlowRate);
            vars.feePaidBy0 += uint96(vars.fee2FlowRate) * (uint256(dt1) + uint256(dt2) + uint256(dt3) + uint256(dt4))
                + feeDelta * (uint256(dt1) + uint256(dt2));
            vars.feePaidBy1 += uint96(vars.fee2FlowRate) * (uint256(dt1) + uint256(dt2) + uint256(dt3) + uint256(dt4))
                + feeDelta * (uint256(dt1) + uint256(dt2) + uint256(dt3));
            console.log("feeDistFlowRate0",
                        uint256(int256(vars.requestedFeeDistFlowRate0)),
                        uint256(int256(vars.feeDistBufer0)));
            console.log("feeDistFlowRate1",
                        uint256(int256(vars.requestedFeeDistFlowRate1)),
                        uint256(int256(vars.feeDistBufer1)));
            console.log("feeDistFlowRate2",
                        uint256(int256(vars.requestedFeeDistFlowRate2)),
                        uint256(int256(vars.feeDistBufer2)));
            console.log("feeDistFlowRate3",
                        uint256(int256(vars.requestedFeeDistFlowRate3)),
                        uint256(int256(vars.feeDistBufer3)));
            console.log("a0 - a1 %d, feePaidBy0 %d", a0 - a1, vars.feePaidBy0);
            console.log("b0 - b1 %d, feePaidBy1 %d", b0 - b1, vars.feePaidBy1);
            assertEq(a0 - a1 - vars.feePaidBy0,
                     b0 - b1 - vars.feePaidBy1,
                     "Unexpected in-token contribution divergence within the 2nd adjustment");
        }
    }

    // == Naughty liquidity mover cases

    function testSliperyLiquidityMover() external {
        _setPriceScaler(2);
        _mockLiquidityMover.setTransferLessOut();

        _testChangeFlow(0, 1000);
        _doAdvanceTime(1 days);

        vm.startPrank(LM);
        _outToken.approve(address(_mockLiquidityMover), type(uint256).max);
        vm.expectRevert(TorexCore.LIQUIDITY_MOVER_SENT_INSUFFICIENT_OUT_TOKENS.selector);
        _mockLiquidityMover.triggerLiquidityMovement(_torex);
        vm.stopPrank();
    }

    // == Captured cases

    function testCase001() external {
        // This triggered a GDA insufficient buffer error once:
        testFtLtFZ(2, 0,
                   0, 100663423, 0,              /* _testChangeFlow(0, 100663423); _doAdvanceTime(0); */
                   0,                            /* _testMoveLiquidity(); _doAdvanceTime(0); */
                   1, 265415803653013468559412); /* _testChangeFlow(1, 265415803653013468559412); */
    }

    function testCase002() external {
        // This triggered a GDA insufficient buffer error once:
        testFtLtFtLZ(2, 0,
                     0, 200, 0,  /* _testChangeFlow(0, 200); _doAdvanceTime(0); */
                     0,          /* _testMoveLiquidity(); _doAdvanceTime(0); */
                     0, 400, 0); /* _testChangeFlow(0, 400); _doAdvanceTime(0); */
    }

    // due to the increased min deposit and the selected flowrate values,
    // this operation increases the buffer required for the feeDistributionPool,
    // but the Torex has no inTokens accumulated to cover that.
    /* function testCaseMinimumDepositChange() external { */
    /*     _testChangeFlow(_toTester(0), 1e12); */
    /*     _testChangeFlow(_toTester(1), 1e12); */
    /*     _setInTokenMinimumDeposit(1e18); */
    /*     _testChangeFlow(_toTester(1), 0); */
    /* } */

    function testFeeDistributionPoolUnitsChange(uint120 u1, uint80 r1,
                                                uint120 u2, uint80 r2
                                               ) external {
        _unbridledX.updateFeeDistributionPoolUnits(_torex, u1);
        _testChangeFlow(0, r1);

        _testMoveLiquidity();

        _unbridledX.updateFeeDistributionPoolUnits(_torex, u2);
        _testChangeFlow(0, r2);
    }
}

contract UnbridledOtherTorexTest is UnbridledTorexTest {
    function testVariousDiscountFactor(uint24 tau, uint16 eps) public {
        // discountModelFactor maximum ranges:
        eps = uint16(bound(eps, 1, 100_000));
        tau = uint16(bound(tau, 1, 52 weeks));

        Torex.Config memory config = _createDefaultConfig();
        config.discountFactor = getDiscountFactor(tau, eps);
        _torex = _torexFactory.createTorex(config);
        _registerTorex(_torex, DEFAULT_IN_TOKEN_FEE_PM, EU);

        uint256 inAmount = 1e18;

        (uint256 minOutAmount0,,) = _torex.getBenchmarkQuote(inAmount);

        _doAdvanceTime(tau);

        (uint256 minOutAmount1,,) = _torex.getBenchmarkQuote(inAmount);

        // imagine bob DCAing from USD to ETH
        // the benchmark price of _outToken (ETH) in _inToken (USD) is 10000,
        // but the spot price is 10001, so nobody wants to move liquidity.
        // thus the discounting model needs to push the benchmark price "up" above 2001
        // for an incentive to move liquidity to kick in.
        // assertGe(price1, price0, "the benchmark price didn't go up as expected");

        console.log("minOutAmount0", minOutAmount0);
        console.log("minOutAmount1", minOutAmount1);

        // only if the price goes up, does the outAmount to be provided in an LME go down
        assertLe(minOutAmount1, minOutAmount0, "the minOutAmount didn't go down as expected");
    }

    function testVariousOutTokenDistPoolScalers(uint64 ods, int64 fr1, int64 fr2) public {
        Scaler scaler = Scaler.wrap(-int256(uint256(ods)));
        fr1 = int64(bound(fr1, 1, type(int64).max));
        fr2 = int64(bound(fr2, 1, type(int64).max));

        Torex.Config memory config = _createDefaultConfig();
        config.outTokenDistributionPoolScaler = scaler;
        _torex = _torexFactory.createTorex(config);
        _registerTorex(_torex, DEFAULT_IN_TOKEN_FEE_PM, EU);
        _connectAllPools();

        _testChangeFlow(alice, fr1);
        _testChangeFlow(bob, fr2);

        _doAdvanceTime(1 hours);

        (,uint256 outAmount,)= _testMoveLiquidity();

        ISuperfluidPool outTokenPool = _torex.outTokenDistributionPool();

        assertEq(outTokenPool.getUnits(alice),
                 uint256((scaler.scaleValue(fr1 - fr1 * _expectedFeePM  / 1e6))),
                 "Unexpected alice' outTokenDistributionPool units");

        assertEq(outTokenPool.getUnits(bob),
                 uint256(scaler.scaleValue(fr2 - fr2 * _expectedFeePM / 1e6)),
                 "Unexpected bob' outTokenDistributionPool units");

        assertEq(uint256(outTokenPool.getTotalUnits()),
                 outTokenPool.getUnits(alice) + outTokenPool.getUnits(bob) + outTokenPool.getUnits(EU),
                 "Unexpected totalUnits of outTokenDistributionPool");

        uint256 totalUnits = _torex.outTokenDistributionPool().getTotalUnits();
        if (totalUnits > 0) {
            uint256 amountPerUnit = outAmount / totalUnits;

            uint256 expectedAliceOutBal = amountPerUnit * outTokenPool.getUnits(alice);
            assertEq(_outToken.balanceOf(address(alice)), expectedAliceOutBal,
                     "Unexpected out tokens received for alice");

            uint256 expectedBobOutBal = amountPerUnit * outTokenPool.getUnits(bob);
            assertEq(_outToken.balanceOf(address(bob)), expectedBobOutBal,
                     "Unexpected out tokens received for bob");

            // due to rounding, not everything may be distributed
            uint256 expectedRemainder = outAmount % totalUnits;
            assertEq(_outToken.balanceOf(address(_torex)),
                     expectedRemainder,
                     "Unexpected remainder amount in Torex");
        }
    }

    function testMaxFeeProtection(int256 a, uint80 r) public {
        int256 feePM = int256(bound(a, MAX_IN_TOKEN_FEE_PM, type(int16).max)); // [max, 32.767%]

        _torex = new Torex(_createDefaultConfig());

        _registerTorex(_torex, feePM, EU);

        _doChangeFlow(_toTester(0), int96(uint96(r)));
        int96 feeFlowRate = _torex.getTraderState(_toTester(0)).feeFlowRate;

        assertLe(feeFlowRate, int256(uint256(r)) * MAX_IN_TOKEN_FEE_PM / 1e6,
                 "Trader got scammed!");
    }
}

// This poor man's statefull fuzzing using foundry.
// What is stateful fuzzing? See:
// https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/basic/testing-modes.md#stateless-vs-stateful
contract UnbridledTorexStatefulFuzzTest is UnbridledTorexTest {
    enum TestActionType {
        // testStatefullFuzzMinimum:
        TA_CHANGE_FLOW,
        TA_MOVE_LIQUIDITY,

        // testStatefullFuzzComplete:
        TA_CHANGE_FEE_POOL_UNITS,
        TA_OTHER_FEE_DISTRIBUTOR,

        // excluded due to minimum deposit issue
        TA_CHANGE_MINIMUM_DEPOSIT
    }

    struct Actions {
        uint8   actionCode;
        uint8   w;  // who
        uint24  dt; // time delta,
        uint256 v;  // values: flow rate, fee pool units, or minimum deposit
    }

    function toActionType(uint8 actionCode, uint8 maxAction) internal pure returns (TestActionType) {
        return TestActionType(actionCode % (maxAction + 1));
    }

    function _testStatefullFuzz(uint8 maxAction,
                                uint64 ods, int64 ps, uint24 dt0,
                                Actions[] memory actions) internal {
        // create and setup torex
        {
            Torex.Config memory config = _createDefaultConfig();
            config.outTokenDistributionPoolScaler = Scaler.wrap(-int256(uint256(ods)));
            _torex = _torexFactory.createTorex(config);
            _registerTorex(_torex, DEFAULT_IN_TOKEN_FEE_PM, EU);
            _connectAllPools();
        }

        _setPriceScaler(ps);

        _doAdvanceTime(dt0);

        for (uint256 i = 0; i < actions.length; i++) {
            Actions memory a = actions[i];
            TestActionType t = toActionType(a.actionCode, maxAction);
            if (t == TestActionType.TA_CHANGE_FLOW) {
                _testChangeFlow(a.w, a.v % type(uint80).max);
            } else if (t== TestActionType.TA_MOVE_LIQUIDITY) {
                _testMoveLiquidity();
            } else if (t == TestActionType.TA_CHANGE_MINIMUM_DEPOSIT) {
                _setInTokenMinimumDeposit(a.v % type(uint64).max);
            } else if (t == TestActionType.TA_CHANGE_FEE_POOL_UNITS ) {
                uint128 units = uint128(a.v % type(uint120).max);
                _unbridledX.updateFeeDistributionPoolUnits(_torex, units);
            } else if (t == TestActionType.TA_OTHER_FEE_DISTRIBUTOR) {
                address who = _toTester(a.w);
                int96 distFlowRate = int96(uint96(a.v % type(uint80).max));
                console.log("= DO TA_OTHER_DISTRIBUTOR from %s adjusted to %d", who, uint96(distFlowRate));
                vm.startPrank(who);
                _inToken.distributeFlow(who, _torex.feeDistributionPool(), distFlowRate);
                vm.stopPrank();
            } else assert(false);

            _doAdvanceTime(a.dt);
        }
    }

    // Fuzzing with only TA_CHANGE_FLOW and TA_MOVE_LIQUIDITY
    function testStatefullFuzzMinimum(uint64 md, uint64 ods, int64 ps, uint24 dt0,
                                      Actions[5] calldata actions) external {
        // set minimum deposit once in the beginning
        _setInTokenMinimumDeposit(md);

        Actions[] memory actions2 = new Actions[](actions.length);
        for (uint256 i = 0; i < actions.length; i++) actions2[i] = actions[i];
        _testStatefullFuzz(uint8(TestActionType.TA_MOVE_LIQUIDITY), ods, ps, dt0, actions2);
    }

    // Fuzzing excluding TA_CHANGE_MINIMUM_DEPOSIT and TA_OTHER_DISTRIBUTOR
    function testStatefullFuzzComplete(uint64 ods, int64 ps, uint24 dt0,
                                      Actions[10] calldata actions) external {
        Actions[] memory actions2 = new Actions[](actions.length);
        for (uint256 i = 0; i < actions.length; i++) actions2[i] = actions[i];
        _testStatefullFuzz(uint8(TestActionType.TA_OTHER_FEE_DISTRIBUTOR), ods, ps, dt0, actions2);
    }
}
