// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { BeaconProxiable } from "@superfluid-finance/ethereum-contracts/contracts/upgradability/BeaconProxiable.sol";

import {
    ISuperToken, ISuperfluidPool
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";


/**
 * @dev Sleep pods are contracts where BORING token stays for the stakers before the transferable event.
 *
 * Note:
 * - This is a beacon proxy.
 */
contract SleepPod is BeaconProxiable {
    using SuperTokenV1Library for ISuperToken;

    function proxiableUUID() override public pure returns (bytes32) {
        return keccak256("SuperBoring.contracts.SleepPod");
    }

    address     public immutable admin;
    ISuperToken public immutable boringToken;

    address public staker;

    constructor(ISuperToken boringToken_) {
        admin = msg.sender;
        boringToken = boringToken_;
    }

    function initialize(address staker_) external initializer {
        staker = staker_;
    }

    function approve(address target, uint256 amount) external onlyAdmin {
        boringToken.approve(target, amount);
    }

    function connectPool(ISuperfluidPool pool) external onlyAdmin {
        boringToken.connectPool(pool);
    }

    function disconnectPool(ISuperfluidPool pool) external onlyAdmin {
        boringToken.disconnectPool(pool);
    }

    modifier onlyAdmin() {
        require(admin == msg.sender, "Not your pod");
        _;
    }
}

function createSleepPodBeacon(ISuperToken boringToken) returns (UpgradeableBeacon) {
    return new UpgradeableBeacon(address(new SleepPod(boringToken)));
}

function createSleepPod(UpgradeableBeacon sleepPodBeacon, address staker) returns (SleepPod) {
    bytes memory initCall = abi.encodeWithSelector(SleepPod.initialize.selector, staker);
    return SleepPod(address(new BeaconProxy(address(sleepPodBeacon), initCall)));
}
