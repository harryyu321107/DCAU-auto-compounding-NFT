// const { expect } = require("chai");
// const { ethers } = require("hardhat");
// const { BigNumber } = ethers;
// const {
//   getBigNumber,
//   QUICK_SWAP,
//   WETH,
//   createPair,
//   createPairETH,
//   advanceBlock,
//   advanceTimeStamp,
// } = require("../scripts/shared");

// const DCAU_PER_SECOND = getBigNumber(5, 16); // 0.05 dcau per block

// describe("Vault", function () {
//   before(async function () {
//     this.VaultChef = await ethers.getContractFactory("VaultChef");
//     this.MasterChef = await ethers.getContractFactory("MasterChef");
//     this.DragonNestSupporter = await ethers.getContractFactory(
//       "DragonNestSupporter"
//     );
//     this.MockDCAU = await ethers.getContractFactory("MockDCAU");
//     this.MockERC20 = await ethers.getContractFactory("MockERC20");
//     this.StrategyMasterChef = await ethers.getContractFactory(
//       "StrategyMasterChef"
//     );
//     this.StrategyMasterChefLP = await ethers.getContractFactory(
//       "StrategyMasterChefLP"
//     );

//     this.signers = await ethers.getSigners();
//     this.dev = this.signers[0];
//     this.bob = this.signers[1];
//     this.devWallet = this.signers[2];
//     this.game = this.signers[2];
//     this.withdrawFeeAddress = this.signers[3];
//     this.feeAddress = this.signers[4];

//     this.NFTMarketAddress = this.signers[0].address;
//   });

//   beforeEach(async function () {
//     this.vaultChef = await this.VaultChef.deploy();
//     this.dcau = await this.MockDCAU.deploy(this.dev.address);
//     this.usdc = await this.MockERC20.deploy(
//       "Mock USDC",
//       "MockUSDC",
//       getBigNumber(10000000000)
//     );
//     this.link = await this.MockERC20.deploy(
//       "Mock LINK",
//       "MockLINK",
//       getBigNumber(10000000000)
//     );

//     this.dragonNestSupporter = await this.DragonNestSupporter.deploy(
//       this.dev.address,
//       this.usdc.address,
//       ~~(new Date().getTime() / 1000 + 60)
//     );
//     this.masterChef = await this.MasterChef.deploy(
//       this.dcau.address,
//       this.dragonNestSupporter.address,
//       this.game.address, // game address
//       this.devWallet.address,
//       ~~(new Date().getTime() / 1000 + 60),
//       DCAU_PER_SECOND, // 0.05 DCAU
//       this.devWallet.address,
//       this.NFTMarketAddress
//     );
//     await this.dcau.transferOwnership(this.masterChef.address);

//     /** Basic actions */
//     // create DCAU_WMATIC pair
//     this.DCAU_WMATIC = await createPairETH(
//       QUICK_SWAP.ROUTER,
//       QUICK_SWAP.FACTORY,
//       this.dcau.address,
//       getBigNumber(10000),
//       getBigNumber(50),
//       this.dev.address,
//       this.dev
//     );

//     // create DCAU_USDC pair
//     this.DCAU_USDC = await createPair(
//       QUICK_SWAP.ROUTER,
//       QUICK_SWAP.FACTORY,
//       this.dcau.address,
//       this.usdc.address,
//       getBigNumber(5000),
//       getBigNumber(10000),
//       this.dev.address,
//       this.dev
//     );

//     this.DCAU_LINK = await createPair(
//       QUICK_SWAP.ROUTER,
//       QUICK_SWAP.FACTORY,
//       this.dcau.address,
//       this.link.address,
//       getBigNumber(5000),
//       getBigNumber(10000),
//       this.dev.address,
//       this.dev
//     );

//     this.USDC_LINK = await createPair(
//       QUICK_SWAP.ROUTER,
//       QUICK_SWAP.FACTORY,
//       this.usdc.address,
//       this.link.address,
//       getBigNumber(5000),
//       getBigNumber(10000),
//       this.dev.address,
//       this.dev
//     );
//   });

//   // describe("StrategyMasterChef", function () {
//   //   beforeEach(async function () {
//   //     /** Add USDC to MasterChef */
//   //     await (
//   //       await this.masterChef.add(50 * 100, this.usdc.address, 0, false)
//   //     ).wait(); // poolID: 0

