<script lang="ts">
	import LastDeposits from "$lib/LastDeposits.svelte";
	import {getStakingPoolContract} from "$utils/contracts";
	import {signer, address, provider} from "$store/wallet";
	import {BigNumber, utils} from 'ethers';
	const {formatEther} = utils;

	let loading = false;
	let stakingContract; 
	let symbol: string = '';
	let totalEarned = BigNumber.from(0);
	let totalEarnedInUSD = BigNumber.from(0);
	let totalStaked = BigNumber.from(0);
	let totalStakedInUSD = BigNumber.from(0);

	async function load() {
		loading = true;

		if (!$provider || !$address) {
			return;
		}

		stakingContract = await getStakingPoolContract();

		if (!stakingContract) {
			throw new Error("invalid contract");
		}

		[totalEarned, totalEarnedInUSD, totalStaked, totalStakedInUSD, symbol] = await Promise.all([
			stakingContract.calcRewards($address),
			stakingContract.calcRewardsInUSD($address),
			stakingContract.balanceOf($address),
			stakingContract.totalStakedInUSD($address),
			stakingContract.symbol(),
		]);
	}

	$: if ($signer) {
		load();
	}

	$: if ($address) {
		load();
	}
</script>

<svelte:head>
	<title>Dashboard</title>
	<meta name="description" content="Svelte demo app" />
</svelte:head>

<div class="min-h-screen bg-base-200 flex flex-col w-full items-center py-10">
	<div class="flex flex-col my-5">
		<h1 class="text-5xl">Dashboard</h1>
	</div>
	<div class="flex flex-row lg:flex-row-reverse">
		<div class="flex flex-col items-center lg:text-left border-2 py-10 px-5 m-2">
			<h2 class="text-3xl font-bold text-center">Total Staked</h2>
			<p class="py-6">
				This is how much ethere you have staked in the platform
			</p>
			<div class="flex flex-col justify-stretch">
				{#if totalStaked.gt(0)}
					<h3 class="font-bold text-2xl text-center">{formatEther(totalStaked)} ETH</h3>
					<h4 class="text-center">{formatEther(totalStakedInUSD)} USD</h4>
					<button 
						class="btn btn-primary btn-wide mt-5"
						class:disabled={totalStaked.eq(0)}
						disabled={totalStaked.eq(0)}
					>Unstake</button>
				{:else}
					<p class="">You have not staked anything yet</p>
				{/if}
			</div>
		</div>
		<div class="flex flex-col items-center lg:text-left border-2 py-10 px-5 m-2">
			<h2 class="text-3xl font-bold text-center">Total Earned</h2>
			<p class="py-6">
				This is how much ETH you have earned and that you can claim.
			</p>
			<div class="flex flex-col justify-stretch">
				{#if totalEarned.gt(0)}
					<h3 class="font-bold text-2xl text-center">{formatEther(totalEarned)} ETH</h3>
					<h4 class="text-center">{formatEther(totalEarnedInUSD)} USD</h4>
					<button 
						class="btn btn-primary btn-wide mt-5" 
						class:disabled={totalEarned.eq(0)}
						disabled={totalEarned.eq(0)}
					>Claim</button>
				{:else}
					<p class="">You have not earned anything yet</p>
				{/if}
			</div>
		</div>
	</div>
	<LastDeposits />
	
</div>
