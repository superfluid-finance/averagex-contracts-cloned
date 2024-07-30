// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

import {
    ISuperfluidPool
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { ITorex } from "../interfaces/torex/ITorex.sol";

import { Scaler, getScaler10Pow } from "../libs/Scaler.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { UINT_100PCT_PM, toUint96, toUint256 } from "../libs/MathExtra.sol";
import { EmissionTreasury } from "./EmissionTreasury.sol";


/**
 * @title Quadratic emission token-incentive program.
 *
 * Note:
 * 1. The program includes a quadratic emission mechanism for the TOREXes, where the more staked a TOREX is, the more
 *    emission that TOREXes would create.
 * 2. The program also includes a referral bonus program for referrers.
 */
library QuadraticEmissionTIP {
    uint256 internal constant REFERRAL_BONUS = 5_0000; // 5% fixed referral bonus

    event ReferrerUpdated(ITorex indexed torex,
                          address indexed traderPod, uint128 newTraderUnits,
                          address indexed referrerPod, uint128 newReferralUnits);

    event EmissionUpdated(ITorex indexed torex, int96 emissionRate, uint256 q, uint256 qqSum);

    event TargetTotalEmissionRateUpdated(int96 targetTotalEmissionRate);

    /// Referral data for each trader-referrer pair. It is packed to exact 1-word.
    struct ReferralData {
        address referrerPod;
        uint96  referrerUnits;
    }

    /// The storage used by the library.
    struct Storage {
        /// Scaler used for scaling in-token flow rate to boring pool units.
        mapping (ITorex => Scaler) boringPoolScalers;
        /// Sum of sqrt of staked amounts for each TOREX.
        EnumerableMap.AddressToUintMap torexQs;
        /// Sum q^2 of all TOREXes.
        uint256 qqSum;
        /// Targeted total emission rate of the program.
        int96 targetTotalEmissionRate;
        /// Bonus reward referrers.
        mapping (ITorex torex => mapping (address trader => ReferralData)) referrals;
    }
    // keccak256(abi.encode(uint256(keccak256("superboring.storage.QuadraticEmissionTIP")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant _STORAGE_SLOT = 0x4063b196db8c84bc81e99c3a57424189a6f850babf6415719a003957c40e6900;
    // solhint-disable-next-line no-inline-assembly
    function _getStorage() private pure returns (Storage storage $) { assembly { $.slot := _STORAGE_SLOT } }

    function setBoringPoolScaler(ITorex torex, int8 n10pow) internal {
        _getStorage().boringPoolScalers[torex] = getScaler10Pow(n10pow);
    }

    function getBoringPoolScaler(ITorex torex) internal view returns (Scaler) {
        return _getStorage().boringPoolScalers[torex];
    }

    function scaleInTokenFlowRateToBoringPoolUnits(ITorex torex, int96 flowRate)
        internal view
        returns (uint128 units)
    {
        Scaler scaler = _getStorage().boringPoolScalers[torex];
        return SafeCast.toUint128(scaler.scaleValue(toUint256(flowRate)));
    }

    function enableQEForTorex(ITorex torex) internal
    {
        EnumerableMap.set(_getStorage().torexQs, address(torex), 0);
    }

    function isQEEnabledForTorex(ITorex torex) internal view returns (bool) {
        return EnumerableMap.contains(_getStorage().torexQs, address(torex));
    }

    function listEnabledTorexes() internal view returns (ITorex[] memory torexes) {
        Storage storage $ = _getStorage();
        address[] memory keys = EnumerableMap.keys($.torexQs);
        // solhint-disable-next-line no-inline-assembly
        assembly { torexes := keys }
    }

    // @dev This hook updates the emission for torexes that are part of the QE program, quadratically.
    //
    // Note:
    //   - formula: $$\left( \sum_{i \in stakers} \sqrt{stakedAmount(i)} \right)^2$$
    function onStakeUpdated(EmissionTreasury emissionTreasury, ITorex torex,
                            uint256 oldStakedAmount, uint256 newStakedAmount) internal
    {
        if (isQEEnabledForTorex(torex)) {
            Storage storage $ = _getStorage();

            // Note: what if sqrt implementation outputs different number over different implementations?
            uint256 q0 = EnumerableMap.get($.torexQs, address(torex));
            uint256 q1 = q0 + Math.sqrt(newStakedAmount) - Math.sqrt(oldStakedAmount);
            $.qqSum = $.qqSum + q1 * q1 - q0 * q0;
            EnumerableMap.set($.torexQs, address(torex), q1);

            adjustEmission(emissionTreasury, torex);
        }
    }

    // @dev This hook updates flow updater's emission share.
    function onInFlowChanged(EmissionTreasury emissionTreasury, ITorex torex,
                             address traderPod, address referrerPod,
                             int96 prevFlowRate, int96 newFlowRate) internal
    {
        assert(traderPod != referrerPod); // please provide a nicer revert in the use-site

        if (isQEEnabledForTorex(torex)) {
            Storage storage $ = _getStorage();
            ISuperfluidPool emissionPool = emissionTreasury.getEmissionPool(address(torex));

            // update trader's reward
            // Assumption: the scaling factor is fixed; otherwise, we would have to store prevTraderUnits.
            // Regretfully, this should have been a stored value, as it was originally so.
            uint128 newTraderUnits = scaleInTokenFlowRateToBoringPoolUnits(torex, newFlowRate);
            {
                uint128 prevTraderUnits = scaleInTokenFlowRateToBoringPoolUnits(torex, prevFlowRate);
                emissionTreasury.updateMemberEmissionUnits
                    (address(torex), traderPod,
                     // NOTE: QE could be enabled after the TOREX has been active, so this underflow may happen
                     emissionPool.getUnits(traderPod) + newTraderUnits >= prevTraderUnits
                     ? emissionPool.getUnits(traderPod) + newTraderUnits  - prevTraderUnits
                     : 0);
            }

            // update referrer's reward
            ReferralData memory oldRefData = $.referrals[torex][traderPod];
            //   if either there is a new referrer or there was an existing referrer, then we need an update.
            if (oldRefData.referrerPod != address(0) || referrerPod != address(0)) {
                uint128 newReferralUnits = SafeCast.toUint128(uint256(newTraderUnits)
                                                              * REFERRAL_BONUS / UINT_100PCT_PM);
                if (oldRefData.referrerPod == referrerPod) { // this branch is a small optimization
                    // invariant: oldRefData.referrer != referrer != address(0)
                    emissionTreasury.updateMemberEmissionUnits(address(torex), referrerPod,
                                                               emissionPool.getUnits(referrerPod)
                                                               + newReferralUnits - oldRefData.referrerUnits);
                } else {
                    if (referrerPod != address(0)) {
                        emissionTreasury.updateMemberEmissionUnits(address(torex), referrerPod,
                                                                   emissionPool.getUnits(referrerPod)
                                                                   + newReferralUnits);
                    }
                    if (oldRefData.referrerPod != address(0)) {
                        emissionTreasury.updateMemberEmissionUnits(address(torex), oldRefData.referrerPod,
                                                                   emissionPool.getUnits(oldRefData.referrerPod)
                                                                   - oldRefData.referrerUnits);
                    }
                }
                $.referrals[torex][traderPod] = ReferralData(referrerPod, toUint96(newReferralUnits));
                emit ReferrerUpdated(torex, traderPod, newTraderUnits, referrerPod, newReferralUnits);
            }
        }
    }

    function getCurrentReferrerPod(ITorex torex, address trader) internal view returns (address referrerPod) {
        return _getStorage().referrals[torex][trader].referrerPod;
    }

    function getTargetTotalEmissionRate() internal view returns (int96 targetTotalEmissionRate) {
        return _getStorage().targetTotalEmissionRate;
    }

    function updateTargetTotalEmissionRate(int96 r) internal {
        _getStorage().targetTotalEmissionRate = r;
        emit TargetTotalEmissionRateUpdated(r);
    }

    // @dev This hook adjust the total emission rate to the torex flow senders.
    function adjustEmission(EmissionTreasury emissionTreasury, ITorex torex) internal {
        int96 emissionRate = 0;
        if (isQEEnabledForTorex(torex)) {
            Storage storage $ = _getStorage();
            uint256 q = EnumerableMap.get($.torexQs, address(torex));

            if ($.qqSum > 0) {
                // if treasury is running out of budget in one week, set rate to zero to wind down the emissions
                if (emissionTreasury.balanceLeft() > uint256(int256($.targetTotalEmissionRate)) * 7 days) {
                    uint256 qq = q * q;
                    emissionRate = SafeCast.toInt96(int256($.targetTotalEmissionRate)
                                                    * SafeCast.toInt256(qq) / SafeCast.toInt256($.qqSum));
                }
            }

            emit EmissionUpdated(torex, emissionRate, q, $.qqSum);
        } // else make sure emission rate goes to zero if a torex is removed from the program.

        emissionTreasury.updateEmissionRate(address(torex), emissionRate);
    }
}
