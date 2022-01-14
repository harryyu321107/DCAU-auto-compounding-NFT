const fs = require("fs");
const { ethers } = require("hardhat");
const hre = require("hardhat");
const {
  createPair,
  createPairETH,
  getContract,
  getBigNumber,
} = require("./shared");
const UniswapV2Router = require("./abis/UniswapV2Router.json");
const AdditionalTokens = require("./args/additional_tokens_dev.json");

require("dotenv").config();

const ROUTER_ADDRESS = "0x2D99ABD9008Dc933ff5c0CD271B88309593aB921"; // fuji pangolin
const FACTORY_ADDRESS = "0xE4A575550C2b460d2307b82dCd7aFe84AD1484dd"; // fuji pangolin

// const ROUTER_ADDRESS = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"; // rinkeby
// const FACTORY_ADDRESS = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"; // rinkeby

/**
 * This script is only for testnet, don't use it on mainnet
 */
async function main() {
  console.log(
    "Preparing liquidity pairs and Writing result in scripts/args/pairs_dev.json..."
  );
  const signers = await ethers.getSigners();
  const alice = signers[0];

  const routerContract = getContract(ROUTER_ADDRESS, UniswapV2Router);
  const factory = await routerContract.factory();

  // create DCAU_Wrapped Token pair
  const wrapped_pair = await createPairETH(
    ROUTER_ADDRESS,
    FACTORY_ADDRESS,
    "0xF72Cc18218058722a3874b63487F1B4C82F92081",
    getBigNumber(1000),
    getBigNumber(1),
    alice.address,
    alice
  );

  console.log(`Wrapped token pair at ${wrapped_pair}`);

  // console.log("[factory]", factory);

  // const tokens = [
  //   { symbol: "WAVAX", address: AdditionalTokens.WAVAX },
  //   { symbol: "USDTe", address: AdditionalTokens.USDTe },
  //   { symbol: "MIM", address: AdditionalTokens.MIM },
  // ];

  // let pairsContent = {}

  // for (const token of tokens) {
  //   console.log(`creating DCAU_${token.symbol} pair...`);
  //   const pair = await createPair(
  //     ROUTER_ADDRESS,
  //     FACTORY_ADDRESS,
  //     "0xF72Cc18218058722a3874b63487F1B4C82F92081", // on fuji DCAU
  //     token.address,
  //     getBigNumber(10000),
  //     getBigNumber(50000),
  //     alice.address,
  //     alice
  //   );

  //   pairsContent['dcau_' + token.symbol.toLowerCase()] = pair

  //   console.log(`created DCAU_${token.symbol} pair at ${pair}`);
  // }

  // await fs.writeFileSync(
  //   "./scripts/args/pairs_dev.json",
  //   JSON.stringify(pairsContent),
  //   { flag: "w+" }
  // );

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
