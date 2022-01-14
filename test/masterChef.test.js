// const { expect, assert } = require("chai");
// // const { providers } = require("ethers");
// const { ethers } = require("hardhat");
// const {
//   DCAU_PRE_MINT,
//   getBigNumber,
//   advanceBlock,
//   advanceTimeStamp,
// } = require("../scripts/shared");

// const DCAU_PER_SECOND = getBigNumber(5, 16); // 0.05 dcau per block

// describe("MasterChef", function () {
//   before(async function () {
//     this.MasterChef = await ethers.getContractFactory("MasterChef");
//     this.DragonNestSupporter = await ethers.getContractFactory(
//       "DragonNestSupporter"
//     );
//     this.MockDCAU = await ethers.getContractFactory("MockDCAU");
//     this.MockERC20 = await ethers.getContractFactory("MockERC20");
//     this.signers = await ethers.getSigners();

//     this.dev = this.signers[0];
//     this.devWallet = this.signers[1];
//     this.game = this.signers[2];
//     this.alice = this.signers[3];
//     this.bob = this.signers[4];
//   });

//   beforeEach(async function () {
//     this.dcau = await this.MockDCAU.deploy(this.dev.address);
//     this.usdc = await this.MockERC20.deploy(
//       "Mock USDC",
//       "MockUSDC",
//       getBigNumber(10000000000)
//     );
//     this.weth = await this.MockERC20.deploy(
//       "Mock WETH",
//       "MockWETH",
//       getBigNumber(100000000)
//     );
//     this.link = await this.MockERC20.deploy(
//       "Mock Link",
//       "MockLink",
//       getBigNumber(100000000)
//     );

//     this.dragonNestSupporter = await this.DragonNestSupporter.deploy(
//       this.dev.address,
//       this.usdc.address,
//       ~~(new Date().getTime() / 1000 + 1)
//     );

//     // @todo
//     this.NFTMarketAddress = this.signers[0].address;

//     this.masterChef = await this.MasterChef.deploy(
//       this.dcau.address,
//       this.dragonNestSupporter.address,
//       this.game.address, // game address
//       this.devWallet.address,
//       ~~(new Date().getTime() / 1000 + 1),
//       DCAU_PER_SECOND, // 0.05 DCAU
//       this.devWallet.address,
//       this.NFTMarketAddress
//     );

//     this.dcau.transferOwnership(this.masterChef.address);
//   });

//   describe("PoolLength", function () {
//     it("PoolLength should be increased", async function () {
//       await this.masterChef.add(50 * 100, this.dcau.address, 0, false);
//       expect(await this.masterChef.poolLength()).to.be.equal(1);
//     });

//     it("Each Pool can not be added twice", async function () {
//       await this.masterChef.add(50 * 100, this.dcau.address, 0, false);
//       expect(await this.masterChef.poolLength()).to.be.equal(1);

//       await expect(
//         this.masterChef.add(50 * 100, this.dcau.address, 0, false)
//       ).to.be.revertedWith("nonDuplicated: duplicated");
//     });
//   });

//   describe("Set", function () {
//     it("Should emit SetPool", async function () {
//       await this.masterChef.add(50 * 100, this.dcau.address, 0, false);
//       await expect(this.masterChef.set(0, 60 * 100, 100, false))
//         .to.emit(this.masterChef, "SetPool")
//         .withArgs(0, this.dcau.address, 60 * 100, 100);
//     });

//     it("Should revert if invalid pool", async function () {
//       await expect(
//         this.masterChef.set(2, 60 * 100, 100, false)
//       ).to.be.revertedWith("Dragon: Non-existent pool");
//     });
//   });

//   describe("Pending DCAU", function () {
//     it("PendingDCAU should equal ExpectedDCAU", async function () {
//       await this.masterChef.add(50000, this.dcau.address, 0, false);
//       await this.dcau
//         .connect(this.alice)
//         .approve(this.masterChef.address, getBigNumber(1000000000000000));
//       await this.dcau.transfer(this.alice.address, getBigNumber(10000));

//       const log1 = await (
//         await this.masterChef.connect(this.alice).deposit(0, getBigNumber(1000))
//       ).wait();
//       const block1 = await ethers.provider.getBlock(log1.blockHash);

//       await advanceTimeStamp(1);

//       const log2 = await this.masterChef.connect(this.alice).updatePool(0);
//       const block2 = await ethers.provider.getBlock(log2.blockHash);

//       const expectedDCAU = DCAU_PER_SECOND.mul(
//         ~~(block2.timestamp - block1.timestamp)
//       );
//       const pendingDCAU = await this.masterChef.pendingDcau(
//         0,
//         this.alice.address
//       );

