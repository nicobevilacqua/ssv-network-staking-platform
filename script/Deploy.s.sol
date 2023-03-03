// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";

// import {ISSVNetwork} from "ssv-network/ISSVNetwork.sol";
// import {ISSVRegistry} from "ssv-network/ISSVRegistry.sol";
// import {IDepositContract} from "src/interfaces/IDepositContract.sol";

import "src/StakingPool.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address depositContractAddress = vm.envAddress("DEPOSIT_CONTRACT_ADDRESS");
        address SSVTokenAddress = vm.envAddress("SSV_TOKEN_ADDRESS");
        address SSVNetworkAddress = vm.envAddress("SSV_NETWORK_ADDRESS");
        address SSVRegistryAddress = vm.envAddress("SSV_REGISTRY_ADDRESS");
        address wethAddress = vm.envAddress("WETH_ADDRESS");
        address priceFeedAddress = vm.envAddress("ETH_USD_PRICE_FEED_ADDRESS");

        StakingPool stakingPool = new StakingPool(
            IDepositContract(depositContractAddress),
            ERC20(SSVTokenAddress),
            ISSVNetwork(SSVNetworkAddress),
            ISSVRegistry(SSVRegistryAddress),
            WETH(payable(wethAddress)),
            AggregatorV3Interface(priceFeedAddress)
        );

        console.log("StakingPool", address(stakingPool));

        vm.stopBroadcast();
    }
}
