/* solhint-disable reentrancy */
pragma solidity 0.8.23;

import { console2 } from "forge-std/Test.sol";

import { SuperTokenV1Library, deployPureSuperToken } from "../src/libs/SuperTokenExtra.sol";
import { UINT_100PCT_PM, INT_100PCT_PM } from "../src/libs/MathExtra.sol";
import {
    SuperBoring, ITorex, TorexFactory, ISuperToken, ISuperfluidPool
} from "../src/SuperBoring.sol";
import {
    EmissionTreasury, createEmissionTreasury
} from "../src/BoringPrograms/EmissionTreasury.sol";
import {
    DistributionFeeManager, createDistributionFeeManager
} from "../src/BoringPrograms/DistributionFeeManager.sol";

import { TorexTest } from "./TestCommon.sol";


using SuperTokenV1Library for ISuperToken;

contract SuperBoringTest is TorexTest {
    address internal constant DISTRIBUTOR = address(0x101);

    TorexFactory internal immutable _torexFactory = new TorexFactory();
    ISuperToken internal _boringToken;
    SuperBoring internal _sb;

    function setUp() virtual override public {
        super.setUp();

        vm.startPrank(ADMIN);

        _boringToken = deployPureSuperToken(_sf.host, "Boring", "SB", 1e10 ether);

        EmissionTreasury emissionTreasury = createEmissionTreasury(_boringToken);
        _boringToken.transfer(address(emissionTreasury), 1e9 ether);

        DistributionFeeManager distributionFeeManager = createDistributionFeeManager();

        _sb = new SuperBoring(_boringToken,
                              _torexFactory,
                              emissionTreasury,
                              distributionFeeManager);

        emissionTreasury.initialize(address(_sb));
        distributionFeeManager.initialize(address(_sb));

        vm.stopPrank();
    }

    function _createTorex() internal {
        _torex = _sb.createTorex(_createDefaultConfig(),
                                 -12 /* feePoolScalerN10Pow */, -12 /* boringPoolScalerN10Pow */);
        _expectedFeePM = _sb.IN_TOKEN_FEE_PM();
    }

    function _enableQEForDefaultTorex() internal {
        vm.startPrank(ADMIN);

        // a trick to fund admin's sleeping pod:
        _sb.updateStake(_torex, 0); // ensure the pod is created.
        _boringToken.transfer(address(_sb.getSleepPod(ADMIN)), 1e3 ether);

        _sb.govQEUpdateTargetTotalEmissionRate(int96(1e7 ether) / 360 days);
        _sb.govQEEnableForTorex(_torex);
        // Bootstrap emission qqsum by staking at least some stake in it.
        // However, in order for the distributor fee to kick in, let's also
        // a) fit the scaler too,
        // b) allow rooms for distribution tax rate.
        _sb.updateStake(_torex, _sb.getFeePoolScaler(_torex).inverse().scaleValue(uint256(100)));

        vm.stopPrank();
    }

    function _updateStake(ITorex torex, uint8 byWhom, uint256 newStakedAmount) internal {
        address staker = _toTester(byWhom);
        console2.log("= BEGIN TA_STAKE %s %d", _addr2name(staker), newStakedAmount);

        uint256 staked0 = _sb.getStakedAmountOf(torex, staker);
        uint256 stakeable0 = _sb.getStakeableAmount(staker);
        console2.log("before, staked %d stakable %d", staked0, stakeable0);
        vm.startPrank(staker);
        _sb.updateStake(torex, newStakedAmount);
        vm.stopPrank();
        uint256 staked1 = _sb.getStakedAmountOf(torex, staker);
        uint256 stakeable1 = _sb.getStakeableAmount(staker);
        console2.log("after, staked %d stakable %d", staked1, stakeable1);
        assertEq(staked1, newStakedAmount, "wrong staked amount");
        assertEq(stakeable1 + newStakedAmount, stakeable0 + staked0, "wrong stakable left");

        _printTorexState();
        _printTestersState();
        console2.log("= END TA_STAKE\n");
    }
}

