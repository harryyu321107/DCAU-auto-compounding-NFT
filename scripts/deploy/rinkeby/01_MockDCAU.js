// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("MockDCAU", {
    from: deployer,
    log: true,
    args: ["0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b"],
    deterministicDeployment: false,
  });
};

module.exports.tags = ["DCAU", "ERC20", "DragonCrypto"];
