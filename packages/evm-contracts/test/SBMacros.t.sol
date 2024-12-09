// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {console} from "forge-std/Test.sol";
import {VmSafe} from "forge-std/Vm.sol";

import {ISuperToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import {SuperTokenV1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

import {SB712Macro} from "../src/utils/SB712Macro.sol";

import {SuperBoringTest} from "./SuperBoring.t.sol";

using SuperTokenV1Library for ISuperToken;

contract SBMacroTest is SuperBoringTest {
    int96 private constant DEFAULT_FLOWRATE = 190258751902587; // example: AF 500 DEGENx/month
    address private constant DEFAULT_DISTRIBUTOR = address(0x69);
    address private constant DEFAULT_REFERRER = address(0x70);

    function setUp() public virtual override {
        super.setUp();
        _createTorex();
        _connectAllPools();
    }

    // REF: https://book.getfoundry.sh/tutorials/testing-eip712
    function testCase712Simple() external {
        VmSafe.Wallet memory elon = vm.createWallet("elon");
        console.log("Elon's wallet address %s", elon.addr);
        vm.startPrank(ADMIN);
        _inToken.transfer(elon.addr, 1e40 ether);
        vm.stopPrank();

        SB712Macro m = new SB712Macro();

        bytes32 lang = "en";

        SB712Macro.SetDCAPositionParams memory dcaParams =
            SB712Macro.SetDCAPositionParams(_torex, DEFAULT_FLOWRATE, DEFAULT_DISTRIBUTOR, DEFAULT_REFERRER, 0);

        (, string memory message, bytes memory paramsToSign, bytes32 digest) =
            m.encode712SetDCAPosition(lang, dcaParams);

        console.log("Message generated[%d]: %s  ", uint96(DEFAULT_FLOWRATE) * 2628000, message);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(elon, digest);
        bytes memory signatureVRS = abi.encode(v, r, s);

        bytes memory params = abi.encode(m.ACTION_SET_DCA_POSITION_CODE(), lang, paramsToSign, signatureVRS);

        vm.startPrank(elon.addr);
        _sf.macroForwarder.runMacro(m, params);
        vm.stopPrank();
    }

    /*
    function testWithoutUpgrade() external {
        SBMacro m = new SBMacro();

        vm.startPrank(alice);
        address underlyingToken = _inToken.getUnderlyingToken();
        IERC20(underlyingToken).approve(address(_inToken), type(uint256).max);
        _inToken.upgrade(1000 ether);

        _macroFwd.runMacro(m, abi.encode(address(_torex), DEFAULT_FLOWRATE, DEFAULT_DISTRIBUTOR, DEFAULT_REFERRER, 0));
        vm.stopPrank();

        ISuperfluidPool outTokenDistributionPool = _torex.outTokenDistributionPool();
        assertGt(outTokenDistributionPool.getUnits(alice), 0, "no outTokenDistributionPool units assigned");
        assertEq(_inToken.getFlowRate(alice, address(_torex)), DEFAULT_FLOWRATE, "wrong flowrate to torex");

        // TODO: verify distributor, referrer
    }

    function testWithoutUpgradeUsingConvenienceFunction() external {
        SBMacro m = new SBMacro();

        vm.startPrank(alice);
        address underlyingToken = _inToken.getUnderlyingToken();
        IERC20(underlyingToken).approve(address(_inToken), type(uint256).max);
        _inToken.upgrade(1000 ether);

        macroFwd.runMacro(m, m.getParams(address(_torex), DEFAULT_FLOWRATE, DEFAULT_DISTRIBUTOR, DEFAULT_REFERRER, 0));
        m.postCheck(host, m.getParams(address(_torex), DEFAULT_FLOWRATE, DEFAULT_DISTRIBUTOR, DEFAULT_REFERRER, 0), alice);
        vm.stopPrank();

        ISuperfluidPool outTokenDistributionPool = _torex.outTokenDistributionPool();
        assertGt(outTokenDistributionPool.getUnits(alice), 0, "no outTokenDistributionPool units assigned");
        assertEq(_inToken.getFlowRate(alice, address(_torex)), DEFAULT_FLOWRATE, "wrong flowrate to torex");
        // TODO: verify distributor, referrer
    }

    function testWithExactUpgradeAmount() public {
        SBMacro m = new SBMacro();

        vm.startPrank(alice);
        address underlyingToken = _inToken.getUnderlyingToken();
        IERC20(underlyingToken).approve(address(_inToken), type(uint256).max);

        vm.expectRevert(); // revert bcs sender got no SuperTokens and upgradeAmount is 0
        macroFwd.runMacro(m, abi.encode(address(_torex), DEFAULT_FLOWRATE, DEFAULT_DISTRIBUTOR, DEFAULT_REFERRER, 0));

        uint256 upgradeAmount = 1000 ether;
        (uint256 underlyingAmount,) = _inToken.toUnderlyingAmount(upgradeAmount);
        uint256 uBalanceBefore = IERC20(underlyingToken).balanceOf(alice);
        macroFwd.runMacro(m, abi.encode(address(_torex), DEFAULT_FLOWRATE, DEFAULT_DISTRIBUTOR, DEFAULT_REFERRER, 1000 ether));
        uint256 uBalanceAfter = IERC20(underlyingToken).balanceOf(alice);
        vm.stopPrank();

        assertEq(uBalanceBefore - uBalanceAfter, underlyingAmount, "wrong underlying token amount after upgrade");
        assertEq(_inToken.getFlowRate(alice, address(_torex)), DEFAULT_FLOWRATE, "wrong flowrate to torex");
    }

    function testWithMaxUpgradeAmount(uint256 allowance) public {
        // set the floor high enough to avoid failure due to insufficient funds for buffer and backcharging
        vm.assume(allowance > 1000 ether);
        SBMacro m = new SBMacro();

        vm.startPrank(alice);
        address underlyingToken = _inToken.getUnderlyingToken();
        IERC20(underlyingToken).approve(address(_inToken), allowance);
        uint256 uBalanceBefore = IERC20(underlyingToken).balanceOf(alice);
        macroFwd.runMacro(m, abi.encode(address(_torex), DEFAULT_FLOWRATE, DEFAULT_DISTRIBUTOR, DEFAULT_REFERRER, type(uint256).max));
        uint256 uBalanceAfter = IERC20(underlyingToken).balanceOf(alice);
        vm.stopPrank();

        // note that this is underlying token amount, may have different decimals than SuperToken
        // This assertion may fail if the underlying token has MORE decimals than the SuperToken (more than 18!)
        // Since that's a very exotic case and it's a limitation of the test and not of the macro, so be it.
        uint256 expectedUpgradedAmount = Math.min(uBalanceBefore, allowance);
        assertEq(uBalanceBefore - uBalanceAfter, expectedUpgradedAmount, "wrong underlying token amount after upgrade");
    }

    function testWithNativeTokenUnderlying() public {
        SBMacro m = new SBMacro();
        vm.deal(alice, 10000 ether);

        vm.startPrank(alice);
        ISETH(address(inToken2)).upgradeByETH{ value: 1000 ether }();
        address underlyingToken = inToken2.getUnderlyingToken();
        assertEq(underlyingToken, address(0), "underlying token is not native token");

        macroFwd.runMacro(m, abi.encode(address(torex2), DEFAULT_FLOWRATE, DEFAULT_DISTRIBUTOR, DEFAULT_REFERRER, 0));
        vm.stopPrank();

        assertEq(inToken2.getFlowRate(alice, address(torex2)), DEFAULT_FLOWRATE, "wrong flowrate to torex");
    }

    function testWithPreexistingFlow() public {
        SBMacro m = new SBMacro();

        vm.startPrank(alice);
        address underlyingToken = _inToken.getUnderlyingToken();
        IERC20(underlyingToken).approve(address(_inToken), type(uint256).max);
        _inToken.approve(address(_torex), type(uint256).max);
        _inToken.upgrade(1000 ether);

        _inToken.createFlow(address(_torex), 1, new bytes(0));

        macroFwd.runMacro(m, abi.encode(address(_torex), DEFAULT_FLOWRATE, DEFAULT_DISTRIBUTOR, DEFAULT_REFERRER, 0));
        vm.stopPrank();

        assertEq(_inToken.getFlowRate(alice, address(_torex)), DEFAULT_FLOWRATE, "wrong flowrate to torex after update");
    }
    */
}