contract SuperBoringTorexTest is SuperBoringTest {
    function setUp() override public {
        super.setUp();
        _createTorex();
        _enableQEForDefaultTorex();
        _connectAllPools();
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

    function testCase001(int64 ps,
                         uint80 r1, uint24 dt1,
                         uint24 dt2) external {
        _setPriceScaler(ps);

        _testChangeFlow(0, r1);
        _doAdvanceTime(dt1);

        console2.log("Emission rate before LM", _sb.emissionTreasury().getEmissionRate(address(_torex)));
        _testMoveLiquidity();
        console2.log("Emission rate after LM", _sb.emissionTreasury().getEmissionRate(address(_torex)));
        _doAdvanceTime(dt2);

        uint256 stakable = _sb.getStakeableAmount(_toTester(0));
        if (_sb.getBoringPoolScaler(_torex).scaleValue(r1) > 0 && dt2 > 0) {
            assertTrue(stakable > 0, "Should have received some emissions");
        }
        _updateStake(_torex, 0, stakable);
    }

    function testCase002(int64 ps,
                         uint80 r1, uint24 dt1,
                         uint24 dt3,
                         uint80 r2, uint24 dt4) external {
        _setPriceScaler(ps);

        _testChangeFlow(0, r1);
        _doAdvanceTime(dt1);

        console2.log("Emission rate before LM", _sb.emissionTreasury().getEmissionRate(address(_torex)));
        _testMoveLiquidity();
        console2.log("Emission rate after LM", _sb.emissionTreasury().getEmissionRate(address(_torex)));
        _doAdvanceTime(dt3);

        _testChangeFlow(0, r2);
        _doAdvanceTime(dt4);

        uint256 stakable = _sb.getStakeableAmount(_toTester(0));
        _updateStake(_torex, 0, stakable);
    }
}

contract SuperBoringReferralTest is SuperBoringTest {
    function setUp() override public {
        super.setUp();
        _createTorex();
        _enableQEForDefaultTorex();
        _connectAllPools();
    }

    function testSimpleReferral(uint8 a, uint8 b, uint80 r1, uint24 dt1) external {
        vm.assume(_toTester(a) != _toTester(b));
        address referrer = _toTester(b);
        _testChangeFlow(a, r1, abi.encode(address(0), referrer));

        // trigger the reward emission adjustment for the torex
        _testMoveLiquidity();

        // Testing the expected bonus
        _doAdvanceTime(dt1);
        {
            uint256 sA = _sb.getStakeableAmount(_toTester(a));
            uint256 sB = _sb.getStakeableAmount(_toTester(b));
            console2.log("Stakeable amount of A", sA);
            console2.log("Stakeable amount of B", sB);
            uint256 traderUnits = _sb.getBoringPoolScaler(_torex).scaleValue(r1);
            uint256 bonusUnits = traderUnits * _sb.QE_REFERRAL_BONUS() / UINT_100PCT_PM;
            console2.log("expected traderUnits", traderUnits);
            console2.log("expected traderUnits", bonusUnits);
            if (traderUnits > 0) {
                if (dt1 > 0) assertGt(sA, 0, "Some reward is expected");
                assertEq(sB, sA / traderUnits * bonusUnits, "Referral bonus not matching");
            } else {
                assertEq(sA, 0, "No boring emission for small flow 1");
                assertEq(sB, 0, "No boring emission for small flow 2");
            }
        }

        _testChangeFlow(a, 0, abi.encode("to be ignored"));
    }

    function testReferralChanges(uint8 a,
                                 uint8 b, uint80 r1,
                                 uint8 c, uint80 r2) external {
        vm.assume(_toTester(a) != _toTester(b));
        vm.assume(_toTester(a) != _toTester(c));
        address referrer1 = _toTester(b);
        address referrer2 = _toTester(b);
        _testChangeFlow(a, r1, abi.encode(address(0), referrer1));
        _testChangeFlow(a, r2, abi.encode(address(0), referrer2));
        _testChangeFlow(a, 0, abi.encode("to be ignored"));
    }

    function testTraderBecomesReferrer(uint8 a,
                                       uint8 b, uint80 r1,
                                       uint8 c, uint80 r2) external {
        ISuperfluidPool pool = _sb.emissionTreasury().getEmissionPool(address(_torex));
        vm.assume(_toTester(a) != _toTester(b));
        vm.assume(_toTester(b) != _toTester(c));
        // TODO less assumption
        vm.assume(r1 > 1e15);
        vm.assume(r2 > 1e15);
        // "b" is a trader, only
        _testChangeFlow(b, r2, abi.encode(address(0), _toTester(c)));
        console2.log("!!!! 1", pool.getTotalUnits());
        uint128 u1 = pool.getUnits(address(_sb.getSleepPod(_toTester(b))));
        // "b" is now a referrer for a
        _testChangeFlow(a, r1, abi.encode(address(0), _toTester(b)));
        uint128 u2 = pool.getUnits(address(_sb.getSleepPod(_toTester(b))));
        assertGt(u2, u1, "B should get referral rewards");
        console2.log("!!!! 2", pool.getTotalUnits());
        // "b" becomes a trader now
        _testChangeFlow(b, r2, abi.encode(address(0), _toTester(c)));
        uint128 u3 = pool.getUnits(address(_sb.getSleepPod(_toTester(b))));
        assertEq(u2, u3, "B's Referrer bonus should not disappear");
    }

    function testNoSelfReferral() external {
        vm.expectRevert(SuperBoring.NO_SELF_REFERRAL.selector);
        // Bundle a seris of internal calls to an external call in order to capture the revert.
        this._stubTestNoSelfReferral();
    }
    function _stubTestNoSelfReferral() external {
        _doChangeFlow(_toTester(0), int96(42e18) / 1 days, abi.encode(address(0), _toTester(0)));
    }
}

contract SuperBoringDistributionFeeTest is SuperBoringTest {
    function setUp() override public {
        super.setUp();
        _createTorex();
        _enableQEForDefaultTorex();
        _connectAllPools();
    }

    function testBasicDistributionFee(uint8 a, uint80 r1, uint24 dt1, uint24 dt2) external {
        _testChangeFlow(a, r1, abi.encode(DISTRIBUTOR, address(0)));

        console2.log("Fee distribution pool total units before LM",
                     _torex.feeDistributionPool().getTotalUnits());

        // trigger the reward emission adjustment for the torex
        _testMoveLiquidity();

        console2.log("Fee distribution pool total units after LM",
                     _torex.feeDistributionPool().getTotalUnits());

        _doAdvanceTime(dt1);

        // first sync to update distributor units
        _sb.distributionFeeManager().sync(_torex, DISTRIBUTOR);

        _doAdvanceTime(dt2);

        // second sync to trigger distributor fee distribution
        _sb.distributionFeeManager().sync(_torex, DISTRIBUTOR);

        // validation of distribution stats
        (int256 vol1, int96 tr1) = _sb.getDistributorStats(_torex, DISTRIBUTOR);
        (int256 vol2, int96 tr2) = _sb.getTotalityStats(_torex);
        assertGe(tr1, int80(r1), "total flow rate is not expected");
        assertEq(tr1, tr2, "total flow rate does not matches");
        assertGe(vol1, int256(uint256(r1)*dt1), "distributed volume is not expected");
        assertEq(vol1, vol2, "total distributed volume does not matches");

        // Testing the expected distribution fee
        if (// slightly sloppy hard coded number as test condition, factors:
            // 1) DistributionFeeManager's pool units
            // 2) Torex feeDistributionPool's pool units
            int256(uint256(r1)) * _sb.IN_TOKEN_FEE_PM() / INT_100PCT_PM  > 1e8
            && dt1 > 0 && dt2 > 0) {
            assertGt(_inToken.balanceOf(DISTRIBUTOR), 0, "Some distributor fee expected");
        }
    }
}

contract SuperBoringTorexStatefulFuzzTest is SuperBoringTest {
    enum TestActionType {
        TA_CHANGE_FLOW,
        TA_MOVE_LIQUIDITY,
        TA_STAKE
    }

    struct Actions {
        uint8  actionCode;
        uint8   w;  // who
        uint24  dt; // time delta,
        uint256 v;  // values: flow rate, stake amount, etc.
    }

    function toActionType(uint8 actionCode, uint8 maxAction) internal pure returns (TestActionType) {
        return TestActionType(actionCode % (maxAction + 1));
    }

    function _testStatefullFuzz(uint8 maxAction,
                                int64 ps, uint24 dt0,
                                Actions[] memory actions) internal {
        // create and setup torex
        {
            _createTorex();
            _enableQEForDefaultTorex();
            _connectAllPools();
        }

        _setPriceScaler(ps);

        _doAdvanceTime(dt0);

        for (uint256 i = 0; i < actions.length; i++) {
            Actions memory a = actions[i];
            TestActionType t = toActionType(a.actionCode, maxAction);
            if (t == TestActionType.TA_CHANGE_FLOW) {
                _testChangeFlow(a.w, a.v % type(uint80).max);
            } else if (t == TestActionType.TA_MOVE_LIQUIDITY) {
                _testMoveLiquidity();
            } else if (t == TestActionType.TA_STAKE) {
                address who = _toTester(a.w);
                uint256 pct = uint256(a.v % 101);
                uint256 staked = _sb.getStakedAmountOf(_torex, who);
                uint256 stakeable = _sb.getStakeableAmount(who);
                console2.log("pct %d", pct);
                _updateStake(_torex, a.w, (staked + stakeable) * pct / 100);
            } else assert(false);

            _doAdvanceTime(a.dt);
        }
    }

    // Fuzzing with only TA_CHANGE_FLOW and TA_MOVE_LIQUIDITY
    function testStatefullFuzz(uint64 md, int64 ps, uint24 dt0,
                               Actions[10] calldata actions) external {
        // set minimum deposit once in the beginning
        _setInTokenMinimumDeposit(md);

        Actions[] memory actions2 = new Actions[](actions.length);
        for (uint256 i = 0; i < actions.length; i++) actions2[i] = actions[i];
        _testStatefullFuzz(uint8(TestActionType.TA_STAKE), ps, dt0, actions2);
    }
}
