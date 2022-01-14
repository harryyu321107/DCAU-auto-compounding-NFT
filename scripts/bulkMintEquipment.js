const fs = require("fs");
const { ethers } = require("hardhat");
const hre = require("hardhat");

require("dotenv").config();

async function main() {
  const dragonEquipmentAddress = "0xD081C1Bb02c5493082edB8416b2D43e7dF771CeF";
  const dragonEquipmentContract = await ethers.getContractAt("DragonEquipment", "0xD081C1Bb02c5493082edB8416b2D43e7dF771CeF");
  const equipmentBulkMint = await ethers.getContractAt(
    "DragonEquipmentBulkMint",
    "0x224614E0201185f1b0203b509843a5CD4507B9d6"
  );
  
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
    const owner = equipmentBulkMint.address;
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

  const owner = await dragonEquipmentContract.owner();
  console.log('owner', owner);

  const tx = await equipmentBulkMint.bulkMint(
    dragonEquipmentAddress,
    ownerArr,
    typeArr,
    damageArr,
    defenseArr,
    durabilityArr,
    speedArr,
    enduranceArr,
    luckArr
  );


  console.log("Transaction was sent");
  // const tx = await equipmentBulkMint.transferCharacterOwnerShip(
  //   dragonEquipmentAddress,
  //   "0x6C641CE6A7216F12d28692f9d8b2BDcdE812eD2b"
  // );


  console.log(`tx was sent ${tx.hash}`);
  await tx.wait();
  console.log('transaction hash', tx.hash);

  console.log("Transaction was mined");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
