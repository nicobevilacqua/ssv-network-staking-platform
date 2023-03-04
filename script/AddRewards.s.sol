// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {StakingPool} from "src/StakingPool.sol";

contract AddRewards is Script {
    StakingPool private stakingPool;

    function setUp() public {
        address stakingPoolAddress = vm.envAddress("STAKING_POOL_ADDRESS");
        stakingPool = StakingPool(payable(stakingPoolAddress));
    }

    function run() public {
        vm.startBroadcast();

        uint256 amount = 10 ether;

        // SEND REWARDS TO THE CONTRACT
        address(stakingPool).call{value: amount}("");

        vm.stopBroadcast();
    }
}
