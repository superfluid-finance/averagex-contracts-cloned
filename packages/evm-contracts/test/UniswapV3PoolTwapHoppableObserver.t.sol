/* solhint-disable reentrancy */
pragma solidity ^0.8.26;

import { console2 } from "forge-std/Test.sol";
import { Test } from "forge-std/Test.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { UniswapV3PoolTwapHoppableObserver , IUniswapV3Pool } from "../src/UniswapV3PoolTwapHoppableObserver.sol";
import { IUniswapV3Factory } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import { TickMath } from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import { OracleLibrary } from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";


contract UniV3TwapObserverTestSetup is Test {
    // Mock ERC20 Tokens (TokenA - TokenB - TokenC)
    ERC20 internal _tokenA;
    ERC20 internal _tokenB;
    ERC20 internal _tokenC;

    // Uniswap V3 Factory
    IUniswapV3Factory private _uniV3factory;

    // TokenA <-> TokenB Uniswap V3 Pool
    IUniswapV3Pool internal _uniV3poolBA;
    bool internal constant _B_A_INVERSE_ORDER = false;

    // TokenA <-> TokenC Uniswap V3 Pool
    IUniswapV3Pool internal _uniV3poolAC;
    bool internal constant _A_C_INVERSE_ORDER = false;

    // Uniswap V3 Pool Tick Data and Ratio
    int24 private constant _MIN_TICK = TickMath.MIN_TICK;
    int24 private constant _MAX_TICK = TickMath.MAX_TICK;
    int24 private constant _TICK_SPACING = 60;
    uint160 private constant _MIN_SQRT_RATIO = TickMath.MIN_SQRT_RATIO;
    uint160 private constant _MAX_SQRT_RATIO = TickMath.MAX_SQRT_RATIO;

    uint256 private constant _MILLION_TOKENS = 1_000_000e18;
    uint256 private constant _LIQUIDITY = 100_000_000e18;
    uint256 private constant _BP_DENOMINATOR = 10_000;
    uint256 private constant _BP_1_PERCENT = 100;


    // Initial UniV3 pool price is calculated as follow :
    // P = 5000 (i.e. 5000 TokenA for 1 TokenB)
    // Q96 = 2**96
    // SQRT_PRICE_X96 = sqrt(P) * Q96

    // UniV3 Pool Fees
    uint24 private constant _POOL_FEE = 3000;

    // Initial pool price for UniV3 Pool B-A
    // 1 TokenB = 5000 TokenA
    uint160 private constant _INITIAL_PRICE_BA = 5602277097478614198912276234240;

    // Initial pool price (1 TokenA = 1000 TokenC)
    uint160 private constant _INITIAL_PRICE_AC = 2505414483750479251915866636288;

    // Error thrown upon incorrect bytes passed in Uniswap `Swap` callback function
    error INCORRECT_SWAP_DATA();

    // Error thrown upon incorrect bytes passed in Uniswap `Mint` callback function
    error INCORRECT_MINT_DATA();

    function setUp() virtual public {
        _deployTokens();
        _deployUniswapV3(_INITIAL_PRICE_BA, _INITIAL_PRICE_AC);
    }

    function _createPriceActionMultiHop(bool twapUp, bool moveBA, uint256 deltaTime) internal {
        // Create Price Action in Pool BA
        if(moveBA) {
            // Moving B To C TWAP Up
            if(twapUp) {
                // Swap 1% of initial liquidity deposited of token B for token A
                _uniV3poolBA.swap(address(this), true, int256(_LIQUIDITY * _BP_1_PERCENT / _BP_DENOMINATOR), _MIN_SQRT_RATIO + 1, "UP_A_DOWN_B");

            // Moving B To C TWAP Down
            } else {
                // Swap 1% of initial liquidity deposited of token A for token B
                _uniV3poolBA.swap(address(this), false, int256(_LIQUIDITY * _BP_1_PERCENT / _BP_DENOMINATOR), _MAX_SQRT_RATIO - 1, "UP_B_DOWN_A");
            }

        // Create Price Action in Pool AC
        } else {
            // Moving B To C TWAP Up
            if(twapUp) {
                // Swap 1% of initial liquidity deposited of token A for token C
                _uniV3poolAC.swap(address(this), true, int256(_LIQUIDITY * _BP_1_PERCENT / _BP_DENOMINATOR), _MIN_SQRT_RATIO + 1, "UP_C_DOWN_A");

            // Moving B To C TWAP Down
            } else {
                // Swap 1% of initial liquidity deposited of token C for token A
                _uniV3poolAC.swap(address(this), false, int256(_LIQUIDITY * _BP_1_PERCENT / _BP_DENOMINATOR), _MAX_SQRT_RATIO - 1, "UP_A_DOWN_C");
            }
        }

        // Move current timestamp
        vm.warp(block.timestamp + deltaTime);
    }

    function _createPriceActionSingleHop(bool twapUp, uint256 deltaTime) internal {
        // Moving B To A TWAP Up
        if(twapUp) {
            // Swap 1% of initial liquidity deposited of token B for token A
            _uniV3poolBA.swap(address(this), true, int256(_LIQUIDITY * _BP_1_PERCENT / _BP_DENOMINATOR), _MIN_SQRT_RATIO + 1, "UP_A_DOWN_B");
        // Moving B To A TWAP Down
        } else {
            // Swap 1% of initial liquidity deposited of token A for token B
            _uniV3poolBA.swap(address(this), false, int256(_LIQUIDITY * _BP_1_PERCENT / _BP_DENOMINATOR), _MAX_SQRT_RATIO - 1, "UP_B_DOWN_A");
        }
        // Move current timestamp
        vm.warp(block.timestamp + deltaTime);
    }

    // UniswapV3 Mint Callback function necessary for calling `mint(...)` function in UniswapV3Pool
    function uniswapV3MintCallback(uint256 amount0, uint256 amount1, bytes calldata data) external {
        if(keccak256(data) == keccak256("POOL_BA")) {
            _tokenA.transfer(msg.sender, amount1);
            _tokenB.transfer(msg.sender, amount0);
        } else if (keccak256(data) ==  keccak256("POOL_AC")) {
            _tokenA.transfer(msg.sender, amount0);
            _tokenC.transfer(msg.sender, amount1);
        } else {
            revert INCORRECT_MINT_DATA();
        }
    }

    // UniswapV3 Swap Callback function necessary for calling `swap(...)` function in UniswapV3Pool
    function uniswapV3SwapCallback(int256 amount0, int256 amount1, bytes calldata data) external {
        if(keccak256(data) == keccak256("UP_A_DOWN_B")) {
            _tokenB.transfer(address(_uniV3poolBA), uint256(amount0));
        } else if(keccak256(data) == keccak256("UP_B_DOWN_A")) {
            _tokenA.transfer(address(_uniV3poolBA), uint256(amount1));
        } else if(keccak256(data) == keccak256("UP_A_DOWN_C")) {
            _tokenC.transfer(address(_uniV3poolAC), uint256(amount1));
        } else if(keccak256(data) == keccak256("UP_C_DOWN_A")) {
            _tokenA.transfer(address(_uniV3poolAC), uint256(amount0));
        } else {
            revert INCORRECT_SWAP_DATA();
        }
    }

    function _deployTokens() internal {
        _tokenA = new ERC20("Token A", "TKNA");
        _tokenB = new ERC20("Token B", "TKNB");
        _tokenC = new ERC20("Token C", "TKNC");

        // Ensure TokenA > TokenB and TokenC > TokenA
        while(
            address(_tokenA) < address(_tokenB)
            && address(_tokenC) < address(_tokenA)
        ) {
            _tokenA = new ERC20("Token A", "TKNA");
            _tokenB = new ERC20("Token B", "TKNB");
            _tokenC = new ERC20("Token C", "TKNC");
        }

        deal(address(_tokenA), address(this), type(uint256).max);
        deal(address(_tokenB), address(this), type(uint256).max);
        deal(address(_tokenC), address(this), type(uint256).max);
        vm.label(address(_tokenA), "tokenA");
        vm.label(address(_tokenB), "tokenB");
        vm.label(address(_tokenC), "tokenC");
    }

    function _deployUniswapV3(uint160 initPriceBA, uint160 initPriceAC) internal {
        _uniV3factory = IUniswapV3Factory(
            deployCode("test/bytecodes/UniswapV3Factory.sol/UniswapV3Factory.json")
        );


        // Create TokenA/TokenB Pool (token0 = TokenB / token1 = TokenA)
        _uniV3poolBA = IUniswapV3Pool(_uniV3factory.createPool(address(_tokenA), address(_tokenB), _POOL_FEE));

        // Create TokenA/TokenC Pool (token0 = TokenA / token1 = TokenC)
        _uniV3poolAC = IUniswapV3Pool(_uniV3factory.createPool(address(_tokenA), address(_tokenC), _POOL_FEE));

        // Initialize UniswapV3 Pools
        _uniV3poolBA.initialize(initPriceBA);
        _uniV3poolAC.initialize(initPriceAC);

        // Add liquidity to the pools
        _uniV3poolBA.mint(
            address(this),
            (_MIN_TICK / _TICK_SPACING) * _TICK_SPACING,
            (_MAX_TICK / _TICK_SPACING) * _TICK_SPACING,
            uint128(_LIQUIDITY),
            "POOL_BA"
        );
        _uniV3poolAC.mint(
            address(this),
            (_MIN_TICK / _TICK_SPACING) * _TICK_SPACING,
            (_MAX_TICK / _TICK_SPACING) * _TICK_SPACING,
            uint128(_LIQUIDITY),
            "POOL_AC"
        );
        vm.label(address(_uniV3factory), "factory");
        vm.label(address(_uniV3poolBA), "poolBA");
        vm.label(address(_uniV3poolAC), "poolAC");
    }

    function _logDeployment() internal view {
        console2.log(":: TokenA             deployed at address : %s ", address(_tokenA));
        console2.log(":: TokenB             deployed at address : %s ", address(_tokenB));
        console2.log(":: TokenC             deployed at address : %s ", address(_tokenC));
        console2.log("");
        console2.log(":: UniswapV3Factory   deployed at address : %s ", address(_uniV3factory));
        console2.log("");
        console2.log(":: UniswapV3Pool TokenA - TokenC");
        console2.log(":::: deployed at address : %s ", address(_uniV3poolAC));
        console2.log(":::: token0 : TokenA | token1: TokenC");
        console2.log("");
        console2.log(":: UniswapV3Pool TokenB - TokenA");
        console2.log(":::: deployed at address : %s ", address(_uniV3poolBA));
        console2.log(":::: token0 : TokenB | token1: TokenA");
    }
}



