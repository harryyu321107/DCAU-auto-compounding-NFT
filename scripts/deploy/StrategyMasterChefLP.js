// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
// this script is for getting Metadata.json
// address[] memory _initialWalletPath, dcauAddress = _initialWalletPath[0]; withdrawFeeAddress = _initialWalletPath[1]; feeAddress = _initialWalletPath[2];
// address _vaultChefAddress,
// address _masterchefAddress,
// address _uniRouterAddress,
// uint256 _pid,
// address _wantAddress, // the token which we want to put in pool
// address _earnedAddress,
// address[] memory _earnedToWmaticPath,
// address[] memory _earnedToDcauPath,
// address[] memory _earnedToToken0Path,
// address[] memory _earnedToToken1Path

require("dotenv").config();

// This is for DCAU_LINK LP on rinkeby, pool id is 3
module.exports = async function ({
  ethers,
  getNamedAccounts,
  deployments,
  getChainId,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const mockDCAU = await deployments.get("MockDCAU");
  const vaultChef = await deployments.get("VaultChef");
  const masterChef = await deployments.get("MasterChef");

  const dcau =
    process.env.PRODUCTION_MODE === "development"
      ? mockDCAU.address
      : "0xmainnet dcau address here";
  const withdrawFeeAddress = "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b";
  const feeAddress = "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b";

  const uniRouterAddress = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
  const pid = 3;
  const wantAddress = "0xb500aa687c59919b8031d885129178315f47e320"; // DCAU_LINK on rinkeby
  const linkAddress = "0xA41F61747BcdA7E3c945054c3da111d364E031Aa"; // Link on rinkeby
  const WETH = "0xc778417e063141139fce010982780140aa0cd5ab";
  await deploy("StrategyMasterChefLP", {
    from: deployer,
    log: true,
    args: [
      [dcau, withdrawFeeAddress, feeAddress],
      vaultChef.address,
      masterChef.address,
      uniRouterAddress,
      pid,
      wantAddress,
      dcau, // dcau
      [dcau, WETH],
      [dcau, dcau],
      [dcau, dcau],
      [dcau, linkAddress],
    ],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["StrategyMasterChef", "DragonCrypto"];
module.exports.dependencies = ["MockDCAU", "VaultChef", "MasterChef"];