//   //     this.usdcPoolId = 0;
//   //     this.strategyMasterChefUSDC = await this.StrategyMasterChef.deploy(
//   //       [
//   //         this.dcau.address,
//   //         this.withdrawFeeAddress.address,
//   //         this.feeAddress.address,
//   //       ],
//   //       this.vaultChef.address,
//   //       this.masterChef.address,
//   //       QUICK_SWAP.ROUTER,
//   //       this.usdcPoolId,
//   //       this.usdc.address,
//   //       this.dcau.address,
//   //       [
//   //         this.dcau.address,
//   //         WETH, // this is WMATIC
//   //       ]
//   //     );
//   //   });

//   //   it("Vault Add pool", async function () {
//   //     await this.vaultChef.addPool(this.strategyMasterChefUSDC.address);
//   //     expect(await this.vaultChef.poolLength()).to.be.equal(1);
//   //   });

//   //   it("Vault Deposit", async function () {
//   //     await this.vaultChef.addPool(this.strategyMasterChefUSDC.address);
//   //     await this.usdc.approve(this.vaultChef.address, getBigNumber(1000000000));

//   //     const testAmount = 200;
//   //     await this.vaultChef.deposit(0, getBigNumber(testAmount));

//   //     const userInfo = await this.vaultChef.userInfo(
//   //       this.usdcPoolId,
//   //       this.dev.address
//   //     );

//   //     expect(userInfo).to.be.equal(getBigNumber(testAmount));
//   //   });

//   //   it("Vault withdraw", async function () {
//   //     await this.vaultChef.addPool(this.strategyMasterChefUSDC.address);
//   //     await this.usdc.approve(this.vaultChef.address, getBigNumber(1000000000));

//   //     const testDepositAmount = 200;
//   //     const testWithdrawAmount = 50;
//   //     await this.vaultChef.deposit(
//   //       this.usdcPoolId,
//   //       getBigNumber(testDepositAmount)
//   //     );

//   //     const userBalanceBefore = await this.usdc.balanceOf(this.dev.address);
//   //     const userInfoBefore = await this.vaultChef.userInfo(
//   //       this.usdcPoolId,
//   //       this.dev.address
//   //     );

//   //     await this.vaultChef.withdraw(
//   //       this.usdcPoolId,
//   //       getBigNumber(testWithdrawAmount)
//   //     );

//   //     const userBalanceAfter = await this.usdc.balanceOf(this.dev.address);
//   //     const userInfoAfter = await this.vaultChef.userInfo(
//   //       this.usdcPoolId,
//   //       this.dev.address
//   //     );

//   //     expect(userBalanceAfter).to.be.equal(
//   //       userBalanceBefore.add(getBigNumber(testWithdrawAmount)).sub(
//   //         getBigNumber(1) //withdraw fee 1% calc
//   //           .mul(getBigNumber(testWithdrawAmount))
//   //           .div(getBigNumber(100))
//   //       )
//   //     );
//   //     expect(userInfoAfter).to.be.equal(
//   //       userInfoBefore.sub(getBigNumber(testWithdrawAmount))
//   //     );
//   //   });

//   //   it("Vault earn", async function () {
//   //     await this.vaultChef.addPool(this.strategyMasterChefUSDC.address);
//   //     await this.usdc.approve(this.vaultChef.address, getBigNumber(1000000000));

//   //     const testDepositAmount = 200;
//   //     const testWithdrawAmount = 50;
//   //     await this.vaultChef.deposit(
//   //       this.usdcPoolId,
//   //       getBigNumber(testDepositAmount)
//   //     );

//   //     await advanceBlock();
//   //     await advanceTimeStamp(10);

//   //     await this.vaultChef.withdraw(
//   //       this.usdcPoolId,
//   //       getBigNumber(testWithdrawAmount)
//   //     );

//   //     const earnedAmountBefore = await this.dcau.balanceOf(
//   //       this.strategyMasterChefUSDC.address
//   //     );

//   //     expect(earnedAmountBefore).to.not.equal(0);
//   //     await this.strategyMasterChefUSDC.earn();

//   //     const earnedAmountAfter = await this.dcau.balanceOf(
//   //       this.strategyMasterChefUSDC.address
//   //     );
//   //     expect(earnedAmountAfter).to.be.equal(0);
//   //   });
//   // });

