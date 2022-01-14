// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
const { getBigNumber } = require("../scripts/shared");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("DragonEquipment", {
    from: deployer,
    log: true,
    args: [
      "https://raw.githubusercontent.com/snowwhitedev/dragon-assets/master/equipments/",
    ],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["DragonEquipment", "ERC721", "DragonCrypto"];
