<script lang="ts">
	import StakeForm from '$lib/StakeForm.svelte';
	import {signer, address, provider} from "$store/wallet";
	import {showNotification, NotificationType} from '$store/notifications';
	import {getStakingPoolContract} from '$utils/contracts';
	import {simulate} from '$utils/simulator';
	import { Contract } from 'ethers';

	let stakingContract: Contract | undefined;

	let loading = false;
	async function load() {
		loading = true;

		if (!$provider || !$address) {
			return;
		}
		
		stakingContract = await getStakingPoolContract();

		if (!stakingContract) {
			showNotification("Invalid Staking Pool Contract", {
				type: NotificationType.Error
			});
			return;
		}
	}

	let staking = false;
	async function stake() {
		if (!stakingContract) {
			showNotification("Invalid Staking Pool Contract", {
				type: NotificationType.Error
			});
			return;
		}
		staking = true;
		try {
			const rawTransaction = await stakingContract.populateTransaction.claim();
			const successfull = await simulate(rawTransaction);
			if (!successfull) {
				showNotification("The transaction will be reverted. Please, check the values", {
					type: NotificationType.Error
				});
				return;
			}
			const tx = await stakingContract.claim();
			const receipt = tx.wait();
			console.log(receipt);
			showNotification("Success", {
				type: NotificationType.Check
			});
		} catch(error) {
			console.error(error);
			showNotification(error.message, {
				type: NotificationType.Error
			});
		}
	}

	$: if($address) {
    load();
  }

	$: if ($signer) {
		load();
	}
</script>

<svelte:head>
	<title>Home</title>
	<meta name="description" content="Svelte demo app" />
</svelte:head>

<div class="hero min-h-screen bg-base-200">
	<div class="hero-content flex-col lg:flex-row-reverse">
		<div class="text-center lg:text-left">
			<h1 class="text-5xl font-bold">Stake ETH now to start earning rewards!</h1>
			<p class="py-6">
				You can stake any ETH amount you want and you will start participate in the ethereum
				consensus layer.
			</p>
			<p>
				Rewards will be distributed fairly between all the stakers. The more ETH you stake, the more
				rewards you will eran!
			</p>
		</div>
		<StakeForm />
	</div>
</div>
