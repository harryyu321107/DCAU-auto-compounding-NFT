// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
const { getBigNumber } = require("../scripts/shared");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("MockJOE", {
    from: deployer,
    log: true,
    args: ["JOE", "JOE", getBigNumber(1000000000)],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["JOE", "ERC20", "DragonCrypto"];
