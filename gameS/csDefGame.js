const { ethers } = require("hardhat");

const hre = require("hardhat");
const ccfd = {"defi":"0x7367905c0aa09d4e43b61cfa5dc0c066bfcce7a5",
  "token":"0x45EA0af0c71eA2Fb161AF3b07F033cEe123386E8","game":"0x45EA0af0c71eA2Fb161AF3b07F033cEe123386E8"}
async function main() {
  const [owner, user1, user2] = await hre.ethers.getSigners();
  const feeData = await ethers.provider.getFeeData();
    const gasPrice = feeData.gasPrice;
  console.log("👤 Owner:", owner.address);
   const abiIERC20 = await artifacts.readArtifact("contracts/stakeDefi.sol:IERC20");  

   const token = new hre.ethers.Contract(ccfd.token, abiIERC20.abi, owner);

 
   const abiDefi = await artifacts.readArtifact("DefiGame");  


   const defi = new hre.ethers.Contract(ccfd.defi, abiDefi.abi, owner);

// const defi = await hre.ethers.getContractAt("DefiGame", await sosk.getAddress(), user1);
  const aa = await token.connect(owner).approve(ccfd.defi, hre.ethers.parseUnits("1000", 18),{
    gasPrice: gasPrice}
);
  console.log("✅ User1 approved DefiQS",aa);

//   // 4. user1 参与质押
  const stakeAmount = hre.ethers.parseUnits("200", 18);
  const tx = await defi.connect(owner).stake(owner.address, stakeAmount);
  await tx.wait();
  console.log("✅ User1 staked 200");

//   // 5. 查看个人等级和衰减算力
//   const level = await defi.getUserLevel(user1.address);
//   const sycp = await defi.getSyCp(user1.address);
//   console.log("👤 user1 等级:", level.toString(), "衰减算力:", hre.ethers.formatUnits(sycp, 0));

//   // 6. 获取 getInfo() 信息结构
//   const re2 = await defi.getUserReward(user1.address);
//   console.log(re2);  
//   await defi.connect(owner).setGameC(game.getAddress());
//   console.log("✅ setGameC to game contract");
// //   const gameCC =  await defi.gameC()
// //   console.log(gameCC);  
//   const re3 = await defi.getRewardTeam(user1.address);
//   console.log(re3);  
//   const info = await defi.getInfo(user1.address);
 const info3 = await defi.getOutToken();
  console.log("📊 getInfo(user1):", info3);  
  //  const info4 = await defi.getR();
  // console.log("📊 getInfo(user1):", info4);  
// await defi.connect(owner).setGameC("0x8436Cd7Ab4AE55Fe1825B1EAf139794e16030c1A");
    
//   const info2 = await defi.getRewardTeam("0x49C3411005103C67C998C98EbcB2730bCf7932f2");
//   console.log("📊 getInfo(user1):", info2);
  const info = await defi.getInfo ("0xE07431AC96ac820961caBbFA75809276482Aed5e");
  
  console.log("📊 rewarid:", info);
  const info6 = await defi.team2Big("0xE07431AC96ac820961caBbFA75809276482Aed5e");
  
  console.log("📊 rewarid:", info6);
//   // 7. 读取全网收益分配
//   const outToken = await defi.getOutToken();
//   console.log("📈 getOutToken():", hre.ethers.formatUnits(outToken, 0));

//   // 8. 测试领取收益（用户）
//   const claimTx = await defi.connect(user1).claimUser();
//   await claimTx.wait();
//   console.log("✅ user1 claimed personal reward");

//   // 9. 测试领取收益（团队）
//   const claimTx2 = await defi.connect(user1).claimTeam();
//   await claimTx2.wait();
//   console.log("✅ user1 claimed team reward");
}

main().catch((error) => {
  console.error("❌ 测试失败:", error);
  process.exit(1);
});
