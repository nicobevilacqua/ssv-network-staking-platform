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
source .env && anvil --fork-url $INFURA_RPC_URL

# run the test locally
source .env && forge test --fork-url $INFURA_RPC_URL -vvv

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

## Deploy on local node

### First terminal
```sh
source .env && anvil --fork-url $INFURA_RPC_URL
```

### Second Terminal
```sh
source .env && forge script ./script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```


### Deploy with tenderly gateway
```sh
source .env && forge script ./script/Deploy.s.sol --rpc-url https://goerli.gateway.tenderly.co/4qcCAJIkvm7jWdk51yzcu9 --broadcast --private-key $PRIVATE_KEY --legacy
```

### USE fRPC

1 - Clone https://github.com/fluencelabs/fRPC-Substrate
2 - Follow the guide

```sh
npm run run configs/quickstart_config.json
```



### Use ganache for local testing

1 - 

```sh
source .env && forge script ./script/Deploy.s.sol --rpc-url http://127.0.01:8545 --broadcast --private-key 0xa545b25e3591733f315337baaf4d972104470122f39a441295d8378c6ee05edb
```