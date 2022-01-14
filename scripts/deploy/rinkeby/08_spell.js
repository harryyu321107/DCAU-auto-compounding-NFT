// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
const { getBigNumber } = require("../scripts/shared");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("MockSpell", {
    from: deployer,
    log: true,
    args: ["SPELL", "SPELL", getBigNumber(1000000000)],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["Spell", "ERC20", "DragonCrypto"];
