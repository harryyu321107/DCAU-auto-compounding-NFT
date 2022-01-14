// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
require("dotenv").config();
const deployedTokens = require("../scripts/args/tokens_dev.json");

module.exports = async function ({
  ethers,
  getNamedAccounts,
  deployments,
  getChainId,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const stableCoin =
    process.env.PRODUCTION_MODE === "development"
      ? "0x3D900d5268a33F8f4e06BD6c157abEb789460BA5" // USDTe on fuji
      : "0xmainnet usdc address here";
  const devWallet =
    process.env.PRODUCTION_MODE === "development"
      ? "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b"
      : "0xmainnet address here";
  const saleTimeStamp = ~~(new Date().getTime() / 1000 + 50);

  await deploy("DragonNestSupporter", {
    from: deployer,
    log: true,
    args: [devWallet, stableCoin, saleTimeStamp],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["DragonNestSupporter", "DragonCrypto"];
