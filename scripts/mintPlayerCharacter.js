const fs = require("fs");
const { ethers } = require("hardhat");
const hre = require("hardhat");

require("dotenv").config();

async function main() {
  // DragonPlaterCharacter on Fuji
  const dragonPlayerCharacter = await ethers.getContractAt(
    "DragonPlayerCharacter",
    "0xa48E72e5B139c048B793D7f5530264b228ff8A48"
  );

  const startId = 67;
  const endId = 100;
  for (let index = startId; index < endId; index++) {
    console.log(`Character ${index + 1} is minting...`);
    const webUrl = "https://tinydragon.games/json/g1/" + (index + 1) + ".json";
    const attack = 3;
    const defense = 3;
    const speed = 3;
    const endurance = 3;
    const rank = 1;
    const tx = await dragonPlayerCharacter.mintCharacter(
      webUrl,
      attack,
      defense,
      speed,
      endurance
    );
    await tx.wait();

    console.log(`Character ${index + 1} was minted`);
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