//   describe("StrategyMasterChefLP", function () {
//     beforeEach(async function () {
//       await (
//         await this.masterChef.add(100 * 100, this.USDC_LINK, 0, false)
//       ).wait(); // poolID: 0
//       this.dcauMaticPoolId = 0;
//       this.strategyMasterChefLPUSDC_LINK =
//         await this.StrategyMasterChefLP.deploy(
//           [
//             this.dcau.address,
//             this.withdrawFeeAddress.address,
//             this.feeAddress.address,
//           ],
//           this.vaultChef.address,
//           this.masterChef.address,
//           QUICK_SWAP.ROUTER,
//           this.dcauMaticPoolId,
//           this.USDC_LINK, // the token which we want to put in pool
//           this.dcau.address,
//           [
//             this.dcau.address,
//             WETH, // this is WMATIC
//           ],
//           [this.dcau.address, this.dcau.address],
//           [this.dcau.address, this.usdc.address], // earnedToToken0
//           [this.dcau.address, this.link.address] // earnedToToken1
//         );
//       this.dcauWmatic = await this.MockERC20.attach(this.USDC_LINK);
//     });

//     it("Vault LP Deposit", async function () {
//       await this.vaultChef.addPool(this.strategyMasterChefLPUSDC_LINK.address);
//       const currentBal = await this.dcauWmatic.balanceOf(this.dev.address);
//       await this.dcauWmatic.approve(
//         this.vaultChef.address,
//         getBigNumber(1000000000)
//       );

//       // // 0.1 % of current balance
//       const testAmount = getBigNumber(1)
//         .mul(currentBal)
//         .div(getBigNumber(1000));
//       await this.vaultChef.deposit(this.dcauMaticPoolId, testAmount);
//       const userInfo = await this.vaultChef.userInfo(
//         this.dcauMaticPoolId,
//         this.dev.address
//       );
//       expect(userInfo).to.be.equal(testAmount);
//     });

//     it("Vault withdraw", async function () {
//       await this.vaultChef.addPool(this.strategyMasterChefLPUSDC_LINK.address);
//       await this.dcauWmatic.approve(
//         this.vaultChef.address,
//         getBigNumber(1000000000)
//       );
//       const currentBal = await this.dcauWmatic.balanceOf(this.dev.address);

//       // // 0.1 % of current balance
//       const testAmount = getBigNumber(1)
//         .mul(currentBal)
//         .div(getBigNumber(1000));
//       await this.vaultChef.deposit(this.dcauMaticPoolId, testAmount);
//       const userBalanceBefore = await this.dcauWmatic.balanceOf(
//         this.dev.address
//       );
//       const userInfoBefore = await this.vaultChef.userInfo(
//         this.dcauMaticPoolId,
//         this.dev.address
//       );
//       await this.vaultChef.withdraw(this.dcauMaticPoolId, testAmount);
//       const userBalanceAfter = await this.dcauWmatic.balanceOf(
//         this.dev.address
//       );
//       const userInfoAfter = await this.vaultChef.userInfo(
//         this.dcauMaticPoolId,
//         this.dev.address
//       );
//       expect(userBalanceAfter).to.be.equal(
//         userBalanceBefore.add(testAmount).sub(
//           getBigNumber(1) //withdraw fee 1% calc
//             .mul(testAmount)
//             .div(getBigNumber(100))
//         )
//       );
//       expect(userInfoAfter).to.be.equal(userInfoBefore.sub(testAmount));
//     });

//     it("Vault earn", async function () {
//       await this.vaultChef.addPool(this.strategyMasterChefLPUSDC_LINK.address);
//       await this.dcauWmatic.approve(
//         this.vaultChef.address,
//         getBigNumber(1000000000)
//       );

//       const currentBal = await this.dcauWmatic.balanceOf(this.dev.address);
//       const testAmount = getBigNumber(1)
//         .mul(currentBal)
//         .div(getBigNumber(1000));
//       await this.vaultChef.deposit(this.dcauMaticPoolId, testAmount);

//       await advanceBlock();
//       await advanceTimeStamp(10);

//       await this.strategyMasterChefLPUSDC_LINK.earn();
//     });
//   });
// });
