// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { UUPSProxiable } from "@superfluid-finance/ethereum-contracts/contracts/upgradability/UUPSProxiable.sol";
import { UUPSProxy } from "@superfluid-finance/ethereum-contracts/contracts/upgradability/UUPSProxy.sol";
import {
    SuperTokenV1Library, ISuperToken, ISuperfluidPool, PoolConfig
} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

import { ITorex } from "../interfaces/torex/ITorex.sol";

/// The program that uses the fee manager must provide this interface.
interface IDistributorUnitsProvider {
    /// Calculate pool units for the distributor according the program, based on their performance stats.
    function getDistributorUnits(ITorex torex, address distributor) external view returns (uint128);
}

/**
 * @title Distribution fee manager for the distribution fee program.
 *
 * Note:
 * 1. Distribution fees is distributed to this contract first.
 * 2. Distribution fees is further distributed to the distributors according to their performance stats.
 * 3. Distributors are responsible themselves to synchronize the manager with their performance stats, whilst the sync
 *    operation is permission-less and yields the same result regardless who did it.
 */
contract DistributionFeeManager is UUPSProxiable, Ownable {
    using SuperTokenV1Library for ISuperToken;

    event DistributorStatsSynced(ITorex indexed torex, address indexed distributor,
                                 ISuperToken indexed inToken, uint256 distributedAmount, uint128 units);

    /// Each torex needs their own distribution fee pools.
    mapping (ITorex => ISuperfluidPool) public pools;

    /// Synchronize a distributor performance stats for a specific torex.
    function sync(ITorex torex, address distributor) public {
        // ensure pool is created
        (ISuperToken inToken,) = torex.getPairedTokens();
        ISuperfluidPool pool = pools[torex];
        if (address(pool) == address(0)) {
            pools[torex] = pool = inToken.createPool(address(this), PoolConfig({
                    transferabilityForUnitsOwner: false,
                    distributionFromAnyAddress: true
                    }));
        }

        // distribute all in-tokens to distributors
        inToken.claimAll(torex.feeDistributionPool(), address(this));
        uint256 inTokenStored = inToken.balanceOf(address(this));
        inToken.distributeToPool(address(this), pool, inTokenStored);

        // claim for the distributor
        inToken.claimAll(pool, distributor);

        // sync units based on distribution stats
        uint128 units = IDistributorUnitsProvider(owner()).getDistributorUnits(torex, distributor);
        pool.updateMemberUnits(distributor, units);

        emit DistributorStatsSynced(torex, distributor, inToken, inTokenStored, units);
    }

    /// Batch the sync operations of torexes for a distributor.
    function batchSync(ITorex[] calldata torexes, address distributor) external {
        for (uint256 i = 0; i < torexes.length; ++i) sync(torexes[i], distributor);
    }

    /*******************************************************************************************************************
     * UUPS Upgradability
     ******************************************************************************************************************/

    function proxiableUUID() public pure override returns (bytes32) {
        return keccak256("superboring.contracts.DistributionFeeManager.implementation");
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

function createDistributionFeeManager() returns (DistributionFeeManager r) {
    DistributionFeeManager logic = new DistributionFeeManager();
    logic.castrate();
    UUPSProxy proxy = new UUPSProxy();
    proxy.initializeProxy(address(logic));
    r = DistributionFeeManager(address(proxy));
}
