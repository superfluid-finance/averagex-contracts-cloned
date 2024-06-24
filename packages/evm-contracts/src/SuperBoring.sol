// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {
    ISuperfluidPool, ISuperToken
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

import { toInt96, INT_100PCT_PM } from "./libs/MathExtra.sol";
import { Scaler } from "./libs/Scaler.sol";

import { ITorexController, ITorex, LiquidityMoveResult, TorexMetadata } from "./interfaces/torex/ITorex.sol";
import { Torex } from "./Torex.sol";
import { TorexFactory, IUniswapV3Pool } from "./TorexFactory.sol";

import { BasicStakingTIP } from "./BoringPrograms/BasicStakingTIP.sol";
import { SleepPod, createSleepPodBeacon } from "./BoringPrograms/SleepPod.sol";
import { InitialStakingTIP } from "./BoringPrograms/InitialStakingTIP.sol";
import { QuadraticEmissionTIP, EmissionTreasury } from "./BoringPrograms/QuadraticEmissionTIP.sol";
import { DistributionFeeManager, IDistributorUnitsProvider } from "./BoringPrograms/DistributionFeeManager.sol";
import { DistributionFeeDIP } from "./BoringPrograms/DistributionFeeDIP.sol";


/**
 * @dev The super boring way of controlling TOREXes and managing $BORING token emissions.
 *
 * TODOs:
 *
 * - Programs:
 *   - [x] TIP: IS (Initial Staking) <<< BS (Basic Staking)
 *   - [x] TIP: QE (Quadratic Emission)
 *   - [x]      - built-in referral bonus
 *   - [x] DIP: DF (Distribution Fee)
 *   - [x]      - Distributor ranking system
 *   - [ ] Staking fee to make QE less gameable.
 *   - [ ] MathExtra: safeSubNoThrow
 * - Per TOREX Stats:
 *   - [x] BORING staked
 *     - why: as a degen, knowing how QE works, I'd like to know which TOREX has more BORING staked.
 *     - unit: amount of BORING.
 *     - how: rpc call `sb.getTotalStakedAmount` over each torex.
 *   - [x] Est. Monthly DCA volume
 *     - why: it is good to know. Also, as a trader, investing in a slow market may mean paying higher premium, which is
 *       something to be avoided.
 *     - unit: in-tokens flow rate / s
 *     - how: based on the flow rate from a direct rpc query of in-token flow rate to the torex.
 *   - [x] Est. Rewards, aka. "Staking rewards", or in-token fees
 *     - why: as a degen, I'd like to put BORING into work, this is the most direct metric.
 *     - unit: in-tokens flow rate (per norminal BORING)
 *     - how: rpc call `distribution flow rate from torex.feeDistributionPool() / sb.getTotalStakedAmount()` , and maybe
 *       normalize with the market price of in-tokens.
 *   - [x] Monthly BORING reward
 *     - why: as a degen, I'd like to put my assets into work (earn BORING), this is the most direct metric.
 *     - unit: BORING, per in-token (or preferably its dollar value) traded
 *     - how: rpc call `sb.emissionTreasury().getEmissionRate(torex)`.
 * - Global Stats:
 *   - These lacking strong personalized "why"s, since they are mostly in "good to know" category.
 *   - [ ] Total DCA volume in $
 *     - note: as a starter, UI can do aggregations of known TOREXes; with market price, sacrificing data accuracy.
 *   - [ ] Total rewards volume in $
 *     - note: ditto.
 *   - [ ] Total BORING staked
 *     - note: ditto.
 *   - [ ] Total BORING emitted
 *     - note: may need to build extra accounting into the EmissionTreasury contract.
 */
