// const { expect, assert } = require("chai");
// const { ethers } = require("hardhat");

// const { getBigNumber } = require("../scripts/shared");

// describe("DragonEquipment", function () {
//   before(async function () {
//     this.DragonEquipment = await ethers.getContractFactory("DragonEquipment");
//     this.DragonPlayerCharacter = await ethers.getContractFactory(
//       "DragonPlayerCharacter"
//     );
//     this.MockERC721 = await ethers.getContractFactory("MockERC721");
//     this.signers = await ethers.getSigners();
//   });

//   beforeEach(async function () {
//     this.baseURI = "https://google.com/";
//     this.dragonEquipment = await (
//       await this.DragonEquipment.deploy(this.baseURI)
//     ).deployed();
//     this.dragonPlayerCharacter = await this.DragonPlayerCharacter.deploy(
//       this.dragonEquipment.address,
//       this.baseURI
//     );
//     this.utilityContract = await this.MockERC721.deploy(this.baseURI);
//     this.name = "Dragon Player Character";
//     this.symbol = "DPC";

//     this.defaultAttack = 3;
//     this.defaultDefense = 3;
//     this.defaultSpeed = 2;
//     this.defaultEndurance = 2;
//     this.defaultCrafting = 2;
//     this.defaultGathering = 2;
//     this.defaultMagic = 1;
//     this.defaultRank = 1;

//     await this.dragonPlayerCharacter.addUtility(this.utilityContract.address);
//   });

//   it("Should be deployed with correct name, symbol and types", async function () {
//     expect(await this.dragonPlayerCharacter.name()).to.be.equal(this.name);
//     expect(await this.dragonPlayerCharacter.symbol()).to.be.equal(this.symbol);
//   });

//   it("Minting items", async function () {
//     await this.dragonPlayerCharacter.mintCharacter(
//       this.defaultAttack,
//       this.defaultDefense,
//       this.defaultSpeed,
//       this.defaultEndurance,
//       this.defaultCrafting,
//       this.defaultGathering,
//       this.defaultMagic,
//       this.defaultRank
//     );

//     expect(await this.dragonPlayerCharacter.tokenURI(0)).to.be.equal(
//       this.baseURI + "0"
//     );
//   });

//   describe("Dragon Actions", function () {
//     beforeEach(async function () {
//       // mint 5 characters
//       for (let ii = 0; ii < 5; ii++) {
//         await this.dragonPlayerCharacter.mintCharacter(
//           this.defaultAttack,
//           this.defaultDefense,
//           this.defaultSpeed,
//           this.defaultEndurance,
//           this.defaultCrafting,
//           this.defaultGathering,
//           this.defaultMagic,
//           this.defaultRank
//         );
//       }
//     });

//     if (
//       ("Adding experiences",
//       async function () {
//         const BASE_EXP_TO_LEVEL = 2500;
//         await this.dragonPlayerCharacter.addExperience(0, 1000);
//       })
//     );
//   });
// });
