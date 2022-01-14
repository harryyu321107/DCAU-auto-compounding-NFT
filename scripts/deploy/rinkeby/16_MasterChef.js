// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
require("dotenv").config();
const { getBigNumber } = require("../scripts/shared");

module.exports = async function ({
  ethers,
  getNamedAccounts,
  deployments,
  getChainId,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const mockDCAU = await deployments.get("MockDCAU");
  const dragonNestSupporter = await deployments.get("DragonNestSupporter");
  const dcauNFTMarket = await deployments.get("DCAUNFTMarket");

  const dcau = mockDCAU.address;
  const feeAddress = "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b";
  const startTime = ~~(new Date().getTime() / 1000 + 500);
  const dcauPerBlock = getBigNumber(5, 16); // 0.05 dcau
  const devWallet = "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b";
  await deploy("MasterChef", {
    from: deployer,
    log: true,
    args: [
      dcau,
      dragonNestSupporter.address,
      devWallet,
      feeAddress,
      startTime,
      dcauPerBlock,
      devWallet,
      dcauNFTMarket.address,
    ],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["MasterChef", "DragonCrypto"];
module.exports.dependencies = [
  "DragonNestSupporter",
  "MockDCAU",
  "DCAUNFTMarket",
];
