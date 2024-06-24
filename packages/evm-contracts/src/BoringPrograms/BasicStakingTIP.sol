// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";

import {
    ISuperToken
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { Scaler, getScaler10Pow } from "../libs/Scaler.sol";

import { ITorex } from "../interfaces/torex/ITorex.sol";


/**
 * @title The basic staking program, where other programs can build their own logic on top of it.
 *
 * Note:
 * - Stakers stakes boring token and earn fees.
 * - The problem allows the separation of staker and feeRecipient.
 */
library BasicStakingTIP {
    /// The state for the torex.
    struct TorexState {
        uint256 totalStaked;
        mapping (address staker => uint256 stakedAmount) stakes;
    }

    /// The storage used by the library.
    struct Storage {
        /// Scaler used for scaling staked amount to in-token fee pool units.
        mapping (ITorex => Scaler) feePoolScalers;
        /// Global staking states for each torex.
        mapping (ITorex => TorexState) torexStates;
    }
    // keccak256(abi.encode(uint256(keccak256("superboring.storage.BasicStakingTIP")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant _STORAGE_SLOT = 0xd753b92ba281b6c715e92be8ef0679297bd9ca43ca30beee7d858e3947a63800;
    // solhint-disable-next-line no-inline-assembly
    function _getStorage() private pure returns (Storage storage $) { assembly { $.slot := _STORAGE_SLOT } }

    function setFeePoolScaler(ITorex torex, int8 n10pow) internal {
        _getStorage().feePoolScalers[torex] = getScaler10Pow(n10pow);
    }

    function getFeePoolScaler(ITorex torex) internal view returns (Scaler) {
        return _getStorage().feePoolScalers[torex];
    }

    function scaleStakedAmountToFeePoolUnits(ITorex torex, uint256 stakedAmount)
        internal view
        returns (uint128 stakedUnits)
    {
        Storage storage $ = _getStorage();
        Scaler scaler = $.feePoolScalers[torex];
        return SafeCast.toUint128(scaler.scaleValue(stakedAmount));
    }

    /// Get staked amount to a torex by a staker.
    function getStakedAmountOf(ITorex torex, address staker) internal view
        returns (uint256 stakedAmount)
    {
        Storage storage $ = _getStorage();
        return $.torexStates[torex].stakes[staker];
    }

    function getTotalStakedAmount(ITorex torex) internal view
        returns (uint256 stakedAmount)
    {
        return _getStorage().torexStates[torex].totalStaked;
    }

    /// Update staked amount to a torex by a staker
    function updateStake(ISuperToken boringToken,
                         ITorex torex,
                         address staker, address feeRecipient, uint256 newStakedAmount) internal
        returns (uint256 oldStakedAmount)
    {
        Storage storage $ = _getStorage();
        TorexState storage ts = $.torexStates[torex];

        // adjust totalStaked & stakedAmount of the staker
        oldStakedAmount = ts.stakes[staker];
        if (newStakedAmount > oldStakedAmount) {
            boringToken.transferFrom(staker, address(this), newStakedAmount - oldStakedAmount);
            ts.totalStaked += newStakedAmount - oldStakedAmount;
        } else {
            boringToken.transfer(staker, oldStakedAmount - newStakedAmount);
            ts.totalStaked -= oldStakedAmount - newStakedAmount;
        }
        ts.stakes[staker] = newStakedAmount;

        // update the staker's fee pool member units, consulting the global mechanism
        uint128 units = scaleStakedAmountToFeePoolUnits(torex, newStakedAmount);
        torex.feeDistributionPool().updateMemberUnits(feeRecipient, units);
    }
}
