// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {WETH} from "solmate/tokens/WETH.sol";

import {ISSVNetwork} from "ssv-network/ISSVNetwork.sol";
import {ISSVRegistry} from "ssv-network/ISSVRegistry.sol";

import {IDepositContract} from "./interfaces/IDepositContract.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract StakingPool is Owned, ERC4626 {
    enum IsActive{ NONE, FALSE, TRUE }

    uint256 private constant VALIDATOR_STAKE_AMOUNT = 32 ether;

    mapping(bytes32 => Validator) public validators;
    uint256 public totalValidators;
    uint256 public totalValidatorStakes;

    IDepositContract public immutable depositContract;
    ISSVNetwork public immutable SSVNetwork;
    ISSVRegistry public immutable SSVRegistry;
    ERC20 public immutable SSVToken;
    AggregatorV3Interface internal immutable priceFeed;

    struct Validator {
        bytes pubkey;
        uint32[] operatorIds;
        bytes[] sharesPublicKeys;
        bytes[] sharesEncrypted;
        uint256 amount;
        IsActive active;
    }

    /* EVENTS */
    event ValidatorRegistered(bytes32 pubKeyHash, uint256 timestamp);
    event ValidatorRemoved(bytes32 pubKeyHash, uint256 timestamp);
    event ValidatorStakeDeposited(bytes32 pubKeyHash, uint256 timestamp);
    event StakeReached(uint256 stakeCount);

    event RewardIndexUpdated(
        address indexed from,
        uint256 reward,
        uint256 timestamp
    );
    event Staked(address indexed from, uint256 amount, uint256 timestamp);
    event Unstaked(address indexed from, uint256 amount, uint256 timestamp);
    event Claimed(address indexed from, uint256 amount, uint256 timestamp);

    /* ERRORS */
    error InvalidAmount();
    error ValidatorAlreadyExists(bytes32 pubKeyHash, uint256 timestamp);

    constructor(
        IDepositContract _depositContract,
        ERC20 _SSVToken,
        ISSVNetwork _SSVNetwork,
        ISSVRegistry _SSVRegistry,
        ERC20 _weth,
        AggregatorV3Interface _priceFeedAddress
    ) Owned(msg.sender) ERC4626(_weth, "pool SSV token", "PSSV") {
        depositContract = _depositContract;
        SSVToken = _SSVToken;
        SSVRegistry = _SSVRegistry;
        SSVNetwork = _SSVNetwork;
        priceFeed = _priceFeedAddress;
    }

    receive() external payable {}

    function stake(uint256 _amount) public payable {
        if (msg.value > 0) {
            if (_amount != msg.value) { revert InvalidAmount(); }
            WETH(payable(address(asset))).deposit{value: _amount}();
        } else {
            if (_amount == 0) { revert InvalidAmount(); }
           asset.transferFrom(msg.sender, address(this), _amount);
        }

        uint256 remainder = asset.balanceOf(address(this)) - (totalValidatorStakes * VALIDATOR_STAKE_AMOUNT);

        if (remainder >= VALIDATOR_STAKE_AMOUNT) {
            unchecked {
                uint256 stakeCount = remainder / VALIDATOR_STAKE_AMOUNT;
                totalValidatorStakes = totalValidatorStakes + stakeCount;
                emit StakeReached(stakeCount);
            }
        }

        _mint(msg.sender, _amount);

        emit Staked(msg.sender, _amount, block.timestamp);
    }

    function unstake(uint256 _amount) external {
        _burn(msg.sender, _amount);

        asset.transferFrom(msg.sender, address(this), _amount);

        emit Unstaked(msg.sender, _amount, block.timestamp);
    }

    // todo
    function claim() external {

    }

    function registerValidator(
        bytes calldata pubKey,
        uint32[] calldata operatorIds,
        bytes[] calldata sharesPublicKeys,
        bytes[] calldata sharesEncrypted,
        uint256 amount
    ) external onlyOwner {
        bytes32 pubKeyHash = keccak256(pubKey);

        if (validators[pubKeyHash].active == IsActive.TRUE) {
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

        validators[pubKeyHash] = Validator(
            pubKey,
            operatorIds,
            sharesPublicKeys,
            sharesEncrypted,
            amount,
            IsActive.TRUE
        );

        unchecked { totalValidators = totalValidators + 1; }

        // Emit an event to log the deposit of shares
        emit ValidatorRegistered(pubKeyHash, block.timestamp);
    }

    function removeValidator(bytes calldata pubKey) external onlyOwner {
        bytes32 pubKeyHash = keccak256(pubKey);

        if (validators[pubKeyHash].active == IsActive.FALSE) {
            revert ValidatorAlreadyExists(pubKeyHash, block.timestamp);
        }

        SSVNetwork.removeValidator(pubKey);

        delete validators[pubKeyHash];

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

        // Emit an event to log the deposit of the public key
        emit ValidatorStakeDeposited(keccak256(pubKey), block.timestamp);
    }

    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    function getLatestPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }
}