//       expect(expectedDCAU).to.be.equal(pendingDCAU);
//     });
//   });

//   describe("Deposit", function () {
//     beforeEach(async function () {
//       await this.masterChef.add(5000, this.dcau.address, 0, false);
//       await this.dcau.approve(
//         this.masterChef.address,
//         getBigNumber(1000000000000000)
//       );
//     });

//     it("Should not allow to deposit in non-existent pool", async function () {
//       await expect(
//         this.masterChef.deposit(1001, getBigNumber(1))
//       ).to.be.revertedWith("Dragon: Non-existent pool");
//     });
//   });

//   describe("Withdraw", function () {
//     beforeEach(async function () {});

//     it("Withdraw 0 amount", async function () {
//       await this.masterChef.add(5000, this.dcau.address, 0, false);
//       await this.dcau
//         .connect(this.alice)
//         .approve(this.masterChef.address, getBigNumber(1000000000000000));
//       await this.dcau.transfer(this.alice.address, getBigNumber(10000));

//       const depositLog = await (
//         await this.masterChef.connect(this.alice).deposit(0, getBigNumber(1000))
//       ).wait();
//       const dcauBalanceBefore = await this.dcau.balanceOf(this.alice.address);

//       const block1 = await ethers.provider.getBlock(depositLog.blockNumber);

//       await advanceTimeStamp(3);

//       const withdrawLog = await this.masterChef
//         .connect(this.alice)
//         .withdraw(0, getBigNumber(100));
//       const block2 = await ethers.provider.getBlock(withdrawLog.blockNumber);

//       const expectedDCAU = DCAU_PER_SECOND.mul(
//         ~~(block2.timestamp - block1.timestamp)
//       ); // Pending amount

//       const dcauBalanceAfter = await this.dcau.balanceOf(this.alice.address);

//       expect(
//         expectedDCAU.add(dcauBalanceBefore).add(getBigNumber(100))
//       ).to.be.equal(dcauBalanceAfter);
//     });

//     // TODO should revert invalid pool
//   });

//   describe("EmergencyWithdraw", function () {
//     beforeEach(async function () {});

//     it("EmergencyWithdraw 0 amount", async function () {
//       await this.masterChef.add(5000, this.dcau.address, 0, false);
//       await this.dcau
//         .connect(this.bob)
//         .approve(this.masterChef.address, getBigNumber(1000000000000000));
//       await this.dcau.transfer(this.bob.address, getBigNumber(10000));
//       const dcauBalanceBefore = await this.dcau.balanceOf(this.bob.address);

//       await (
//         await this.masterChef.connect(this.bob).deposit(0, getBigNumber(1000))
//       ).wait();
//       const userInfoBefore = await this.masterChef.userInfo(
//         0,
//         this.bob.address
//       );
//       await advanceTimeStamp(10);

//       await expect(this.masterChef.connect(this.bob).emergencyWithdraw(0))
//         .to.emit(this.masterChef, "EmergencyWithdraw")
//         .withArgs(this.bob.address, 0, userInfoBefore.amount);

//       const dcauBalanceAfter = await this.dcau.balanceOf(this.bob.address);

//       expect(dcauBalanceBefore).to.be.equal(dcauBalanceAfter);

//       const userInfoAfter = await this.masterChef.userInfo(0, this.bob.address);
//       expect(userInfoAfter.amount).to.be.equal(0);
//       expect(userInfoAfter.rewardDebt).to.be.equal(0);
//     });
//   });

//   describe("stakeDragonNest", function () {
//     beforeEach(async function () {
//       this.usedNestNFTId = 1;

//       await this.masterChef.add(5000, this.dcau.address, 0, false);
//       await this.dcau.approve(
//         this.masterChef.address,
//         getBigNumber(1000000000000000)
//       );
//       await this.dragonNestSupporter.mintItem("https://xxxxx");
//       await this.dragonNestSupporter.setItemCost(getBigNumber(5, 16));
//       await this.dragonNestSupporter.activateSale();
//       await this.usdc.approve(
//         this.dragonNestSupporter.address,
//         getBigNumber(100000000)
//       );
//       await this.dragonNestSupporter.buyDragonNest();
//     });

//     it("Should stake dragon nest", async function () {
//       const dragonNestOwnerBefore = await this.dragonNestSupporter.ownerOf(
//         this.usedNestNFTId
//       );
//       expect(dragonNestOwnerBefore).to.be.equal(this.dev.address);

