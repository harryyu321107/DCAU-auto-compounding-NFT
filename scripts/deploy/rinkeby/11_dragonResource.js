// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
const { getBigNumber } = require("../scripts/shared");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("DragonResource", {
    from: deployer,
    log: true,
    args: [
      "https://raw.githubusercontent.com/snowwhitedev/nft_metadata/master/dragon_resource/",
      "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b",
    ],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["DragonEquipment", "ERC1155", "DragonCrypto"];
