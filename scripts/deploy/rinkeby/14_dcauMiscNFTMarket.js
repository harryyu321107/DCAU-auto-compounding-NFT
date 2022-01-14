// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
const { getBigNumber } = require("../scripts/shared");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const mockDCAU = await deployments.get("MockDCAU");

  await deploy("DCAUMiscNFTMarket", {
    from: deployer,
    log: true,
    args: [
      mockDCAU.address,
      "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b",
      "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b",
    ],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["DCAUMiscNFTMarket", "ERC721", "DragonCrypto"];
module.exports.dependencies = ["MockDCAU"];
