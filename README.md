## Setup
1 - Install https://github.com/ethereum/staking-deposit-cli


## Create validator keys

```sh
./deposit.sh new-mnemonic --num_validators=<NUM_VALIDATORS> --mnemonic_language=english --chain=<CHAIN_NAME> --folder=<YOUR_FOLDER_PATH>
```

get operators
// https://api.ssv.network/api/v2/prater/operators - list all operators
// https://api.ssv.network/api/v2/prater/operators/42/? - get an operator data


# run the node
source .env.local && anvil --fork-url $INFURA_RPC_URL

# run the test locally
source .env.local && forge test --fork-url $INFURA_RPC_URL -vvv

# run tests on local node

# Initialization Stage
1 - Generate validator keys through ethereum staking service
2 - Select operators from ssv through ssv api (batches of four operators)
3 - Validator key distribution among operators using ssv key distributor service
4 - Registry validators in registry contract
5 - Fund operators with sufficient ssv tokens

* NOTE: validator could be registry after the stake reachs 32 ether (on demand)

# 


```sh
source .env.local && forge test --fork-url $INFURA_RPC_URL
```