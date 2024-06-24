// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";

import {
    BasicParticle, Value, FlowRate, Time
} from "@superfluid-finance/solidity-semantic-money/src/SemanticMoney.sol";

import { ITorex, ISuperfluidPool } from "../interfaces/torex/ITorex.sol";
import { UINT_100PCT_PM, toInt96 } from "../libs/MathExtra.sol";

import { DistributionFeeManager } from "./DistributionFeeManager.sol";


/**
 * @title Distribution incentive program that shares in-token fees with distributors.
 *
 * Note:
 * 1. For each trader on a TOREX, the program tracks who is the distributor for the trade.
 * 2. For each in-token where multiple TOREXes may apply,the program tracks total volume and total flow rate facilitated
 *    by each distributor. The summation stats of all distributors is called the totality stats.
 * 3. On top of pool units distributor to stakers, the program applies a tax in the form of pool units distributing to
 *    the DistributionFeeManager contract.
 */
library DistributionFeeDIP {
    /// This is a pseudo distributor address for tracking totality stats.
    address constant private _PSEUDO_DISTRIBUTOR_FOR_TOTALITY_STATS = address(1);

    /// Distribution tax rate of the total in token fee.
    uint256 constant internal DISTRIBUTION_TAX_RATE_PM = 22_0000; // 22%

    /// An event to track distributor changes.
    event DistributorUpdated(ITorex indexed torex, address trader,
                             address indexed prevDistributor, address indexed newDistributor);

    /// Distribution stats for the distributor of a specific in-token.
    struct DistributionStats {
        /// Using semantic money basic particle to track money stats
        BasicParticle particle;
    }

    /// The storage used by the library.
    struct Storage {
        /// Who the distributor for the trader is.
        mapping (ITorex => mapping (address trader => address distributor)) distributors;
        /// Tracking distribution stats of the distributor, including a pseudo distributor for totality stats.
        mapping (ITorex => mapping (address distributor => DistributionStats)) distributionStats;
    }
    // keccak256(abi.encode(uint256(keccak256("superboring.storage.DistributionFeeDIP")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant _STORAGE_SLOT = 0x5990d645d6cb97b16b2879948f5db335ce368c448d260d2450c28e7b1dcd3b00;
    // solhint-disable-next-line no-inline-assembly
    function _getStorage() private pure returns (Storage storage $) { assembly { $.slot := _STORAGE_SLOT } }

    /// Update distribution stats where a new distributor may replace the previous distributor
    function updateDistributionStats(ITorex torex, address trader, address distributor,
                                     int96 prevFlowRate, int96 newFlowRate) internal {
        Storage storage $ = _getStorage();
        Time tnow = Time.wrap(uint32(block.timestamp));

        address prevDistributor = $.distributors[torex][trader];
        DistributionStats storage curStats = $.distributionStats[torex][prevDistributor];
        DistributionStats storage totalityStats = $.distributionStats[torex][_PSEUDO_DISTRIBUTOR_FOR_TOTALITY_STATS];
        if (prevDistributor == distributor) {
            (curStats.particle, totalityStats.particle) = curStats.particle.shift_flow2b
                (totalityStats.particle, FlowRate.wrap(newFlowRate - prevFlowRate), tnow);
        } else {
            DistributionStats storage newStats = $.distributionStats[torex][distributor];
            (curStats.particle, totalityStats.particle) = curStats.particle.shift_flow2b
                (totalityStats.particle, FlowRate.wrap(-prevFlowRate), tnow);
            (newStats.particle, totalityStats.particle) = newStats.particle.shift_flow2b
                (totalityStats.particle, FlowRate.wrap(newFlowRate), tnow);
        }

        emit DistributorUpdated(torex, trader, distributor, prevDistributor);
    }

    /// Perform a distribution fee units update based applying the tax rate.
    function adjustDistributionFeeUnits(DistributionFeeManager manager, ITorex torex) internal
    {
        ISuperfluidPool pool = torex.feeDistributionPool();
        uint128 tu = pool.getTotalUnits();
        uint128 oldUnits = pool.getUnits(address(manager));
        uint128 newUnits = SafeCast.toUint128((tu - oldUnits) * DISTRIBUTION_TAX_RATE_PM / UINT_100PCT_PM);
        pool.updateMemberUnits(address(manager), newUnits);
    }

    /// Get the current distributor for the trader.
    function getCurrentDistributor(ITorex torex, address trader) internal view
        returns (address distributor)
    {
        return _getStorage().distributors[torex][trader];
    }

    /// Get the distribution stats for each distributor and each torex.
    function getDistributorStats(ITorex torex, address distributor) internal view
        returns (int256 distributedVolume, int96 totalFlowRate)
    {
        Storage storage $ = _getStorage();
        Time tnow = Time.wrap(uint32(block.timestamp));
        DistributionStats storage stats = $.distributionStats[torex][distributor];
        return (Value.unwrap(-stats.particle.rtb(tnow)),
                toInt96(FlowRate.unwrap(-stats.particle.flow_rate())));
    }

    /// Get the summation stats of all distributors and each torex.
    function getTotalityStats(ITorex torex) internal view
        returns (int256 distributedVolume, int96 totalFlowRate)
    {
        (distributedVolume, totalFlowRate) = getDistributorStats(torex, _PSEUDO_DISTRIBUTOR_FOR_TOTALITY_STATS);
        distributedVolume = -distributedVolume;
        totalFlowRate = -totalFlowRate;
    }
}
