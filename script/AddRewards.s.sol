// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {StakingPool} from "src/StakingPool.sol";

contract AddRewards is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address stakingPoolAddress = vm.envAddress("STAKING_POOL_ADDRESS");
        uint256 amount = vm.envUint("amount");

        StakingPool stakingPool = StakingPool(payable(stakingPoolAddress));

        // SEND REWARDS TO THE CONTRACT
        address(stakingPool).call{value: amount}("");

        vm.stopBroadcast();
    }
}
