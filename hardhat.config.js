require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

// console.log(process.env.API_KEY); // ~输出 your_api_key_here

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.28", // 替换为你用的版本
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true, // ✅ 关键：启用 IR 编译路径
    },
  },
  defaultNetwork: "hardhat",

  networks: {
    bscMain: {
      url: "https://bnb.rpc.subquery.network/public",
      chainId: 56,
      accounts: [process.env.PRIVATE_KEY,process.env.PRIVATE_KEY2,]  // 从 .env 文件加载私钥
    },
    // hardhat: {
    //    // ← disable the 24 KB contract‑size limit
    //    allowUnlimitedContractSize: true,      // ◆ important ◆
    //   forking: {
    //     url: "https://binance.llamarpc.com", // 或 Infura 等
    //     // blockNumber: 18000000 // 可选：固定某个区块高度，确保稳定性
    //   }
    // },
    // 下面是 anvil 的配置
    anvil: {
      url: "https://rebrtnty.baby/",  // 与 anvil 端口对应
      accounts: [process.env.PRIVATE_KEY], // 账户私钥"
      // chainId: 56,                    // 如果 fork Ethereum 主网
    },
    anvil2: {
      url: "http://127.0.0.1:8545/",  // 与 anvil 端口对应
      accounts: [process.env.PRIVATE_KEY,], // 账户私钥"
      // chainId: 56,                    // 匹配当前连接的链ID
    },
    localhost: {
      url: "http://localhost:8545/",  // 与 anvil 端口对应
      accounts: ["0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80","0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d","0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6","0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a","0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba",], // 账户私钥"
      // chainId: 56,                    // 匹配当前连接的链ID
    },
  },
};
