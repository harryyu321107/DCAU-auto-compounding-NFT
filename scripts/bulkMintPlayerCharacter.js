const fs = require("fs");
const { ethers } = require("hardhat");
const hre = require("hardhat");

require("dotenv").config();

async function main() {
  const dragonCharacter = "0x07060e84716c653DF7F1Bfc5496FD32141408B21";
  const dragonBulkMint = await ethers.getContractAt(
    "DragonBulkMint",
    "0xD3067965605EE3F98D32860c3169FF6246F13826"
  );
  
  const CHUNK_SIZE = 50;
  for (let groupId = 0; groupId < 10; groupId++) {
    const startId = groupId * CHUNK_SIZE;
    const endId = (groupId + 1) * CHUNK_SIZE;
    const attackArr = [];
    const defenseArr = [];
    const speedArr = [];
    const enduranceArr = [];
    const craftingArr = [];
    const gatheringArr = [];
    const magicArr = [];
    const rankArr = [];
  
    for (let index = startId; index < endId; index++) {
      const attack = 3;
      const defense = 3;
      const speed = 2;
      const endurance = 2;
      const crafting = 2;
      const gathering = 2;
      const magic = 1;
      const rank = 1;
      attackArr.push(attack);
      defenseArr.push(defense);
      speedArr.push(speed);
      enduranceArr.push(endurance);
      craftingArr.push(crafting);
      gatheringArr.push(gathering);
      magicArr.push(magic);
      rankArr.push(rank);
    }
  
    console.log("Transaction was sent");
    const tx = await dragonBulkMint.bulkMint(
      dragonCharacter,
      attackArr,
      defenseArr,
      speedArr,
      enduranceArr,
      craftingArr,
      gatheringArr,
      magicArr,
      rankArr
    );
  
    console.log(`${groupId} Group tx was sent`, tx.hash);
    await tx.wait();
    console.log('transaction hash', tx.hash);
  
    console.log("Transaction was mined");
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
