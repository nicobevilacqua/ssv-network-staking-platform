// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ISSVNetwork} from "ssv-network/ISSVNetwork.sol";
import {ISSVRegistry} from "ssv-network/ISSVRegistry.sol";

import {IDepositContract} from "src/interfaces/IDepositContract.sol";
// import {StakingShareToken} from "src/StakingShareToken.sol";

import {StakingPool} from "src/StakingPool.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

import {StakingDataMock} from "./mocks/StakingDataMock.sol";

contract StakingPoolTest is Test, StakingDataMock {
    IDepositContract private depositContract;
    ISSVNetwork private ssvNetwork;
    ISSVRegistry private ssvRegistry;
    ERC20 private ssvToken;

    StakingPool private stakingPool;

    function setUp() external {
        address depositContractAddress = vm.envAddress(
            "DEPOSIT_CONTRACT_ADDRESS"
        );
        address SSVTokenAddress = vm.envAddress("SSV_TOKEN_ADDRESS");
        address SSVNetworkAddress = vm.envAddress("SSV_NETWORK_ADDRESS");
        address SSVRegistryAddress = vm.envAddress("SSV_REGISTRY_ADDRESS");

        depositContract = IDepositContract(depositContractAddress);
        ssvToken = ERC20(SSVTokenAddress);
        ssvNetwork = ISSVNetwork(SSVNetworkAddress);
        ssvRegistry = ISSVRegistry(SSVRegistryAddress);

        stakingPool = new StakingPool(
            depositContractAddress,
            SSVTokenAddress,
            SSVNetworkAddress,
            SSVRegistryAddress
        );

        vm.label(depositContractAddress, "DepositContract");
        vm.label(SSVTokenAddress, "SSVToken");
        vm.label(SSVNetworkAddress, "SSVNetwork");
        vm.label(SSVRegistryAddress, "SSVRegistryAddress");
        vm.label(address(this), "owner");

        deal(SSVTokenAddress, address(stakingPool), 100 ether);
    }

    function testStakingPool() external {
        address bob = makeAddr("bob");
        deal(bob, 100 ether);

        stakingPool.stake{value: 32 ether}();

        stakingPool.depositValidatorStaking(
            pubKey,
            withdrawal_credentials,
            signature,
            deposit_data_root
        );

        uint256 amount = 10 ether;

        stakingPool.registerValidator(
            pubKey,
            operatorIds,
            sharesPublicKeys,
            sharesEncrypted,
            amount
        );
    }
}
