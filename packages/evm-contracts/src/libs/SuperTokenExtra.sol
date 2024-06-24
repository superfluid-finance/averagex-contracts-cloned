// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {
    ISuperfluid, ISuperToken, ISuperTokenFactory
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";
import { PureSuperToken } from "@superfluid-finance/ethereum-contracts/contracts/tokens/PureSuperToken.sol";


/**
 * @title Additional extensions of SuperTokenV1Library
 */
library SuperTokenV1LibraryExtension {
    using SuperTokenV1Library for ISuperToken;

    function flow(ISuperToken token, address receiver, int96 flowRate) internal returns (bool) {
        int96 prevFlowRate = token.getFlowRate(address(this), receiver);

        if (flowRate > 0) {
            if (prevFlowRate == 0) {
                return token.createFlow(receiver, flowRate);
            } else if (prevFlowRate != flowRate) {
                return token.updateFlow(receiver, flowRate);
            } // else no change, do nothing
        } else if (flowRate == 0) {
            if (prevFlowRate > 0) {
                return token.deleteFlow(address(this), receiver);
            } // else no change, do nothing
        } else assert(false); // should not happen

        return true;
    }
}

function deployPureSuperToken(ISuperfluid host, string memory name, string memory symbol, uint256 initialSupply)
    returns (ISuperToken pureSuperToken)
{
    ISuperTokenFactory factory = host.getSuperTokenFactory();

    PureSuperToken pureSuperTokenProxy = new PureSuperToken();
    factory.initializeCustomSuperToken(address(pureSuperTokenProxy));
    pureSuperTokenProxy.initialize(name, symbol, initialSupply);

    pureSuperToken = ISuperToken(address(pureSuperTokenProxy));
}
