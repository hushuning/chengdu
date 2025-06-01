const hre = require("hardhat");

async function main() {
  const [user1, user2] = await hre.ethers.getSigners();
  console.log("👤 Owner:", user1.address);

  // 1. 主网 USDT、TOKEN 和 Protocol 地址
  const usdtAddr     = "0x55d398326f99059fF775485246999027B3197955";
  const tokenAddr    = "0x45EA0af0c71eA2Fb161AF3b07F033cEe123386E8";
  const protocolAddr = "0x123F227697c8F1F798Cb9D0359743a1b152B567d";

  // 先把已部署的合约实例化
  const Token    = await hre.ethers.getContractFactory("MyMockERC20");
  const usdt     = await hre.ethers.getContractAt("MyMockERC20", usdtAddr);
  const token    = await hre.ethers.getContractAt("MyMockERC20", tokenAddr);
  const protocol = await hre.ethers.getContractAt("LimitOrderProtocol", protocolAddr);

  console.log("✅ USDT at:", usdtAddr);
  console.log("✅ MTK at:", tokenAddr);
  console.log("✅ Protocol at:", protocolAddr);

  // 2. 分发 Mainnet 上不存在，跳过
  const feeData = await ethers.provider.getFeeData();
    const gasPrice = feeData.gasPrice;  
    console.log(
    "Current gasPrice:",
    hre.ethers.formatUnits(gasPrice, "gwei"),
    "gwei"
  );
  // 3. 分发 Mainnet 上不存在，跳过

  // 4. 授权 protocol 合约操作
//   await usdt.connect(user1).approve(protocolAddr, hre.ethers.parseUnits("1000000", 18),{gasPrice: gasPrice});
//   await token.connect(user2).approve(protocolAddr, hre.ethers.parseUnits("1000000", 18),{gasPrice: gasPrice});
//   await usdt.connect(user2).approve(protocolAddr, hre.ethers.parseUnits("1000000", 18),{gasPrice: gasPrice});
//   await token.connect(user1).approve(protocolAddr, hre.ethers.parseUnits("1000000", 18),{gasPrice: gasPrice});
  console.log("✅ Users approved protocol to spend tokens");

  // 5. 构建卖单：user2 卖 MTK，user1 买入
  // 5. 构建卖单：user2 卖 MTK，user1 买入
  const chainId = await hre.ethers.provider.getNetwork().then(n => n.chainId);
  const expiry = Math.floor(Date.now() / 1000) + 3600; // 1 小时内有效
  const sellOrder = {
    makerToken: tokenAddr,
    takerToken: usdtAddr,
    makerAmount: hre.ethers.parseUnits("100", 18),
    takerAmount: hre.ethers.parseUnits("0.001", 18),
    maker: user2.address,
    taker: "0x0000000000000000000000000000000000000000",
    sender: "0x0000000000000000000000000000000000000000",
    pool: hre.ethers.keccak256(hre.ethers.toUtf8Bytes("default")),
    expiry,
    salt: Date.now()
  };
  const domain = {
    name: "0x Protocol",
    version: "4",
    chainId,
    verifyingContract: protocolAddr
  };
  const types = {
    LimitOrder: [
      { name: "makerToken", type: "address" },
      { name: "takerToken", type: "address" },
      { name: "makerAmount", type: "uint128" },
      { name: "takerAmount", type: "uint128" },
      { name: "maker", type: "address" },
      { name: "taker", type: "address" },
      { name: "sender", type: "address" },
      { name: "pool", type: "bytes32" },
      { name: "expiry", type: "uint64" },
      { name: "salt", type: "uint256" },
    ]
  };
  const sellSig = await user2.signTypedData(domain, types, sellOrder);
  console.log("✅ Sell order signed by user2");

  const fillTx = await protocol.connect(user1).fillLimitOrder(sellOrder, sellSig, sellOrder.takerAmount);
  await fillTx.wait();
  console.log("✅ Sell order filled by user1");

  // 6. 查询交易历史 & 价格（原有逻辑）
  const count = await protocol.getInfo(user1.address);
  console.log(`📊 user1 历史记录数量: ${count}`);
  if (count > 0) {
    const [entry] = await protocol.getArry(user1.address, 0, 1);
    console.log(`📌 第 1 条记录: 类型=${entry[0]} 时间=${entry[1]} 输入=${entry[2]} 输出=${entry[3]}`);
  }
  const rawPrice = await protocol.price();
  console.log(`💸 当前 Token 价格为: ${hre.ethers.formatUnits(rawPrice, 18)} USDT`);

  // —— 新增部分 —— //
  // 7. 构建买单：user1 用 USDT 购买 MTK，委托给 user2 来执行
  const buyExpiry = Math.floor(Date.now() / 1000) + 3600;
  const buyOrder = {
    makerToken: usdtAddr,
    takerToken: tokenAddr,
    makerAmount: hre.ethers.parseUnits("0.001", 18),    // user1 愿意支付 500 USDT
    takerAmount: hre.ethers.parseUnits("100", 18),    // user1 想要买入 100 MTK
    maker: user1.address,
    taker: "0x0000000000000000000000000000000000000000",                             // 指定只有 user2 可以 fill
    sender: "0x0000000000000000000000000000000000000000",
    pool: hre.ethers.keccak256(hre.ethers.toUtf8Bytes("default")),
    expiry: buyExpiry,
    salt: Date.now() + 1
  };
  const buySig = await user1.signTypedData(domain, types, buyOrder);
  console.log("🛒 Buy order signed by user1");
  console.log("📝 Buy order details:", buyOrder);
  // 8. user2 执行买单（委托购买）
  const buyTx = await protocol.connect(user2).fillLimitOrder(
    buyOrder,
    buySig,
    buyOrder.takerAmount
  );
  await buyTx.wait();
  console.log("✅ Buy order filled by user2");
  const rawPrice2 = await protocol.price();
  console.log(`💸 当前 Token 价格为: ${hre.ethers.formatUnits(rawPrice2, 18)} USDT`);

  // 9. 再次查询两用户余额，验证买入效果
  const user1Mtk = await token.balanceOf(user1.address);
  const user2Usdt = await usdt.balanceOf(user2.address);
  console.log(`🔍 user1 现在持有 MTK: ${hre.ethers.formatUnits(user1Mtk, 18)}`);
  console.log(`🔍 user2 现在持有 USDT: ${hre.ethers.formatUnits(user2Usdt, 18)}`);
}

main().catch((error) => {
  console.error("❌ 脚本执行失败:", error);
  process.exit(1);
});
