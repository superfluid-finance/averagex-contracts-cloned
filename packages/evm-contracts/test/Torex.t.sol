pragma solidity ^0.8.26;

// import { console } from "forge-std/Test.sol";

import { Torex, ITorexController, LiquidityMoveResult } from "../src/Torex.sol";
import { TorexFactory, createTorexFactory } from "../src/TorexFactory.sol";

import { TorexTest } from "./TestCommon.sol";

contract MockTorexController is ITorexController {
    bool private _nextOnInFlowChangedToFail;
    bool private _nextOnLiquidityMovedToFail;

    uint256 public onInFlowChangedCounter;
    uint256 public onLiquidityMovedCounter;

    function getTypeId() external pure returns (bytes32) { return keccak256("MockTorexController") ; }

    function markNextOnInFlowChangedToFail() external { _nextOnInFlowChangedToFail = true; }
    function markNextOnLiquidityMovedToFail() external { _nextOnLiquidityMovedToFail = true; }

    function onInFlowChanged(address /* flowUpdater */,
                             int96 /* prevFlowRate */, int96 /* preFeeFlowRate */, uint256 /* lastUpdated */,
                             int96 /* newFlowRate */, uint256 /* now */,
                             bytes calldata /* userData */) external
        returns (int96 /* newFeeFlowRate */)
    {
        ++onInFlowChangedCounter;
        if (_nextOnInFlowChangedToFail) revert("onInFlowChanged");
        return 0;
    }

    function onLiquidityMoved(LiquidityMoveResult calldata /* result */) external returns (bool) {
        ++onLiquidityMovedCounter;
        if (_nextOnLiquidityMovedToFail) revert("onLiquidityMoved");
        return true;
    }
}

contract TorexControllerTest is TorexTest {
    TorexFactory private immutable _torexFactory;
    MockTorexController private _m;

    constructor() {
        _torexFactory = createTorexFactory();
    }

    function setUp() virtual override public {
        super.setUp();

        Torex.Config memory config = _createDefaultConfig();
        _m = new MockTorexController();
        config.controller = _m;
        _torex = _torexFactory.createTorex(config);
    }

    function _stubDoChangeFlow(int96 flowRate) external {
        _doChangeFlow(_toTester(0), flowRate);
        assertEq(_m.onInFlowChangedCounter(), 1);
    }

    function testOnInFlowCreatedFailure() external {
        _m.markNextOnInFlowChangedToFail();
        vm.expectRevert(abi.encodeWithSelector(ERROR_SELECTOR, "onInFlowChanged"));
        this._stubDoChangeFlow(42);
    }

    function testOnInFlowUpdatedFailure() external {
        this._stubDoChangeFlow(42);
        _m.markNextOnInFlowChangedToFail();
        vm.expectRevert(abi.encodeWithSelector(ERROR_SELECTOR, "onInFlowChanged"));
        this._stubDoChangeFlow(69);
    }

    function testOnInFlowDeletedFailure() external {
        this._stubDoChangeFlow(42);
        _m.markNextOnInFlowChangedToFail();
        this._stubDoChangeFlow(0);
        assertEq(_torex.controllerInternalErrorCounter(), 1);
    }

    function testTorexRC3Quirk() external {
        _testMoveLiquidity();
        assertEq(_torex.controllerInternalErrorCounter(), 0, "controllerInternalErrorCounter");
        assertEq(_m.onLiquidityMovedCounter(), 1, "onLiquidityMovedCounter");
    }

    function testOnLiquidityMovedFailure() external {
        _m.markNextOnLiquidityMovedToFail();
        _testMoveLiquidity();
        assertEq(_torex.controllerInternalErrorCounter(), 1, "controllerInternalErrorCounter");
        assertEq(_m.onLiquidityMovedCounter(), 0, "onLiquidityMovedCounter");
    }
}