contract UniV3TwapMultiHopObserverTest is UniV3TwapObserverTestSetup {
    // TWAP Observer for TokenB/TokenC multihop pair (TokenB/TokenA + TokenA/TokenC)
    UniswapV3PoolTwapHoppableObserver internal _twapObs;

    function setUp() override public {
        super.setUp();

        UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops = new UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[](2);
        hops[0] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_uniV3poolBA, _B_A_INVERSE_ORDER);
        hops[1] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_uniV3poolAC, _A_C_INVERSE_ORDER);
        _twapObs = new UniswapV3PoolTwapHoppableObserver(hops);
    }

    function testGetTypeId() public {
        bytes32 expectedTypeId = keccak256("UniswapV3PoolTwapHoppableObserver");
        assertEq(_twapObs.getTypeId(), expectedTypeId);
    }

    function testInvalidHopsConfiguration() public {
        UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops = new UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[](2);
        hops[0] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_uniV3poolBA, _B_A_INVERSE_ORDER);
        hops[1] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_uniV3poolAC, !_A_C_INVERSE_ORDER);

        vm.expectRevert(UniswapV3PoolTwapHoppableObserver.INVALID_HOPS_CONFIG.selector);
        new UniswapV3PoolTwapHoppableObserver(hops);

        hops[0] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_uniV3poolBA, !_B_A_INVERSE_ORDER);
        hops[1] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_uniV3poolAC, _A_C_INVERSE_ORDER);

        vm.expectRevert(UniswapV3PoolTwapHoppableObserver.INVALID_HOPS_CONFIG.selector);
        new UniswapV3PoolTwapHoppableObserver(hops);
    }

    function testLogDeployment() public view {
        _logDeployment();
        assert(true);
    }

    function testInitialPrice(uint256 inAmount) external {
        inAmount = bound(inAmount, 1, 100_000_000e18);

        // STEP 1 : Check initial price without extra checkpoint created
        (uint256 outAmountT0,) = _twapObs.getTwapSinceLastCheckpointNow(inAmount);

        (, int24 tickBA,,,,,) = _uniV3poolBA.slot0();
        uint256 outAmountBA = OracleLibrary.getQuoteAtTick(tickBA, uint128(inAmount), address(_tokenB), address(_tokenA));

        (, int24 tickAC,,,,,) = _uniV3poolAC.slot0();
        uint256 expectedOutAmountT0 = OracleLibrary.getQuoteAtTick(tickAC, uint128(outAmountBA), address(_tokenA), address(_tokenC));

        assertEq(outAmountT0, expectedOutAmountT0, "wrong initial price (T0)");

        // STEP 2: Check current price after a first checkpoint created (but without price action)
        _twapObs.createCheckpoint(block.timestamp);
        (uint256 outAmountT1,) = _twapObs.getTwapSinceLastCheckpointNow(inAmount);

        (, tickBA,,,,,) = _uniV3poolBA.slot0();
        outAmountBA = OracleLibrary.getQuoteAtTick(tickBA, uint128(inAmount), address(_tokenB), address(_tokenA));

        (, tickAC,,,,,) = _uniV3poolAC.slot0();
        uint256 expectedOutAmountT1 = OracleLibrary.getQuoteAtTick(tickAC, uint128(outAmountBA), address(_tokenA), address(_tokenC));

        assertEq(outAmountT1, expectedOutAmountT1, "wrong price (T1)");

        // STEP 3: Check current price after another checkpoint created a week later (but without price action in between)
        vm.warp(block.timestamp + 1 weeks);

        _twapObs.createCheckpoint(block.timestamp);
        (uint256 outAmountT2,) = _twapObs.getTwapSinceLastCheckpointNow(inAmount);

        (, tickBA,,,,,) = _uniV3poolBA.slot0();
        outAmountBA = OracleLibrary.getQuoteAtTick(tickBA, uint128(inAmount), address(_tokenB), address(_tokenA));

        (, tickAC,,,,,) = _uniV3poolAC.slot0();
        uint256 expectedOutAmountT2 = OracleLibrary.getQuoteAtTick(tickAC, uint128(outAmountBA), address(_tokenA), address(_tokenC));

        assertEq(outAmountT2, expectedOutAmountT2, "wrong price (T2)");

        // Quoted Amount shall be constant accross all checkpoints :
        assertEq(outAmountT0, outAmountT1, "wrong price (T0 - T1)");
        assertEq(outAmountT0, outAmountT2, "wrong price (T0 - T2)");
    }

    function testTwapUpdate(uint256 deltaTime, uint256 inAmount, bool twapUp, bool moveBA) public {
        inAmount = bound(inAmount, 1, 100_000_000e18);
        deltaTime = bound(deltaTime, 1 seconds, 1 days);

        _twapObs.createCheckpoint(block.timestamp);

        vm.warp(block.timestamp + 1);
        (uint256 outAmountT0,) = _twapObs.getTwapSinceLastCheckpointNow(inAmount);

        _createPriceActionMultiHop(twapUp, moveBA, deltaTime);

        (uint256 outAmountT1,) = _twapObs.getTwapSinceLastCheckpointNow(inAmount);

        if(twapUp) {
            assertGt(outAmountT0, outAmountT1, "twap did not go up");
            console2.log(":: TWAPs :");
            console2.log("::: before UP ONLY     : %d C/B (wei)", outAmountT0);
            console2.log("::: after UP ONLY      : %d C/B (wei)", outAmountT1);
        } else {
            assertLt(outAmountT0, outAmountT1, "twap did not go down");
            console2.log(":: TWAPs :");
            console2.log("::: before DOWN ONLY   : %d C/B (wei)", outAmountT0);
            console2.log("::: after DOWN ONLY    : %d C/B (wei)", outAmountT1);
        }
    }

    function testDebugCurrentDetails(uint256 expectedDuration) public {
        expectedDuration = bound(expectedDuration, 1 seconds, 30 days);

        uint256 lastCheckpointDate = block.timestamp;

        _twapObs.createCheckpoint(lastCheckpointDate);

        (int56[] memory expectLastTickCumulativeBA,) = _uniV3poolBA.observe(new uint32[](1));
        (int56[] memory expectLastTickCumulativeAC,) = _uniV3poolAC.observe(new uint32[](1));

        vm.warp(lastCheckpointDate + expectedDuration);

        uint256 expectedCurrentTime = block.timestamp;

        (int56[] memory expectCurrentTickCumulativeBA,) = _uniV3poolBA.observe(new uint32[](1));
        (int56[] memory expectCurrentTickCumulativeAC,) = _uniV3poolAC.observe(new uint32[](1));

        (
            uint256 currentTime,
            uint256 duration,
            int56[] memory currentTickCumulative,
            int56[] memory lastTickCumulative
        ) = _twapObs.debugCurrentDetails();

        assertEq(currentTime, expectedCurrentTime);
        assertEq(duration, expectedDuration);
        assertEq(currentTickCumulative[0], expectCurrentTickCumulativeBA[0]);
        assertEq(currentTickCumulative[1], expectCurrentTickCumulativeAC[0]);
        assertEq(lastTickCumulative[0], expectLastTickCumulativeBA[0]);
        assertEq(lastTickCumulative[1], expectLastTickCumulativeAC[0]);
    }
}

