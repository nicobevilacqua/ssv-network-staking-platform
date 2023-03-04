const { SSVKeys } = require("ssv-keys");

const keystores = [
  require("../config/keystores/keystore1.json"),
  require("../config/keystores/keystore2.json"),
  require("../config/keystores/keystore3.json"),
  require("../config/keystores/keystore4.json"),
  require("../config/keystores/keystore5.json"),
];

const deposits = [
  require("../config/deposits/deposit1.json"),
  require("../config/deposits/deposit2.json"),
  require("../config/deposits/deposit3.json"),
  require("../config/deposits/deposit4.json"),
  require("../config/deposits/deposit5.json"),
];

const axios = require("axios");

async function getOperators() {
  const { data } = await axios.get(
    `https://api.ssv.network/api/v2/prater/operators`
  );

  const filteredOperators = data.operators.filter(
    ({ is_active, status, is_valid, is_deleted }) =>
      !!is_active && !is_deleted && is_valid && status === "Active"
  ); // this is paginated

  const choosenOperators = [];
  for (let i = 0; i < 4; i++) {
    const index = Math.floor(Math.random() * filteredOperators.length);
    const operator = filteredOperators[index];
    filteredOperators[index] = filteredOperators[filteredOperators.length - 1];
    filteredOperators.pop();
    choosenOperators.push({
      id: parseInt(operator.id, 10),
      publicKey: operator.public_key,
    });
  }
  return choosenOperators;
}

function generateValidatorData() {
  const index = Math.floor(Math.random() * keystores.length);

  const keystore = keystores[index];
  keystores[index] = keystores[keystores.length];
  keystores.pop();

  const deposit = deposits[index];
  deposits[index] = deposits[deposits.length];
  deposits.pop();

  return { keystore, deposit };
}

async function main() {
  const { keystore, deposit } = generateValidatorData();
  const ssvKeys = new SSVKeys(SSVKeys.VERSION.V3);
  const keystorePassword = process.env.KEYSTORE_PASSWORD;
  const privateKey = await ssvKeys.getPrivateKeyFromKeystoreData(
    keystore,
    keystorePassword
  );

  const operators = await getOperators();

  const operatorIds = operators.map(({ id }) => id);

  const encryptedShares = await ssvKeys.buildShares(
    privateKey,
    operatorIds,
    operators.map(({ publicKey }) => publicKey)
  );

  const payload = await ssvKeys.buildPayload({
    publicKey: ssvKeys.publicKey,
    operatorIds,
    encryptedShares,
  });

  const keyShares = await ssvKeys.keyShares.fromJson({
    version: "v3",
    data: {
      operators,
      publicKey: ssvKeys.publicKey,
      encryptedShares,
    },
    payload,
  });

  const {
    data: {
      publicKey,
      operators: o,
      shares: { publicKeys, encryptedKeys },
    },
  } = keyShares;

  const depositValidatorStakingData = {
    pubKey: deposit.pubkey,
    withdrawal_credentials: deposit.withdrawal_credentials,
    signature: deposit.signature,
    deposit_data_root: deposit.deposit_data_root,
  };

  const registerValidatorData = {
    pubKey: keyShares.data.publicKey,
    operatorIds: keyShares.data.operators.map(({ id }) => id),
    sharesPublicKeys: keyShares.data.shares.publicKeys,
    sharesEncrypted: keyShares.data.shares.encryptedKeys,
  };

  console.log(depositValidatorStakingData, registerValidatorData);

  return {
    validatorPublicKey: publicKey,
    operators: o,
    sharePublicKeys: publicKeys,
    shareEncrypted: encryptedKeys,
  };
}

main().then((data) => console.log(JSON.stringify(data, null, 2)));
