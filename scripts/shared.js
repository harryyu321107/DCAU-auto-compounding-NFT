const { ethers } = require("hardhat");
const { BigNumber } = ethers;

const DGNG_TOTAL_SUPPLY = 146300;
const DGNG_PRE_MINT = 46300;

const EQUIPMENT_BODY = 1;
const EQUIPMENT_FIRST_HAND = 2;
const EQUIPMENT_SECOND_HAND = 3;
const EQUIPMENT_TWO_HANDS = 4;
const EQUIPMENT_LEFT_RING = 5;
const EQUIPMENT_RIGHT_RING = 6;
const EQUIPMENT_HEAD = 7;
const EQUIPMENT_NECK = 8;
const EQUIPMENT_BACK = 9;
const EQUIPMENT_SHOULDERS = 10;
const EQUIPMENT_ARMS = 11;
const EQUIPMENT_GLOVES = 12;
const EQUIPMENT_LEGS = 13;
const EQUIPMENT_FEET = 14;
const EQUIPMENT_WAIST = 15;
const EQUIPMENT_UTILITY = 16;

const ADDRESS_ZERO = ethers.constants.AddressZero;

// Quick Swap addresses
// const QUICK_SWAP = {
//   ROUTER: "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff",
//   FACTORY: "0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32",
// };

const QUICK_SWAP = {
  ROUTER: "0x60aE616a2155Ee3d9A68541Ba4544862310933d4",
  FACTORY: "0x9Ad6C38BE94206cA50bb0d90783181662f0Cfa10",
};

// this is rinkeby
// const QUICK_SWAP = {
//   ROUTER: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
//   FACTORY: "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f",
// };

// const WETH = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270"; // on polygon
// const WETH = "0xc778417e063141139fce010982780140aa0cd5ab "; // on rinkeby
const WETH = "0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7"; // on Avalanche

const UniswapV2Router = require("./abis/UniswapV2Router.json");
const UniswapV2Factory = require("./abis/UniswapV2Factory.json");
const ERC20 = require("./abis/ERC20.json");

// function getUniswapV2Router(routerAddress) {
//   const contract = new ethers.Contract(routerAddress, JSON.stringify(UniswapV2Router), ethers.provider);
//   return contract;
// }

// function getUniswapV2Factory(factoryAddress) {
//   const contract = new ethers.Contract(factoryAddress, JSON.stringify(UniswapV2Factory), ethers.provider);
//   return contract;
// }

function getContract(address, abi) {
  return new ethers.Contract(address, abi, ethers.provider);
}

async function createPair(
  router,
  factory,
  token0,
  token1,
  amount0,
  amount1,
  to,
  signer
) {
  const deadline = new Date().getTime();
  const routerContract = getContract(router, JSON.stringify(UniswapV2Router));
  const factoryContract = getContract(
    factory,
    JSON.stringify(UniswapV2Factory)
  );
  const token0Contract = getContract(token0, JSON.stringify(ERC20));
  const token1Contract = getContract(token1, JSON.stringify(ERC20));

  console.log("Approving router to consume tokens...");
  await (
    await token0Contract
      .connect(signer)
      .approve(router, getBigNumber(10000000000), { from: signer.address })
  ).wait();
  await (
    await token1Contract
      .connect(signer)
      .approve(router, getBigNumber(10000000000), { from: signer.address })
  ).wait();
  console.log("Approved.");

  console.log("Adding liquidity...");
  await (
    await routerContract
      .connect(signer)
      .addLiquidity(
        token0,
        token1,
        amount0,
        amount1,
        amount0,
        amount1,
        to,
        deadline,
        { from: signer.address }
      )
  ).wait();

  const pair = await factoryContract.getPair(token0, token1);

  return pair;
}

async function createPairETH(
  router,
  factory,
  token0,
  amount0,
  amount1,
  to,
  signer
) {
  const deadline = new Date().getTime();
  const routerContract = getContract(router, JSON.stringify(UniswapV2Router));
  const factoryContract = getContract(
    factory,
    JSON.stringify(UniswapV2Factory)
  );
  const token0Contract = getContract(token0, JSON.stringify(ERC20));

  console.log("Approving router to consume tokens...");
  await (
    await token0Contract
      .connect(signer)
      .approve(router, getBigNumber(10000000000), { from: signer.address })
  ).wait();
  console.log("Approved.");

  console.log("Adding liquidity...");
  await (
    await routerContract
      .connect(signer)
      .addLiquidityAVAX(token0, amount0, amount0, amount1, to, deadline, {
        value: amount1,
      })
  ).wait();

  const pair = await factoryContract.getPair(token0, WETH);

  return pair;
}

function getBigNumber(amount, decimal = 18) {
  return BigNumber.from(amount).mul(BigNumber.from(10).pow(decimal));
}

async function advanceBlock() {
  return ethers.provider.send("evm_mine", []);
}

async function advanceBlockTo(blockNumber) {
  for (let i = await ethers.provider.getBlockNumber(); i < blockNumber; i++) {
    await advanceBlock();
  }
}

async function advanceTimeStamp(advancedHrs) {
  const afterHoursTimeStampUTC =
    ~~(new Date().getTime() / 1000) + 3600 * advancedHrs;
  network.provider.send("evm_setNextBlockTimestamp", [afterHoursTimeStampUTC]);
  await network.provider.send("evm_mine");
}

module.exports = {
  DGNG_TOTAL_SUPPLY,
  DGNG_PRE_MINT,
  QUICK_SWAP,
  WETH,
  ADDRESS_ZERO,
  EQUIPMENT_BODY,
  EQUIPMENT_FIRST_HAND,
  EQUIPMENT_SECOND_HAND,
  EQUIPMENT_TWO_HANDS,
  EQUIPMENT_LEFT_RING,
  EQUIPMENT_RIGHT_RING,
  EQUIPMENT_HEAD,
  EQUIPMENT_NECK,
  EQUIPMENT_BACK,
  EQUIPMENT_SHOULDERS,
  EQUIPMENT_ARMS,
  EQUIPMENT_GLOVES,
  EQUIPMENT_LEGS,
  EQUIPMENT_FEET,
  EQUIPMENT_WAIST,
  EQUIPMENT_UTILITY,
  getBigNumber,
  advanceBlock,
  advanceBlockTo,
  advanceTimeStamp,
  createPair,
  createPairETH,
  getContract,
};
