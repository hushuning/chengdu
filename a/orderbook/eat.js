// scripts/fillOrder.js
const { ethers } = require("hardhat");

const ABI = [
  "function fillOrder((uint256,address,address,address,address,uint256,uint256,bytes,bytes,bytes),bytes,uint256,uint256,uint256) payable"
];

async function main() {
  const [taker] = await ethers.getSigners();

  const limitOrderAddress = "0x11111112542d85B3EF69AE05771c2dCCff4fAa26";
  const limitOrder = new ethers.Contract(limitOrderAddress, ABI, taker);

  const order = {
    salt: "1684136127000",
    maker: "0xMakerAddress",  // 挂单地址
    receiver: "0xMakerAddress",
    makerAsset: "0x55d398326f99059fF775485246999027B3197955", // USDT
    takerAsset: "0x45EA0af0c71eA2Fb161AF3b07F033cEe123386E8",
    makerAmount: ethers.utils.parseUnits("100", 18),
    takerAmount: ethers.utils.parseUnits("5000", 18),
    predicate: "0x",
    permit: "0x",
    interaction: "0x",
  };

  const signature = "0x..."; // 来自挂单人的签名

  const tx = await limitOrder.fillOrder(
    order,
    signature,
    order.makerAmount,
    order.takerAmount,
    0,
    { gasLimit: 1_000_000 }
  );

  console.log("⛓️ 吃单交易已发送:", tx.hash);
  await tx.wait();
  console.log("✅ 吃单完成");
}

main().catch(console.error);
