const hre = require("hardhat");
const { ethers, getAddress, parseUnits, formatUnits } = require("ethers");
require("dotenv").config();
const axios = require("axios");

// 使用 checksum 地址或直接使用字符串
const limitOrderAddress = getAddress("0x11111112542D85B3EF69AE05771c2dCCff4fAa26");
const USDT = "0x55d398326f99059fF775485246999027B3197955";
const TOKEN = "0x45EA0af0c71eA2Fb161AF3b07F033cEe123386E8";

async function ensureApproval(tokenAddress, signer, spender, amount) {
  const abi = [
    "function approve(address spender, uint256 amount) external returns (bool)",
    "function allowance(address owner, address spender) external view returns (uint256)",
  ];
  const token = new hre.ethers.Contract(tokenAddress, abi, signer);
  const allowance = await token.allowance(signer.address, spender);
  
  // 使用 BigNumber 比较 allowance
  // if (allowance<amount) {
  //   console.log(`🔑 授权 ${spender} 使用 ${tokenAddress} 中的 ${amount.toString()}`);
  //    token.connect(signer).approve(spender, hre.MaxUint256);
  //   console.log("✅ 授权成功", tx);
  // } else {
  //   console.log("✅ 已授权，跳过");
  // }
}
function serializeBigInt(obj) {
  return JSON.parse(JSON.stringify(obj, (_, v) =>
    typeof v === 'bigint' ? v.toString() :
    v && v._isBigNumber ? v.toString() :
    v
  ));
}

async function main() {
  const [signer] = await hre.ethers.getSigners();
  const chainId = 56;

  // ⚙️ 设置交易参数
  const side = "buy"; // "buy" = 用 USDT 买 token, "sell" = 卖 token 换 USDT
  const amount = "5000"; // token 数量
  const price = "1";  // 单价：每个 token 对应 USDT 价格
  console.log(signer.address);
  let makerAsset, takerAsset, makerAmount, takerAmount;

  if (side === "buy") {
    makerAsset = USDT;
    takerAsset = TOKEN;
    takerAmount = parseUnits(amount, 18); // 你要买多少 token
    makerAmount = parseUnits((parseFloat(amount) * parseFloat(price)).toString(), 18); // 你将支付多少 USDT
  } else {
    makerAsset = TOKEN;
    takerAsset = USDT;
    makerAmount = parseUnits(amount, 18); // 你卖出的 token 数量
    takerAmount = parseUnits((parseFloat(amount) * parseFloat(price)).toString(), 18); // 你想收到的 USDT 数量
  }

  // 🪙 先授权
  await ensureApproval(makerAsset, signer, limitOrderAddress, makerAmount);

  // 📄 构建订单
  const order = {
    salt: Date.now().toString(),
    maker: signer.address,
    receiver: signer.address,
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

  // 签署订单
  const signature = await signer.signTypedData(domain, types, order);
  const signedOrder = { ...order, signature };

  // 📤 广播订单
  const serializedOrder = serializeBigInt(signedOrder);

  const response = await axios.post(
    `https://limit-orders.1inch.io/v3.0/${chainId}/limit-order`,
    serializedOrder
  );

  console.log("✅ 广播成功：", response.data);
}

main().catch((error) => {
  console.error("❌ 错误：", error);
  process.exit(1);
});
