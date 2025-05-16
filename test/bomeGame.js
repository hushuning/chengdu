const assert = require("assert");
const hre = require("hardhat");

describe("BombGame", function () {
  let bombGame, token, owner, player1, player2;

  beforeEach(async function () {
    [owner, player1, player2, team] = await ethers.getSigners();
    console.log("Owner address:", owner.address);
    console.log("Player1 address:", player1.address);
    console.log("Player2 address:", player2.address);
    console.log("Team address:", team.address); 
    // console.log("Token address:", token.address);
    network = hre.network.name;
    console.log("Network:", network);
    const Token = await ethers.getContractFactory("MyMockERC20");
    token = await Token.deploy("GameToken", "GT", hre.ethers.parseEther("1000000"));
    console.log("Token deployed to:", token.target);
    const BombGame = await ethers.getContractFactory("BombGame");
    bombGame = await BombGame.deploy();
    console.log("BombGame deployed to:", bombGame.target);
    await bombGame.setGameToken(token.target);
    await bombGame.setTeamAddress(team.address);
    await token.transfer(bombGame.target, hre.ethers.parseEther("10000")); 
    for (const player of [player1, player2]) {
        console.log("Transferring tokens to player:", player.address);
      await token.transfer(player.address, hre.ethers.parseEther("1000"));
    console.log("Player token balance:", (await token.balanceOf(player.address)));

      await token.connect(player).approve(bombGame.target, hre.ethers.parseEther("1000"));
        console.log("Player token balance:", (await token.balanceOf(player.address)));
    }
    console.log("Token2222222 balance of BombGame:", (await token.balanceOf(bombGame.target)).toString());
  });

//   it("should initialize with correct admin and roundId", async function () {
//     const admin = await bombGame.admin();
//     const roundId = await bombGame.roundId();

//     assert.strictEqual(admin, owner.address);
//     assert.strictEqual(roundId.toNumber(), 1);
//   });

  it("should allow admin to transfer admin", async function () {
        console.log("Admin transferred to:", bombGame);

    await bombGame.connect(owner).transferAdmin(player1.address);
    console.log("Admin transferred to:", bombGame);
    const newAdmin = await bombGame.admin();
    // assert.strictEqual(newAdmin, player1.address);
  });

  it("should allow players to join the game", async function () {
    await bombGame.connect(player1).joinGame(1, hre.ethers.parseEther("100"));

    const stats = await bombGame.getMyStats(player1.address);
    console.log("Player1 stats:", stats);
    // assert.strictEqual(stats.roundAmount.toString(), hre.ethers.parseEther("100").toString());
    // assert.strictEqual(stats.roundRoom, 1);
  });

  it("should reject joinGame if room is invalid", async function () {
    await assert.rejects(
      bombGame.connect(player1).joinGame(99, hre.ethers.parseEther("10")),
      /Invalid room/
    );
  });

  it("should reject joinGame if no allowance", async function () {
    await token.connect(player1).approve(bombGame.target, 0);
    await assert.rejects(
      bombGame.connect(player1).joinGame(1, hre.ethers.parseEther("10")),
      /Insufficient allowance/
    );
  });

  it("should end game and distribute correctly", async function () {
    await bombGame.connect(player1).joinGame(1, hre.ethers.parseEther("100"));
    await bombGame.connect(player2).joinGame(2, hre.ethers.parseEther("100"));

    const balanceBefore = await token.balanceOf(player1.address);
    await bombGame.endGame();
    const balanceAfter = await token.balanceOf(player1.address);

    // assert(balanceAfter.gt(balanceBefore) || balanceAfter.lt(balanceBefore));
  });

  it("should return game statistics", async function () {
    await bombGame.connect(player1).joinGame(1, hre.ethers.parseEther("10"));
    const stats = await bombGame.getGameStatistics();
    // assert.strictEqual(stats.currentRound.toNumber(), 1);
    // assert(stats.allPlayersInRound.length >= 1);
  });

  it("should return player stats", async function () {
    await bombGame.connect(player1).joinGame(2, hre.ethers.parseEther("20"));
    const stats = await bombGame.getMyStats(player1.address);
    // assert.strictEqual(stats.roundAmount.toString(), hre.ethers.parseEther("20").toString());
    // assert.strictEqual(stats.roundRoom, 2);
  });

  it("should return top 10 daily and weekly rankings", async function () {
    await bombGame.connect(player1).joinGame(0, hre.ethers.parseEther("20"));
    const nowDay = Math.floor(Date.now() / 1000 / 86400);
    const nowWeek = Math.floor(Date.now() / 1000 / 604800);

    const dailyTop = await bombGame.getTopRankingInfo(nowDay, true);
    const weeklyTop = await bombGame.getTopRankingInfo(nowWeek, false);

    assert(Array.isArray(dailyTop));
    assert(Array.isArray(weeklyTop));
  });

  it("should allow admin to withdraw tokens", async function () {
    await token.transfer(bombGame.target, hre.ethers.parseEther("100"));
    await bombGame.withdrawToken(token.target, player1.address, hre.ethers.parseEther("50"));

    const bal = await token.balanceOf(player1.address);
    console.log("Player1 token balance after withdrawal:", bal.toString());
    // assert.strictEqual(bal.toString(), hre.ethers.parseEther("1050").toString());
  });

  it("should receive BNB", async function () {
    await owner.sendTransaction({
      to: bombGame.target,
      value: hre.ethers.parseEther("1"),
    });

    const contractBNB = await ethers.provider.getBalance(bombGame.target);
    // assert.strictEqual(contractBNB.toString(), hre.ethers.parseEther("1").toString());
  });

  it("should allow admin to withdraw BNB", async function () {
    await owner.sendTransaction({
      to: bombGame.target,
      value: hre.ethers.parseEther("1"),
    });

    const balanceBefore = await ethers.provider.getBalance(player1.address);
    await bombGame.withdrawBNB(player1.address, hre.ethers.parseEther("0.5"));
    const balanceAfter = await ethers.provider.getBalance(player1.address);

    // assert(balanceAfter.gt(balanceBefore));
  });
});
