// const { expect, assert } = require("chai");
// // const { providers } = require("ethers");
// const { ethers } = require("hardhat");

// const ERC20 = require("../scripts/abis/ERC20.json");

// const {
//   DCAU_PRE_MINT,
//   getBigNumber,
//   advanceBlock,
//   advanceTimeStamp,
// } = require("../scripts/shared");

// // Below addresses are all on rinkeby

// const DCAU_POOL_ID = 0;
// // const DCAU_ADDRESS = "0xaba6D7b5515f70402bFb2633B5446670B996c10b";
// // const MASTER_CHEF_ADDRESS = "0x4068D7Ab3867A52c0eB48282E17e15eA677A7167";

// // categories[1] = "Characters";
// // categories[2] = "Equipment";
// // categories[3] = "Utility";
// // categories[4] = "Resources";
// const DCAU_PER_SECOND = getBigNumber(5, 16); // 0.05 dcau per block

// describe("DCAUNFTMarket", function () {
//   before(async function () {
//     this.DCAUNFTMarket = await ethers.getContractFactory("DCAUNFTMarket");
//     this.MasterChef = await ethers.getContractFactory("MasterChef");
//     this.DragonNestSupporter = await ethers.getContractFactory(
//       "DragonNestSupporter"
//     );

//     this.MockDCAU = await ethers.getContractFactory("MockDCAU");
//     this.MockERC20 = await ethers.getContractFactory("MockERC20");
//     this.MockERC721 = await ethers.getContractFactory("MockERC721");

//     this.signers = await ethers.getSigners();
//     this.commissionTaker = this.signers[0];
//     this.dev = this.signers[0];
//     this.game = this.signers[2];
//   });

//   beforeEach(async function () {
//     this.dcau = await this.MockDCAU.deploy(this.dev.address);

//     this.usdc = await this.MockERC20.deploy(
//       "Mock USDC",
//       "MockUSDC",
//       getBigNumber(10000000000)
//     );

//     this.dragonNestSupporter = await this.DragonNestSupporter.deploy(
//       this.dev.address,
//       this.usdc.address,
//       ~~(new Date().getTime / (1000 * 2))
//     );

//     this.masterChef = await this.MasterChef.deploy(
//       this.dcau.address,
//       this.dragonNestSupporter.address,
//       this.game.address, // game address
//       this.signers[1].address,
//       0,
//       DCAU_PER_SECOND, // 0.05 DCAU
//       this.signers[1].address
//     );

//     await this.masterChef.add(50 * 100, this.dcau.address, 0, false);

//     this.dcauNFTMarketPlace = await this.DCAUNFTMarket.deploy(
//       this.dcau.address,
//       this.commissionTaker.address,
//       this.masterChef.address,
//       DCAU_POOL_ID
//     );

//     this.dcau.transfer(this.signers[1].address, getBigNumber(5000));

//     this.nftCharacters = await this.MockERC721.deploy("https://google.com");
//     this.nftEquipment = await this.MockERC721.deploy("https://google.com");
//     this.nftUtility = await this.MockERC721.deploy("https://google.com");
//     this.nftResources = await this.MockERC721.deploy("https://google.com");
//   });

//   it("Add and remove whitelisted token", async function () {
//     await expect(
//       this.dcauNFTMarketPlace.addWhitelistedCollection(
//         this.nftCharacters.address,
//         1
//       )
//     )
//       .to.emit(this.dcauNFTMarketPlace, "NewCollectionAdded")
//       .withArgs(this.nftCharacters.address, 1);

//     await expect(
//       this.dcauNFTMarketPlace.addWhitelistedCollection(
//         this.nftCharacters.address,
//         1
//       )
//     ).to.be.revertedWith(
//       "addWhitelistedCollection: collection already whitelisted"
//     );

//     await expect(
//       this.dcauNFTMarketPlace.addWhitelistedCollection(
//         this.nftEquipment.address,
//         5
//       )
//     ).to.be.revertedWith("addWhitelistedCollection: Not listed category");
//   });

//   describe("Set NFT on sale", function () {
//     beforeEach(async function () {
//       await expect(
//         this.dcauNFTMarketPlace.addWhitelistedCollection(
//           this.nftCharacters.address,
//           1
//         )
//       )
//         .to.emit(this.dcauNFTMarketPlace, "NewCollectionAdded")
//         .withArgs(this.nftCharacters.address, 1);
//     });
//     it("Should not sale NFT not in white list", async function () {
//       await expect(
//         this.dcauNFTMarketPlace.saleNFT(
//           this.nftEquipment.address,
//           1,
//           getBigNumber(10)
//         )
//       ).to.be.revertedWith("Collection not whitelisted!");
//     });
//     it("Should not sale NFT not in white list", async function () {
//       await this.nftCharacters.approve(this.dcauNFTMarketPlace.address, 1);
//       await expect(
//         this.dcauNFTMarketPlace.saleNFT(
//           this.nftCharacters.address,
//           1,
//           getBigNumber(10)
//         )
//       )
//         .to.emit(this.dcauNFTMarketPlace, "TokenOnSale")
//         .withArgs(
//           this.signers[0].address,
//           this.nftCharacters.address,
//           1,
//           getBigNumber(10),
//           1,
//           0
//         );
//     });
//     it("Remove NFT from sale", async function () {
//       await this.nftCharacters.approve(this.dcauNFTMarketPlace.address, 1);
//       await this.nftCharacters.approve(this.dcauNFTMarketPlace.address, 2);
//       await this.dcauNFTMarketPlace.saleNFT(
//         this.nftCharacters.address,
//         1,
//         getBigNumber(10)
//       );
//       await this.dcauNFTMarketPlace.saleNFT(
//         this.nftCharacters.address,
//         2,
//         getBigNumber(10)
//       );

//       await expect(this.dcauNFTMarketPlace.removeNFT(0))
//         .to.emit(this.dcauNFTMarketPlace, "TokenRemovedFromSale")
//         .withArgs(0);
//       await expect(this.dcauNFTMarketPlace.getSale(0)).to.be.revertedWith(
//         "This sale is no longer active"
//       );
//       const item1 = await this.dcauNFTMarketPlace.getSale(1);
//       expect(item1.seller).to.be.equal(this.signers[0].address);
//     });

//     describe("Buying", function () {
//       beforeEach(async function () {
//         this.saleNFTId = 1;
//         this.price1 = getBigNumber(10);
//         this.saleId = 0;

//         await this.nftCharacters.approve(
//           this.dcauNFTMarketPlace.address,
//           this.saleNFTId
//         );
//         await this.dcauNFTMarketPlace.saleNFT(
//           this.nftCharacters.address,
//           this.saleNFTId,
//           this.price1
//         );
//       });

//       it("Buy NFT from market", async function () {
//         await this.dcau
//           .connect(this.signers[1])
//           .approve(this.dcauNFTMarketPlace.address, getBigNumber(10000000000));
//         await this.dcauNFTMarketPlace
//           .connect(this.signers[1])
//           .buyNFT(this.saleId);

//         expect(await this.nftCharacters.ownerOf(this.saleNFTId)).to.be.equal(
//           this.signers[1].address
//         );
//       });
//     });
//   });
// });
