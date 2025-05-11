
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const MyToken = await hre.ethers.getContractFactory("MyToken");
  const myToken = await MyToken.deploy();
  
  // await myToken.deployed();
    console.log("MyToken deployed to:", myToken.address);
  const aa = await myToken.balanceOf(deployer.address)
  console.log("代币地址:", myToken.target);
  console.log("1亿MTK代币已自动铸造给部署者:", deployer.address);
  console.log("合约部署完成，",hre.ethers.formatUnits(aa.toString(),18),"MTK");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
