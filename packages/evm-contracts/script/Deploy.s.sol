// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script, console, console2 } from "forge-std/Script.sol";

import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import {
    ISuperfluid, ISuperToken, IERC20Metadata
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { getDiscountFactor } from "../src/libs/DiscountFactor.sol";
import { Scaler, getScaler10Pow } from "../src/libs/Scaler.sol";
import { deployPureSuperToken } from "../src/libs/SuperTokenExtra.sol";

import { Torex, ITorexController } from "../src/Torex.sol";
import { UniswapV3PoolTwapHoppableObserver, ITwapObserver } from "../src/UniswapV3PoolTwapHoppableObserver.sol";
import { TorexFactory, createTorexFactory } from "../src/TorexFactory.sol";
import {
    SuperBoring, SleepPod,
    createSuperBoring,
    createSleepPodLogic, createEmissionTreasuryLogic, createDistributionFeeManagerLogic
} from "../src/SuperBoring.sol";
import { EmissionTreasury, createEmissionTreasury } from "../src/BoringPrograms/EmissionTreasury.sol";
import { DistributionFeeManager, createDistributionFeeManager } from "../src/BoringPrograms/DistributionFeeManager.sol";

import {
    DistributorFeeCollector,
    createDistributorFeeCollector
} from "../src/utils/DistributorFeeCollector.sol";
import { FakeLiquidityMover } from "../src/utils/FakeLiquidityMover.sol";


abstract contract DeploymentScriptBase is Script {
    uint256 internal constant CONTROLLER_SAFE_CALLBACK_GAS_LIMIT = 3e6;
    uint256 internal constant MAX_TOREX_FEE_PM = 30_000;                // Maximum 3% fee for the Torex
    uint256 internal constant DEFAULT_TOREX_FEE_PM = 5_000;             // Default 0.5% fee
    uint256 internal constant DEFAULT_MINIMUM_STAKING_AMUONT = 1e18;    // Default 1 $BORING
    uint256 internal constant DEFAULT_INITIAL_AVG_SUPPLY = 1e6 ether;
    uint8 internal constant MAX_HOPS = 4;


    function _startBroadcast() internal returns (address deployer) {
        uint256 deployerPrivKey = vm.envOr("PRIVKEY", uint256(0));

        // Setup deployment account, using private key from environment variable or foundry keystore (`cast wallet`).
        if (deployerPrivKey != 0) {
            vm.startBroadcast(deployerPrivKey);
        } else {
            vm.startBroadcast();
        }

        // This is the way to get deployer address in foundry:
        (,deployer,) = vm.readCallers();
        console2.log("Deployer address", deployer);
    }

    function _stopBroadcast() internal {
        vm.stopBroadcast();
    }

    function _showGitRevision() internal {
        string[] memory inputs = new string[](2);
        inputs[0] = "../../tasks/show-git-rev.sh";
        inputs[1] = "forge_ffi_mode";
        try vm.ffi(inputs) returns (bytes memory res) {
            console.log("Git revision: %s", string(res));
        } catch {
            console.log("!! _showGitRevision: FFI not enabled");
        }
    }
}

contract DeployPureSuperToken is DeploymentScriptBase {
    function run() external {
        _showGitRevision();

        _startBroadcast();

        ISuperfluid host = ISuperfluid(vm.envAddress("SUPERFLUID_HOST"));

        // deploy reward token
        ISuperToken sbToken = deployPureSuperToken(host,
                                                   vm.envString("SB_TOKEN_NAME"),
                                                   vm.envString("SB_TOKEN_SYMBOL"),
                                                   vm.envUint("SB_TOKEN_INITIAL_SUPPLY"));
        console2.log("SuperBoring token deployed at %s", address(sbToken));
        console2.log("  name %s", sbToken.name());
        console2.log("  symbol %s", sbToken.symbol());
        console2.log("  total supply %d", sbToken.totalSupply());

        _stopBroadcast();
    }
}

/***********************************************************************************************************************
 * TOREX Contracts
 **********************************************************************************************************************/

contract DeployTorexFactory is DeploymentScriptBase {
    function run() external {
        _showGitRevision();

        _startBroadcast();

        TorexFactory factory = createTorexFactory();
        console.log("TorexFactory deployed at", address(factory));

        _stopBroadcast();
    }
}

contract UniswapV3PoolTwapObserverDeployer is DeploymentScriptBase {
    function run() external {
        _showGitRevision();

        IUniswapV3Pool[] memory pools = new IUniswapV3Pool[](MAX_HOPS);
        bool[] memory poolsOrderReversed = new bool[](MAX_HOPS);

        // TOREX_UNIV3POOL_${index} env vars must be filled sequentially
        //      i.e. : var0 = ETH/USDC - var1 = ETH/DEGEN
        //      if var0 = ETH/USDC - var1 = address(0) - var2 = ETH/DEGEN :
        //      then the second hop (ETH/DEGEN) will be ignored resulting in a simple hop observer (ETH/USDC)
        pools[0] = IUniswapV3Pool(vm.envOr("TOREX_UNIV3POOL_0", address(0)));
        pools[1] = IUniswapV3Pool(vm.envOr("TOREX_UNIV3POOL_1", address(0)));
        pools[2] = IUniswapV3Pool(vm.envOr("TOREX_UNIV3POOL_2", address(0)));
        pools[3] = IUniswapV3Pool(vm.envOr("TOREX_UNIV3POOL_3", address(0)));

        poolsOrderReversed[0] = vm.envOr("TOREX_REVERSE_TOKENS_ORDER_0", false);
        poolsOrderReversed[1] = vm.envOr("TOREX_REVERSE_TOKENS_ORDER_1", false);
        poolsOrderReversed[2] = vm.envOr("TOREX_REVERSE_TOKENS_ORDER_2", false);
        poolsOrderReversed[3] = vm.envOr("TOREX_REVERSE_TOKENS_ORDER_3", false);

        uint8 poolCount;

        for(uint8 i = 0; i < MAX_HOPS; ++i) {
            if(address(pools[i]) != address(0)) poolCount++;
            else i = MAX_HOPS;
        }

        UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops = new UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[](poolCount);

        for(uint8 i = 0; i < poolCount; ++i) {
            hops[i] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(pools[i], poolsOrderReversed[i]);
        }

        _startBroadcast();

        UniswapV3PoolTwapHoppableObserver obs = new UniswapV3PoolTwapHoppableObserver(hops);
        obs.transferOwnership(msg.sender);
        console.log("UniswapV3PoolTwapHoppableObserver deployed at %s, with %d hops",
                    address(obs), poolCount);

        _stopBroadcast();
    }
}

abstract contract TwinTorexDeployer is DeploymentScriptBase {
    function deployTwinTorex(ITorexController controller,
                             function (int8 /* feePoolScalerN10Pow */, int8 /* boringPoolScalerN10Pow */,
                                       UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory,
                                       Torex.Config memory) internal returns (Torex) deploy
                            ) internal {
        _startBroadcast();

        IUniswapV3Pool[] memory pools = new IUniswapV3Pool[](MAX_HOPS);
        bool[] memory poolsOrderReversed = new bool[](MAX_HOPS);

        pools[0] = IUniswapV3Pool(vm.envAddress("TOREX_UNIV3POOL_0"));
        pools[1] = IUniswapV3Pool(vm.envOr("TOREX_UNIV3POOL_1", address(0)));
        pools[2] = IUniswapV3Pool(vm.envOr("TOREX_UNIV3POOL_2", address(0)));
        pools[3] = IUniswapV3Pool(vm.envOr("TOREX_UNIV3POOL_3", address(0)));
        poolsOrderReversed[0] = vm.envOr("TOREX_REVERSE_TOKENS_ORDER_0", false);
        poolsOrderReversed[1] = vm.envOr("TOREX_REVERSE_TOKENS_ORDER_1", false);
        poolsOrderReversed[2] = vm.envOr("TOREX_REVERSE_TOKENS_ORDER_2", false);
        poolsOrderReversed[3] = vm.envOr("TOREX_REVERSE_TOKENS_ORDER_3", false);

        uint8 poolCount;

        for(uint8 i = 0; i < MAX_HOPS; ++i) {
            if (address(pools[i]) != address(0)) poolCount++;
            else i = MAX_HOPS;
        }

        Torex.Config memory config;
        {
            ISuperToken superToken0 = ISuperToken(vm.envAddress("TOREX_SUPER_TOKEN0"));
            ISuperToken superToken1 = ISuperToken(vm.envAddress("TOREX_SUPER_TOKEN1"));
            uint32 discountModelTau = uint32(vm.envOr("TOREX_DISCOUNT_TAU", uint32(1 hours)));
            uint32 discountModelEpsilon = uint32(vm.envOr("TOREX_DISCOUNT_EPSILON", uint32(1_0000)));

            // Note: assuming it's an uniswap pool for underlying tokens.
            address inTokenUnderlying = poolsOrderReversed[0] ?
                pools[0].token1() : pools[0].token0();
            require(_matchUnderlyingToken(superToken0, inTokenUnderlying), "Unmatching super token 0");

            address outTokenUnderlying = poolsOrderReversed[poolCount - 1] ?
                pools[poolCount - 1].token0() : pools[poolCount - 1].token1();
            require(_matchUnderlyingToken(superToken1, outTokenUnderlying), "Unmatching super token 1");

            console.log("Torex controller is configured to %s", address(controller));

            console.log("Creating twin torexes with:");

            if(poolCount > 1) {
                console.log("  multi hop observer : ");
                for(uint256 i = 0; i < poolCount; ++i) {
                    console.log("    Pool %d :", i);
                    console.log("      Uniswap v3 pool of token0 %s and token1 %s at %s",
                                IERC20Metadata(pools[i].token0()).symbol(),
                                IERC20Metadata(pools[i].token1()).symbol(),
                                address(pools[i]));

                    if(!poolsOrderReversed[i]) {
                        console.log("      Trade Direction : %s -> %s",
                                    IERC20Metadata(pools[i].token0()).symbol(),
                                    IERC20Metadata(pools[i].token1()).symbol());
                    } else {
                        console.log("      Trade Direction : %s -> %s",
                                    IERC20Metadata(pools[i].token1()).symbol(),
                                    IERC20Metadata(pools[i].token0()).symbol());
                    }
                }
            } else {
                console.log("  single hop observer : ");
                console.log("    Uniswap v3 pool of token0 %s and token1 %s at %s",
                            IERC20Metadata(pools[0].token0()).symbol(),
                            IERC20Metadata(pools[0].token1()).symbol(),
                            address(pools[0]));
                if(!poolsOrderReversed[0]) {
                    console.log("      Trade Direction : %s -> %s",
                                IERC20Metadata(pools[0].token0()).symbol(),
                                IERC20Metadata(pools[0].token1()).symbol());
                } else {
                    console.log("      Trade Direction : %s -> %s",
                                IERC20Metadata(pools[0].token1()).symbol(),
                                IERC20Metadata(pools[0].token0()).symbol());
                }
            }

            console.log("  in-token  %s at %s", superToken0.symbol(), address(superToken0));
            console.log("  out-token %s at %s",  superToken1.symbol(), address(superToken1));
            console2.log(unicode"  discount model with τ (seconds) %d ε %d (per-million)",
                         discountModelTau, discountModelEpsilon);

            config = Torex.Config({
                inToken: superToken0,
                outToken: superToken1,
                observer: ITwapObserver(address(0)), // unitialized for createUniV3PoolTwapObserverAndTorex
                twapScaler: Scaler.wrap(0), // unitialized for createUniV3PoolTwapObserverAndTorex
                discountFactor: getDiscountFactor(discountModelTau, discountModelEpsilon),
                outTokenDistributionPoolScaler: Scaler.wrap(0), // to be filled later
                controller: controller,
                controllerSafeCallbackGasLimit: CONTROLLER_SAFE_CALLBACK_GAS_LIMIT,
                maxAllowedFeePM: MAX_TOREX_FEE_PM
                });
        }

        Torex torex;
        {
            int8 feePoolScalerN10Pow = int8(vm.envInt("FEE_POOL_SCALER_N10POW_0"));
            int8 boringPoolScalerN10Pow = int8(vm.envInt("BORING_POOL_SCALER_N10POW_0"));
            int8 outTokenDistributionPoolScalerN10Pow = int8(vm.envInt("OUT_TOKEN_POOL_SCALER_N10POW_0"));

            config.outTokenDistributionPoolScaler = getScaler10Pow(outTokenDistributionPoolScalerN10Pow);

            UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops =
                new UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[](poolCount);

            for(uint8 i = 0; i < poolCount; ++i) {
                hops[i] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop(pools[i], poolsOrderReversed[i]);
            }

            torex = deploy(feePoolScalerN10Pow, boringPoolScalerN10Pow, hops, config);
            console2.log("  with outTokenDistributionPoolScalerN10Pow", outTokenDistributionPoolScalerN10Pow);
        }
        {
            int8 feePoolScalerN10Pow = int8(vm.envInt("FEE_POOL_SCALER_N10POW_1"));
            int8 boringPoolScalerN10Pow = int8(vm.envInt("BORING_POOL_SCALER_N10POW_1"));
            int8 outTokenDistributionPoolScalerN10Pow = int8(vm.envInt("OUT_TOKEN_POOL_SCALER_N10POW_1"));

            config.outTokenDistributionPoolScaler = getScaler10Pow(outTokenDistributionPoolScalerN10Pow);

            // inverse token pair
            (config.outToken, config.inToken) = (config.inToken, config.outToken);

            UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops =
               new UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[](poolCount);

            for(uint8 i = 0; i < poolCount; ++i) {
                hops[i] = UniswapV3PoolTwapHoppableObserver.UniV3PoolHop
                    (pools[poolCount - 1 - i], !poolsOrderReversed[poolCount - 1 - i]);
            }

            torex = deploy(feePoolScalerN10Pow, boringPoolScalerN10Pow, hops, config);
            console2.log("  with outTokenDistributionPoolScalerN10Pow", outTokenDistributionPoolScalerN10Pow);
        }

        _stopBroadcast();
    }

    function _matchUnderlyingToken(ISuperToken superToken, address underlyingToken) internal view returns (bool) {
        if (superToken.getUnderlyingToken() != address(0)) {
            return underlyingToken == superToken.getUnderlyingToken();
        } else {
            string memory underlyingSymbol = IERC20Metadata(underlyingToken).symbol();
            if (Strings.equal(underlyingSymbol, "WETH")) {
                console.log("Super token %s is a WETH native super token", superToken.symbol());
                return true;
            }
            if (Strings.equal(underlyingSymbol, "CELO")) {
                console.log("Super token %s is a CELO native super token", superToken.symbol());
                return true;
            }
            return false;
        }
    }
}

/***********************************************************************************************************************
 * Super Boring Contracts
 **********************************************************************************************************************/

contract DeployEmissionTreasury is DeploymentScriptBase {
    function run() external {
        _showGitRevision();

        _startBroadcast();

        ISuperToken token = ISuperToken(vm.envAddress("SB_TOKEN_ADDRESS"));
        EmissionTreasury treasury = createEmissionTreasury(token);
        console2.log("EmissionTreasury deployed at %s", address(treasury));
        console2.log("  with token %s", address(token));

        _stopBroadcast();
    }
}

contract DeployDistributionFeeManager is DeploymentScriptBase {
    function run() external {
        _showGitRevision();

        _startBroadcast();

        DistributionFeeManager manager = createDistributionFeeManager();
        console2.log("DistributionFeeManager deployed at %s", address(manager));

        _stopBroadcast();
    }
}

contract DeploySuperBoring is DeploymentScriptBase {
    function run() external {
        _showGitRevision();

        address deployer = _startBroadcast();

        ISuperToken token = ISuperToken(vm.envAddress("SB_TOKEN_ADDRESS"));
        TorexFactory torexFactory = TorexFactory(vm.envAddress("SB_TOREX_FACTORY"));
        EmissionTreasury emissionTreasury = EmissionTreasury(vm.envAddress("SB_EMISSION_TREASURY"));
        DistributionFeeManager distributionFeeManager =
            DistributionFeeManager(vm.envAddress("SB_DISTRIBUTION_FEE_MANAGER"));
        uint256 inTokenFeePM = vm.envOr("SB_IN_TOKEN_FEE_PM", DEFAULT_TOREX_FEE_PM);
        uint256 minimumStakingAmount = vm.envOr("SB_MINIMUM_STAKING_AMOUNT", DEFAULT_MINIMUM_STAKING_AMUONT);

        SuperBoring sb = createSuperBoring(token,
                                           torexFactory,
                                           emissionTreasury,
                                           distributionFeeManager,
                                           SuperBoring.Config({
                                               inTokenFeePM: inTokenFeePM,
                                               minimumStakingAmount: minimumStakingAmount
                                           }),
                                           deployer /* sb owner */);
        console2.log("SuperBoring deployed at %s", address(sb));
        console2.log("  with boringToken %s", address(sb.boringToken()));
        console2.log("  with torexFactory %s", address(sb.torexFactory()));
        console2.log("  with emissionTreasury %s", address(sb.emissionTreasury()));
        console2.log("  with distributionFeeManager %s", address(sb.distributionFeeManager()));
        console2.log("  with sleepPodBeacon %s", address(sb.sleepPodBeacon()));
        console2.log("  with inTokenFeePM %d", sb.IN_TOKEN_FEE_PM());
        console2.log("  with minimumStakingAmount %s", sb.MINIMUM_STAKING_AMOUNT());
        console2.log("  with owner %s", sb.owner());

        _stopBroadcast();
    }
}

contract UpgradeSuperBoring is DeploymentScriptBase {
    function run() external {
        _showGitRevision();

        _startBroadcast();

        SuperBoring sb = SuperBoring(vm.envAddress("SB_ADDRESS"));

        SuperBoring newSBLogic;
        SleepPod newSleepPodLogic;
        EmissionTreasury newEmissionTreasuryLogic;
        DistributionFeeManager newDistributionFeeManagerLogic;

        if (vm.envOr("SB_DO_UPGRADE_SB_LOGIC", false)) {
            TorexFactory torexFactory = TorexFactory(vm.envOr("SB_TOREX_FACTORY", address(sb.torexFactory())));
            if (torexFactory != sb.torexFactory()) {
                console.log("Upgrading to new torex factory %s", address(torexFactory));
            }

            newSBLogic = new SuperBoring(sb.boringToken(),
                                         torexFactory,
                                         sb.emissionTreasury(),
                                         sb.distributionFeeManager(),
                                         sb.sleepPodBeacon(),
                                         SuperBoring.Config({
                                             inTokenFeePM: sb.IN_TOKEN_FEE_PM(),
                                             minimumStakingAmount: sb.MINIMUM_STAKING_AMOUNT()
                                         }));
            console2.log("Using new SuperBoring logic %s", address(newSBLogic));
        }
        if (vm.envOr("SB_DO_UPGRADE_SLEEP_POD_LOGIC", false)) {
            newSleepPodLogic = createSleepPodLogic(sb);
            console2.log("Using new SleepPod logic %s", address(newSleepPodLogic));
        }
        if (vm.envOr("SB_DO_UPGRADE_EMISSION_TREASURY_LOGIC", false)) {
            newEmissionTreasuryLogic = createEmissionTreasuryLogic(sb);
            console2.log("Using new EmissionTreasury logic %s", address(newEmissionTreasuryLogic));
        }
        if (vm.envOr("SB_DO_UPGRADE_DISTRIBUTION_FEE_MANAGER_LOGIC", false)) {
            newDistributionFeeManagerLogic = createDistributionFeeManagerLogic(sb);
            console2.log("Using new DistributionFeeManager logic %s", address(newDistributionFeeManagerLogic));
        }

        // NOTE: you may need to use updateCode if this function signature changes.
        sb.govUpdateLogic(newSBLogic, newSleepPodLogic, newEmissionTreasuryLogic, newDistributionFeeManagerLogic);
        console2.log("SuperBoring upgraded at %s", address(sb));
        console2.log("  with code logic %s", sb.getCodeAddress());
        console2.log("  with token %s", address(sb.boringToken()));
        console2.log("  with torexFactory %s", address(sb.torexFactory()));
        console2.log("  with emissionTreasury %s", address(sb.emissionTreasury()));
        console2.log("  with distributionFeeManager %s", address(sb.distributionFeeManager()));
        console2.log("  with sleepPodBeacon %s", address(sb.sleepPodBeacon()));
        console2.log("  with inTokenFeePM %d", sb.IN_TOKEN_FEE_PM());
        console2.log("  with minimumStakingAmount %s", sb.MINIMUM_STAKING_AMOUNT());

        _stopBroadcast();
    }
}

contract DeploySuperBoringTwinTorex is TwinTorexDeployer {
    function run() external {
        _showGitRevision();
        deployTwinTorex(ITorexController(address(0)) /* to be set by SB directly */, _deploy);
    }

    function _deploy(int8 feePoolScalerN10Pow, int8 boringPoolScalerN10Pow,
                     UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops,
                     Torex.Config memory config) internal
        returns (Torex torex)
    {
        SuperBoring sb = SuperBoring(vm.envAddress("SB_ADDRESS"));
        console.log("SuperBoring is at %s", address(sb));

        torex = sb.createUniV3PoolTwapObserverAndTorex(config,
                                                       feePoolScalerN10Pow, boringPoolScalerN10Pow,
                                                       hops);
        console2.log("Torex created at %s by SuperBoring", address(torex));
        console2.log("  feePoolScalerN10Pow", feePoolScalerN10Pow);
        console2.log("  boringPoolScalerN10Pow", boringPoolScalerN10Pow);
        console2.log("  with TWAP observer %s", address(torex.getConfig().observer));
        console2.log("  and TWAP scaler", Scaler.unwrap(torex.getConfig().twapScaler));
    }
}

/***********************************************************************************************************************
 * Peripherals
 **********************************************************************************************************************/

contract DeployDistributorFeeCollector is DeploymentScriptBase {
    function run() external {
        _showGitRevision();

        SuperBoring sb = SuperBoring(vm.envAddress("SB_ADDRESS"));
        console.log("Using SuperBoring at %s", address(sb));

        address deployer = _startBroadcast();

        DistributorFeeCollector c = createDistributorFeeCollector(sb.distributionFeeManager(), deployer);
        console.log("DistributorFeeCollector created at %s, with", address(c));
        console.log("  owner %s", c.owner());
        console.log("  manager %s", address(c.manager()));

        _stopBroadcast();
    }
}

contract FakeLiquidityMoverDeployer is DeploymentScriptBase {
    function run() external {
        _showGitRevision();

        _startBroadcast();

        FakeLiquidityMover flm = new FakeLiquidityMover();
        console.log("FakeLiquidityMover deployed at", address(flm));

        _stopBroadcast();
    }
}
