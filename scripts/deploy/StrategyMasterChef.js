// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
// this script is for getting Metadata.json
// address[] memory _initialWalletPath,  dcauAddress = _initialWalletPath[0]; withdrawFeeAddress = _initialWalletPath[1]; feeAddress = _initialWalletPath[2];
// address _vaultChefAddress,
// address _masterchefAddress,
// address _uniRouterAddress,
// uint256 _pid,
// address _wantAddress, // the token which we want to put in pool
// address _earnedAddress,
// address[] memory _earnedToWmaticPath
require("dotenv").config();

// This is for DAI pool on rinkeby pool id is 1
module.exports = async function ({
  ethers,
  getNamedAccounts,
  deployments,
  getChainId,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // const _vaultChefAddress = await deployments.get('VaultChef');
  const mockDCAU = await deployments.get("MockDCAU");
  const vaultChef = await deployments.get("VaultChef");
  const masterChef = await deployments.get("MasterChef");

  const dcau =
    process.env.PRODUCTION_MODE === "development"
      ? mockDCAU.address
      : "0xmainnet dcau address here";
  const withdrawFeeAddress = "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b";
  const feeAddress = "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b";

  const uniRouterAddress = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"; // on rinkeby
  const pid = 1;
  const wantAddress = "0xa37EB8Fe910A00f973E0913024F631Ed387eE512"; // DAI on rinkeby
  const WETH = "0xc778417e063141139fce010982780140aa0cd5ab";
  await deploy("StrategyMasterChef", {
    from: deployer,
    log: true,
    args: [
      [dcau, withdrawFeeAddress, feeAddress],
      vaultChef.address,
      masterChef.address,
      uniRouterAddress,
      pid,
      wantAddress,
      dcau,
      [dcau, WETH],
    ],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["StrategyMasterChef", "DragonCrypto"];
module.exports.dependencies = ["MockDCAU", "VaultChef", "MasterChef"];
