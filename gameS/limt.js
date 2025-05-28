const hre = require("hardhat");

async function main() {
  const [owner, user1, user2] = await hre.ethers.getSigners();
  console.log("👤 Owner:", owner.address);

  // 1. 部署 Mock USDT 和 TOKEN
  const Token = await hre.ethers.getContractFactory("MyMockERC20");
  const usdt = await Token.deploy("Tether USD", "USDT", hre.ethers.parseUnits("1000000", 18));
  await usdt.waitForDeployment();
  const usdtAddr = await usdt.getAddress();
  console.log("✅ USDT deployed at:", usdtAddr);

  const token = await Token.deploy("MyToken", "MTK", hre.ethers.parseUnits("1000000", 18));
  await token.waitForDeployment();
  const tokenAddr = await token.getAddress();
  console.log("✅ MTK deployed at:", tokenAddr);

  // 2. 部署协议合约
  const Protocol = await hre.ethers.getContractFactory("LimitOrderProtocol");
  const protocol = await Protocol.deploy();
  await protocol.waitForDeployment();
  const protocolAddr = await protocol.getAddress();
  console.log("✅ Protocol deployed at:", protocolAddr);

  // 3. 分发 USDT & TOKEN 给用户
  await usdt.transfer(user1.address, hre.ethers.parseUnits("1000", 18));
  await token.transfer(user2.address, hre.ethers.parseUnits("1000", 18));
  console.log("✅ Distributed tokens to users");

  // 4. 授权 protocol 合约操作
  await usdt.connect(user1).approve(protocolAddr, hre.ethers.parseUnits("1000", 18));
  await token.connect(user2).approve(protocolAddr, hre.ethers.parseUnits("1000", 18));
  console.log("✅ Users approved protocol to spend tokens");

  // 5. 构建订单：user2 卖 TOKEN，user1 买入
  const chainId = await hre.ethers.provider.getNetwork().then(n => n.chainId);
  const expiry = Math.floor(Date.now() / 1000) + 3600; // 1 小时内有效
  const order = {
    makerToken: tokenAddr,
    takerToken: usdtAddr,
    makerAmount: hre.ethers.parseUnits("100", 18),
    takerAmount: hre.ethers.parseUnits("500", 18),
    maker: user2.address,
    taker: user1.address,
    sender: user1.address,
    pool: hre.ethers.keccak256(hre.ethers.toUtf8Bytes("default")),
    expiry: expiry,
    salt: Date.now()
  };

  // 6. 构建签名（EIP712）
  const domain = {
    name: "0x Protocol",
    version: "4",
    chainId: chainId,
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

  const signature = await user2.signTypedData(domain, types, order);
  console.log("✅ Order signed by user2");

  // 7. user1 执行撮合交易
  const tx = await protocol.connect(user1).fillLimitOrder(order, signature, order.takerAmount);
  await tx.wait();
  console.log("✅ Order filled successfully");

  // 8. 获取用户交易历史
  const count = await protocol.getInfo(user1.address);
  console.log(`📊 user1 历史记录数量: ${count}`);

  if (count > 0) {
    const result = await protocol.getArry(user1.address, 0, 1);
    const entry = result[0];
    console.log(`📌 第 1 条记录: 类型=${entry[0]} 时间=${entry[1]} 输入=${entry[2]} 输出=${entry[3]}`);
  }

  // 9. 查看当前价格（USDT per Token）
  const rawPrice = await protocol.price();
  const price = hre.ethers.formatUnits(rawPrice, 18);
  console.log(`💸 当前 Token 价格为: ${price} USDT`);
}

main().catch((error) => {
  console.error("❌ 脚本执行失败:", error);
  process.exit(1);
});
