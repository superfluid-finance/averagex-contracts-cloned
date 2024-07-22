// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import {
    ISuperToken, ISuperfluidPool, PoolConfig
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";
import { UUPSProxiable } from "@superfluid-finance/ethereum-contracts/contracts/upgradability/UUPSProxiable.sol";
import { UUPSProxy } from "@superfluid-finance/ethereum-contracts/contracts/upgradability/UUPSProxy.sol";


/**
 * @title Emission treasury takes custody of BORING and provides an interface of emission rates controls of BORING to
 *        targets to the QE TIP.
 */
contract EmissionTreasury is UUPSProxiable, Ownable {
    using SuperTokenV1Library for ISuperToken;

    event EmissionRateUpdated(address indexed emissionTarget, int96 emissionRate);

    event EmissionUnitsUpdated(address indexed emissionTarget, address member, uint128 units);

    ISuperToken immutable public boringToken;

    mapping (address emissionTarget => ISuperfluidPool) private _emissionPools;

    constructor(ISuperToken token) {
        boringToken = token;
    }

    function ensurePoolCreatedFor(address emissionTarget) external
        onlyOwner
    {
        if (address(_emissionPools[emissionTarget]) == address(0)) {
            _emissionPools[emissionTarget] = boringToken.createPool(address(this), PoolConfig({
                    transferabilityForUnitsOwner: false,
                    distributionFromAnyAddress: false
                    }));
        }
    }

    /*******************************************************************************************************************
     * View Functions
     ******************************************************************************************************************/

    function balanceLeft() external view
        returns (uint256)
    {
        return boringToken.balanceOf(address(this));
    }

    function getEmissionPool(address emissionTarget) external view
        returns (ISuperfluidPool)
    {
        return _emissionPools[emissionTarget];
    }

    function getEmissionRate(address emissionTarget) external view
        returns (int96 emissionRate)
    {
        if (address(_emissionPools[emissionTarget]) != address(0)) {
            return boringToken.getFlowDistributionFlowRate(address(this), _emissionPools[emissionTarget]);
        } else return 0;
    }

    function getMemberEmissionUnits(address emissionTarget, address member) external view
        returns (uint128 units)
    {
        return _emissionPools[emissionTarget].getUnits(member);
    }

    function getMemberEmissionRate(address emissionTarget, address member) external view
        returns (int96 emissionRate)
    {
        return _emissionPools[emissionTarget].getMemberFlowRate(member);
    }

    /*******************************************************************************************************************
     * Emission Target Controls
     ******************************************************************************************************************/

    /// Update flow rate for the emission target.
    function updateEmissionRate(address emissionTarget, int96 emissionRate) external
        onlyOwner
    {
        boringToken.distributeFlow(address(this), _emissionPools[emissionTarget], emissionRate);
        emit EmissionRateUpdated(emissionTarget, emissionRate);
    }

    /// Control individual member emission units.
    function updateMemberEmissionUnits(address emissionTarget, address member, uint128 units) external
        onlyOwner
    {
        _emissionPools[emissionTarget].updateMemberUnits(member, units);
        emit EmissionUnitsUpdated(emissionTarget, member, units);
    }

    /*******************************************************************************************************************
     * UUPS Upgradability
     ******************************************************************************************************************/

    function proxiableUUID() public pure override returns (bytes32) {
        return keccak256("superboring.contracts.EmissionTreasury.implementation");
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

/// Create an emission treasury. !WARNING! It must be initialized to the rightful owner as soon as possible.
function createEmissionTreasury(ISuperToken token) returns (EmissionTreasury r) {
    EmissionTreasury logic = new EmissionTreasury(token);
    logic.castrate();
    UUPSProxy proxy = new UUPSProxy();
    proxy.initializeProxy(address(logic));
    r = EmissionTreasury(address(proxy));
}
