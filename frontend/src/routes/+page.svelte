<script lang="ts">
	import {address} from "$store/wallet";
	import {getStakingPoolContract} from '$utils/contracts';
	import {utils} from 'ethers';

	let stakingPoolContract;
	let totalEarned = 0;
	let totalValidators = 0;
	let totalValidatorStakes = 0;

	let loading = false;

	async function load() {
		stakingPoolContract = await getStakingPoolContract();

		if (!stakingPoolContract) {
			throw new Error('contract error');
		}

		[totalEarned, totalValidators, totalValidatorStakes] = await Promise.all([
				stakingPoolContract.totalEarned(),
				stakingPoolContract.totalValidators(),
				stakingPoolContract.totalValidatorStakes(),
		]);

		loading = false;
	}

	$: if($address) {
    load();
  }
</script>

<svelte:head>
	<title>D-Staker! - Ethereum stake service</title>
	<meta name="description" content="D-Staker! - Ethereum stake service" />
</svelte:head>

<div
	class="hero min-h-screen"
	style="background-image: url(/hero.jpg);"
>
	<div class="hero-overlay bg-opacity-30" />
	<div class="hero-content text-center text-neutral-content">
		<div class="max-w-md">
			<h1 class="mb-5 text-6xl font-bold">D-Staker!</h1>
			<p class="mb-5">
				Stake ETH, contribute on Ethereum and earn rewards with low risks!
			</p>
			<a class="btn btn-primary" href="/stake">Get Started</a>
		</div>
	</div>
</div>

<div class="w-full p-10">
	<div class="flex flex-row justify-around w-full my-5">
		<div class="flex flex-col justify-center">
			<p class="text-2xl font-bold  text-center">
				{utils.formatEther(totalValidatorStakes)}
			</p>
			<p class="uppercase text-center">
				Total staked
			</p>
		</div>
		<div class="flex flex-col justify-center">
			<p class="text-2xl font-bold  text-center">
				{totalValidators}
			</p>
			<p class="uppercase text-center">Validators</p>
		</div>
		<div class="flex flex-col justify-center">
			<p class="text-2xl font-bold  text-center">
				{utils.formatEther(totalEarned)}
			</p>
			<p class="uppercase text-center">rewards earned</p>
		</div>
	</div>
</div>
