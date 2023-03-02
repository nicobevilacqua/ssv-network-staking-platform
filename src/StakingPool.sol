// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {ISSVNetwork} from "ssv-network/ISSVNetwork.sol";
import {ISSVRegistry} from "ssv-network/ISSVRegistry.sol";

import {IDepositContract} from "./interfaces/IDepositContract.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// import {StakingShareToken} from "./StakingShareToken.sol";

//

contract StakingPool is Owned, ERC20 {
    AggregatorV3Interface internal immutable priceFeed;

    uint256 private constant VALIDATOR_STAKE_AMOUNT = 32 * 1e18;

    mapping(bytes32 => Validator) public validator;
    uint256 public totalValidators;

    // StakingShareToken public token;

    IDepositContract public immutable depositContract;
    ISSVNetwork public immutable SSVNetwork;
    ISSVRegistry public immutable SSVRegistry;
    ERC20 public immutable SSVToken;

    struct Validator {
        bytes pubkey;
        uint32[] operatorIds;
        bytes[] sharesPublicKeys;
        bytes[] sharesEncrypted;
        uint256 amount;
        bool active;
    }

    /* EVENTS */
    event ValidatorRegistered(bytes32 pubKeyHash, uint256 timestamp);
    event ValidatorRemoved(bytes32 pubKeyHash, uint256 timestamp);
    event ValidatorStakeDeposited(bytes32 pubKeyHash, uint256 timestamp);
    event StakeAmountReached(uint256 timestamp);

    event RewardIndexUpdated(
        address indexed from,
        uint256 reward,
        uint256 timestamp
    );
    event Staked(address indexed from, uint256 amount, uint256 timestamp);
    event Unstaked(address indexed from, uint256 amount, uint256 timestamp);
    event Claimed(address indexed from, uint256 amount, uint256 timestamp);

    /* ERRORS */
    error InvalidEthAmount();
    error ValidatorAlreadyExists(bytes32 pubKeyHash, uint256 timestamp);

    constructor(
        address _depositContract,
        // address _token,
        address _SSVToken,
        address _SSVNetwork,
        address _SSVRegistry,
        address _priceFeedAddress
    ) Owned(msg.sender) ERC20("Shared Token", "STKN", 18) {
        depositContract = IDepositContract(_depositContract);
        // token = StakingShareToken(_token);
        SSVToken = ERC20(_SSVToken);
        SSVRegistry = ISSVRegistry(_SSVRegistry);
        SSVNetwork = ISSVNetwork(_SSVNetwork);

        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    receive() external payable {}

    function stake() public payable {
        if (msg.value == 0) {
            revert InvalidEthAmount();
        }

        _mint(msg.sender, msg.value);

        emit Staked(msg.sender, msg.value, block.timestamp);

        if (address(this).balance >= VALIDATOR_STAKE_AMOUNT) {
            emit StakeAmountReached(block.timestamp);
        }
    }

    function unstake(uint256 amount) external {
        _burn(msg.sender, amount);

        SafeTransferLib.safeTransferETH(msg.sender, amount);

        emit Unstaked(msg.sender, amount, block.timestamp);
    }

    // todo
    function claim() external {}

    function registerValidator(
        bytes calldata pubKey,
        uint32[] calldata operatorIds,
        bytes[] calldata sharesPublicKeys,
        bytes[] calldata sharesEncrypted,
        uint256 amount
    ) external onlyOwner {
        bytes32 pubKeyHash = keccak256(pubKey);

        if (validator[pubKeyHash].active) {
            revert ValidatorAlreadyExists(pubKeyHash, block.timestamp);
        }

        SSVToken.approve(address(SSVNetwork), amount);

        // Register the validator and deposit the shares
        SSVNetwork.registerValidator(
            pubKey,
            operatorIds,
            sharesPublicKeys,
            sharesEncrypted,
            amount
        );

        validator[pubKeyHash] = Validator(
            pubKey,
            operatorIds,
            sharesPublicKeys,
            sharesEncrypted,
            amount,
            true
        );

        totalValidators++;

        // Emit an event to log the deposit of shares
        emit ValidatorRegistered(pubKeyHash, block.timestamp);
    }

    // todo: revisar como implementar esto (si es que se puede)
    function removeValidator(bytes calldata pubKey) external onlyOwner {
        bytes32 pubKeyHash = keccak256(pubKey);

        SSVNetwork.removeValidator(pubKey);

        delete validator[pubKeyHash];

        emit ValidatorRemoved(pubKeyHash, block.timestamp);
    }

    function depositValidatorStaking(
        bytes calldata pubKey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external onlyOwner {
        // Deposit the validator to the deposit contract
        depositContract.deposit{value: VALIDATOR_STAKE_AMOUNT}(
            pubKey,
            withdrawal_credentials,
            signature,
            deposit_data_root
        );

        bytes32 pubKeyHash = keccak256(pubKey);

        // Emit an event to log the deposit of the public key
        emit ValidatorStakeDeposited(pubKeyHash, block.timestamp);
    }

    function getLatestPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }
}
