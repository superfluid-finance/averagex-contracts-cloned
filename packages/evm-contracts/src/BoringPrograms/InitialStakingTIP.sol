// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

import {
    ISuperToken
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { ITorex } from "../interfaces/torex/ITorex.sol";

import { BasicStakingTIP } from "./BasicStakingTIP.sol";
import { SleepPod, createSleepPod } from "./SleepPod.sol";


/**
 * @title The initial staking program, where unstaked boring tokens are locked in the "sleep pods".
 *
 * This is built on top of the basic stacking TIP, by always using staker's sleep pod's staking balance.
 */
library InitialStakingTIP {
    /// The storage used by the library.
    struct Storage {
        mapping (address staker => SleepPod) sleepPods;
    }
    // keccak256(abi.encode(uint256(keccak256("superboring.storage.InitialStakingTIP")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant _STORAGE_SLOT = 0x5cf275d110f76ebbea56bbc343cc89db4174cffae57aaed7434ab7e73025c200;
    // solhint-disable-next-line no-inline-assembly
    function _getStorage() private pure returns (Storage storage $) { assembly { $.slot := _STORAGE_SLOT } }

    function getSleepPod(address staker) internal view returns (SleepPod sleepPod) {
        return _getStorage().sleepPods[staker];
    }

    function getOrCreateSleepPod(UpgradeableBeacon sleepPodBeacon, address staker) internal
        returns (SleepPod p)
    {
        Storage storage $ = _getStorage();
        p = $.sleepPods[staker];
        if (address(p) == address(0)) {
            p = $.sleepPods[staker] = createSleepPod(sleepPodBeacon, staker);
        }
    }

    function getStakeOfPod(ITorex torex, address staker) internal view
        returns (uint256 stakedAmount)
    {
        Storage storage $ = _getStorage();
        address sleepPod = address($.sleepPods[staker]);
        return BasicStakingTIP.getStakedAmountOf(torex, sleepPod);
    }

    function updateStakeOfPod(ISuperToken boringToken, UpgradeableBeacon sleepPodBeacon,
                              ITorex torex,
                              address staker, uint256 newStakedAmount) internal
        returns (uint256 oldStakedAmount)
    {
        SleepPod sleepPod = getOrCreateSleepPod(sleepPodBeacon, staker);
        sleepPod.approve(address(this), newStakedAmount);
        return BasicStakingTIP.updateStake(boringToken, torex, address(sleepPod), staker, newStakedAmount);
    }
}
