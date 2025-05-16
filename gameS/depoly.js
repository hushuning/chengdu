const hre = require("hardhat");
console.log("Deploying contracts with account:");
ccdr={}
async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  const BombGame = await hre.ethers.getContractFactory("BombGame");
  const bombGame = await BombGame.deploy();

  // await bombGame.deployed();

  console.log("BombGame deployed to:", bombGame.target);
  ccdr.bombGame = bombGame.target;
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
