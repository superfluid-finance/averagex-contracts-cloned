// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IERC20Metadata } from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

import { Torex, ISuperfluid } from "./Torex.sol";
import { UniswapV3PoolTwapObserver, IUniswapV3Pool } from "./UniswapV3PoolTwapObserver.sol";
import { Scaler, getScaler10Pow } from "../src/libs/Scaler.sol";


contract UniswapV3PoolTwapObserverFactory {
    function create(IUniswapV3Pool uniV3Pool, bool inverseOrder) external
        returns (UniswapV3PoolTwapObserver o)
    {
        o = new UniswapV3PoolTwapObserver(uniV3Pool, inverseOrder);
        o.transferOwnership(msg.sender);
    }
}

/**
 * @title Factory contract that stores the code of Torex
 */
contract TorexFactory {
    UniswapV3PoolTwapObserverFactory public immutable uniswapV3PoolTwapObserverFactory;

    constructor(UniswapV3PoolTwapObserverFactory f1) {
        uniswapV3PoolTwapObserverFactory = f1;
    }

    function createTorex(Torex.Config memory config) public
        returns (Torex torex)
    {
        torex = new Torex(config);
        ISuperfluid host = ISuperfluid(config.inToken.getHost());

        // register as SuperApp - on networks with permissioned SuperApp registration,
        // this requires the factory to be whitelisted
        host.registerAppByFactory(torex, torex.getConfigWord(true, true, true));
    }

    function createUniV3PoolTwapObserverAndTorex(IUniswapV3Pool uniV3Pool, bool inverseOrder,
                                                 Torex.Config memory config) external
        returns (Torex torex)
    {
        // leave these parameters auto-configured
        assert(address(config.observer) == address(0));
        assert(Scaler.unwrap(config.twapScaler) == 0);

        // creating the corresponding twap observer
        UniswapV3PoolTwapObserver observer;
        config.observer = observer = uniswapV3PoolTwapObserverFactory.create(uniV3Pool, inverseOrder);
        if (inverseOrder) {
            config.twapScaler = getScaler10Pow(int8(IERC20Metadata(uniV3Pool.token1()).decimals())
                                               - int8(IERC20Metadata(uniV3Pool.token0()).decimals()));
        } else {
            config.twapScaler = getScaler10Pow(int8(IERC20Metadata(uniV3Pool.token0()).decimals())
                                               - int8(IERC20Metadata(uniV3Pool.token1()).decimals()));
        }

        torex = createTorex(config);
        observer.transferOwnership(address(torex));
    }
}

function createTorexFactory() returns (TorexFactory) {
    return new TorexFactory(new UniswapV3PoolTwapObserverFactory());
}
