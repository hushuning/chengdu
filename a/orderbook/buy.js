// scripts/buyTokenOrder.js
const { ethers } = require("hardhat");
const axios = require("axios");
//✅ 脚本1：USDT → 买入 0x45EA...（限价挂单）
//即你想用 100 USDT 买入 5000 个 token，限价：0.02 USDT/token
async function main() {
  const [maker] = await ethers.getSigners();

  const chainId = 56; // BNB Chain
  const limitOrderAddress = "0x11111112542d85B3EF69AE05771c2dCCff4fAa26";

  const USDT = "0x55d398326f99059fF775485246999027B3197955";
  const TOKEN = "0x45EA0af0c71eA2Fb161AF3b07F033cEe123386E8";

  const makerAsset = USDT;   // 你出的钱
  const takerAsset = TOKEN;  // 你想买的 token

  const makerAmount = ethers.utils.parseUnits("100", 18);   // 出 100 USDT
  const takerAmount = ethers.utils.parseUnits("5000", 18);  // 想要 5000 token

  const order = {
    salt: Date.now().toString(),
    maker: maker.address,
    receiver: maker.address,
    makerAsset,
    takerAsset,
    makerAmount,
    takerAmount,
    predicate: "0x",
    permit: "0x",
    interaction: "0x",
  };

  const domain = {
    name: "1inch Limit Order Protocol",
    version: "3",
    chainId,
    verifyingContract: limitOrderAddress,
  };

  const types = {
    Order: [
      { name: "salt", type: "uint256" },
      { name: "maker", type: "address" },
      { name: "receiver", type: "address" },
      { name: "makerAsset", type: "address" },
      { name: "takerAsset", type: "address" },
      { name: "makerAmount", type: "uint256" },
      { name: "takerAmount", type: "uint256" },
      { name: "predicate", type: "bytes" },
      { name: "permit", type: "bytes" },
      { name: "interaction", type: "bytes" },
    ],
  };

  const signature = await maker._signTypedData(domain, types, order);

  const signedOrder = { ...order, signature };

  console.log("✅ 签名完成，准备广播订单");

  const response = await axios.post(
    `https://limit-orders.1inch.io/v3.0/${chainId}/limit-order`,
    signedOrder
  );

  console.log("✅ 广播成功:", response.data);
}

main().catch((e) => {
  console.error("❌ 出错:", e);
  process.exit(1);
});
