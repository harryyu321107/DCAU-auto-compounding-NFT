// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
const { getBigNumber } = require("../scripts/shared");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("MockWAVAX", {
    from: deployer,
    log: true,
    args: ["Wrapped AVAX", "WAVAX", getBigNumber(1000000000)],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["WAVAX", "ERC20", "DragonCrypto"];