contract SuperBoring is ITorexController, Ownable, IDistributorUnitsProvider {
    using SuperTokenV1Library for ISuperToken;
    using EnumerableSet for EnumerableSet.AddressSet;

    /*******************************************************************************************************************
     * Definitions
     ******************************************************************************************************************/

    error ONLY_REGISTERED_TOREX_ALLOWED();

    error NO_SELF_REFERRAL();

    event TorexCreated(ITorex indexed torex);

    event StakeUpdated(ITorex indexed torex, address indexed staker, uint256 stakedAmount);

    /*******************************************************************************************************************
     * Configurations and Constructor
     ******************************************************************************************************************/

    int256  public constant IN_TOKEN_FEE_PM = 5_000; // 0.5%

    ISuperToken            public immutable boringToken;
    TorexFactory           public immutable torexFactory;
    EmissionTreasury       public immutable emissionTreasury;
    DistributionFeeManager public immutable distributionFeeManager;
    UpgradeableBeacon      public immutable sleepPodBeacon;

    constructor(ISuperToken boringToken_,
                TorexFactory tokenFactory_,
                EmissionTreasury emissionTreasury_,
                DistributionFeeManager distributionFeeManager_) {
        boringToken = boringToken_;
        torexFactory = tokenFactory_;
        emissionTreasury = emissionTreasury_;
        distributionFeeManager = distributionFeeManager_;
        sleepPodBeacon = createSleepPodBeacon(boringToken);
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

    function getAllTorexesMetadata() external view
        returns (TorexMetadata[] memory metadataList)
    {
        return getAllTorexesMetadata(0, 100);
    }

    function createTorex(Torex.Config memory torexConfig,
                         int8 feePoolScalerN10Pow, int8 boringPoolScalerN10Pow) external
        returns (Torex torex)
    {
        EnumerableSet.AddressSet storage $ = _getTorexRegistryStorage();

        assert(address(torexConfig.controller) == address(0)); // leave it to us
        torexConfig.controller = this;
        torex = torexFactory.createTorex(torexConfig);

        $.add(address(torex));
        emit TorexCreated(torex);

        BasicStakingTIP.setFeePoolScaler(torex, feePoolScalerN10Pow);
        QuadraticEmissionTIP.setBoringPoolScaler(torex, boringPoolScalerN10Pow);
    }

    function createUniV3PoolTwapObserverAndTorex(IUniswapV3Pool uniV3Pool, bool inverseOrder,
                                                 Torex.Config memory torexConfig,
                                                 int8 feePoolScalerN10Pow, int8 boringPoolScalerN10Pow) external
        returns (Torex torex)
    {
        EnumerableSet.AddressSet storage $ = _getTorexRegistryStorage();

        assert(address(torexConfig.controller) == address(0)); // leave it to us
        torexConfig.controller = this;
        torex = torexFactory.createUniV3PoolTwapObserverAndTorex(uniV3Pool, inverseOrder, torexConfig);

        $.add(address(torex));
        emit TorexCreated(torex);

        BasicStakingTIP.setFeePoolScaler(torex, feePoolScalerN10Pow);
        QuadraticEmissionTIP.setBoringPoolScaler(torex, boringPoolScalerN10Pow);
    }

    /*******************************************************************************************************************
     * Torex Controller Implementation
     ******************************************************************************************************************/

    // @inheritdoc ITorexController
    function getTypeId() external pure override returns (bytes32) { return keccak256("SuperBoring"); }

    // @inheritdoc ITorexController
    function onInFlowChanged(address trader,
                             int96 prevFlowRate, int96 /*preFeeFlowRate*/, uint256 /*lastUpdated*/,
                             int96 newFlowRate, uint256 /*now*/,
                             bytes calldata userData) external override
        onlyRegisteredTorex(msg.sender)
        returns (int96 newFeeFlowRate)
    {
        address referrer;

        // Update global distribution stats, this is the oracle necessary for ranking distributors
        {
            address distributor;

            // Unless deleting a flow, we expect an optional (distributor, referrer) is provided through the userData.
            // When deleting the flow (newFlowRate == 0), distributor and referrer are reset to NONE.
            if (newFlowRate > 0) {
                // - userData is optional.
                // - when provided, its schema: (address distributor, address referrer)
                if (userData.length > 0) {
                    // This may revert, and it will make create/update flow fail.
                    (distributor, referrer) = abi.decode(userData, (address, address));
                    if (trader == referrer) revert NO_SELF_REFERRAL();
                } else {
                    // during update flow, we keep same distributor and referrer
                    if (prevFlowRate > 0) {
                        distributor = DistributionFeeDIP.getCurrentDistributor(ITorex(msg.sender), trader);
                        referrer = QuadraticEmissionTIP.getCurrentReferrer(ITorex(msg.sender), trader);
                    }
                }
            }

            // Note, we track trader instead of trader's pod here
            DistributionFeeDIP.updateDistributionStats(ITorex(msg.sender),
                                                       trader, distributor,
                                                       prevFlowRate, newFlowRate);
        }

        // To support sleep pod, modifying these value in-place, to workaround solidity stack too deep issue
        trader = address(InitialStakingTIP.getOrCreateSleepPod(sleepPodBeacon, trader));
        referrer = address(InitialStakingTIP.getOrCreateSleepPod(sleepPodBeacon, referrer));

        // Updating quadratic emission weights.
        //
        // NOTE:
        //
        // 1. The actual quadratic emission distribution flow rate adjustment is down during the liquidity movement,
        //    instead. This is to a) minimize the cost trader needs to pay for each trade; b) minimize any potential
        //    reverts during a flow deletion callback.
        QuadraticEmissionTIP.onInFlowChanged(emissionTreasury, ITorex(msg.sender),
                                             trader, referrer,
                                             prevFlowRate, newFlowRate);

        return toInt96(newFlowRate * IN_TOKEN_FEE_PM / INT_100PCT_PM);
    }

    // @inheritdoc ITorexController
    function onLiquidityMoved(LiquidityMoveResult memory) external override
        onlyRegisteredTorex(msg.sender)
        returns (bool)
    {
        // Let liquidity movers pay for the emission adjustment for each torex.
        QuadraticEmissionTIP.adjustEmission(emissionTreasury, ITorex(msg.sender));
        // Let liquidity movers pay for the distribution fee program adjustment, too.
        DistributionFeeDIP.adjustDistributionFeeUnits(distributionFeeManager, ITorex(msg.sender));
        return true;
    }

    /*******************************************************************************************************************
     * Initial Staking TIP
     ******************************************************************************************************************/

    function getSleepPod(address staker) public view
        returns (SleepPod sleepPod)
    {
        return InitialStakingTIP.getSleepPod(staker);
    }

    function _updateStake(address staker, ITorex torex, uint256 newStakedAmount) internal
        onlyRegisteredTorex(address(torex))
    {
        // 1. For sleep pods, connect them to the emission pools
        _ensureSleepPodPoolConnections(staker);

        // 2. Update the staking program.
        uint256 oldStakedAmount = InitialStakingTIP.updateStakeOfPod(boringToken, sleepPodBeacon,
                                                                     torex, staker, newStakedAmount);

        // 3. Update the QE program.
        QuadraticEmissionTIP.onStakeUpdated(emissionTreasury, torex, oldStakedAmount, newStakedAmount);

        emit StakeUpdated(torex, staker, newStakedAmount);
    }

    /// Update the absolute staked amount of the `msg.sender` for the `torex` to `newStakedAmount`.
    function updateStake(ITorex torex, uint256 newStakedAmount) external
    {
        _updateStake(msg.sender, torex, newStakedAmount);
    }

    function increaseStake(ITorex torex, uint256 addStake) external
    {
        uint256 stakedAmount = getStakedAmountOf(torex, msg.sender);
        return _updateStake(msg.sender, torex, stakedAmount + addStake);
    }

    function decreaseStake(ITorex torex, uint256 addStake) external
    {
        uint256 stakedAmount = getStakedAmountOf(torex, msg.sender);
        return _updateStake(msg.sender, torex, stakedAmount - addStake); // solidity will check overflow
    }

    /// Get the staked amount of the `staker` to the `torex`.
    function getStakedAmountOf(ITorex torex, address staker) public view
        returns (uint256 stakedAmount)
    {
        return InitialStakingTIP.getStakeOfPod(torex, staker);
    }

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
            }
        }
    }

    /// Get total staked amount to the `torex`.
    function getTotalStakedAmount(ITorex torex) external view
        returns (uint256 stakedAmount)
    {
        return BasicStakingTIP.getTotalStakedAmount(torex);
    }

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

    function isQEEnabledForTorex(ITorex torex) external view returns (bool) {
        return QuadraticEmissionTIP.isQEEnabledForTorex(torex);
    }

    function getBoringPoolScaler(ITorex torex) external view
        returns (Scaler scaler)
    {
        return QuadraticEmissionTIP.getBoringPoolScaler(torex);
    }

    function getCurrentReferrer(ITorex torex, address trader) internal view returns (address referrer) {
        return QuadraticEmissionTIP.getCurrentReferrer(torex, trader);
    }

    struct TorexQEMetadata {
        ITorex torex;
        uint256 q;
    }
    function debugInfoQE() external view
        returns (int96 targetTotalEmissionRate, uint256 qqSum, TorexQEMetadata[] memory torexMetadata)
    {
        ITorex[] memory torexes = QuadraticEmissionTIP.listEnabledTorexes();
        torexMetadata = new TorexQEMetadata[](torexes.length);
        for (uint256 i = 0; i < torexes.length; i++) {
            ITorex torex = torexes[i];
            torexMetadata[i] = TorexQEMetadata(torex, QuadraticEmissionTIP.debugInfoTorex(torex));
        }
        return (QuadraticEmissionTIP.getTargetTotalEmissionRate(),
                QuadraticEmissionTIP.debugInfoQQSum(),
                torexMetadata);
    }

    /*******************************************************************************************************************
     * Distribution Fee DIP
     ******************************************************************************************************************/

    uint256 constant public DISTRIBUTION_TAX_RATE_PM = DistributionFeeDIP.DISTRIBUTION_TAX_RATE_PM;

    function getCurrentDistributor(ITorex torex, address trader) external view
        returns (address distributor)
    {
        return DistributionFeeDIP.getCurrentDistributor(torex, trader);
    }

    function getDistributorStats(ITorex torex, address distributor) external view
        returns (int256 distributedVolume, int96 totalFlowRate)
    {
        return DistributionFeeDIP.getDistributorStats(torex, distributor);
    }

    function getTotalityStats(ITorex torex) external view
        returns (int256 distributedVolume, int96 totalFlowRate)
    {
        return DistributionFeeDIP.getTotalityStats(torex);
    }

    function getDistributorUnits(ITorex torex, address distributor) external override view
        returns (uint128)
    {
        (int256 dvol,) = DistributionFeeDIP.getDistributorStats(torex, distributor);
        (int256 tvol,) = DistributionFeeDIP.getTotalityStats(torex);
        if (tvol > 0) {
            return uint128(SafeCast.toUint256(dvol * INT_100PCT_PM / tvol));
        } else return 0;
    }

    /*******************************************************************************************************************
     * Governance
     ******************************************************************************************************************/

    function govQEEnableForTorex(ITorex torex) external
        onlyOwner
        onlyRegisteredTorex(address(torex))
    {
        QuadraticEmissionTIP.enableQEForTorex(emissionTreasury, torex);
    }

    function govQEUpdateTargetTotalEmissionRate(int96 r) external
        onlyOwner
    {
        QuadraticEmissionTIP.updateTargetTotalEmissionRate(r);
    }

    function govUpgradeEmissionTreasuryLogic(EmissionTreasury newLogic) external
        onlyOwner
    {
        emissionTreasury.updateCode(address(newLogic));
    }
}
