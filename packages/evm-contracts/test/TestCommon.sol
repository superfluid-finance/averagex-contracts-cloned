// solhint-disable reentrancy
pragma solidity 0.8.23;

import { Test, console, console2 } from "forge-std/Test.sol";

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";

import { ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { ERC1820RegistryCompiled } from "@superfluid-finance/ethereum-contracts/contracts/libs/ERC1820RegistryCompiled.sol";
import { SuperfluidFrameworkDeployer } from "@superfluid-finance/ethereum-contracts/contracts/utils/SuperfluidFrameworkDeployer.sol";

import { ILiquidityMover } from "../src/interfaces/torex/ILiquidityMover.sol";
import { ITwapObserver } from "../src/interfaces/torex/ITwapObserver.sol";
import { ITorex, ITorexController, LiquidityMoveResult } from "../src/interfaces/torex/ITorex.sol";
import { DiscountFactor } from "../src/libs/DiscountFactor.sol";
import { Scaler } from "../src/libs/Scaler.sol";
import { toInt96 } from "../src/libs/MathExtra.sol";
import { SuperTokenV1Library, SuperTokenV1LibraryExtension } from "../src/libs/SuperTokenExtra.sol";
import { Torex } from "../src/Torex.sol";


/// Mock implementation of ITwapObserver which price out amount twice of nominal amount of in amount.65G
contract MockTorexObserver is ITwapObserver {
    Scaler public priceScaler;
    uint256 public lastCheckpoint;

    constructor() {
        lastCheckpoint = block.timestamp;
    }

    function getTypeId() override external pure returns (bytes32) {
        return keccak256("MockTorexObserver");
    }

    function getDurationSinceLastCheckpoint(uint256 time) public override view returns (uint256 duration) {
        return time - lastCheckpoint;
    }

    function createCheckpoint(uint256 time) public override returns (bool) {
        lastCheckpoint = time;
        return true;
    }
    function getTwapSinceLastCheckpoint(uint256 time, uint256 inAmount) external override view
        returns (uint256 outAmount, uint256 duration)
    {
        return (priceScaler.scaleValue(inAmount), getDurationSinceLastCheckpoint(time));
    }

    function setPrice(Scaler ps) external {
        priceScaler = ps;
    }
}

/// Mock implementation of a LiquidityMover which sends incoming liquidity to and fetches outgoing liquidity from who
/// triggered the triggerLiquidityMovement function. This also shows how a liquidity mover could be implemented.
contract MockLiquidityMover is ILiquidityMover {
    bool public transferLessOut;

    function setTransferLessOut() external {
        transferLessOut = true;
    }

    function triggerLiquidityMovement(ITorex _torex) external
        returns (uint256 inAmount, uint256 outAmount, uint256 actualOutAmount)
    {
        LiquidityMoveResult memory result = _torex.moveLiquidity(abi.encode(msg.sender));
        inAmount = result.inAmount;
        outAmount = result.outAmount;
        actualOutAmount = result.actualOutAmount;
    }

    function moveLiquidityCallback(ISuperToken _inToken, ISuperToken _outToken,
                                   uint256 inAmount, uint256 minOutAmount,
                                   bytes memory moverData)
        external override returns (bool)
    {
        address triggeredFrom = abi.decode(moverData, (address));
        _inToken.transfer(triggeredFrom, inAmount);
        _outToken.transferFrom(triggeredFrom, address(this), minOutAmount);
        _outToken.transfer(msg.sender, transferLessOut ? minOutAmount - 1 : minOutAmount);
        return true;
    }
}

contract TorexTest is Test {
    using SuperTokenV1Library for ISuperToken;
    using SuperTokenV1LibraryExtension for ISuperToken;

    Scaler  internal constant DEFAULT_IN_TOKEN_FEE_POOL_SCALER = Scaler.wrap(-1e7);
    Scaler  internal constant DEFAULT_OUT_TOKEN_DIST_POOL_SCALER = Scaler.wrap(-1e7);
    uint256 internal constant CONTROLLER_SAFE_CALLBACK_GAS_LIMIT = 2e6; // 2M gas for controller
    uint256 internal constant MAX_IN_TOKEN_FEE_PM = 30_000;    // 3% fee
    uint256 internal constant DEFAULT_IN_TOKEN_FEE_PM = 5_000; // 0.5% fee

    /* solhint-disable const-name-snakecase */
    address internal constant alice  = address(0x41);
    address internal constant bob    = address(0x42);
    address internal constant caspar = address(0x43);
    address internal constant dan    = address(0x44);
    address internal constant elena  = address(0x45);
    address internal constant TESTER_START = alice;
    address internal constant TESTER_END   = elena;
    uint8   internal constant N_TESTERS    = uint8(uint160(TESTER_END) - uint160(TESTER_START));
    address internal constant ADMIN  = address(0x80);
    address internal constant EU     = address(0x81); // EU, the professional tax collector
    address internal constant LM     = address(0x82); // Liquidity Mover
    /* solhint-enable const-name-snakecase */

    string internal constant TEST_INVARIANCE_11 = "11. TRADER PREVIOUS FLOW RATE";
    string internal constant TEST_INVARIANCE_12 = "12. DURATION SINCE LAST LME";
    string internal constant TEST_INVARIANCE_13 = "13. TOREX JAILED";
    string internal constant TEST_INVARIANCE_14 = "14. TOREX CONTROLLER INTERNAL ERROR";
    string internal constant TEST_BEHAVIOR_21   = "21. TRADER FEE FLOW DIST RATE";
    string internal constant TEST_BEHAVIOR_22   = "22. TRADER CONTRIB RATE";
    string internal constant TEST_BEHAVIOR_23   = "23. TOREX REQ FEE DIST FLOW RATE";
    string internal constant TEST_BEHAVIOR_24   = "24. TOREX ACTUAL FEE DIST FLOW RATE";
    string internal constant TEST_BEHAVIOR_31   = "31. TRADER BACK CHARGE + FEES";
    string internal constant TEST_BEHAVIOR_32   = "32. TRADER BACK REFUND";
    string internal constant TEST_BEHAVIOR_41   = "41. TRADER RECEIVED OUT AMOUNT";
    string internal constant TEST_BEHAVIOR_42   = "42. TOTAL ACTUAL OUT AMOUNT";

    SuperfluidFrameworkDeployer internal immutable _deployer;

    SuperfluidFrameworkDeployer.Framework internal _sf;

    ISuperToken internal _inToken;
    ISuperToken internal _outToken;
    MockLiquidityMover internal _mockLiquidityMover;

    uint256 internal _expectedFeePM;
    Torex internal _torex;

    constructor() {
        // deploy prerequisites for _SF framework
        vm.etch(ERC1820RegistryCompiled.at, ERC1820RegistryCompiled.bin);

        vm.startPrank(ADMIN);

        // deploy _SF framework
        _deployer = new SuperfluidFrameworkDeployer();
        _deployer.deployTestFramework();
        _sf = _deployer.getFramework();

        vm.stopPrank();
    }

    function setUp() virtual public {
        vm.startPrank(ADMIN);

        _inToken = _deployer.deployPureSuperToken("InToken", "IN", 1e50 ether);
        _outToken = _deployer.deployPureSuperToken("OutToken", "OUT", 1e50 ether);
        _mockLiquidityMover = new MockLiquidityMover();

        // distribute inTokens to the testers
        for (address i = TESTER_START; i <= TESTER_END; i = address(uint160(i)+1)) {
            _inToken.transfer(i, 1e40 ether);
        }

        // distribute outTokens to the liquidity mover
        _outToken.transfer(LM, 1e49 ether);

        // need to initialize it, to be in sync with MockLiquidityMover implementation
        _lastLiquidityMoveTime = block.timestamp;

        vm.stopPrank();
    }

    function _createDefaultConfig() virtual internal returns (Torex.Config memory) {
        return Torex.Config({
            inToken: _inToken,
            outToken: _outToken,
            observer: new MockTorexObserver(),
            twapScaler: Scaler.wrap(1),
            discountFactor: DiscountFactor.wrap(0), /* No discount */
            outTokenDistributionPoolScaler: DEFAULT_OUT_TOKEN_DIST_POOL_SCALER,
            controller: ITorexController(address(0)), /* to be filled */
            controllerSafeCallbackGasLimit: CONTROLLER_SAFE_CALLBACK_GAS_LIMIT,
            maxAllowedFeePM: MAX_IN_TOKEN_FEE_PM
            });
    }

    function _setPriceScaler(int256 ps) internal {
        console2.log("Price scaler:", ps);
        MockTorexObserver(address(_torex.getConfig().observer)).setPrice(Scaler.wrap(ps));
    }

    function _setInTokenMinimumDeposit(uint256 md) internal {
        console2.log("Minimum deposit", md);
        vm.startPrank(address(_sf.governance.owner()));
        _sf.governance.setSuperTokenMinimumDeposit(_sf.host, _inToken, md);
        vm.stopPrank();
    }

    function _forEachTesters(function (address) internal f) internal  {
        for (address i = TESTER_START; i <= TESTER_END; i = address(uint160(i)+1)) f(i);
    }

    function _forEachTestersV(function (address) internal view f) internal view {
        for (address i = TESTER_START; i <= TESTER_END; i = address(uint160(i)+1)) f(i);
    }

    function _connectOutTokenPool(address byWhom) internal {
        vm.startPrank(byWhom);
        _outToken.connectPool(_torex.outTokenDistributionPool());
        vm.stopPrank();
    }

    function _connectAllPools() internal {
        _forEachTesters(_connectOutTokenPool);
        _connectOutTokenPool(EU);
    }

    /*******************************************************************************************************************
     * Test Actions
     ******************************************************************************************************************/

    uint256 private _lastLiquidityMoveTime;
    mapping (address => int256) private _outTokenBalances;

    function _doAdvanceTime(uint256 dt) internal {
        uint256 t = block.timestamp + uint256(dt);
        console.log("= BEGIN TA_ADVANCE_TIME %d + %d = %d", block.timestamp, uint256(dt), t);
        vm.warp(t);
        _printTorexState();
        _printTestersState();
        console.log("= END TA_ADVANCE_TIME\n");
    }

    function _doChangeFlow(address byWhom, int96 newFlowRate) internal
        returns (int256 ownedBalanceDelta)
    {
        int96 prevFlowRate = _inToken.getFlowRate(byWhom, address(_torex));
        return _doChangeFlow(byWhom, prevFlowRate, newFlowRate, "");
    }

    function _doChangeFlow(address byWhom, int96 newFlowRate, bytes memory userData) internal
        returns (int256 ownedBalanceDelta)
    {
        int96 prevFlowRate = _inToken.getFlowRate(byWhom, address(_torex));
        return _doChangeFlow(byWhom, prevFlowRate, newFlowRate, userData);
    }

    function _doChangeFlow(address byWhom,
                           int96 prevFlowRate, int96 newFlowRate,
                           bytes memory userData) internal
        returns (int256 ownedBalanceDelta)
    {
        vm.startPrank(byWhom);

        (int256 avb0, uint256 deposit0,,) = _inToken.realtimeBalanceOfNow(byWhom);

        // Note: this in the actual front-end should be a batch call.
        _inToken.approve(address(_torex), _torex.estimateApprovalRequired(newFlowRate));
        if (prevFlowRate > 0) {
            if (newFlowRate > 0) {
                _inToken.updateFlow(address(_torex), newFlowRate, userData);
            } else {
                _inToken.deleteFlow(byWhom, address(_torex), userData);
            }
        } else {
            if (newFlowRate > 0) {
                _inToken.createFlow(address(_torex), newFlowRate, userData);
            }
        }
        _inToken.approve(address(_torex), 0); // this is not strictly necessary.

        (int256 avb1, uint256 deposit1,,) = _inToken.realtimeBalanceOfNow(byWhom);
        ownedBalanceDelta = avb1 + int256(deposit1) - avb0 - int256(deposit0);

        vm.stopPrank();
    }

    function _testChangeFlow(uint8 a, uint256 b) internal {
        address byWhom = _toTester(a);
        int96 newFlowRate = toInt96(b);
        _testChangeFlow(byWhom, newFlowRate);
    }

    function _testChangeFlow(uint8 a, uint256 b, bytes memory userData) internal {
        address byWhom = _toTester(a);
        int96 newFlowRate = toInt96(b);
        _testChangeFlow(byWhom, newFlowRate, userData);
    }

    function _testChangeFlow(address byWhom, int96 newFlowRate) internal {
        _testChangeFlow(byWhom, newFlowRate, "");
    }

    function _testChangeFlow(address byWhom, int96 newFlowRate, bytes memory userData) internal {
        int96 prevFlowRate = _inToken.getFlowRate(byWhom, address(_torex));
        uint256 durationSinceLastLME = _torex.getDurationSinceLastLME();
        Torex.TraderState memory ts0 = _torex.getTraderState(byWhom);
        (int96 requestedFeeDistFlowRate0, , uint256 feeDistBuffer0) = _torex.debugCurrentDetails();
        console.log("= BEGIN TA_CHANGE_FLOW %s, %d -> %d",
                    _addr2name(byWhom), uint256(int256(prevFlowRate)), uint256(int256(newFlowRate)));

        assertEq(ts0.contribFlowRate + ts0.feeFlowRate, prevFlowRate, TEST_INVARIANCE_11);
        assertEq(durationSinceLastLME, block.timestamp - _lastLiquidityMoveTime,
                 TEST_INVARIANCE_12);

        // this means "available balance + deposit", because we don't test deposit changes.
        int256 ownedBalanceDelta = _doChangeFlow(byWhom, prevFlowRate, newFlowRate, userData);

        _printTorexState();
        _printTestersState();

        Torex.TraderState memory ts1 = _torex.getTraderState(byWhom);
        (int96 requestedFeeDistFlowRate1, /*int96 actualFeeDistFlowRate1*/, ) = _torex.debugCurrentDetails();

        assertFalse(_sf.host.isAppJailed(_torex), TEST_INVARIANCE_13);
        assertEq(_torex.controllerInternalErrorCounter(), 0, TEST_INVARIANCE_14);
        assertEq(ts1.feeFlowRate, newFlowRate * int256(_expectedFeePM) / 1e6, TEST_BEHAVIOR_21);
        assertEq(ts1.contribFlowRate, newFlowRate - ts1.feeFlowRate, TEST_BEHAVIOR_22);
        assertEq(requestedFeeDistFlowRate1,
                 requestedFeeDistFlowRate0 + ts1.feeFlowRate - ts0.feeFlowRate,
                 TEST_BEHAVIOR_23);

        /* { */
        /*     (int96 expectedActualFeeDistFlowRate1, ) = _inToken.estimateFlowDistributionActualFlowRate */
        /*         (address(_torex), _torex.feeDistributionPool(), requestedFeeDistFlowRate1); */
        /*     assertEq(actualFeeDistFlowRate1, expectedActualFeeDistFlowRate1, TEST_BEHAVIOR_24); */
        /* } */

        {
            if (newFlowRate > prevFlowRate) {
                assertGe(ts1.feeFlowRate, ts0.feeFlowRate,
                         "An assumption about the protocol broke (1)");
                // back adjustment rule 1: back charge + fee distribution flow buffer
                int256 backCharge = (newFlowRate - prevFlowRate) * int256(durationSinceLastLME);
                uint256 bufferFee = _expectedBufferFee(requestedFeeDistFlowRate1, feeDistBuffer0);
                console2.log("Expected back charge", SafeCast.toUint256(backCharge));
                console2.log("Expected bufferFee", bufferFee);
                assertEq(-ownedBalanceDelta,
                         backCharge + int256(bufferFee),
                         TEST_BEHAVIOR_31);
            } else {
                assertLe(ts1.contribFlowRate, ts0.contribFlowRate,
                         "An assumption about the protocol broke (2)");
                // back adjustment rule 2: back refund
                int256 backRefund = (ts0.contribFlowRate - ts1.contribFlowRate) * int256(durationSinceLastLME);
                console2.log("Expected back refund", SafeCast.toUint256(backRefund));
                assertEq(ownedBalanceDelta,
                         backRefund,
                         TEST_BEHAVIOR_32);
            }
        }

        console.log("= END TA_CHANGE_FLOW\n");
    }

    function _testMoveLiquidity() internal returns (uint256 inAmount, uint256 outAmount, uint256 actualOutAmount) {
        console.log("= BEGIN TA_MOVE_LIQUIDITY");

        Scaler scaler = _torex.getConfig().outTokenDistributionPoolScaler;
        uint128 tu = _torex.outTokenDistributionPool().getTotalUnits();

        {
            vm.startPrank(LM);
            _outToken.approve(address(_mockLiquidityMover), type(uint256).max);
            (inAmount, outAmount, actualOutAmount) = _mockLiquidityMover.triggerLiquidityMovement(_torex);
            vm.stopPrank();

            console.log("Liquidity moved: inAmount %d outAmount %d actualOutAmount %d",
                        inAmount, outAmount, actualOutAmount);

            _lastLiquidityMoveTime = block.timestamp;

        }

        _printTorexState();
        _printTestersState();

        // actual out token amount
        int256 actualOutAmount2;
        // tally balance changes from testers
        for (address i = TESTER_START; i <= TESTER_END; i = address(uint160(i) + 1)) {
            int256 bal = int256(_outToken.balanceOf(i));

            // a little trick of using product instead of division to avoid precision issue
            assertEq(int256(actualOutAmount) * scaler.scaleValue(_torex.getTraderState(i).contribFlowRate),
                     int256(uint256(tu)) * (bal - _outTokenBalances[i]),
                     TEST_BEHAVIOR_41);

            actualOutAmount2 += bal - _outTokenBalances[i];
            _outTokenBalances[i] = bal;
        }

        assertEq(int256(actualOutAmount), actualOutAmount2, TEST_BEHAVIOR_42);

        console.log("= END TA_MOVE_LIQUIDITY\n");
    }

    // This should be in sync with the `Torex._onInFlowChanged` implementation
    function _expectedBufferFee(int96 requestedFeeDistFlowRate1, uint256 feeDistBuffer0) internal view
        returns (uint256 bufferFee)
    {
        uint256 feeDistBuffer1 = _inToken.getBufferAmountByFlowRate(requestedFeeDistFlowRate1);
        return feeDistBuffer1 > feeDistBuffer0 ? feeDistBuffer1 - feeDistBuffer0 : 0;
    }

    /*******************************************************************************************************************
     * Debug Info
     ******************************************************************************************************************/

    function _toTester(uint8 a) internal pure returns (address) {
        return address(uint160(TESTER_START) + uint160(a % N_TESTERS));
    }

    function _addr2name(address addr) internal pure returns (string memory name) {
        if (addr == ADMIN)       return "ADMIN";
        else if (addr == alice)  return "alice";
        else if (addr == bob)    return "bob";
        else if (addr == caspar) return "caspar";
        else if (addr == dan)    return "dan";
        else if (addr == elena)  return "elena";
        else if (addr == LM)     return "LM";
        else if (addr == EU)     return "EU";
    }

    function _printOneTesterState(address addr) internal view {
        uint256 units = _torex.outTokenDistributionPool().getUnits(addr);
        (int256 claimable,) = _torex.outTokenDistributionPool().getClaimableNow(addr);
        console.log("%s\tin-token %d, out-token %d", _addr2name(addr),
                    uint256(_inToken.balanceOf(addr)), uint256(_outToken.balanceOf(addr)));
        console.log("   torex flow rate %d, contrib flow rate %d, fee flow rate %d",
                    uint256(int256(_inToken.getFlowRate(addr, address(_torex)))),
                    uint256(int256(_torex.getTraderState(addr).contribFlowRate)),
                    uint256(int256(_torex.getTraderState(addr).feeFlowRate)));
        console.log("   units %d, claimable %d",
                    units, uint256(claimable));
    }

    function _printTestersState() internal view {
        console.log("=== Account States ===");
        _forEachTestersV(_printOneTesterState);
        _printOneTesterState(ADMIN);
        _printOneTesterState(LM);
        _printOneTesterState(EU);
        console.log("======");
    }

    function _printTorexState() internal view {
        console.log("=== TOREX States ===");
        console.log("TOREX in-token %d, out-token %d",
                    uint256(_inToken.balanceOf(address(_torex))), uint256(_outToken.balanceOf(address(_torex))));

        console.log("=== TOREX.outTokenDistributionPool States ===");
        uint128 tcu = _torex.outTokenDistributionPool().getTotalConnectedUnits();
        uint128 tdu = _torex.outTokenDistributionPool().getTotalDisconnectedUnits();
        console.log("total connected units", tcu);
        console.log("total disconnected units", tdu);
        console.log("total units", tdu + tcu);
        console.log("======");
    }
}
