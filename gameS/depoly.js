const { ethers } = require("hardhat");

const hre = require("hardhat");
console.log("Deploying contracts with account:");
ccdr={}
async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  
  // const BombGame = await hre.ethers.getContractFactory("BombGame");
  // const bombGame = await BombGame.deploy({
  //     // 把小费至少设成 1 gwei（1000000000 wei）
  //     maxPriorityFeePerGas: hre.ethers.parseUnits("1", "gwei"),
  //     // 总费上限也要足够覆盖 baseFee + priorityFee
  //     maxFeePerGas:      hre.ethers.parseUnits("30", "gwei"),
  //     // 可选：显式设 gasLimit
  //     gasLimit:          2_000_000,
  //   });
  // console.log("BombGame deployed to:", bombGame.target);
  // ccdr.game = bombGame.getAddress();
  // const Defi = await hre.ethers.getContractFactory("DefiGame");

  // const defi = await Defi.deploy("0x66a533161b391feb7d80a02e0eac461ee3b583ef",{
  //     // 把小费至少设成 1 gwei（1000000000 wei）
  //     maxPriorityFeePerGas: hre.ethers.parseUnits("1", "gwei"),
  //     // 总费上限也要足够覆盖 baseFee + priorityFee
  //     maxFeePerGas:      hre.ethers.parseUnits("30", "gwei"),
  //     // 可选：显式设 gasLimit
  //     gasLimit:          3_000_000,
  //   });

  

 
  // console.log("BombGame deployed to:", ccdr.bombGame);
  // ccdr.defi = defi.getAddress();
  // console.log("BombGame deployed to:", ccdr);
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

  

 
  console.log("BombGame deployed to:", ccdr.lmit);
  ccdr.lmit = lmit.getAddress();
  console.log("BombGame deployed to:", ccdr);
  

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
