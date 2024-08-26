// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20Metadata } from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

import { Torex, ITorexController, ISuperfluid } from "./Torex.sol";
import { UniswapV3PoolTwapHoppableObserver } from "./UniswapV3PoolTwapHoppableObserver.sol";
import { Scaler, getScaler10Pow } from "../src/libs/Scaler.sol";


contract UniswapV3PoolTwapObserverFactory {
    function create(UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops_) external
        returns (UniswapV3PoolTwapHoppableObserver o)
    {
        o = new UniswapV3PoolTwapHoppableObserver(hops_);
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
        // if controller is not set, we assume msg.sender to be the controller
        if (address(config.controller) == address(0)) {
            config.controller = ITorexController(msg.sender);
        }

        torex = new Torex(config);
        ISuperfluid host = ISuperfluid(config.inToken.getHost());

        // register as SuperApp - on networks with permissioned SuperApp registration,
        // this requires the factory to be whitelisted
        host.registerAppByFactory(torex, torex.getConfigWord(true, true, true));
    }

    function createUniV3PoolTwapObserverAndTorex(UniswapV3PoolTwapHoppableObserver.UniV3PoolHop[] memory hops_,
                                                 Torex.Config memory config) external
        returns (Torex torex)
    {
        // leave these parameters auto-configured
        assert(address(config.observer) == address(0));
        assert(Scaler.unwrap(config.twapScaler) == 0);

        // creating the corresponding twap observer
        UniswapV3PoolTwapHoppableObserver observer;
        config.observer = observer = uniswapV3PoolTwapObserverFactory.create(hops_);

        // calculate the TWAP scaler
        address inToken = hops_[0].inverseOrder
            ? hops_[0].pool.token1()
            : hops_[0].pool.token0();

        uint256 lastHopIdx = hops_.length - 1;

        address outToken = hops_[lastHopIdx].inverseOrder
            ? hops_[lastHopIdx].pool.token0()
            : hops_[lastHopIdx].pool.token1();

        config.twapScaler = getScaler10Pow(int8(IERC20Metadata(inToken).decimals())
                                           - int8(IERC20Metadata(outToken).decimals()));

        torex = createTorex(config);
        observer.transferOwnership(address(torex));
    }
}

function createTorexFactory() returns (TorexFactory) {
    return new TorexFactory(new UniswapV3PoolTwapObserverFactory());
}
