// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
// require("@nomiclabs/hardhat-ethers");  
const hre = require("hardhat");
// const { expect } = require("chai");

// const { ethers } = require("hardhat");
// console.log("ethers", hre.ethers);

const ccAddr = {};
async function main() {

//  await deploy(); 
//  await tokenTme();
//  await fireC(ccAddr);//测试FR合约
 await tokenApprove(ccAddr);//测试M2合约
//  await m2();
}
// async function m2() {
//   //调用M2合约的所有函数功能
//   const M2 = await hre.ethers.getContractFactory("M2");
//   const m2 = await M2.attach(ccAddr.m2);
// }
async function deploy() {
  // const LingQu = await hre.ethers.getContractFactory("LingQu");
  // const lingqu = await LingQu.deploy();
  // ccAddr.lingqu = lingqu.target;
  // console.log("lingqu合约地址2",
  //   ccAddr.lingqu
  // );
  // console.log("lingqu合约地址",
  //   lingqu.target
  // );
     const [s1] = await hre.ethers.getSigners();  
  console.log("signer",s1.address);
  // return;
  const Fire = await hre.ethers.getContractFactory("LimitOrderProtocol");
  const fire = await Fire.deploy();
  ccAddr.fr = fire.address;
 

  console.log("limit合约地址",
    fire.address,fire.target
  );
  
  // const M2 = await hre.ethers.getContractFactory("M2");
  // const m2 = await M2.deploy(fire.target);


  // ccAddr.m2 = m2.target;

  // console.log("m2合约地址",
  //   m2.target
  // );
  
}
async function tokenApprove(obj) {
   // —— 1. 读取 ABI ——  
   const artifact = await artifacts.readArtifact("DefiQS");  
   // —— 2. 填入你部署后得到的地址 ——  
   const address  = obj.m2; // 这里是你部署的合约地址
   const abiIERC20 = await artifacts.readArtifact("contracts/erc20.sol:IERC20");  

   // —— 3. 用默认 signer（部署者）或你自己指定的 signer ——  
   const [s1,s2] = await hre.ethers.getSigners();  
   // —— 4. 生成合约实例 ——  
   const m2 = new hre.ethers.Contract(address, artifact.abi, s1);
 
   // —— 5. 调用自动生成的 getter ——  
   ccAddr.pgpg    = await m2.pgpg();
  //  console.log("pgpg合约地址", pgpg);
   ccAddr.v1      = await m2.v1();
   ccAddr.v2      = await m2.v2();

   ccAddr.v3     = await m2.v3();
   ccAddr.v4     = await m2.v4();
   const pgpgC = new hre.ethers.Contract(ccAddr.pgpg, abiIERC20.abi, s2);

   const v2C = new hre.ethers.Contract(ccAddr.v2, abiIERC20.abi, s2);
   const v3C = new hre.ethers.Contract(ccAddr.v3, abiIERC20.abi, s2);
   const v4C = new hre.ethers.Contract(ccAddr.v4, abiIERC20.abi, s2);
   const txpg = await pgpgC.transfer(ccAddr.m2, hre.ethers.parseUnits("10000", 18));  
   const txv2 = await v2C.transfer(ccAddr.m2, hre.ethers.parseUnits("10", 18));  
   balanceOf = await v2C.balanceOf(ccAddr.m2);
   console.log("v2余额", hre.ethers.formatUnits(balanceOf, 18));
   const txv3 =await  v3C.transfer(ccAddr.m2, hre.ethers.parseUnits("10", 18));  
   const txv4 =await v4C.transfer(ccAddr.m2, hre.ethers.parseUnits("10", 18));  
   console.log("pgpg转账成功",txpg.hash);

   console.log("v2转账成功",txv2.hash);
   console.log("v3转账成功",txv3.hash);
   console.log("v4转账成功",txv4.hash);
   await setWhite(ccAddr.pgpg,[
    ccAddr.m2,])
   await setWhite(ccAddr.v1,[
    ccAddr.m2,])
   await setWhite(ccAddr.v2,[
      ccAddr.m2,]) 
   await setWhite(ccAddr.v3,[
    ccAddr.m2,]) 
   await setWhite(ccAddr.v4,[
      ccAddr.m2,]) 
      
  // 获取 ERC‑20 合约实例（ABI 使用 OpenZeppelin 的 IERC20）
  const IERC20 = [
    "function approve(address spender, uint256 amount) external returns (bool)",
    "function allowance(address owner, address spender) external view returns (uint256)"
  ];
  const token = await hre.ethers.getContractAt(IERC20, ccAddr.v4, s1);

  // 授权数量，例如 100 个 token（假设代币 18 decimals）
  const amount = hre.ethers.parseUnits("10000000000000000000000", 18);

  // 发起 approve 交易
  const tx = await token.connect(s2).approve(obj.m2, amount);
  console.log("Approve tx hash:", tx.hash);
  await tx.wait();
  console.log("Approved ✅");
  const tx3 = await s1.sendTransaction({
      to: s2.address,
      value: ethers.parseEther("100"),
    });
  
    console.log("z转账陈公公:", tx3.hash);
    await m2.getPrice(ccAddr.pgpg,hre.ethers.parseEther("0.01")).then((price) => {
      console.log("Price:", hre.ethers.formatUnits(price, 18), "BNB");
    });
  // 验证 allowance
  const allowance = await token.allowance(s2.address, obj.m2);
  console.log("Allowance is now:", hre.ethers.formatUnits(allowance, 18));
  const  tx1 = await m2.connect(s2).stake4(s1.address,{
    value: hre.ethers.parseEther("1")
  });
  await tx1.wait();
  console.log("stake1 success ✅");
  console.log("TX Hash:", tx1.hash);
  aa = await m2.getInfo(s2.address);
  console.log("getinfo:", aa);
}
async function fireC(obj) {
  // —— 1. 读取 ABI ——  
  const artifact = await artifacts.readArtifact("Fire");  
  // —— 2. 填入你部署后得到的地址 ——  
  const address  = obj.fr; // 这里是你部署的合约地址
  const abiIERC20 = await artifacts.readArtifact("contracts/erc20.sol:IERC20");  

  // —— 3. 用默认 signer（部署者）或你自己指定的 signer ——  
  const [s1,s2] = await hre.ethers.getSigners();  
  // —— 4. 生成合约实例 ——  
  const fr = new hre.ethers.Contract(address, artifact.abi, s1);

  // —— 5. 调用自动生成的 getter ——  
  ccAddr.pgpg    = await fr.pgpg();
  ccAddr.lp    = await fr.lp();

 //  console.log("pgpg合约地址", pgpg);
  // ccAddr.v1      = await m2.v1();
  // ccAddr.v2      = await m2.v2();

  // ccAddr.v3     = await m2.v3();
  // ccAddr.v4     = await m2.v4();
  const pgpgC = new hre.ethers.Contract(ccAddr.pgpg, abiIERC20.abi, s2);

  // const v2C = new hre.ethers.Contract(ccAddr.v2, abiIERC20.abi, s2);
  // const v3C = new hre.ethers.Contract(ccAddr.v3, abiIERC20.abi, s2);
  // const v4C = new hre.ethers.Contract(ccAddr.v4, abiIERC20.abi, s2);
  // const txpg = await pgpgC.transfer(ccAddr.m2, hre.ethers.parseUnits("10000", 18));  
  // const txv2 = await v2C.transfer(ccAddr.m2, hre.ethers.parseUnits("10", 18));  
  // balanceOf = await v2C.balanceOf(ccAddr.m2);
  // console.log("v2余额", hre.ethers.formatUnits(balanceOf, 18));
  // const txv3 =await  v3C.transfer(ccAddr.m2, hre.ethers.parseUnits("10", 18));  
  // const txv4 =await v4C.transfer(ccAddr.m2, hre.ethers.parseUnits("10", 18));  
  // console.log("pgpg转账成功",txpg.hash);

  // console.log("v2转账成功",txv2.hash);
  // console.log("v3转账成功",txv3.hash);
  // console.log("v4转账成功",txv4.hash);
  await setWhite(ccAddr.pgpg,[
   ccAddr.fr,])
  // await setWhite(ccAddr.v1,[
  //  ccAddr.m2,])
  // await setWhite(ccAddr.v2,[
  //    ccAddr.m2,]) 
  // await setWhite(ccAddr.v3,[
  //  ccAddr.m2,]) 
  // await setWhite(ccAddr.v4,[
  //    ccAddr.m2,]) 
     
 // 获取 ERC‑20 合约实例（ABI 使用 OpenZeppelin 的 IERC20）
 const IERC20 = [
   "function approve(address spender, uint256 amount) external returns (bool)",
   "function allowance(address owner, address spender) external view returns (uint256)"
];
 const token = await hre.ethers.getContractAt(IERC20, ccAddr.pgpg, s1);

 // 授权数量，例如 100 个 token（假设代币 18 decimals）
 const amount = hre.ethers.parseUnits("10000000000000000000000", 18);

 // 发起 approve 交易
 const tx = await token.connect(s2).approve(obj.m2, amount);
 console.log("Approve tx hash:", tx.hash);
 await tx.wait();
 console.log("Approved ✅");
 const tx3 = await s1.sendTransaction({
     to: s2.address,
     value: ethers.parseEther("100"),
   });
 
   console.log("z转账陈公公:", tx3.hash);
   await fr.getReward(s2.address,1).then((price) => {
     console.log("reward模式1:", price);
   });
   await fr.getReward(s2.address,2).then((price) => {
    console.log("reward模式2:", price);
  });
 // 验证 allowance
 const allowance = await token.allowance(s2.address, obj.fr);
 console.log("Allowance is now:", hre.ethers.formatUnits(allowance, 18));
 const abc =  await fr.getUsdtWbnb(hre.ethers.parseEther("100"))
 console.log("Wbnb=token?how?:", hre.ethers.formatUnits(abc, 18));
 const  tx1 = await fr.connect(s2).stakeBnb(100,3,{
   value: abc
 });
 await tx1.wait();
 console.log("stake1 success ✅");
 console.log("TX Hash:", tx1.hash);
 aa = await fr.getInfo(s2.address);
 console.log("getinfo:", aa);
}
async function tokenTme() {
  const [signer,s2] = await hre.ethers.getSigners();  
   
  const whale = "0x82791d87CDD8c820AD7Db131b5303cf2A586fbf4";  // 示例 WBTC “鲸鱼” 地址
  const me    = signer.address;                        // 把它换成你自己的测试地址

  // 1) 模拟解锁鲸鱼账户
  await network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [whale]
  });

  // 2) 获取该账户的 Signer
  const whaleSigner = await ethers.getSigner(whale);

  // 3) 准备 ERC‑20 合约接口（以 WBTC 为例）
  const tokenAddress = ccAddr.pgpg ;  // WBTC 主网地址
  const ERC20 = [
    "function balanceOf(address) view returns (uint256)",
    "function transfer(address to, uint256 amount) returns (bool)"
  ];
  const token = new hre.ethers.Contract(tokenAddress, ERC20, s2);

  // 4) 查询鲸鱼余额
  const bal = await token.balanceOf(whale);
  console.log("Whale balance:", hre.ethers.formatUnits(bal, 18), "WBTC");

  // 5) 转 1 WBTC 给 “我”
  const amount = hre.ethers.parseUnits("10000.0", 18);  // WBTC 8 decimals
  const tx = await token.transfer(me, amount);
  await tx.wait();
  console.log(`✅ 已从鲸鱼转账 100000 TOken 给 ${me}`);

  // 6) 停止模拟
  await network.provider.request({
    method: "hardhat_stopImpersonatingAccount",
    params: [whale]
  });
}
async function setWhite(tokenAddr,whitelist) {
    const [owner,myAccount] = await ethers.getSigners(); // 必须是合约 owner
    
    const tokenAddress = tokenAddr; // 替换为你的代币地址
 
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
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
