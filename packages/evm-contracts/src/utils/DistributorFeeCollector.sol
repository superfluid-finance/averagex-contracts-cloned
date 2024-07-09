// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { UUPSProxiable } from "@superfluid-finance/ethereum-contracts/contracts/upgradability/UUPSProxiable.sol";
import { UUPSProxy } from "@superfluid-finance/ethereum-contracts/contracts/upgradability/UUPSProxy.sol";
import { ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

import { DistributionFeeManager } from "../BoringPrograms/DistributionFeeManager.sol";

/**
 * @title A contract to participate in the distribution fee program.
 *
 * Notes:
 *
 * ## On Workflows
 *
 * 1. An automation process must call DistributionFeeManager.batchSync(torex, collector) for all torexes, which
 *   a. claim all inTokens for the collector, using current units
 *   b. sync collector's units according to the amount of total distribution it has done
 * 2. Collector owner then can withdraw inTokens any time.
 */
contract DistributorFeeCollector is UUPSProxiable, Ownable {
    DistributionFeeManager public immutable manager;

    constructor (DistributionFeeManager m) {
        manager = m;
    }

    function withdraw(ISuperToken inToken, address to) external
        onlyOwner
    {
        inToken.transfer(to, inToken.balanceOf(address(this)));
    }

    /*******************************************************************************************************************
     * UUPS Upgradability
     ******************************************************************************************************************/

    function proxiableUUID() public pure override returns (bytes32) {
        return keccak256("superboring.contracts.DistributorFeeCollector.implementation");
    }

    function initialize(address owner) external initializer {
        _transferOwnership(owner);
    }

    function updateCode(address newAddress) external override
        onlyOwner
    {
        _updateCodeAddress(newAddress);
    }
}

function createDistributorFeeCollector(DistributionFeeManager manager, address newOwner)
    returns (DistributorFeeCollector r)
{
    DistributorFeeCollector logic = new DistributorFeeCollector(manager);
    logic.castrate();
    UUPSProxy proxy = new UUPSProxy();
    proxy.initializeProxy(address(logic));
    r = DistributorFeeCollector(address(proxy));
    r.initialize(newOwner);
}