contract UniV3TwapSingleHopObserverTest is UniV3TwapObserverTestSetup {
    // TWAP Observer for TokenB/TokenA single hop pair
    UniswapV3PoolTwapHoppableObserver internal _twapObs;

    function setUp() override public {
        super.setUp();

        UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops = new UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[](1);
        hops[0] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_uniV3poolBA, _B_A_INVERSE_ORDER);
        _twapObs = new UniswapV3PoolTwapHoppableObserver(hops);
    }

    function testLogDeployment() public view {
        _logDeployment();
        assert(true);
    }

    function testInitialPrice(uint256 inAmount) external {
        inAmount = bound(inAmount, 1, 100_000_000e18);

        // STEP 1 : Check initial price without extra checkpoint created
        (uint256 outAmountT0,) = _twapObs.getTwapSinceLastCheckpointNow(inAmount);

        (, int24 tick,,,,,) = _uniV3poolBA.slot0();
        uint256 expectedOutAmountT0 = OracleLibrary.getQuoteAtTick(tick, uint128(inAmount), address(_tokenB), address(_tokenA));

        assertEq(outAmountT0, expectedOutAmountT0, "wrong initial price (T0)");

        // STEP 2: Check current price after a first checkpoint created (but without price action)
        _twapObs.createCheckpoint(block.timestamp);
        (uint256 outAmountT1,) = _twapObs.getTwapSinceLastCheckpointNow(inAmount);

        (, tick,,,,,) = _uniV3poolBA.slot0();
        uint256 expectedOutAmountT1 = OracleLibrary.getQuoteAtTick(tick, uint128(inAmount), address(_tokenB), address(_tokenA));

        assertEq(outAmountT1, expectedOutAmountT1, "wrong price (T1)");

        // STEP 3: Check current price after another checkpoint created a week later (but without price action in between)
        vm.warp(block.timestamp + 1 weeks);

        _twapObs.createCheckpoint(block.timestamp);
        (uint256 outAmountT2,) = _twapObs.getTwapSinceLastCheckpointNow(inAmount);

        (, tick,,,,,) = _uniV3poolBA.slot0();
        uint256 expectedOutAmountT2 = OracleLibrary.getQuoteAtTick(tick, uint128(inAmount), address(_tokenB), address(_tokenA));

        assertEq(outAmountT2, expectedOutAmountT2, "wrong price (T2)");

        // Quoted Amount shall be constant accross all checkpoints :
        assertEq(outAmountT0, outAmountT1, "wrong price (T0 - T1)");
        assertEq(outAmountT0, outAmountT2, "wrong price (T0 - T2)");
    }

    function testTwapUpdate(uint256 deltaTime, uint256 inAmount, bool twapUp) public {
        inAmount = bound(inAmount, 1, 100_000_000e18);
        deltaTime = bound(deltaTime, 1 seconds, 1 days);

        _twapObs.createCheckpoint(block.timestamp);

        vm.warp(block.timestamp + 1);
        (uint256 outAmountT0,) = _twapObs.getTwapSinceLastCheckpointNow(inAmount);

        _createPriceActionSingleHop(twapUp, deltaTime);

        (uint256 outAmountT1,) = _twapObs.getTwapSinceLastCheckpointNow(inAmount);

        if(twapUp) {
            assertGt(outAmountT0, outAmountT1, "twap did not go up");
            console2.log(":: TWAPs :");
            console2.log("::: before UP ONLY     : %d A/B (wei)", outAmountT0);
            console2.log("::: after UP ONLY      : %d A/B (wei)", outAmountT1);
        } else {
            assertLt(outAmountT0, outAmountT1, "twap did not go down");
            console2.log(":: TWAPs :");
            console2.log("::: before DOWN ONLY   : %d A/B (wei)", outAmountT0);
            console2.log("::: after DOWN ONLY    : %d A/B (wei)", outAmountT1);
        }
    }

    function testDebugCurrentDetails(uint256 expectedDuration) public {
        expectedDuration = bound(expectedDuration, 1 seconds, 30 days);

        uint256 lastCheckpointDate = block.timestamp;

        _twapObs.createCheckpoint(lastCheckpointDate);

        (int56[] memory expectLastTickCumulativeBA,) = _uniV3poolBA.observe(new uint32[](1));

        vm.warp(lastCheckpointDate + expectedDuration);

        uint256 expectedCurrentTime = block.timestamp;

        (int56[] memory expectCurrentTickCumulativeBA,) = _uniV3poolBA.observe(new uint32[](1));

        (
            uint256 currentTime,
            uint256 duration,
            int56[] memory currentTickCumulative,
            int56[] memory lastTickCumulative
        ) = _twapObs.debugCurrentDetails();

        assertEq(currentTime, expectedCurrentTime);
        assertEq(duration, expectedDuration);
        assertEq(currentTickCumulative[0], expectCurrentTickCumulativeBA[0]);
        assertEq(lastTickCumulative[0], expectLastTickCumulativeBA[0]);
    }
}
