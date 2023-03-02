// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";

// import {ISSVNetwork} from "ssv-network/ISSVNetwork.sol";
// import {ISSVRegistry} from "ssv-network/ISSVRegistry.sol";
// import {IDepositContract} from "src/interfaces/IDepositContract.sol";

import {StakingPool} from "src/StakingPool.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address depositContractAddress = vm.envAddress(
            "DEPOSIT_CONTRACT_ADDRESS"
        );
        address SSVTokenAddress = vm.envAddress("SSV_TOKEN_ADDRESS");
        address SSVNetworkAddress = vm.envAddress("SSV_NETWORK_ADDRESS");
        address SSVRegistryAddress = vm.envAddress("SSV_REGISTRY_ADDRESS");

        StakingPool stakingPool = new StakingPool(
            depositContractAddress,
            SSVTokenAddress,
            SSVNetworkAddress,
            SSVRegistryAddress
        );

        console.log("StakingPool", address(stakingPool));

        vm.stopBroadcast();
    }
}