//       await this.dragonNestSupporter.approve(
//         this.masterChef.address,
//         this.usedNestNFTId
//       );
//       await this.masterChef.stakeDragonNest(this.usedNestNFTId);

//       const dragonNestOwnerAfter = await this.dragonNestSupporter.ownerOf(
//         this.usedNestNFTId
//       );
//       expect(dragonNestOwnerAfter).to.be.equal(this.masterChef.address);
//     });
//   });

//   describe("withdrawDragonNest", function () {
//     beforeEach(async function () {
//       this.usedNestNFTId = 1;

//       await this.masterChef.add(5000, this.dcau.address, 0, false);
//       await this.masterChef.add(500, this.usdc.address, 400, false);

//       await this.dcau.approve(
//         this.masterChef.address,
//         getBigNumber(1000000000000000)
//       );
//       await this.masterChef.deposit(0, getBigNumber(5000));
//       await this.usdc.approve(this.masterChef.address, getBigNumber(100000000));
//       await this.masterChef.deposit(1, getBigNumber(2000));

//       await this.dragonNestSupporter.mintItem("https://xxxxx");
//       await this.dragonNestSupporter.setItemCost(getBigNumber(5, 16));
//       await this.dragonNestSupporter.activateSale();
//       await this.usdc.approve(
//         this.dragonNestSupporter.address,
//         getBigNumber(100000000)
//       );
//       await this.dragonNestSupporter.buyDragonNest();
//       await this.dragonNestSupporter.approve(
//         this.masterChef.address,
//         this.usedNestNFTId
//       );
//       await this.masterChef.stakeDragonNest(this.usedNestNFTId);
//     });

//     it("Should withdraw dragon nest", async function () {
//       const dragonNestOwnerBefore = await this.dragonNestSupporter.ownerOf(
//         this.usedNestNFTId
//       );
//       expect(dragonNestOwnerBefore).to.be.equal(this.masterChef.address);

//       const poolLen = await this.masterChef.poolLength();
//       const poolInfoBefore = [];
//       const poolInfoAfter = [];

//       for (let i = 0; i < poolLen; i++) {
//         const poolInfo = await this.masterChef.poolInfo(i);
//         const lpToken = await this.MockERC20.attach(poolInfo.lpToken);
//         const balanceBefore = await lpToken.balanceOf(this.dev.address);
//         poolInfoBefore.push({ balanceBefore });
//       }

//       await this.masterChef.withdrawDragonNest(this.usedNestNFTId);

//       for (let i = 0; i < poolLen; i++) {
//         const poolInfo = await this.masterChef.poolInfo(i);
//         const lpToken = await this.MockERC20.attach(poolInfo.lpToken);
//         const balanceAfter = await lpToken.balanceOf(this.dev.address);
//         const poolDragonNestInfo = await this.masterChef.poolDragonNestInfo(i);
//         const dragonNestInfo = await this.masterChef.dragonNestInfo(i, 1);

//         poolInfoAfter.push({
//           balanceAfter,
//           poolDragonNestInfo,
//           dragonNestInfo,
//         });
//       }

//       for (let i = 0; i < poolLen; i++) {
//         expect(
//           poolInfoAfter[i].balanceAfter.sub(poolInfoBefore[i].balanceBefore)
//         ).to.be.equal(
//           poolInfoAfter[i].poolDragonNestInfo.accDepFeePerShare.sub(
//             poolInfoAfter[i].dragonNestInfo
//           )
//         );
//       }

//       const dragonNestOwnerAfter = await this.dragonNestSupporter.ownerOf(
//         this.usedNestNFTId
//       );
//       expect(dragonNestOwnerAfter).to.be.equal(this.dev.address);
//     });

//     it("updatePoolDragonNest -1", async function () {
//       // check poolDragonNestInfo, dragonNetInfo state
//       const USDCPoolDragonNestInfoBefore =
//         await this.masterChef.poolDragonNestInfo(1);

//       const expecedPendingDepFee = getBigNumber(2000)
//         .mul(4)
//         .mul(10)
//         .div(100)
//         .div(100);

//       expect(expecedPendingDepFee).to.be.equal(
//         USDCPoolDragonNestInfoBefore.pendingDepFee
//       );

//       // trying update pool
//       await this.masterChef.massUpdatePoolDragonNests();
//       const USDCPoolDragonNestInfoAfter =
//         await this.masterChef.poolDragonNestInfo(1);

//       // compare expected value(calc in javascript side) with changed
//       expect(USDCPoolDragonNestInfoAfter.accDepFeePerShare).to.be.equal(
//         USDCPoolDragonNestInfoBefore.pendingDepFee
//       );
//     });
//   });
// });
