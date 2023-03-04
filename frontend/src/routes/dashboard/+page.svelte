<script lang="ts">
	import StakeForm from "$lib/StakeForm.svelte";
	import LastDeposits from "$lib/LastDeposits.svelte";
</script>

<svelte:head>
	<title>Home</title>
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
				<h3 class="font-bold text-2xl text-center">100.12 ETH</h3>
				<button class="btn btn-primary btn-wide mt-5">Unstake</button>
			</div>
		</div>
		<div class="flex flex-col items-center lg:text-left border-2 py-10 px-5 m-2">
			<h2 class="text-3xl font-bold text-center">Total Earned</h2>
			<p class="py-6">
				This is how much ETH you have earned and that you can claim.
			</p>
			<div class="flex flex-col justify-stretch">
				<h3 class="font-bold text-2xl text-center">1.12 ETH</h3>
				<button class="btn btn-primary btn-wide mt-5">Claim</button>
			</div>
		</div>
	</div>
	<LastDeposits />
	
</div>
