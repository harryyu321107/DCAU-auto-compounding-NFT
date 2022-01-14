require("dotenv").config();

module.exports = async function ({
  ethers,
  getNamedAccounts,
  deployments,
  getChainId,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const DCAU = "0xF72Cc18218058722a3874b63487F1B4C82F92081"; // DCAU on fuji
  const feeAddress = "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b";
  const dragonEquipment = await deployments.get("DragonEquipment");

  /**************************/

  await deploy("DragonPlayerCharacter", {
    from: deployer,
    log: true,
    args: [DCAU, feeAddress, dragonEquipment.address],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["DragonPlayerCharacter", "DragonCryptoAurum"];
module.exports.dependencies = ["DragonEquipment"];
