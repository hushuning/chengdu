// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
// require("@nomiclabs/hardhat-ethers");  
// address public pgpg = 0xC534165f8EA9998E878F4350536cAA9765b22222;
// // pgv1凭证
// address public v1 = 0x74dc66c4c96cD6153191da38f2D68D1d18fd95a1;
// // pgv2凭证
// address public v2 = 0xc46D6aE9CEdB8422c662edfF043f5D858E9caaa2;
// // pgv3凭证
// address public v3 = 0xcFAa1C274cBfAb275FA7267359DF4e59A191aaa3;
// // pgv4 凭证
// address public v4 = 0x83D5277075746E6220a3d34776D52ec746DFaaa4;

const hre = require("hardhat");
// const { expect } = require("chai");

// const { ethers } = require("hardhat");
// console.log("ethers", hre.ethers);

const ccAddr = {};
ccAddr.lingqu = "0x01ED40AB57028e1ee9e3354f9f2b2FC2985dC491"; // pancake router地址.
ccAddr.m2 = "0x5c5122453d742ecec8f9e42b88f58ca5c53c17d1"; // M2合约地址
ccAddr.fr = "0x721bbea0acb2de1c96d2cdfeb768b4ae63b14947"; // FR合约地址
ccAddr.pgpg = "0xC534165f8EA9998E878F4350536cAA9765b22222"; // pgpg合约地址 

ccAddr.v1 = "0x74dc66c4c96cD6153191da38f2D68D1d18fd95a1"; // FR合约地址
ccAddr.v2 = "0xc46D6aE9CEdB8422c662edfF043f5D858E9caaa2"; // FR合约地址
ccAddr.v3 = "0xcFAa1C274cBfAb275FA7267359DF4e59A191aaa3"; // FR合约地址
ccAddr.v4 = "0x83D5277075746E6220a3d34776D52ec746DFaaa4"; // FR合约地址





async function main() {


//  await tokenTme();
//  await fireC(ccAddr);//测试FR合约
 await tokenApprove(ccAddr);//测试M2合约
//  await m2();
}


async function tokenApprove(obj) {
   // —— 1. 读取 ABI ——  
   const artifact = await artifacts.readArtifact("Fire");  
   // —— 2. 填入你部署后得到的地址 ——  
//    const address  = obj.m2; // 这里是你部署的合约地址
   const abiIERC20 = await artifacts.readArtifact("contracts/erc20.sol:IERC20");  

   // —— 3. 用默认 signer（部署者）或你自己指定的 signer ——  
   const [s1] = await hre.ethers.getSigners();  
   // —— 4. 生成合约实例 ——  
   const fr = new hre.ethers.Contract(ccAddr.fr, artifact.abi, s1);
   const abc =  await fr.getUsdtWbnb(hre.ethers.parseEther("100"))
   console.log("Wbnb=token?how?:", hre.ethers.formatUnits(abc, 18));
   const abcd =  await fr.getUsdtPrice(ccAddr.pgpg,hre.ethers.parseEther("100"))
   console.log("PGPG=token?how?:", hre.ethers.formatUnits(abcd, 18));
   // // —— 5. 调用自动生成的 getter ——  
//    ccAddr.pgpg    = await m2.pgpg();
//   //  console.log("pgpg合约地址", pgpg);
//    ccAddr.v1      = await m2.v1();
//    ccAddr.v2      = await m2.v2();

//    ccAddr.v3     = await m2.v3();
//    ccAddr.v4     = await m2.v4();
   // const pgpgC = new hre.ethers.Contract(ccAddr.pgpg, abiIERC20.abi, s1);
   // const v1C = new hre.ethers.Contract(ccAddr.v2, abiIERC20.abi, s1);
   // const v2C = new hre.ethers.Contract(ccAddr.v2, abiIERC20.abi, s1);
   // const v3C = new hre.ethers.Contract(ccAddr.v3, abiIERC20.abi, s1);
   // const v4C = new hre.ethers.Contract(ccAddr.v4, abiIERC20.abi, s1);
   
//    await setWhite(ccAddr.pgpg,[
//       ccAddr.m2,s1.address,])
//    await setWhite(ccAddr.v1,[
//     ccAddr.lingqu,s1.address,])
//    await setWhite(ccAddr.v2,[
//       ccAddr.m2,s1.address,]) 
//    await setWhite(ccAddr.v3,[
//       ccAddr.m2,s1.address,]) 
//    await setWhite(ccAddr.v4,[
//       ccAddr.m2,s1.address,]) 
//    await setWhite(ccAddr.v1,[
//       ccAddr.lingqu,s1.address,])
//    const txpg = await pgpgC.transfer(ccAddr.m2, hre.ethers.parseUnits("10000", 18));  
//    const txv1 = await v1C.transfer(ccAddr.lingqu, hre.ethers.parseUnits("100", 18));  
   
//    console.log("v1转账领取合约成功",txv1.hash);
   
//    console.log("V1设置领取合约为白名单");   
   // const txv2 = await v2C.transfer(ccAddr.m2, hre.ethers.parseUnits("10", 18));  
   // console.log("v2转账到M2合约成功",txv2.hash);
   
   // console.log("V2设置M2合约为白名单");   
   // const txv3 = await v3C.transfer(ccAddr.m2, hre.ethers.parseUnits("10", 18));  
   // console.log("v3转账到M2合约成功",txv3.hash);
  
   // console.log("V2设置M2合约为白名单"); 
   // balanceOf = await v2C.balanceOf(ccAddr.m2);
   
   // console.log("v2余额", hre.ethers.formatUnits(balanceOf, 18));
//    const txv3 =await  v3C.transfer(ccAddr.m2, hre.ethers.parseUnits("10", 18));  
   // const txv4 =await v4C.transfer(ccAddr.m2, hre.ethers.parseUnits("10", 18));  
//    console.log("pgpg转账成功",txpg.hash); 
//    console.log("v2转账成功",txv2.hash);
//    console.log("v3转账成功",txv3.hash);
//    console.log("v4转账成功",txv4.hash);
   
      
  // 获取 ERC‑20 合约实例（ABI 使用 OpenZeppelin 的 IERC20）
//   ;
}


async function setWhite(tokenAddr,whitelist) {
    const [myAccount] = await ethers.getSigners(); // 必须是合约 owner
    
    const tokenAddress = tokenAddr; // 替换为你的代币地址
 
    const tokenAbi = [
      "function setFeeWhiteList(address[] calldata addr, bool enable) external"
    ];
  
    const token2 = await ethers.getContractAt(tokenAbi, tokenAddress);
  
    // const whitelistAddresses = [
    //   "0xAddress1",
    //   "0xAddress2",
    //   "0xAddress3"
    // ];
  
    const tx = await token2.connect(myAccount).setFeeWhiteList(whitelist, true);
    await tx.wait();
  
    console.log("Fee whitelist set successfully.");
  }
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
