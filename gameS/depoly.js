const { ethers } = require("hardhat");

const hre = require("hardhat");
console.log("Deploying contracts with account:");
ccdr={}
async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  
  const feeData = await ethers.provider.getFeeData();
  const gasPrice = feeData.gasPrice;
  console.log(
    "Current gasPrice:",
    hre.ethers.formatUnits(gasPrice, "gwei"),
    "gwei"
  );
  const Lmit = await hre.ethers.getContractFactory("LimitOrderProtocol");

  const lmit = await Lmit.deploy({
      // 把小费至少设成 1 gwei（1000000000 wei）
      // maxPriorityFeePerGas: hre.ethers.parseUnits("1", "gwei"),
      // // 总费上限也要足够覆盖 baseFee + priorityFee
      // maxFeePerGas:      hre.ethers.parseUnits("30", "gwei"),
      gasPrice: gasPrice,
      // // 可选：显式设 gasLimit
      // gasLimit:          3000000,
    });

  

 
  ccdr.lmit = await lmit.getAddress();
  console.log("limt deployed to:", ccdr.lmit);
//部署游戏合约
  //  const Game = await hre.ethers.getContractFactory("BombGame");

  // const game = await Game.deploy("0x45EA0af0c71eA2Fb161AF3b07F033cEe123386E8",{
  //     // 把小费至少设成 1 gwei（1000000000 wei）
  //     // maxPriorityFeePerGas: hre.ethers.parseUnits("1", "gwei"),
  //     // // 总费上限也要足够覆盖 baseFee + priorityFee
  //     // maxFeePerGas:      hre.ethers.parseUnits("30", "gwei"),
  //     gasPrice: gasPrice,
  //     // // 可选：显式设 gasLimit
  //     // gasLimit:          3000000,
  //   });

  

 
  // ccdr.lmit = await game.getAddress();
  // console.log("game deployed to:", ccdr.lmit);
  // console.log("ccdr deployed to:", ccdr);
  

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
