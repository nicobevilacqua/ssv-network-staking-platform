// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "src/StakingPool.sol";

contract AddRewards is Script {
    StakingPool private stakingPool;

    function setUp() public {}

    function run() public {
        address stakingPoolAddress = vm.envAddress("STAKING_POOL_ADDRESS");
        stakingPool = StakingPool(payable(stakingPoolAddress));
        vm.startBroadcast();

        uint256 amount = 10 ether;

        address(stakingPool).call{value: amount}("");

        vm.stopBroadcast();
    }
}
