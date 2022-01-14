// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
const { getBigNumber } = require("../scripts/shared");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const dragonEquipment = await deployments.get("DragonEquipment");

  await deploy("DragonPlayerCharacter", {
    from: deployer,
    log: true,
    args: [
      dragonEquipment.address,
      "https://raw.githubusercontent.com/snowwhitedev/dragon-assets/master/character/",
    ],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["DragonPlayerCharacter", "ERC721", "DragonCrypto"];
module.exports.dependencies = ["MockDCAU", "DragonEquipment"];
