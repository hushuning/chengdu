const hre = require("hardhat");

async function main() {
  const [owner, user1, user2] = await hre.ethers.getSigners();
  console.log("👤 Owner:", owner.address);

  //1. 部署 Mock ERC20 作为 sosk 代币
  const Token = await hre.ethers.getContractFactory("MyMockERC20");
  const sosk = await Token.deploy("SoskToken", "SOSK", hre.ethers.parseUnits("1000000", 18));
  await sosk.waitForDeployment();
  console.log("✅ Sosk deployed:", await sosk.getAddress());
    // 2.1 部署 game 合约
  // const Game = await hre.ethers.getContractFactory("BombGame");
  // const game = await Game.deploy();
  // await game.waitForDeployment();
  // console.log("✅ gameC deployed:", await game.getAddress());  
  // 2. 部署 DefiQS 合约
  const DefiQS = await hre.ethers.getContractFactory("DefiGame");
  const defi = await DefiQS.deploy(await sosk.getAddress());
  await defi.waitForDeployment();
  console.log("✅ DefiQS deployed:", await defi.getAddress());

  // // 3. 给 user1 发币 & 授权
  // await sosk.transfer(user1.address, hre.ethers.parseUnits("1000", 18));
  // const tokenInst = await hre.ethers.getContractAt("contracts/stakeDefi.sol:IERC20", await sosk.getAddress(), user1);
  // await tokenInst.approve(await defi.getAddress(), hre.ethers.parseUnits("1000", 18));
  // console.log("✅ User1 approved DefiQS");

  // // 4. user1 参与质押
  // const stakeAmount = hre.ethers.parseUnits("200", 18);
  // const tx = await defi.connect(user1).stake(owner.address, stakeAmount);
  // await tx.wait();
  // console.log("✅ User1 staked 200");

  // 5. 查看个人等级和衰减算力
  const level = await defi.getUserLevel(user1.address);
  const sycp = await defi.getSyCp(user1.address);
  console.log("👤 user1 等级:", level.toString(), "衰减算力:", hre.ethers.formatUnits(sycp, 0));

  // // 6. 获取 getInfo() 信息结构
  // const re2 = await defi.getUserReward(user1.address);
  // console.log(re2);  
  // await defi.connect(owner).setGameC(game.getAddress());
  // console.log("✅ setGameC to game contract");
//   const gameCC =  await defi.gameC()
//   console.log(gameCC);  
  const re3 = await defi.getRewardTeam(user1.address);
  console.log(re3);  

  const info = await defi.getInfo(user1.address);
  console.log("📊 getInfo(user1):", info);

  // 7. 读取全网收益分配
  const outToken = await defi.getOutToken();
  console.log("📈 getOutToken():", hre.ethers.formatUnits(outToken, 0));

  // 8. 测试领取收益（用户）
  const claimTx = await defi.connect(user1).claimUser();
  await claimTx.wait();
  console.log("✅ user1 claimed personal reward");

  // 9. 测试领取收益（团队）
  const claimTx2 = await defi.connect(user1).claimTeam();
  await claimTx2.wait();
  console.log("✅ user1 claimed team reward");
}

main().catch((error) => {
  console.error("❌ 测试失败:", error);
  process.exit(1);
});
