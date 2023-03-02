const { SSVKeys } = require("ssv-keys");

const keystore = require("./config/validator_keys/keystore-m_12381_3600_0_0_0-1677727151.json");

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

async function main() {
  const ssvKeys = new SSVKeys(SSVKeys.VERSION.V3);
  const keystorePassword = "peronperon";
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

  return {
    validatorPublicKey: publicKey,
    operators: o,
    sharePublicKeys: publicKeys,
    shareEncrypted: encryptedKeys,
  };
}

main().then((data) => console.log(JSON.stringify(data, null, 2)));
