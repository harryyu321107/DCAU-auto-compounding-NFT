// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
const { getBigNumber } = require("../scripts/shared");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const usdt = await deployments.get("MockUSDT");
  const timestamp = ~~(new Date().getTime() / 1000) + 100;

  await deploy("DragonNestSupporter", {
    from: deployer,
    log: true,
    args: [
      "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b",
      usdt.address,
      timestamp,
    ],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["DragonNestSupporter", "ERC721", "DragonCrypto"];
module.exports.dependencies = ["MockUSDT"];
