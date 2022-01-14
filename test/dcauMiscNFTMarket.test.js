// const { expect, assert } = require("chai");
// // const { providers } = require("ethers");
// const { ethers } = require("hardhat");
// const { BigNumber } = ethers;

// const RESOURCE_WOOD_ID = 1;
// const CATEGORY_RESOURCE = 2;

// const {
//   getBigNumber,
// } = require("../scripts/shared");

// // categories[1] = "Equipment";
// // categories[2] = "Resources";

// describe("DCAUMiscNFTMarket", function () {
//   before(async function () {
//     this.DCAUMiscNFTMarket = await ethers.getContractFactory(
//       "DCAUMiscNFTMarket"
//     );

//     this.MockDCAU = await ethers.getContractFactory("MockDCAU");
//     this.DragonResource = await ethers.getContractFactory("DragonResource");
//     this.DragonEquipment = await ethers.getContractFactory("DragonEquipment");

//     this.signers = await ethers.getSigners();
//     this.commissionTaker = this.signers[0];
//     this.rewarder = this.signers[0].address;
//     this.dev = this.signers[0];
//     this.game = this.signers[2];
//   });

//   beforeEach(async function () {
//     this.dcau = await this.MockDCAU.deploy(this.dev.address);
//     this.dcauMiscNFTMarket = await this.DCAUMiscNFTMarket.deploy(
//       this.dcau.address,
//       this.commissionTaker.address,
//       this.rewarder
//     );

//     this.dcau.transfer(this.signers[1].address, getBigNumber(5000));

//     this.dragonEquipment = await this.DragonEquipment.deploy(
//       "https://google.com"
//     );
//     this.dragonResource = await this.DragonResource.deploy(
//       "https://google.com",
//       this.dev.address
//     );
//   });

//   it("Add and remove whitelisted token", async function () {
//     await expect(
//       this.dcauMiscNFTMarket.addWhitelistedCollection(
//         this.dragonResource.address,
//         CATEGORY_RESOURCE
//       )
//     )
//       .to.emit(this.dcauMiscNFTMarket, "NewCollectionAdded")
//       .withArgs(this.dragonResource.address, CATEGORY_RESOURCE);

//     await expect(
//       this.dcauMiscNFTMarket.addWhitelistedCollection(
//         this.dragonResource.address,
//         CATEGORY_RESOURCE
//       )
//     ).to.be.revertedWith(
//       "addWhitelistedCollection: collection already whitelisted"
//     );

//     await expect(
//       this.dcauMiscNFTMarket.addWhitelistedCollection(
//         this.dragonEquipment.address,
//         3
//       )
//     ).to.be.revertedWith("addWhitelistedCollection: Not listed category");
//   });

//   describe("Set NFT on sale", function () {
//     beforeEach(async function () {
//       await expect(
//         this.dcauMiscNFTMarket.addWhitelistedCollection(
//           this.dragonResource.address,
//           CATEGORY_RESOURCE
//         )
//       )
//         .to.emit(this.dcauMiscNFTMarket, "NewCollectionAdded")
//         .withArgs(this.dragonResource.address, CATEGORY_RESOURCE);
//     });
//     it("Should not sale NFT not in white list", async function () {
//       await expect(
//         this.dcauMiscNFTMarket.saleNFT(
//           this.dragonEquipment.address,
//           1,
//           getBigNumber(5),
//           1000
//         )
//       ).to.be.revertedWith("Collection not whitelisted!");
//     });
//     it("Should not sale NFT not in white list", async function () {
//       await this.dragonResource.setApprovalForAll(
//         this.dcauMiscNFTMarket.address,
//         true
//       );
//       // Selling wood 1000 quantity
//       await expect(
//         this.dcauMiscNFTMarket.saleNFT(
//           this.dragonResource.address,
//           RESOURCE_WOOD_ID,
//           getBigNumber(5),
//           1000
//         )
//       )
//         .to.emit(this.dcauMiscNFTMarket, "TokenOnSale")
//         .withArgs(
//           this.signers[0].address,
//           this.dragonResource.address,
//           RESOURCE_WOOD_ID,
//           getBigNumber(5),
//           1000,
//           2,
//           0
//         );
//     });
//     it("Remove NFT from sale", async function () {
//       await this.dragonResource.setApprovalForAll(
//         this.dcauMiscNFTMarket.address,
//         true
//       );
//       await this.dcauMiscNFTMarket.saleNFT(
//         this.dragonResource.address,
//         RESOURCE_WOOD_ID,
//         getBigNumber(5),
//         1000
//       );
//       await this.dcauMiscNFTMarket.saleNFT(
//         this.dragonResource.address,
//         RESOURCE_WOOD_ID,
//         getBigNumber(4),
//         3000
//       );

//       await expect(this.dcauMiscNFTMarket.removeNFT(0, 500))
//         .to.emit(this.dcauMiscNFTMarket, "TokenRemovedFromSale")
//         .withArgs(0, 500);

//       const currentSaleRemaining = await this.dcauMiscNFTMarket.getSale(0);
//       expect(currentSaleRemaining.quantity).to.be.equal(500);
//     });

//     describe("Buying", function () {
//       beforeEach(async function () {
//         await this.dragonResource.setApprovalForAll(
//           this.dcauMiscNFTMarket.address,
//           true
//         );
//         await this.dcauMiscNFTMarket.saleNFT(
//           this.dragonResource.address,
//           RESOURCE_WOOD_ID,
//           getBigNumber(5),
//           1000
//         );
//         this.saleId = 0;
//         this.saleNFTId = 1;
//       });

//       it("Buy NFT from market", async function () {
//         await this.dcau
//           .connect(this.signers[1])
//           .approve(this.dcauMiscNFTMarket.address, getBigNumber(10000000000));

//         await expect(
//           this.dcauMiscNFTMarket
//             .connect(this.signers[1])
//             .buyNFT(this.saleId, 600)
//         )
//           .to.emit(this.dcauMiscNFTMarket, "TokenSold")
//           .withArgs(this.signers[1].address, 0, 600);

//         expect(
//           await this.dragonResource.balanceOf(
//             this.signers[1].address,
//             this.saleNFTId
//           )
//         ).to.be.equal(BigNumber.from(600));
//       });
//     });
//   });
// });
