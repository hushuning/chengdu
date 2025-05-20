const hre = require("hardhat");

async function main() {
  const [owner, user1, user2] = await hre.ethers.getSigners();
  console.log("👤 Owner:", owner.address);

  // 1. 部署 Mock ERC20 代币，用作游戏代币
  const Token = await hre.ethers.getContractFactory("MyMockERC20");
  const gameToken = await Token.deploy("GameToken", "GT", hre.ethers.parseUnits("1000000", 18));
  await gameToken.waitForDeployment();
  console.log("✅ GameToken deployed at:", await gameToken.getAddress());

  // 2. 部署 BombGame 合约
  const BombGame = await hre.ethers.getContractFactory("BombGame");
  const bombGame = await BombGame.deploy();
  await bombGame.waitForDeployment();
  console.log("✅ BombGame deployed at:", await bombGame.getAddress());

  // 3. 设置游戏代币地址
  await bombGame.setGameToken(await gameToken.getAddress());
  console.log("✅ BombGame token set to GameToken");

  // 4. 给 user1 和 user2 发送代币
  await gameToken.transfer(user1.address, hre.ethers.parseUnits("1000", 18));
  await gameToken.transfer(user2.address, hre.ethers.parseUnits("1000", 18));
  console.log("✅ Transferred 1000 GT to user1 and user2");

  // 5. user1 和 user2 授权 BombGame 合约转代币
  await gameToken.connect(user1).approve(bombGame.getAddress(), hre.ethers.parseUnits("1000", 18));
  await gameToken.connect(user2).approve(bombGame.getAddress(), hre.ethers.parseUnits("1000", 18));
  console.log("✅ user1 and user2 approved BombGame to spend tokens");

  // 6. user1 加入房间1，投入100 GT
  await bombGame.connect(user1).joinGame(1, hre.ethers.parseUnits("100", 18));
  console.log("✅ user1 joined room 1 with 100 GT");

  // 7. user2 加入房间2，投入200 GT
  await bombGame.connect(user2).joinGame(2, hre.ethers.parseUnits("200", 18));
  console.log("✅ user2 joined room 2 with 200 GT");

  // 8. 查询当前房间资金情况
  const roomMoney = await bombGame.getRoomMoney();
  console.log("💰 Room Money per room:");
  roomMoney.forEach((money, idx) => {
    console.log(`  Room ${idx}: ${hre.ethers.formatUnits(money, 18)} GT`);
  });
  // 9. 查询查询游戏合约代币余额
    const gameTokenBalance = await gameToken.balanceOf(bombGame.getAddress());
    console.log("💰 Game contract balance:", hre.ethers.formatUnits(gameTokenBalance, 18), "GT");
  // 9. 查询用户余额
  const user1Balance = await gameToken.balanceOf(user1.address);
  console.log("👤 user1 balance:", hre.ethers.formatUnits(user1Balance, 18), "GT");
  // 9. 管理员调用 endGame，传入随机数 12345
  const tx = await bombGame.endGame(12345);
  await tx.wait();
  console.log("✅ endGame called");
  const user1Balance1 = await gameToken.balanceOf(user1.address);
  console.log("👤 user1 balance:", hre.ethers.formatUnits(user1Balance1, 18), "GT");
 
  // 10. 查询游戏结果（爆炸房间）
  const roundId = await bombGame.roundId();
  console.log(`🔥 Round ${roundId} ended`);
//   const roundId = roundIdBN.toNumber(); // 转成普通数字
  const gameResult = await bombGame.getGame(roundId-1n); // 查询上一轮结果
  console.log(gameResult[0].toString(),gameResult[1].toString());

  // 11. 查询今日排行榜（假设用当前天）
  const currentDay = Math.floor(Date.now() / 1000 / 86400);
  const topDaily = await bombGame.getTopRankingInfo(currentDay, true);
  console.log("📊 Top Daily Ranking:");
  topDaily.forEach((entry, i) => {
    console.log(`#${i + 1}: Player=${entry.player}, Amount=${hre.ethers.formatUnits(entry.amount, 18)} GT`);
  });
  // 12. 查询整体游戏数据
  // 额外调用 getGameStatistics，打印更全面数据
const gameStats = await bombGame.getGameStatistics();

console.log("==== Game Statistics ====");
console.log("Current Round:", gameStats.currentRound.toString());

console.log("Players in Current Round:");
gameStats.allPlayersInRound.forEach((ps, idx) => {
  console.log(`#${idx + 1} Player: ${ps.player} Amount: ${hre.ethers.formatUnits(ps.amount, 18)}`);
});

console.log("Top 10 Daily Ranking:");
gameStats.top10Daily.forEach((entry, idx) => {
  console.log(`#${idx + 1} Player: ${entry.player} Amount: ${hre.ethers.formatUnits(entry.amount, 18)}`);
});

console.log("Top 10 Weekly Ranking:");
gameStats.top10Weekly.forEach((entry, idx) => {
  console.log(`#${idx + 1} Player: ${entry.player} Amount: ${hre.ethers.formatUnits(entry.amount, 18)}`);
});

}

main().catch((error) => {
  console.error("❌ 脚本执行失败:", error);
  process.exit(1);
});
