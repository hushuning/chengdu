const { ethers } = require("hardhat");

async function sendBNB(sender, recipient) {  
  const [deployer,d2] = await ethers.getSigners();
  
  const amountBNB = "0.01"; // 要发送的 BNB 数量

  // 查询 sender 和 recipient 的初始余额
  const senderBalanceBefore = await ethers.provider.getBalance(sender.address);
  const recipientBalanceBefore = await ethers.provider.getBalance(recipient.address);

  console.log(`Sender balance before: ${ethers.utils.formatEther(senderBalanceBefore)} BNB`);
  console.log(`Recipient balance before: ${ethers.utils.formatEther(recipientBalanceBefore)} BNB`);

  // 发起转账
  const tx = await deployer.sendTransaction({
    to: d2.address,
    value: ethers.parseEther(amountBNB),
  });

  console.log("Transaction hash:", tx.hash);

  // 等待交易确认
  await tx.wait();

  // 查询转账后的余额
  const senderBalanceAfter = await ethers.provider.getBalance(sender.address);
  const recipientBalanceAfter = await ethers.provider.getBalance(recipient.address);

  console.log(`Sender balance after: ${ethers.utils.formatEther(senderBalanceAfter)} BNB`);
  console.log(`Recipient balance after: ${ethers.utils.formatEther(recipientBalanceAfter)} BNB`);
}
async function main() {
  const [deployer,d2] = await ethers.getSigners();
  await deployer.sendTransaction({
    to: d2.address,
    value: ethers.parseEther("1000"), // 发送1 BNB
  });
  console.log("Deploying contract with address:", deployer.address);
  console.log("d2 contract with address:", d2.address);  
  const routerAddress = "0x10ED43C718714eb63d5aA57B78B54704E256024E";
  const tokenAddress = "0xC534165f8EA9998E878F4350536cAA9765b22222";
  await setWhite([

    "0xC534165f8EA9998E878F4350536cAA9765b22222",
    "0x930d8cF42FF71EfeEB63b62b0948F0c27d17416b",
    deployer.address,
  ]);  
  // ✅ Minimal ABI，只包含 addLiquidityETH
  const routerAbi = [
    "function addLiquidityETH(address token,uint amountTokenDesired,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity)"
  ];

  const tokenAbi  = [
    // 查询余额
    "function balanceOf(address account) view returns (uint256)",
    // 授权 spender 使用账户代币
    "function approve(address spender, uint256 amount) returns (bool)",
    // 授权额度查询
    "function allowance(address owner, address spender) view returns (uint256)",
    // 转账
    "function transfer(address recipient, uint256 amount) returns (bool)",
    // 代他人转账
    "function transferFrom(address sender, address recipient, uint256 amount) returns (bool)",
    // 代币信息
    "function name() view returns (string)",
    "function symbol() view returns (string)",
    "function decimals() view returns (uint8)",
    "function totalSupply() view returns (uint256)"
  ];

  const token = await ethers.getContractAt(tokenAbi, tokenAddress);
  const tokenV1 = await ethers.getContractAt(tokenAbi, "0x74dc66c4c96cD6153191da38f2D68D1d18fd95a1");

  const router = await ethers.getContractAt(routerAbi, routerAddress);

  const tokenAmount = ethers.parseUnits("1000000000000000", 18);
  const bnbAmount = ethers.parseEther("100"); // 0.00001 BNB
  const deadline = Math.floor(Date.now() / 1000) + 60 * 10;
  const tokenAmount2 = ethers.parseUnits("1000000", 18);
  const aa = await tokenV1.balanceOf(d2.address)
  console.log("balanceOf:", ethers.formatUnits(aa, 18));
  // 授权
  await token.connect(d2).approve(routerAddress, tokenAmount);
  balacT = await token.balanceOf(d2.address);
  // 调用路由添加流动性
  console.log("blancneOfD2222",balacT);
//   await token.connect(d2).transfer(deployer.address, tokenAmount);
//   balacTd2 = await token.balanceOf(d2.address);
//     console.log("blancneOfD2",balacTd2);
    // 验证授权是否成功
    deployer.sendTransaction({
      to: d2.address,
      value: ethers.parseEther("0.00001"),
    });
    const allowance = await token.allowance(d2.address, routerAddress);
    console.log("Allowance:", allowance.toString());
    const balance = await ethers.provider.getBalance(d2);
    console.log("Balance:", ethers.formatEther(balance));
    // 调用 addLiquidityETH 方法添加流动性
    const tx = await router.connect(d2).addLiquidityETH(
    tokenAddress,
    tokenAmount2,
    0,
    0,
    deployer.address,
    deadline,
    { value: bnbAmount, gasLimit: 30000000 } // 设置 gasLimit
  );

  console.log("TX Hash:", tx.hash);
    }

async function setWhite(whitelist) {
    const [owner,myAccount] = await ethers.getSigners(); // 必须是合约 owner
    
    const tokenAddress = "0xC534165f8EA9998E878F4350536cAA9765b22222"; // 替换为你的代币地址
    const tokenAbi = [
      "function setFeeWhiteList(address[] calldata addr, bool enable) external"
    ];
  
    const token2 = await ethers.getContractAt(tokenAbi, tokenAddress);
  
    // const whitelistAddresses = [
    //   "0xAddress1",
    //   "0xAddress2",
    //   "0xAddress3"
    // ];
  
    const tx = await token2.connect(myAccount).setFeeWhiteList(whitelist, true);
    await tx.wait();
  
    console.log("Fee whitelist set successfully.");
  }
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });