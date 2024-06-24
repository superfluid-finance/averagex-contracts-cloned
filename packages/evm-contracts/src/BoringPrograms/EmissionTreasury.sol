// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import {
    ISuperToken, ISuperfluidPool, PoolConfig
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";
import { UUPSProxiable } from "@superfluid-finance/ethereum-contracts/contracts/upgradability/UUPSProxiable.sol";
import { UUPSProxy } from "@superfluid-finance/ethereum-contracts/contracts/upgradability/UUPSProxy.sol";


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

    function updateEmissionRate(address emissionTarget, int96 emissionRate) external
        onlyOwner
    {
        emit EmissionRateUpdated(emissionTarget, emissionRate);
        boringToken.distributeFlow(address(this), _emissionPools[emissionTarget], emissionRate);
    }

    function updateEmissionUnits(address emissionTarget, address member, uint128 units) external
        onlyOwner
    {
        emit EmissionUnitsUpdated(emissionTarget, member, units);
        _emissionPools[emissionTarget].updateMemberUnits(member, units);
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

function createEmissionTreasury(ISuperToken token) returns (EmissionTreasury r) {
    EmissionTreasury logic = new EmissionTreasury(token);
    logic.castrate();
    UUPSProxy proxy = new UUPSProxy();
    proxy.initializeProxy(address(logic));
    r = EmissionTreasury(address(proxy));
}
