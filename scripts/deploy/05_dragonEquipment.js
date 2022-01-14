require("dotenv").config();

module.exports = async function ({
  ethers,
  getNamedAccounts,
  deployments,
  getChainId,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const URI = "https://aurum.dragoncrypto.io/json/equipment/";
  const devWallet = "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b";
  /**************************/

  await deploy("DragonEquipment", {
    from: deployer,
    log: true,
    args: [URI, devWallet],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["DragonEquipment", "DragonCryptoAurum"];
