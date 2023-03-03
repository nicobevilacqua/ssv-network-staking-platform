export const ERC20_ABI = [
	'function symbol() view returns (string)',
	'function balanceOf(address) view returns (uint)',
	'function transfer(address to, uint amount)'
];

export const STAKING_POOL_ABI = [
	'function totalValidatorStakes() view returns(uint256)',
	'function totalValidators() view returns(uint256)',
	'function totalEarned() view returns(uint256)'

	// 'function validator(bytes32) view returns (Validator memory)',
	// 'function stake()',
	// 'function unstake(uint256)',
	// 'function claim()',
	// 'function registerValidator(bytes,uint32[],bytes[],bytes[],uint256)',
	// 'function removeValidator(bytes)',
	// 'function depositValidatorStaking(bytes,bytes,bytes,bytes32)',
	// 'function getLatestPrice() view returns (int256)'
];
