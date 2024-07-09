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
 * @title Sleep pods are contracts where BORING token stays for the stakers before the transferable event.
 *
 * Note:
 * - This is a beacon proxy.
 */
contract SleepPod is BeaconProxiable {
    using SuperTokenV1Library for ISuperToken;

    function proxiableUUID() override public pure returns (bytes32) {
        return keccak256("SuperBoring.contracts.SleepPod");
    }

    /// The admin for the pod's functionality. But the admin does not own those BORING.
    address     public immutable admin;
    /// The BORING token address.
    ISuperToken public immutable boringToken;

    /// Each pod belongs to a staker.
    address public staker;

    constructor(address admin_, ISuperToken boringToken_) {
        admin = admin_;
        boringToken = boringToken_;
    }

    /// Initialization code used during BeaconProxy constructor.
    function initialize(address staker_) external initializer {
        staker = staker_;
    }

    /// Approve pod's BORING for the staker.
    function approve(address target, uint256 amount) external onlyAdmin {
        boringToken.approve(target, amount);
    }

    /// Connect the pod's to a pool
    function connectPool(ISuperfluidPool pool) external onlyAdmin {
        boringToken.connectPool(pool);
    }

    /// Disconnect the pod from a pool
    function disconnectPool(ISuperfluidPool pool) external onlyAdmin {
        boringToken.disconnectPool(pool);
    }

    modifier onlyAdmin() {
        require(admin == msg.sender, "Not your pod");
        _;
    }
}

function createSleepPodBeacon(address admin, ISuperToken boringToken) returns (UpgradeableBeacon) {
    return new UpgradeableBeacon(address(new SleepPod(admin, boringToken)));
}

event SleepPodCreated(address indexed staker, SleepPod indexed pod);

function createSleepPod(UpgradeableBeacon sleepPodBeacon, address staker) returns (SleepPod pod) {
    bytes memory initCall = abi.encodeWithSelector(SleepPod.initialize.selector, staker);
    pod = SleepPod(address(new BeaconProxy(address(sleepPodBeacon), initCall)));
    emit SleepPodCreated(staker, pod);
}
