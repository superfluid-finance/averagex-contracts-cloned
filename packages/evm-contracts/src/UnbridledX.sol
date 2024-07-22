// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { LiquidityMoveResult, ITorexController, ITorex, TorexMetadata } from "./interfaces/torex/ITorex.sol";
import { toInt96, INT_100PCT_PM } from "./libs/MathExtra.sol";


/**
 * @dev The unbridled torex controller.
 *
 * Note:
 *
 * Like many things in life, the unbridled ones cede control to the average ones eventually.
 *
 * UnbridledX is a torex controller and registry. It could charge a fee on in-tokens. Unshackled from all DeFi dramas,
 * curiously, it is ownable.
 */
contract UnbridledX is ITorexController, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    /*******************************************************************************************************************
     * Definitions
     ******************************************************************************************************************/

    struct TorexFeeConfig {
        uint256 inTokenFeePM;
        address inTokenFeeDest;
    }

    event TorexRegistered(ITorex indexed torex, TorexFeeConfig feeConfig);

    error ONLY_REGISTERED_TOREX_ALLOWED();

    /*******************************************************************************************************************
     * Configurations and Constructor
     ******************************************************************************************************************/

    address public immutable IN_TOKEN_FEE_DEST;

    EnumerableSet.AddressSet private _torexSet;
    mapping (ITorex => TorexFeeConfig) private _torexFeeConfigs;

    /*******************************************************************************************************************
     * Torex Registry (Non-thoughtful version, duck-typing of AverageX as a drop-in replacement for the UI)
     ******************************************************************************************************************/

    function getAllTorexesMetadata() external view
        returns (TorexMetadata[] memory metadataList)
    {
        uint256 nTorex = _torexSet.length();
        metadataList = new TorexMetadata[](nTorex);
        for (uint256 i = 0; i < nTorex; i++) {
            ITorex torex = ITorex(_torexSet.at(i));
            metadataList[i].torexAddr = address(torex);
            (metadataList[i].inToken, metadataList[i].outToken)  = torex.getPairedTokens();
        }
    }

    function registerTorex(ITorex torex, uint256 inTokenFeePM, address inTokenFeeDest) external
        onlyOwner
        returns (bool)
    {
        require(address(torex.controller()) == address(this), "not my jurisdiction");
        require(_torexSet.add(address(torex)), "already registered");

        _torexFeeConfigs[torex] = TorexFeeConfig(inTokenFeePM, inTokenFeeDest);

        // Fee destination to get all the in-token fees distributed.
        _updateFeeDestUnits(torex, 1);

        emit TorexRegistered(torex, _torexFeeConfigs[torex]);

        return true;
    }

    function unregisterTorex(ITorex torex) external
        onlyOwner
    {
        require(_torexSet.remove(address(torex)), "not registered");
    }

    function getFeeConfig(ITorex torex) external view
        returns (TorexFeeConfig memory config)
    {
        return _torexFeeConfigs[torex];
    }

    function updateFeeConfig(ITorex torex, uint256 inTokenFeePM, address inTokenFeeDest) external
        onlyOwner
        returns (bool)
    {
        _torexFeeConfigs[torex] = TorexFeeConfig(inTokenFeePM, inTokenFeeDest);
        return true;
    }

    function _updateFeeDestUnits(ITorex torex, uint128 units) internal {
        torex.feeDistributionPool().updateMemberUnits(_torexFeeConfigs[torex].inTokenFeeDest, units);
    }

    modifier onlyRegisteredTorex() {
        if (!_torexSet.contains(msg.sender)) revert ONLY_REGISTERED_TOREX_ALLOWED();
        _;
    }

    /*******************************************************************************************************************
     * Torex Controller Implementation
     ******************************************************************************************************************/

    // @inheritdoc ITorexController
    function getTypeId() external pure override returns (bytes32) { return keccak256("BelowAverageX"); }

    // @inheritdoc ITorexController
    function onInFlowChanged(address /*flowUpdater*/,
                             int96 /*prevFlowRate*/, int96 /*preFeeFlowRate*/, uint256 /*lastUpdated*/,
                             int96 newFlowRate, uint256 /*now*/,
                             bytes calldata /*userData*/) external view override
        onlyRegisteredTorex
        returns (int96 newFeeFlowRate)
    {
        return toInt96(newFlowRate
                       * int256(_torexFeeConfigs[ITorex(msg.sender)].inTokenFeePM)
                       / INT_100PCT_PM);
    }

    // @inheritdoc ITorexController
    function onLiquidityMoved(LiquidityMoveResult memory) external view override
        onlyRegisteredTorex
        returns (bool)
    {
        return true;
    }
}
