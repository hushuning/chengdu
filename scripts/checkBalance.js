
const { ethers } = require("hardhat");

async function main() {
  const [signer] = await ethers.getSigners();
  const tokenAddress = "0xC534165f8EA9998E878F4350536cAA9765b22222"; // PGPG
  const fireAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Fire合约
  
  const IERC20 = [
    "function balanceOf(address) view returns (uint256)",
    "function allowance(address owner, address spender) view returns (uint256)"
  ];
  
  const token = await ethers.getContractAt(IERC20, tokenAddress, signer);
  
  // 检查余额
  const balance = await token.balanceOf(signer.address);
  console.log(`User balance: ${ethers.formatUnits(balance, 18)} PGPG`);
  
  // 检查授权
  const allowance = await token.allowance(signer.address, fireAddress);
  console.log(`Allowance to Fire: ${ethers.formatUnits(allowance, 18)} PGPG`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
