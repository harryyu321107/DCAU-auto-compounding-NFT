// const { expect, assert } = require("chai");
// const { ethers } = require("hardhat");

// const {
//   EQUIPMENT_BODY,
//   EQUIPMENT_FIRST_HAND,
//   ADDRESS_ZERO,
// } = require("../scripts/shared");

// describe("DragonEquipment", function () {
//   before(async function () {
//     this.DragonEquipment = await ethers.getContractFactory("DragonEquipment");
//     this.signers = await ethers.getSigners();
//   });

//   beforeEach(async function () {
//     this.baseURI = "https://google.com/";
//     this.dragonEquipment = await this.DragonEquipment.deploy(this.baseURI);
//     this.name = "Dragon Equipment";
//     this.symbol = "DCEQUIP";
//   });

//   it("Should be deployed with correct name, symbol and types", async function () {
//     expect(await this.dragonEquipment.name()).to.be.equal(this.name);
//     expect(await this.dragonEquipment.EQUIPMENT_BODY()).to.be.equal(
//       EQUIPMENT_BODY
//     );
//     expect(await this.dragonEquipment.EQUIPMENT_FIRST_HAND()).to.be.equal(
//       EQUIPMENT_FIRST_HAND
//     );
//   });

//   it("Minting items", async function () {
//     await this.dragonEquipment.mintNewEquipment(
//       this.signers[0].address,
//       EQUIPMENT_BODY,
//       "Aurum Armor",
//       0,
//       20,
//       20,
//       20,
//       20,
//       20
//     );

//     expect(await this.dragonEquipment.tokenURI(0)).to.be.equal(
//       this.baseURI + "0"
//     );

//     await expect(
//       this.dragonEquipment.mintNewEquipment(
//         this.signers[0].address,
//         20,
//         "Aurum Armor",
//         0,
//         20,
//         20,
//         20,
//         20,
//         20
//       )
//     ).to.be.revertedWith("Dragon: Invalid equipment type");

//     const mintedEquipmentStats = {
//       damage: 0,
//       defense: 20,
//       currentDurability: 20,
//       maxDurability: 20,
//       speed: 20,
//       endurance: 20,
//       luck: 20,
//       name: "Aurum Armor",
//     };

//     const tx = await this.dragonEquipment.mintNewEquipment(
//       this.signers[0].address,
//       EQUIPMENT_BODY,
//       "Aurum Armor",
//       0,
//       20,
//       20,
//       20,
//       20,
//       20
//     );
//     // ).to.emit(this.dragonEquipment, "EquipmentCreated").withArgs(this.signers[0].address, EQUIPMENT_BODY, 1, this.signers[0].address, mintedEquipmentStats)

//     const txMined = await tx.wait();
//     console.log(txMined.events[1].args);
//   });

//   it("Damage item", async function () {
//     await this.dragonEquipment.mintNewEquipment(
//       this.signers[0].address,
//       EQUIPMENT_BODY,
//       "Aurum Armor",
//       0,
//       20,
//       20,
//       20,
//       20,
//       20
//     );

//     await this.dragonEquipment.damage(0, 10);
//     expect(
//       (await this.dragonEquipment.equipmentStats(0)).currentDurability
//     ).to.be.equal(20 - 10);

//     await expect(this.dragonEquipment.damage(0, 10))
//       .to.emit(this.dragonEquipment, "Transfer")
//       .withArgs(this.signers[0].address, ADDRESS_ZERO, 0);
//   });
// });
