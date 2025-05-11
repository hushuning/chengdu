require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  settings: {
    evmVersion: "cancun", // 选择 evm 版本
    optimizer: {
      enabled: true,
      runs: 200,  // 默认是 200，设置小一点可减小代码体积
    },
    metadata: {
      bytecodeHash: "none",
    },
  },
  defaultNetwork: "hardhat",

  networks: {
    bscMain: {
      url: "https://binance.llamarpc.com",
      chainId: 56,
      accounts: [""]  // 从 .env 文件加载私钥
    },
    hardhat: {
       // ← disable the 24 KB contract‑size limit
       allowUnlimitedContractSize: true,      // ◆ important ◆
      forking: {
        url: "https://binance.llamarpc.com", // 或 Infura 等
        // blockNumber: 18000000 // 可选：固定某个区块高度，确保稳定性
      }
    },
    // 下面是 anvil 的配置
    anvil: {
      url: "https://rebrtnty.baby/",  // 与 anvil 端口对应
      accounts: ["ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"], // 账户私钥"
      // chainId: 56,                    // 如果 fork Ethereum 主网
    },
    anvil2: {
      url: "http://127.0.0.1:8545/",  // 与 anvil 端口对应
      accounts: ["ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",], // 账户私钥"
      // chainId: 56,                    // 匹配当前连接的链ID
    },
    localhost: {
      url: "http://localhost:8545/",  // 与 anvil 端口对应
      accounts: ["ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",], // 账户私钥"
      // chainId: 56,                    // 匹配当前连接的链ID
    },
  },
};
