/* solhint-disable reentrancy */
pragma solidity ^0.8.26;

import { console2 } from "forge-std/Test.sol";
import { Test } from "forge-std/Test.sol";
import { UniswapV3PoolTwapHoppableObserver, IUniswapV3Pool } from "../src/UniswapV3PoolTwapHoppableObserver.sol";


contract UniswapV3PoolTwapHoppableObserverForkTest is Test {
    // TWAP Observer for USDC/DEGEN multihop pair (USDC/ETH + ETH/DEGEN)
    UniswapV3PoolTwapHoppableObserver internal _twapObs1;

    // TWAP Observer for USDC/BALD multihop pair (USDC/ETH + ETH/BALD)
    UniswapV3PoolTwapHoppableObserver internal _twapObs2;

    // UniswapV3 Pool for ETH/USDC
    IUniswapV3Pool internal constant _USDC_ETH_POOL = IUniswapV3Pool(0xd0b53D9277642d899DF5C87A3966A349A798F224);

    // UniswapV3 Pool ETH/USDC Token Order token0 = ETH / token1 = USDC
    bool internal constant _USDC_ETH_INVERSE_ORDER = true;

    // UniswapV3 Pool for ETH/DEGEN
    IUniswapV3Pool internal constant _ETH_DEGEN_POOL = IUniswapV3Pool(0xc9034c3E7F58003E6ae0C8438e7c8f4598d5ACAA);

    // UniswapV3 Pool ETH/USDC Token Order token0 = ETH / token1 = DEGEN
    bool internal constant _ETH_DEGEN_INVERSE_ORDER = false;

    // UniswapV3 Pool for BALD/ETH
    IUniswapV3Pool internal constant _ETH_BALD_POOL = IUniswapV3Pool(0x9E37cb775a047Ae99FC5A24dDED834127c4180cD);

    // UniswapV3 Pool ETH/USDC Token Order token0 = BALD / token1 = ETH
    bool internal constant _ETH_BALD_INVERSE_ORDER = true;


    // Price Action Trending Up for DEGEN against USDC
    uint256 internal constant _DEGEN_UP_ONLY_START_BLOCK = 12_472_927; // March 28th 2024 - 7 PM | TS : 1711735200
    uint256 internal constant _DEGEN_UP_ONLY_END_BLOCK = 12_544_927; // March 31st 2024 - 12 PM | TS : 1711879200

    // Price Action Trending Down for DEGEN against USDC
    uint256 internal constant _DEGEN_DOWN_ONLY_START_BLOCK = 15_421_327; // June 6th 2024 - 2 AM | TS : 1717632000
    uint256 internal constant _DEGEN_DOWN_ONLY_END_BLOCK = 15_680_527; // June 12th 2024 - 2 AM | TS : 1718150400

    // Price Action Trending Up for BALD against USDC
    uint256 internal constant _BALD_UP_ONLY_START_BLOCK = 16_803_727; // July 8th 2024 - 2 AM | TS : 1720396800
    uint256 internal constant _BALD_UP_ONLY_END_BLOCK = 17_149_327; // July 16th 2024 - 2 AM | TS : 1721088000

    // Price Action Trending Down for BALD against USDC
    uint256 internal constant _BALD_DOWN_ONLY_START_BLOCK = 17_754_127; // July 30th 2024 - 2 AM | TS : 1722297600
    uint256 internal constant _BALD_DOWN_ONLY_END_BLOCK = 18_056_527; // Aug 6th 2024 - 2 AM | TS : 1722902400


    function setUp() public {
        vm.createSelectFork(vm.envString("BASE_ARCHIVE_RPC"), 12_400_000);
        // Deploy USDC-DEGEN TWAP Observer
        UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops1 = new UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[](2);
        hops1[0] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_USDC_ETH_POOL, _USDC_ETH_INVERSE_ORDER);
        hops1[1] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_ETH_DEGEN_POOL, _ETH_DEGEN_INVERSE_ORDER);
        _twapObs1 = new UniswapV3PoolTwapHoppableObserver(hops1);

        // Deploy BALD-USDC TWAP Observer
        UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops2 = new UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[](2);
        hops2[0] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_USDC_ETH_POOL, _USDC_ETH_INVERSE_ORDER);
        hops2[1] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_ETH_BALD_POOL, _ETH_BALD_INVERSE_ORDER);
        _twapObs2 = new UniswapV3PoolTwapHoppableObserver(hops2);

        vm.makePersistent(address(_twapObs1));
        vm.makePersistent(address(_twapObs2));
    }

    function testInvalidHopsConfiguration() public {
        UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops = new UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[](2);
        hops[0] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_USDC_ETH_POOL, _USDC_ETH_INVERSE_ORDER);
        hops[1] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_ETH_DEGEN_POOL, !_ETH_DEGEN_INVERSE_ORDER);

        vm.expectRevert(UniswapV3PoolTwapHoppableObserver.INVALID_HOPS_CONFIG.selector);
        new UniswapV3PoolTwapHoppableObserver(hops);

        hops[0] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_USDC_ETH_POOL, _USDC_ETH_INVERSE_ORDER);
        hops[1] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(_ETH_BALD_POOL, !_ETH_BALD_INVERSE_ORDER);

        vm.expectRevert(UniswapV3PoolTwapHoppableObserver.INVALID_HOPS_CONFIG.selector);
        new UniswapV3PoolTwapHoppableObserver(hops);
    }

    function testUsdcToDegenTWAPUpOnly() public {
        uint256 inAmount = 1e6; // 1 USDC price benchmark

        vm.rollFork(_DEGEN_UP_ONLY_START_BLOCK);
        _twapObs1.createCheckpoint(block.timestamp);

        vm.rollFork(_DEGEN_UP_ONLY_START_BLOCK + 1);
        (uint256 outAmountT0,) = _twapObs1.getTwapSinceLastCheckpointNow(inAmount);

        vm.rollFork(_DEGEN_UP_ONLY_END_BLOCK);
        (uint256 outAmountT1,) = _twapObs1.getTwapSinceLastCheckpointNow(inAmount);

        assertGt(outAmountT0, outAmountT1);

        console2.log(":: TWAPs :");
        console2.log("::: before UP ONLY     : %d DEGEN/USDC (wei)", outAmountT0);
        console2.log("::: after UP ONLY      : %d DEGEN/USDC (wei)", outAmountT1);
    }

    function testUsdcToDegenTWAPDownOnly() public {
        uint256 inAmount = 1e6; // 1 USDC price benchmark

        vm.rollFork(_DEGEN_DOWN_ONLY_START_BLOCK);
        _twapObs1.createCheckpoint(block.timestamp);

        vm.rollFork(_DEGEN_DOWN_ONLY_START_BLOCK + 1);
        (uint256 outAmountT0,) = _twapObs1.getTwapSinceLastCheckpointNow(inAmount);

        vm.rollFork(_DEGEN_DOWN_ONLY_END_BLOCK);
        (uint256 outAmountT1,) = _twapObs1.getTwapSinceLastCheckpointNow(inAmount);

        assertLt(outAmountT0, outAmountT1);

        console2.log(":: TWAPs :");
        console2.log("::: before DOWN ONLY   : %d DEGEN/USDC (wei)", outAmountT0);
        console2.log("::: after DOWN ONLY    : %d DEGEN/USDC (wei)", outAmountT1);
    }

    function testUsdcToBaldTWAPUpOnly() public {
        uint256 inAmount = 1e6; // 1 USDC price benchmark

        vm.rollFork(_BALD_UP_ONLY_START_BLOCK);
        _twapObs2.createCheckpoint(block.timestamp);

        vm.rollFork(_BALD_UP_ONLY_START_BLOCK + 1);
        (uint256 outAmountT0,) = _twapObs2.getTwapSinceLastCheckpointNow(inAmount);

        vm.rollFork(_BALD_UP_ONLY_END_BLOCK);
        (uint256 outAmountT1,) = _twapObs2.getTwapSinceLastCheckpointNow(inAmount);

        assertGt(outAmountT0, outAmountT1);

        console2.log(":: TWAPs :");
        console2.log("::: before UP ONLY     : %d BALD/USDC (wei)", outAmountT0);
        console2.log("::: after UP ONLY      : %d BALD/USDC (wei)", outAmountT1);
    }

        function testUsdcToBaldTWAPDownOnly() public {
        uint256 inAmount = 1e6; // 1 USDC price benchmark

        vm.rollFork(_BALD_DOWN_ONLY_START_BLOCK);
        _twapObs2.createCheckpoint(block.timestamp);

        vm.rollFork(_BALD_DOWN_ONLY_START_BLOCK + 1);
        (uint256 outAmountT0,) = _twapObs2.getTwapSinceLastCheckpointNow(inAmount);

        vm.rollFork(_BALD_DOWN_ONLY_END_BLOCK);
        (uint256 outAmountT1,) = _twapObs2.getTwapSinceLastCheckpointNow(inAmount);

        assertLt(outAmountT0, outAmountT1);

        console2.log(":: TWAPs :");
        console2.log("::: before DOWN ONLY   : %d BALD/USDC (wei)", outAmountT0);
        console2.log("::: after DOWN ONLY    : %d BALD/USDC (wei)", outAmountT1);
    }

    function testGetTypeId() public {
        bytes32 expectedTypeId = keccak256("UniswapV3PoolTwapHoppableObserver");
        assertEq(_twapObs1.getTypeId(), expectedTypeId);
    }
}
