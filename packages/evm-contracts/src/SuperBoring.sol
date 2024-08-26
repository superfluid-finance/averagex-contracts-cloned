// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { UUPSProxiable } from "@superfluid-finance/ethereum-contracts/contracts/upgradability/UUPSProxiable.sol";
import { UUPSProxy } from "@superfluid-finance/ethereum-contracts/contracts/upgradability/UUPSProxy.sol";
import {
    ISuperfluidPool, ISuperToken
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

import { toInt96, INT_100PCT_PM } from "./libs/MathExtra.sol";
import { Scaler } from "./libs/Scaler.sol";

import { ITorexController, ITorex, LiquidityMoveResult, TorexMetadata } from "./interfaces/torex/ITorex.sol";
import { Torex } from "./Torex.sol";
import { TorexFactory } from "./TorexFactory.sol";
import { UniswapV3PoolTwapHoppableObserver } from "./UniswapV3PoolTwapHoppableObserver.sol";

import { BasicStakingTIP } from "./BoringPrograms/BasicStakingTIP.sol";
import { SleepPod, createSleepPodBeacon } from "./BoringPrograms/SleepPod.sol";
import { InitialStakingTIP } from "./BoringPrograms/InitialStakingTIP.sol";
import { QuadraticEmissionTIP, EmissionTreasury } from "./BoringPrograms/QuadraticEmissionTIP.sol";
import { DistributionFeeManager, IDistributorStatsProvider } from "./BoringPrograms/DistributionFeeManager.sol";
import { DistributionFeeDIP } from "./BoringPrograms/DistributionFeeDIP.sol";


/**
 * @dev The super boring way of controlling TOREXes and managing $BORING token emissions.
 *
 * TODOs:
 *
 * - [ ] MathExtra: safeSubNoThrow
 *
 * # Stats
 *
 * - Total BORING staked, currently
 *   - why: as a degen, knowing how QE works, I'd like to know which TOREX has more BORING staked.
 *   - unit: amount of BORING.
 *   - how: rpc call `sb.getTotalStakedAmount` over each torex.
 * - Total Monthly DCA Volume
 *   - why: it is good to know. Also, as a trader, investing in a slow market may mean paying higher premium, which is
 *     something to be avoided.
 *   - unit: in-tokens flow rate / s
 *   - how:
 *     1. based on the flow rate from a direct rpc query of in-token flow rate to the torex.
 *     2. Or, sb.getTotalityStats(torex).distributedVolume.
 * - Total Monthly Staking Revenue
 *   - why: as a degen, I'd like to put BORING into work, this is the most direct metric.
 *   - unit: in-tokens flow rate (per norminal BORING)
 *   - how: rpc call `distribution flow rate from torex.feeDistributionPool() / sb.getTotalStakedAmount()` , and maybe
 *     normalize with the market price of in-tokens.
 * - Total Monthly BORING reward
 *   - why: as a degen, I'd like to put my assets into work (earn BORING), this is the most direct metric.
 *   - unit: BORING, per in-token (or preferably its dollar value) traded
 *   - how: rpc call `sb.emissionTreasury().getEmissionRate(torex)`.
 * - Total $BORING emitted
 *   - May require superfluid protocol subgraph.
 * - Total $BORING flow-rate
 *   - Out flow rate of the emission treasury.
 */
contract SuperBoring is UUPSProxiable, Ownable, ITorexController, IDistributorStatsProvider {
    using SuperTokenV1Library for ISuperToken;
    using EnumerableSet for EnumerableSet.AddressSet;

    /*******************************************************************************************************************
     * Definitions
     ******************************************************************************************************************/

    error ONLY_REGISTERED_TOREX_ALLOWED();

    error NO_SELF_REFERRAL();

    error MINIMUM_STAKING_AMOUNT_REQUIRED();

    event TorexCreated(ITorex indexed torex);

    event StakeUpdated(ITorex indexed torex, address indexed staker, uint256 newStakedAmount);

    /*******************************************************************************************************************
     * Configurations and Constructor
     ******************************************************************************************************************/

    struct Config {
        uint256 inTokenFeePM;
        uint256 minimumStakingAmount;
    }

    /// In token fee (per-million) for all torexes. It may change in the future; however, the changes will not
    /// grandfather for the existing trading streams.
    uint256 public immutable IN_TOKEN_FEE_PM;

    /// Minimum amount of boring token required for a staking position.
    uint256 public immutable MINIMUM_STAKING_AMOUNT;

    // References to contracts used in SuperBoring. Deployment script must stick to the same addresses over time.

    ISuperToken            public immutable boringToken;
    TorexFactory           public immutable torexFactory;
    EmissionTreasury       public immutable emissionTreasury;
    DistributionFeeManager public immutable distributionFeeManager;
    UpgradeableBeacon      public immutable sleepPodBeacon;

    constructor(ISuperToken boringToken_,
                TorexFactory tokenFactory_,
                EmissionTreasury emissionTreasury_,
                DistributionFeeManager distributionFeeManager_,
                UpgradeableBeacon sleepPodBeacon_,
                Config memory config) {
        boringToken = boringToken_;
        torexFactory = tokenFactory_;
        emissionTreasury = emissionTreasury_;
        distributionFeeManager = distributionFeeManager_;
        sleepPodBeacon = sleepPodBeacon_;

        IN_TOKEN_FEE_PM = config.inTokenFeePM;
        MINIMUM_STAKING_AMOUNT = config.minimumStakingAmount;
    }

    /*******************************************************************************************************************
     * Torex Registry
     ******************************************************************************************************************/

    function _getTorexRegistryStorage() private pure returns (EnumerableSet.AddressSet storage $) {
        // keccak256(abi.encode(uint256(keccak256("superboring.storage.TorexRegistry")) - 1)) & ~bytes32(uint256(0xff))
        // solhint-disable-next-line no-inline-assembly
        assembly { $.slot := 0x01603e9cd1cafd885aa5441258b1dc77a568f9d11d8d10b8fd2b5b73cf4b3300 }
    }

    modifier onlyRegisteredTorex(address torex) {
        EnumerableSet.AddressSet storage $ = _getTorexRegistryStorage();
        if (!$.contains(torex)) revert ONLY_REGISTERED_TOREX_ALLOWED();
        _;
    }

    /// List publicly registered torexes. This supports simple range queries through skip and first parameters.
    function getAllTorexesMetadata(uint256 skip, uint256 first) public view
        returns (TorexMetadata[] memory metadataList)
    {
        EnumerableSet.AddressSet storage $ = _getTorexRegistryStorage();

        uint256 nTorex = $.length();
        metadataList = new TorexMetadata[](nTorex);
        for ((uint256 i, uint256 j) = (skip, 0); i < nTorex && j < first; (i++, j++)) {
            ITorex torex = ITorex($.at(i));
            metadataList[i].torexAddr = address(torex);
            (metadataList[i].inToken, metadataList[i].outToken)  = torex.getPairedTokens();
        }
    }

    /// A backward compatible parameter-less getAllTorexesMetadata which hardcodes a query range.
    function getAllTorexesMetadata() external view
        returns (TorexMetadata[] memory metadataList)
    {
        return getAllTorexesMetadata(0, 100);
    }

    /**
     * @dev Create a torex with an optional uniswap pool provided as its TWAP price oracle.
     * @param torexConfig Configuration for the torex.
     * @param feePoolScalerN10Pow Fee pool scaler set to 10**x
     * @param boringPoolScalerN10Pow Boring pool scaler set to 10**x
     * @param hops Uniswap V3 pools to Torex mapping configuration
     */
    function createUniV3PoolTwapObserverAndTorex(Torex.Config calldata torexConfig,
                                                 int8 feePoolScalerN10Pow, int8 boringPoolScalerN10Pow,
                                                 UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] calldata hops
                                                ) external
        returns (Torex torex)
    {
        EnumerableSet.AddressSet storage $ = _getTorexRegistryStorage();

        assert(address(torexConfig.controller) == address(0)); // leave it to us
        // Note: torexConfig.controller will be set to `this` by torexFactory logic
        if (hops.length == 0) {
            torex = torexFactory.createTorex(torexConfig);
        } else {
            torex = torexFactory.createUniV3PoolTwapObserverAndTorex(hops, torexConfig);
        }

        $.add(address(torex));
        emit TorexCreated(torex);

        BasicStakingTIP.setFeePoolScaler(torex, feePoolScalerN10Pow);
        QuadraticEmissionTIP.setBoringPoolScaler(torex, boringPoolScalerN10Pow);
    }

    /*******************************************************************************************************************
     * Torex Controller Implementation
     ******************************************************************************************************************/

    // @inheritdoc ITorexController
    function getTypeId() external pure override returns (bytes32) { return proxiableUUID(); }

    /// The user data struct user must pass to in flow creations and updates. It is equivalent to (address, address).
    struct InFlowUserData {
        address distributor;
        address referrer;
    }

    // workaround for stack too deep for onInFlowChanged
    struct VarsOnInFlowChanged {
        address traderPod;
        address distributor;
        address referrerPod;
    }

    // @inheritdoc ITorexController
    function onInFlowChanged(address trader,
                             int96 prevFlowRate, int96 /*preFeeFlowRate*/, uint256 /*last Updated*/,
                             int96 newFlowRate, uint256 /*now*/,
                             bytes calldata userDataRaw) external override
        onlyRegisteredTorex(msg.sender)
        returns (int96 newFeeFlowRate)
    {
        VarsOnInFlowChanged memory vars;

        vars.traderPod = address(InitialStakingTIP.getOrCreateSleepPod(sleepPodBeacon, trader));

        // Unless deleting a flow, we expect an optional (distributor, referrer) is provided through the userData.
        // When deleting the flow (newFlowRate == 0), distributor and referrer are reset to NONE.
        if (newFlowRate > 0) {
            // - userData is optional.
            // - when provided, its schema: (address distributor, address referrer)
            if (userDataRaw.length > 0) {
                // This may revert, and it will make create/update flow fail.
                InFlowUserData memory userData = abi.decode(userDataRaw, (InFlowUserData));

                if (trader == userData.referrer) revert NO_SELF_REFERRAL();
                require(DistributionFeeDIP.isValidDistributor(userData.distributor), "invalid distributor");

                vars.distributor = userData.distributor;
                if (userData.referrer != address(0)) {
                    vars.referrerPod = address(InitialStakingTIP.getOrCreateSleepPod(sleepPodBeacon,
                                                                                     userData.referrer));
                }
            } else {
                // during update flow, we keep same distributor and referrerPod
                if (prevFlowRate > 0) {
                    vars.distributor = DistributionFeeDIP.getCurrentDistributor(ITorex(msg.sender), trader);
                    vars.referrerPod = QuadraticEmissionTIP.getCurrentReferrerPod(ITorex(msg.sender), trader);
                }
            }
        }

        // Update global distribution stats, this provides the stats necessary for ranking distributors
        {

            // Note, we track trader's instead of trader's pod here
            DistributionFeeDIP.updateDistributionStats(ITorex(msg.sender),
                                                       trader, vars.distributor,
                                                       prevFlowRate, newFlowRate);
        }

        // Updating quadratic emission weights.
        //
        // NOTE:
        //
        // 1. The actual quadratic emission distribution flow rate adjustment is down during the liquidity movement,
        //    instead. This is to a) minimize the cost trader needs to pay for each trade; b) minimize any potential
        //    reverts during a flow deletion callback.
        QuadraticEmissionTIP.onInFlowChanged(emissionTreasury, ITorex(msg.sender),
                                             vars.traderPod, vars.referrerPod,
                                             prevFlowRate, newFlowRate);

        return toInt96(newFlowRate * int256(IN_TOKEN_FEE_PM) / INT_100PCT_PM);
    }

    // @inheritdoc ITorexController
    function onLiquidityMoved(LiquidityMoveResult calldata) external override
        onlyRegisteredTorex(msg.sender)
        returns (bool)
    {
        ITorex torex = ITorex(msg.sender);

        /* !!!!!!!!!!!!!!!!!!!! Torex 1.0.0-rc3 Quirk !!!!!!!!!!!!!!!!!!!! */
        if (_requireRC3Quirk(torex)) return true;
        /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */

        // Let liquidity movers pay for the emission adjustment for each torex.
        QuadraticEmissionTIP.adjustEmission(emissionTreasury, torex);
        // Let liquidity movers pay for the distribution fee program adjustment, too.
        DistributionFeeDIP.adjustDistributionFeeUnits(distributionFeeManager, torex);

        return true;
    }


    /**
     * @dev For Torex 1.0.0-rc3, there was a bug that caused the callback to be called twice. This guard is to address
     * such a quirk. This can also be implemented differently using eip-1153, but that requires "cancun" availability.
     */
    function _requireRC3Quirk(ITorex torex) internal returns (bool) {
        if (Strings.equal(torex.VERSION(), "1.0.0-rc3")) {
            uint256[1] storage rc3guard;
            // keccak256("onLiquidityMovedCalled.rc3guard")
            // solhint-disable-next-line no-inline-assembly
            assembly { rc3guard.slot := 0x1f659adfa28e67037987892f78d3ee72c2e697f69e1b4eba772ddc233478d708 }

            // if the rc3guard having a different block number (0 or non-zero due to a failed callback)
            if (rc3guard[0] != block.number) {
                // The first time is a unsafe callback.
                rc3guard[0] = block.number;
                return true;
            } else {
                // the second time is a safe callback.
                rc3guard[0] = 0;
            }
        }
        return false;
    }

    /*******************************************************************************************************************
     * Initial Staking TIP
     ******************************************************************************************************************/

    /// Get the sleep pod for the staker. For the opposite, one must parse the SleepPodCreated off-chain.
    function getSleepPod(address staker) public view
        returns (SleepPod sleepPod)
    {
        return InitialStakingTIP.getSleepPod(staker);
    }

    /// The workhorse function of updateStake/increaseStake/decreaseStake
    function _updateStake(address staker, ITorex torex, uint256 newStakedAmount) internal
        onlyRegisteredTorex(address(torex))
    {
        if (newStakedAmount > 0 && newStakedAmount < MINIMUM_STAKING_AMOUNT)
            revert MINIMUM_STAKING_AMOUNT_REQUIRED();

        // 1. For sleep pods, connect them to the emission pools
        _ensureSleepPodPoolConnections(staker);

        // 2. Update the staking program.
        uint256 oldStakedAmount = InitialStakingTIP.updateStakeOfPod(boringToken, sleepPodBeacon,
                                                                     torex, staker, newStakedAmount);

        // 3. Update the QE program.
        QuadraticEmissionTIP.onStakeUpdated(emissionTreasury, torex, oldStakedAmount, newStakedAmount);

        // 4. Adjust emission right away
        QuadraticEmissionTIP.adjustEmission(emissionTreasury, torex);

        emit StakeUpdated(torex, staker, newStakedAmount);
    }

    /// Update the absolute staked amount of the `msg.sender` for the `torex` to `newStakedAmount`.
    function updateStake(ITorex torex, uint256 newStakedAmount) external
    {
        _updateStake(msg.sender, torex, newStakedAmount);
    }

    /// Increase the staked amount of the `msg.sender` for the `torex`.
    function increaseStake(ITorex torex, uint256 amount) external
    {
        uint256 stakedAmount = getStakedAmountOf(torex, msg.sender);
        return _updateStake(msg.sender, torex, stakedAmount + amount);
    }

    /// Decrease the staked amount of the `msg.sender` for the `torex`.
    function decreaseStake(ITorex torex, uint256 amount) external
    {
        uint256 stakedAmount = getStakedAmountOf(torex, msg.sender);
        return _updateStake(msg.sender, torex, stakedAmount - amount); // solidity will check overflow
    }

    /// Get the staked amount of the `staker` to the `torex`.
    function getStakedAmountOf(ITorex torex, address staker) public view
        returns (uint256 stakedAmount)
    {
        return InitialStakingTIP.getStakeOfPod(torex, staker);
    }

    /// Get the total stakeable amount for the `staker`.
    function getStakeableAmount(address staker) external view
        returns (uint256 amount)
    {
        SleepPod sleepPod = getSleepPod(staker);
        if (address(sleepPod) == address(0)) return 0;

        amount = boringToken.balanceOf(address(sleepPod));

        // the pools are connected after _ensureSleepPodPoolConnections is called.
        ITorex[] memory torexes = QuadraticEmissionTIP.listEnabledTorexes();
        for (uint256 i = 0; i < torexes.length; ++i) {
            ISuperfluidPool pool = emissionTreasury.getEmissionPool(address(torexes[i]));
            if (!boringToken.isMemberConnected(address(pool), address(sleepPod))) {
                amount += SafeCast.toUint256(pool.getClaimable(address(sleepPod), SafeCast.toUint32(block.timestamp)));
            } // else balance is connected and directly available from the pool
        }
    }

    /// Get total staked amount to the `torex`.
    function getTotalStakedAmount(ITorex torex) external view
        returns (uint256 stakedAmount)
    {
        return BasicStakingTIP.getTotalStakedAmount(torex);
    }

    /// This scales the staked amount to fee pool units. See BasicStakingTIP.scaleStakedAmountToFeePoolUnits.
    function getFeePoolScaler(ITorex torex) external view
        returns (Scaler scaler)
    {
        return BasicStakingTIP.getFeePoolScaler(torex);
    }

    function _ensureSleepPodPoolConnections(address staker) internal
    {
        SleepPod sleepPod = InitialStakingTIP.getOrCreateSleepPod(sleepPodBeacon, staker);
        ITorex[] memory torexes = QuadraticEmissionTIP.listEnabledTorexes();
        for (uint256 i = 0; i < torexes.length; ++i) {
            ISuperfluidPool pool = emissionTreasury.getEmissionPool(address(torexes[i]));
            if (pool.getUnits(address(sleepPod)) > 0) {
                // connect to pools that has units for the member
                if (!boringToken.isMemberConnected(address(pool), address(sleepPod))) {
                    sleepPod.connectPool(pool);
                }
            } else {
                // disconnect to pools that has no units for the member
                if (boringToken.isMemberConnected(address(pool), address(sleepPod))) {
                    sleepPod.disconnectPool(pool);
                }
                if (pool.getClaimable(address(sleepPod), SafeCast.toUint32(block.timestamp)) > 0) {
                    boringToken.claimAll(pool, address(sleepPod));
                }
            }
        }
    }

    /*******************************************************************************************************************
     * Quadratic Emission TIP
     ******************************************************************************************************************/

    uint256 constant public QE_REFERRAL_BONUS = QuadraticEmissionTIP.REFERRAL_BONUS;

    /// This scales in token flow rate to boring emission pool units.
    /// See QuadraticEmissionTIP.scaleInTokenFlowRateToBoringPoolUnits.
    function getBoringPoolScaler(ITorex torex) external view
        returns (Scaler scaler)
    {
        return QuadraticEmissionTIP.getBoringPoolScaler(torex);
    }

    /// Quadratic emission target total emission rate is updated through `govQEUpdateTargetTotalEmissionRate`.
    function getQETargetTotalEmissionRate() external view returns (int96) {
        return QuadraticEmissionTIP.getTargetTotalEmissionRate();
    }

    /// Quadratic emission is enabled for torex through `govQEEnableForTorex`.
    function isQEEnabledForTorex(ITorex torex) external view returns (bool) {
        return QuadraticEmissionTIP.isQEEnabledForTorex(torex);
    }

    /// Query who is the current referrer for the trader on the torex.
    function getCurrentReferrerPod(ITorex torex, address trader) external view returns (address referrer) {
        return QuadraticEmissionTIP.getCurrentReferrerPod(torex, trader);
    }

    /// Query additional reward rate information for an trader.
    function getMyBoringRewardInfo(ITorex torex, address me) external view
        returns (int96 totalRewardRate, int96 tradingRewardRate)
    {
        address myPod = address(getSleepPod(me));
        (ISuperToken inToken,) = torex.getPairedTokens();
        int96 tradingFlowRate = inToken.getFlowRate(me, address(torex));
        uint256 traderUnits = QuadraticEmissionTIP.scaleInTokenFlowRateToBoringPoolUnits(torex, tradingFlowRate);
        uint256 allMyUnits = emissionTreasury.getMemberEmissionUnits(address(torex), myPod);
        totalRewardRate = emissionTreasury.getMemberEmissionRate(address(torex), myPod);
        if (allMyUnits > 0) {
            tradingRewardRate = toInt96(SafeCast.toUint256(totalRewardRate)
                                        * uint256(traderUnits) / uint256(allMyUnits));
        }
    }

    /*******************************************************************************************************************
     * Distribution Fee DIP
     ******************************************************************************************************************/

    /// Distribution tax rate of the total in token fee.
    uint256 constant public DISTRIBUTION_TAX_RATE_PM = DistributionFeeDIP.DISTRIBUTION_TAX_RATE_PM;

    /// @inheritdoc IDistributorStatsProvider
    function getCurrentDistributor(ITorex torex, address trader) override external view
        returns (address distributor)
    {
        return DistributionFeeDIP.getCurrentDistributor(torex, trader);
    }

    /// @inheritdoc IDistributorStatsProvider
    function getDistributorStats(ITorex torex, address distributor) override external view
        returns (int256 distributedVolume, int96 totalFlowRate)
    {
        return DistributionFeeDIP.getDistributorStats(torex, distributor);
    }

    /// @inheritdoc IDistributorStatsProvider
    function getTotalityStats(ITorex torex) override external view
        returns (int256 distributedVolume, int96 totalFlowRate)
    {
        return DistributionFeeDIP.getTotalityStats(torex);
    }

    /*******************************************************************************************************************
     * Governance (onlyOwners and Registerred Torexes)
     ******************************************************************************************************************/

    function govQEEnableForTorex(ITorex torex) external
        onlyOwner
        onlyRegisteredTorex(address(torex))
    {
        QuadraticEmissionTIP.enableQEForTorex(torex);
        // !IMPORTANT! In a not-so-obvious look, this ensures that emission pool is created. Otherwise trading to the
        // !Torex might be blocked.
        emissionTreasury.updateEmissionRate(address(torex), 0);
    }

    function govQEUpdateTargetTotalEmissionRate(int96 r) external
        onlyOwner
    {
        QuadraticEmissionTIP.updateTargetTotalEmissionRate(r);
    }

    function govQEUpdateTorexEmissionBoostFactor(ITorex torex, uint256 f) external
        onlyOwner
    {
        emissionTreasury.updateEmissionBoostFactor(address(torex), f);
    }

    function govUpdateLogic(SuperBoring newSuperBoringLogic,
                            SleepPod newSleepPodLogic,
                            EmissionTreasury newEmissionTreasuryLogic,
                            DistributionFeeManager newDistributionFeeManagerLogic) external
        onlyOwner
    {
        if (address(newSuperBoringLogic) != address(0)) {
            _updateCodeAddress(address(newSuperBoringLogic));
        }
        if (address(newSleepPodLogic) != address(0)) {
            // sleepPodBeacon does not have the Superfluid extention, let's check the signature manually.
            assert(newSleepPodLogic.proxiableUUID() == keccak256("SuperBoring.contracts.SleepPod"));
            sleepPodBeacon.upgradeTo(address(newSleepPodLogic));
        }
        if (address(newEmissionTreasuryLogic) != address(0)) {
            emissionTreasury.updateCode(address(newEmissionTreasuryLogic));
        }
        if (address(newDistributionFeeManagerLogic) != address(0)) {
            distributionFeeManager.updateCode(address(newDistributionFeeManagerLogic));
        }
    }

    /*******************************************************************************************************************
     * UUPS Upgradability
     ******************************************************************************************************************/

    function proxiableUUID() public pure override returns (bytes32) {
        return keccak256("superboring.contracts.SuperBoring.implementation");
    }

    function initialize(address owner) external initializer {
        _transferOwnership(owner);
    }

    function updateCode(address newAddress) public override
        onlyOwner
    {
        _updateCodeAddress(newAddress);
    }
}

