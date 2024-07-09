// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script, console, console2 } from "forge-std/Script.sol";

import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import {
    ISuperfluid, ISuperToken, ISuperTokenFactory, IERC20Metadata
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { PureSuperToken } from "@superfluid-finance/ethereum-contracts/contracts/tokens/PureSuperToken.sol";

import { getDiscountFactor } from "../src/libs/DiscountFactor.sol";
import { Scaler, getScaler10Pow } from "../src/libs/Scaler.sol";
import { Torex, ITorexController } from "../src/Torex.sol";
import { UniswapV3PoolTwapObserver, ITwapObserver } from "../src/UniswapV3PoolTwapObserver.sol";
import { TorexFactory, createTorexFactory } from "../src/TorexFactory.sol";
import { UnbridledX } from "../src/UnbridledX.sol";
import { SuperBoring, createSuperBoring } from "../src/SuperBoring.sol";
import { EmissionTreasury, createEmissionTreasury } from "../src/BoringPrograms/EmissionTreasury.sol";
import { DistributionFeeManager, createDistributionFeeManager } from "../src/BoringPrograms/DistributionFeeManager.sol";

import {
    DistributorFeeCollector,
    createDistributorFeeCollector
} from "../src/utils/DistributorFeeCollector.sol";
import { FakeLiquidityMover } from "../src/utils/FakeLiquidityMover.sol";


abstract contract DeploymentScriptBase is Script {
    uint256 internal constant CONTROLLER_SAFE_CALLBACK_GAS_LIMIT = 2e6;
    uint256 internal constant MAX_TOREX_FEE_PM = 30_000;    // Maximum 3% fee for the Torex
    uint256 internal constant DEFAULT_TOREX_FEE_PM = 5_000; // Default 0.5% fee
    uint256 internal constant DEFAULT_MINIMUM_STAKING_AMUONT = 1e18; // Default 1 $BORING
    uint256 internal constant DEFAULT_INITIAL_AVG_SUPPLY = 1e6 ether;

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
        string[] memory inputs = new string[](1);
        inputs[0] = "../../tasks/show-git-rev.sh";
        try vm.ffi(inputs) returns (bytes memory res) {
            console.log("Git revision: %s", string(res));
        } catch {
            console.log("!! _showGitRevision: FFI not enabled");
        }
    }
}

/***********************************************************************************************************************
 * Superfluid Extra Contracts (TODO: move some to monorepo)
 **********************************************************************************************************************/

function deployPureSuperToken(ISuperfluid host, string memory name, string memory symbol, uint256 initialSupply)
    returns (ISuperToken pureSuperToken)
{
    ISuperTokenFactory factory = host.getSuperTokenFactory();

    PureSuperToken pureSuperTokenProxy = new PureSuperToken();
    factory.initializeCustomSuperToken(address(pureSuperTokenProxy));
    pureSuperTokenProxy.initialize(name, symbol, initialSupply);

    pureSuperToken = ISuperToken(address(pureSuperTokenProxy));
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

        IUniswapV3Pool uniV3Pool = IUniswapV3Pool(vm.envAddress("TOREX_UNIV3POOL"));
        bool reverseTokensOrder = vm.envOr("TOREX_REVERSE_TOKENS_ORDER", false);

        _startBroadcast();

        UniswapV3PoolTwapObserver obs = new UniswapV3PoolTwapObserver(uniV3Pool, reverseTokensOrder);
        obs.transferOwnership(msg.sender);
        console.log("UniswapV3PoolTwapObserver deployed at %s, with reverse order %d",
                    address(obs), reverseTokensOrder);

        _stopBroadcast();
    }
}

abstract contract TwinTorexDeployer is DeploymentScriptBase {
    function deployTwinTorex(ITorexController controller,
                             function (IUniswapV3Pool, bool, Torex.Config memory)
                             internal returns (Torex) deploy) internal {
        _startBroadcast();

        IUniswapV3Pool uniV3Pool;
        Torex.Config memory config;
        {
            uniV3Pool = IUniswapV3Pool(vm.envAddress("TOREX_UNIV3POOL"));
            ISuperToken superToken0 = ISuperToken(vm.envAddress("TOREX_SUPER_TOKEN0"));
            ISuperToken superToken1 = ISuperToken(vm.envAddress("TOREX_SUPER_TOKEN1"));
            uint32 discountModelTau = uint32(vm.envOr("TOREX_DISCOUNT_TAU", uint32(1 hours)));
            uint32 discountModelEpsilon = uint32(vm.envOr("TOREX_DISCOUNT_EPSILON", uint32(1_0000)));

            // Note: assuming it's an uniswap pool for underlying tokens.
            require(_matchUnderlyingToken(superToken0, uniV3Pool.token0()), "Unmatching super token 0");
            require(_matchUnderlyingToken(superToken1, uniV3Pool.token1()), "Unmatching super token 1");

            console.log("Torex controller is configured to %s", address(controller));

            console.log("Creating twin torexes with:");
            console.log("  Uniswap v3 pool of token0 %s and token1 %s at %s",
                        IERC20Metadata(uniV3Pool.token0()).symbol(),
                        IERC20Metadata(uniV3Pool.token1()).symbol(),
                        address(uniV3Pool));
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
            int8 outTokenDistributionPoolScalerN10Pow = int8(vm.envInt("OUT_TOKEN_POOL_SCALER_N10POW_0"));
            config.outTokenDistributionPoolScaler = getScaler10Pow(outTokenDistributionPoolScalerN10Pow);

            torex = deploy(uniV3Pool, false, config);
            console2.log("  with outTokenDistributionPoolScalerN10Pow", outTokenDistributionPoolScalerN10Pow);
        }
        {
            int8 outTokenDistributionPoolScalerN10Pow = int8(vm.envInt("OUT_TOKEN_POOL_SCALER_N10POW_1"));
            config.outTokenDistributionPoolScaler = getScaler10Pow(outTokenDistributionPoolScalerN10Pow);
            // inverse token pair
            (config.outToken, config.inToken) = (config.inToken, config.outToken);

            torex = deploy(uniV3Pool, true, config);
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
                                           }));
        console2.log("SuperBoring deployed at %s", address(sb));
        console2.log("  with boringToken %s", address(sb.boringToken()));
        console2.log("  with torexFactory %s", address(sb.torexFactory()));
        console2.log("  with emissionTreasury %s", address(sb.emissionTreasury()));
        console2.log("  with distributionFeeManager %s", address(sb.distributionFeeManager()));
        console2.log("  with sleepPodBeacon %s", address(sb.sleepPodBeacon()));
        console2.log("  with inTokenFeePM %d", sb.IN_TOKEN_FEE_PM());
        console2.log("  with minimumStakingAmount %s", sb.MINIMUM_STAKING_AMOUNT());

        sb.initialize(deployer);
        console2.log("SB.owner %s", sb.owner());

        console2.log("Initialize emission treasury's ownership to SuperBoring");
        emissionTreasury.initialize(address(sb));

        console2.log("Initialize distribution fee manager's ownership to SuperBoring");
        distributionFeeManager.initialize(address(sb));

        _stopBroadcast();
    }
}

