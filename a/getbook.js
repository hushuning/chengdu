// scripts/orderBook.js
const axios = require("axios");
const { ethers } = require("hardhat");

const USDT = "0x55d398326f99059fF775485246999027B3197955";
const TOKEN = "0x45EA0af0c71eA2Fb161AF3b07F033cEe123386E8";
const chainId = 56;

async function fetchOrders(makerAsset, takerAsset) {
  const url = `https://limit-orders.1inch.io/v3.0/${chainId}/limit-order/all?makerAsset=${makerAsset}&takerAsset=${takerAsset}`;
  const res = await axios.get(url);
  return res.data;
}

function displayOrders(orders, direction = "buy") {
  console.log(`📄 当前${direction === "buy" ? "买入" : "卖出"}挂单（${orders.length}条）:`);
  for (const order of orders) {
    const price = ethers.utils.formatUnits(order.makerAmount, 18) / ethers.utils.formatUnits(order.takerAmount, 18);
    const amount = ethers.utils.formatUnits(order.takerAmount, 18); // token 数量
    console.log(`- ${direction === "buy" ? "买" : "卖"} ${amount} token，价格 ≈ ${price.toFixed(6)} USDT/token，maker: ${order.maker}`);
  }
}

async function main() {
  // 买单 = 用 USDT 买 TOKEN（makerAsset 是 USDT）
  const buyOrders = await fetchOrders(USDT, TOKEN);
  displayOrders(buyOrders, "buy");

  // 卖单 = 卖 TOKEN 换 USDT（makerAsset 是 TOKEN）
  const sellOrders = await fetchOrders(TOKEN, USDT);
  displayOrders(sellOrders, "sell");
}

main().catch((err) => {
  console.error("❌ 查询出错：", err);
});
