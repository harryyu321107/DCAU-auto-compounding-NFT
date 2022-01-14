const fs = require("fs");
const { ethers } = require("hardhat");
const hre = require("hardhat");
const { getBigNumber } = require("./shared");

require("dotenv").config();

/**
 * This script is only for testnet, don't use it on mainnet
 */
async function main() {
  const signers = await hre.ethers.getSigners();
  console.log(
    "Preparing ERC20 tokens and Writing result in tinyArgs/development.json..."
  );

  // Deploying DCAU on testnet
  // console.log("Deploying DCAU...");
  // const DCAUToken = await hre.ethers.getContractFactory("MockDCAU");
  // const dcauToken = await DCAUToken.deploy(signers[0].address);
  // await dcauToken.deployed();
  // console.log("Deployed DCAU");

  // Deploying USDC, Link
  // console.log("Deploying USDC, Link...");
  const MockERC20 = await hre.ethers.getContractFactory("MockERC20");
  // const usdcToken = await MockERC20.deploy(
  //   "USDC Token",
  //   "USDC",
  //   getBigNumber(1000000000)
  // );
  // const linkToken = await MockERC20.deploy(
  //   "Link Token",
  //   "LINK",
  //   getBigNumber(1000000000)
  // );
  // await usdcToken.deployed();
  // await linkToken.deployed();
  // console.log("Deployed USDC, Link");

  // const content = {
  //   dcau: dcauToken.address,
  //   usdc: usdcToken.address,
  // };

  // await fs.writeFileSync(
  //   "./scripts/args/tokens_dev.json",
  //   JSON.stringify(content),
  //   { flag: "w+" }
  // );

  // Deploying additional tokens
  const tokens = [
    // { name: 'Wrapped BTC', symbol: 'WBTC'  },
    // { name: 'Wrapped MATIC', symbol: 'WMATIC' },
    // { name: 'DAI stable coin', symbol: 'DAI'},
    // { name: 'Link Token', symbol: 'Link' },
    // { name: "POLYPUP BALL", symbol: "POLYPUPBALL" },
    // { name: "POLYPUP BONE", symbol: "POLYPUPBONE" },
    // { name: "POLYDOGE", symbol: "POLYDOGE" },
    { name: "Wrapped AVAX", symbol: "WAVAX" },
    { name: "Wrapped Bitcoin", symbol: "WBTC" },
    { name: "Wrapped Ethereum", symbol: "WETHe" },
    { name: "Tether", symbol: "USDTe" },
    { name: "Trader Joe", symbol: "JOE" },
    { name: "Magic Internet Money", symbol: "MIM" },
    { name: "Spell Token", symbol: "SPELL" },
    { name: "Time", symbol: "TIME" },
  ];

  const additionalTokens = {};
  for (const token of tokens) {
    console.log(`Deploying ${token.name}...`);
    const tokenContract = await MockERC20.deploy(
      token.name,
      token.symbol,
      getBigNumber(1000000000)
    );
    await tokenContract.deployed();
    additionalTokens[`${token.symbol}`] = tokenContract.address;
    console.log(`Deployed ${token.name} at ${tokenContract.address}`);
  }

  console.log("Writing result...");
  await fs.writeFileSync(
    "./scripts/args/additional_tokens_dev.json",
    JSON.stringify(additionalTokens),
    { flag: "w+" }
  );

  console.log("==END==");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
