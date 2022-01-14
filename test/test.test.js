const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("DragonEquipmentBulkMint", function () {
  before(async function () {
    
  });

  beforeEach(async function () {
    
  });

  it("Should be deployed with correct name, symbol and types", async function () {
    this.DragonEquipment = await ethers.getContractFactory("DragonEquipment");
    this.DragonEquipmentBulkMint = await ethers.getContractFactory("DragonEquipmentBulkMint");
    this.signers = await ethers.getSigners();
    this.dragonEquipment = await this.DragonEquipment.deploy("https://google.com/");
    this.dragonEquipmentBulkMint = await this.DragonEquipmentBulkMint.deploy();

    await this.dragonEquipment.transferOwnership(this.dragonEquipmentBulkMint.address);

    const startId = 0;
    const endId = 16;
    const ownerArr = [];
    const typeArr = [];
    const damageArr = [];
    const defenseArr = [];
    const durabilityArr = [];
    const speedArr = [];
    const enduranceArr = [];
    const luckArr = [];

    for (let index = startId; index < endId; index++) {
      const owner = this.dragonEquipmentBulkMint.address;
      const type = index + 1;
      const damage = 2;
      const defense = 2;
      const durability = 2;
      const speed = 2;
      const endurance = 1;
      const luck = 1;
      ownerArr.push(owner);
      typeArr.push(type);
      damageArr.push(damage);
      defenseArr.push(defense);
      durabilityArr.push(durability);
      speedArr.push(speed);
      enduranceArr.push(endurance);
      luckArr.push(luck);
    }

    console.log("Transaction was sent");
    const tx = await this.dragonEquipmentBulkMint.bulkMint(
      this.dragonEquipment.address,
      ownerArr,
      typeArr,
      damageArr,
      defenseArr,
      durabilityArr,
      speedArr,
      enduranceArr,
      luckArr
    );

    await tx.wait();
  });
});