contract UpgradeSuperBoring is DeploymentScriptBase {
    function run() external {
        _showGitRevision();

        _startBroadcast();

        SuperBoring sb = SuperBoring(vm.envAddress("SB_ADDRESS"));
        // torex factory can be changed, optionally
        TorexFactory torexFactory = TorexFactory(vm.envOr("SB_TOREX_FACTORY", address(sb.torexFactory())));
        if (torexFactory != sb.torexFactory()) {
            console.log("Upgrading to new torex factory %s", address(torexFactory));
        }

        SuperBoring newSBLogic = new SuperBoring(sb.boringToken(),
                                                 torexFactory,
                                                 sb.emissionTreasury(),
                                                 sb.distributionFeeManager(),
                                                 sb.sleepPodBeacon(),
                                                 SuperBoring.Config({
                                                     inTokenFeePM: sb.IN_TOKEN_FEE_PM(),
                                                     minimumStakingAmount: sb.MINIMUM_STAKING_AMOUNT()
                                                 }));
        sb.updateCode(address(newSBLogic));
        console2.log("SuperBoring upgraded at %s", address(sb));
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

    function _deploy(IUniswapV3Pool uniV3Pool, bool inverseOrder, Torex.Config memory config) internal
        returns (Torex torex)
    {
        SuperBoring sb = SuperBoring(vm.envAddress("SB_ADDRESS"));

        console.log("SuperBoring is at %s", address(sb));

        int8 feePoolScalerN10Pow;
        int8 boringPoolScalerN10Pow;
        if (!inverseOrder) {
            feePoolScalerN10Pow = int8(vm.envInt("FEE_POOL_SCALER_N10POW_0"));
            boringPoolScalerN10Pow = int8(vm.envInt("BORING_POOL_SCALER_N10POW_0"));
        } else {
            feePoolScalerN10Pow = int8(vm.envInt("FEE_POOL_SCALER_N10POW_1"));
            boringPoolScalerN10Pow = int8(vm.envInt("BORING_POOL_SCALER_N10POW_1"));
        }

        torex = sb.createUniV3PoolTwapObserverAndTorex(config,
                                                       feePoolScalerN10Pow, boringPoolScalerN10Pow,
                                                       uniV3Pool, inverseOrder);
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

/***********************************************************************************************************************
 * Unbridled X (Stealth Launch)
 **********************************************************************************************************************/

contract DeployUnbridledX is DeploymentScriptBase {
    function run() external {
        _showGitRevision();

        _startBroadcast();

        UnbridledX unbridledX = new UnbridledX();
        console.log("UnbridledX deployed at", address(unbridledX));

        _stopBroadcast();
    }
}

contract DeployUnbridledTwinTorex is TwinTorexDeployer {
    function run() external {
        _showGitRevision();

        deployTwinTorex(UnbridledX(vm.envAddress("UNBRIDLED_X")), _deploy);
    }

    function _deploy(IUniswapV3Pool uniV3Pool, bool inverseOrder, Torex.Config memory config) internal
        returns (Torex torex)
    {
        UnbridledX unbridledX = UnbridledX(vm.envAddress("UNBRIDLED_X"));
        uint256 torexFeePM = vm.envOr("TOREX_FEE_PM", DEFAULT_TOREX_FEE_PM);
        address torexFeeDest = vm.envOr("TOREX_FEE_DEST", msg.sender);
        TorexFactory factory = TorexFactory(vm.envAddress("TOREX_FACTORY"));

        console.log("UnbridledX is at %s", address(unbridledX));
        console.log("Torex factory is at %s", address(factory));

        torex = factory.createUniV3PoolTwapObserverAndTorex(uniV3Pool, inverseOrder, config);
        unbridledX.registerTorex(torex, torexFeePM, torexFeeDest);
        console2.log("Torex created at %s, and registered to UnbridledX", address(torex));
        console2.log("  with TWAP observer %s", address(torex.getConfig().observer));
        console2.log("  and TWAP scaler", Scaler.unwrap(torex.getConfig().twapScaler));
        console2.log("  torex fee to %s at %d per-million", torexFeeDest, uint256(torexFeePM));
    }
}