function createSuperBoring(ISuperToken boringToken,
                           TorexFactory tokenFactory,
                           EmissionTreasury emissionTreasury,
                           DistributionFeeManager distributionFeeManager,
                           SuperBoring.Config memory config,
                           address sbOwner) returns (SuperBoring sb) {
    UUPSProxy sbProxy = new UUPSProxy();
    UpgradeableBeacon sleepPodBeacon = createSleepPodBeacon(address(sbProxy), boringToken);
    sleepPodBeacon.transferOwnership(address(sbProxy));

    SuperBoring logic = new SuperBoring(boringToken,
                                        tokenFactory,
                                        emissionTreasury,
                                        distributionFeeManager,
                                        sleepPodBeacon,
                                        config);
    logic.castrate();
    sbProxy.initializeProxy(address(logic));

    sb = SuperBoring(address(sbProxy));
    sb.initialize(sbOwner);

    emissionTreasury.initialize(address(sb));
    distributionFeeManager.initialize(address(sb));
}

function createSuperBoringLogic(SuperBoring sb) returns (SuperBoring newLogic) {
    return new SuperBoring(sb.boringToken(),
                           sb.torexFactory(),
                           sb.emissionTreasury(),
                           sb.distributionFeeManager(),
                           sb.sleepPodBeacon(),
                           SuperBoring.Config({
                               inTokenFeePM: sb.IN_TOKEN_FEE_PM(),
                               minimumStakingAmount: sb.MINIMUM_STAKING_AMOUNT()
                           }));
}

function createSleepPodLogic(SuperBoring sb) returns (SleepPod newLogic) {
    SleepPod c = SleepPod(sb.sleepPodBeacon().implementation());
    return new SleepPod(c.admin(), c.boringToken());
}

function createEmissionTreasuryLogic(SuperBoring sb) returns (EmissionTreasury newLogic) {
    EmissionTreasury c = sb.emissionTreasury();
    return new EmissionTreasury(c.boringToken());
}

function createDistributionFeeManagerLogic(SuperBoring /* not needed */) returns (DistributionFeeManager newLogic) {
    return new DistributionFeeManager();
}
