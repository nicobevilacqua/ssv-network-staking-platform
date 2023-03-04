export const ERC20_ABI = [
	'function symbol() view returns (string)',
	'function balanceOf(address) view returns (uint)',
	'function transfer(address to, uint amount)'
];

export const STAKING_POOL_ABI = [
	'function totalValidatorStakes() view returns(uint256)',
	'function totalValidators() view returns(uint256)',
	'function totalEarned() view returns(uint256)',
	'function symbol() view returns (string)',
	'function balanceOf(address) view returns (uint)',
	'function stake()',
	'function claim()',
	'function unstake(uint256)',
	'function getLatestPrice() view returns (int256)',
	'function calcRewards(address) view returns (uint256)',
	'function calcRewardsInUSD(address) view returns (uint256)',
	'function getLatestPrice() view returns (uint256)'
];
