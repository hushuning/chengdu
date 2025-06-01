const { ethers, network } = require("hardhat");

const TOKEN_ADDRESS = "0xC534165f8EA9998E878F4350536cAA9765b22222"; // USDC
const WHALE = "0x6DFc6Cf0C3d8Ad10710408476173d6576e207206"; // 持有大量 USDC 的主网地址
console.log(`Receiver address: ${WHALE}`);

async function main() {
  const [receiver] = await ethers.getSigners();

  console.log(`Receiver address: ${receiver.address}`);

  // 1. 模拟鲸鱼账户
  await network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [WHALE],
  });

  const whaleSigner = await ethers.getSigner(WHALE);
  console.log(`Impersonated whale: ${WHALE}`);

  // 2. 获取 USDC 合约
  const usdc = await ethers.getContractAt("IERC20", TOKEN_ADDRESS, whaleSigner);

  // 3. 查看鲸鱼余额
  const whaleBalance = await usdc.balanceOf(WHALE);
  console.log("Whale USDC balance:", ethers.utils.formatUnits(whaleBalance, 6));

  // 4. 转账 1000 USDC 给 receiver
  const amount = ethers.utils.parseUnits("1000", 6); // USDC 是 6 位小数
  const tx = await usdc.transfer(receiver.address, amount);
  await tx.wait();

  // 5. 查看 receiver 新余额
  const newBalance = await usdc.balanceOf(receiver.address);
  console.log("Receiver USDC balance:", ethers.utils.formatUnits(newBalance, 6));
}
main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
