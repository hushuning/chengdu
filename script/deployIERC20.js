const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contract with address:", deployer.address);

  const Token = await ethers.getContractFactory("MyToken");

  // 1亿个代币，假设是 18 位精度
  const totalSupply = ethers.parseUnits("100000000", 18);

  const token = await Token.deploy(totalSupply);
  await token.deployed();

  console.log("Token deployed to:", token.address);

  const balance = await token.balanceOf(deployer.address);
  console.log("Deployer balance:", ethers.utils.formatUnits(balance, 18));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
