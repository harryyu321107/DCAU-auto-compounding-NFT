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

/** This script is currently for testnet */
/** @note please be caure ful lp token address order */
require("dotenv").config();

module.exports = async function ({
  ethers,
  getNamedAccounts,
  deployments,
  getChainId,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // const mockDCAU = await deployments.get("MockDCAU");
  // const vaultChef = await deployments.get("VaultChef");
  // const masterChef = await deployments.get("MasterChef");

  const vaultChef = { address: "0x1b73c97DDA679B6486f6A200b1d5260f542F675A" };
  const masterChef = { address: "0x79497DeA2A2ea053549b27445a1CD50d08FDC5ea" };

  const dcau = "0xF72Cc18218058722a3874b63487F1B4C82F92081";

  /** @todo */
  const withdrawFeeAddress = "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b";
  const feeAddress = "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b";

  /** @todo should be changed*/
  const uniRouterAddress = "0x2D99ABD9008Dc933ff5c0CD271B88309593aB921"; // Pangolin router on Fuji
  /** @note should be changed every time */
  const pid = 2;
  const wantAddress = "0x675617dD8Abb94bb24DA9cb34cCE93aA936c1307"; // lp address
  const _earnedToToken0Path = [
    dcau,
    "0x8dd3b7bc1e226a96dad12490c4d0f11fff179d11",
  ];
  /******************/

  const earnedAddress = dcau;
  const _earnedToWmaticPath = [
    dcau,
    "0xd00ae08403B9bbb9124bB305C09058E32C39A48c",
  ];
  const _earnedToDcauPath = [dcau, dcau];
  const _earnedToToken1Path = [dcau, dcau];
  /**************************/

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
      earnedAddress, // dcau
      _earnedToWmaticPath,
      _earnedToDcauPath,
      _earnedToToken0Path,
      _earnedToToken1Path,
    ],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["StrategyMasterChefLP", "DragonCryptoAurum"];
// module.exports.dependencies = ["MockDCAU", "VaultChef", "MasterChef"];
