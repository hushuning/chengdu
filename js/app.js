
const API_URL = "https://bsc.api.0x.org/orderbook/v1";
const X_TOKEN_ADDRESS = "0x55d398326f99059fF775485246999027B3197955"; // USDT
const WBNB_ADDRESS = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
const CHAIN_ID = 56;
let provider, signer, userAddress;

async function connectWallet() {
  if (typeof window.ethereum !== 'undefined') {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    try {
      await provider.send("eth_requestAccounts", {});
      const signer = provider.getSigner();
      const address = await signer.getAddress();
      console.log("已连接钱包:", address);
    } catch (error) {
      console.error("连接失败:", error);
    }
  } else {
    alert("请安装 MetaMask 或其他支持的浏览器钱包！");
  }
}

async function createLimitOrder() {
  const makerAmount = ethers.utils.parseUnits(document.getElementById("makerAmount").value, 18);
  const takerAmount = ethers.utils.parseUnits(document.getElementById("takerAmount").value, 18);
  const order = {
    makerToken: X_TOKEN_ADDRESS,
    takerToken: WBNB_ADDRESS,
    makerAmount: makerAmount.toString(),
    takerAmount: takerAmount.toString(),
    maker: userAddress,
    taker: "0x0000000000000000000000000000000000000000",
    sender: "0x0000000000000000000000000000000000000000",
    feeRecipient: "0x0000000000000000000000000000000000000000",
    pool: "0x0000000000000000000000000000000000000000000000000000000000000000",
    expiry: Math.floor(Date.now() / 1000) + 3600,
    salt: Date.now().toString(),
    chainId: CHAIN_ID,
    verifyingContract: "0xdef1c0ded9bec7f1a1670819833240f027b25eff"
  };

  const domain = {
    name: "0x Protocol",
    version: "1.0.0",
    chainId: CHAIN_ID,
    verifyingContract: order.verifyingContract,
  };
  const types = {
    Order: [
      { name: "makerToken", type: "address" },
      { name: "takerToken", type: "address" },
      { name: "makerAmount", type: "uint128" },
      { name: "takerAmount", type: "uint128" },
      { name: "maker", type: "address" },
      { name: "taker", type: "address" },
      { name: "sender", type: "address" },
      { name: "feeRecipient", type: "address" },
      { name: "pool", type: "bytes32" },
      { name: "expiry", type: "uint64" },
      { name: "salt", type: "uint256" },
      { name: "chainId", type: "uint256" },
      { name: "verifyingContract", type: "address" },
    ]
  };
  const signature = await signer._signTypedData(domain, types, order);
  const payload = { order, signature };

  const res = await fetch(API_URL + "/order", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });
  if (res.ok) {
    alert("限价单上传成功");
  } else {
    const err = await res.json();
    alert("上传失败：" + JSON.stringify(err));
  }
}

async function checkAndApproveIfNeeded(tokenAddress, spenderAddress, requiredAmount) {
  const erc20Abi = [
    "function approve(address spender, uint256 amount) public returns (bool)",
    "function allowance(address owner, address spender) public view returns (uint256)"
  ];
  const token = new ethers.Contract(tokenAddress, erc20Abi, signer);
  const allowance = await token.allowance(userAddress, spenderAddress);
  if (allowance.lt(requiredAmount)) {
    const tx = await token.approve(spenderAddress, ethers.constants.MaxUint256);
    alert("授权中，请等待确认...");
    await tx.wait();
    alert("授权完成");
  }
}

async function fillOrder(order, orderHash) {
  const contractAddress = "0xdef1c0ded9bec7f1a1670819833240f027b25eff";
  await checkAndApproveIfNeeded(order.takerToken, contractAddress, ethers.BigNumber.from(order.takerAmount));
  const iface = new ethers.utils.Interface([
    "function fillLimitOrder((address,address,uint128,uint128,address,address,address,address,bytes32,uint64,uint256,uint256,address),bytes,uint128)"
  ]);
  const signature = order.signature || order.metaData?.signature || prompt("请输入订单签名");
  const txData = iface.encodeFunctionData("fillLimitOrder", [order, signature, order.takerAmount]);
  const tx = await signer.sendTransaction({ to: contractAddress, data: txData, gasLimit: 500000 });
  alert("吃单交易发送成功：" + tx.hash);
}

async function loadOrderbook() {
  const url = API_URL + `?makerToken=${X_TOKEN_ADDRESS}&takerToken=${WBNB_ADDRESS}`;
  const res = await fetch(url);
  const data = await res.json();
  const container = document.getElementById("orderbook-body");
  container.innerHTML = "";
  data.records.forEach((record, i) => {
    const o = record.order;
    const price = (parseFloat(o.takerAmount) / parseFloat(o.makerAmount)).toFixed(6);
    const row = document.createElement("tr");
    row.innerHTML = `<td>${i+1}</td><td>${ethers.utils.formatUnits(o.makerAmount, 18)}</td><td>${ethers.utils.formatUnits(o.takerAmount, 18)}</td><td>${price}</td><td><button onclick='fillOrder(${JSON.stringify(o)}, "${record.metaData.orderHash}")'>吃单</button></td>`;
    container.appendChild(row);
  });
}

async function loadMyOrders() {
  const url = API_URL + `/orders?maker=${userAddress}&makerToken=${X_TOKEN_ADDRESS}&takerToken=${WBNB_ADDRESS}`;
  const res = await fetch(url);
  const data = await res.json();
  const container = document.getElementById("my-orders-body");
  container.innerHTML = "";
  data.records.forEach((record, i) => {
    const o = record.order;
    const price = (parseFloat(o.takerAmount) / parseFloat(o.makerAmount)).toFixed(6);
    const row = document.createElement("tr");
    row.innerHTML = `<td>${i+1}</td><td>${ethers.utils.formatUnits(o.makerAmount, 18)}</td><td>${ethers.utils.formatUnits(o.takerAmount, 18)}</td><td>${price}</td><td><button onclick='cancelOrder(${JSON.stringify(o)})'>撤单</button></td>`;
    container.appendChild(row);
  });
}

async function cancelOrder(order) {
  const contractAddress = "0xdef1c0ded9bec7f1a1670819833240f027b25eff";
  const iface = new ethers.utils.Interface([
    "function cancelLimitOrder((address,address,uint128,uint128,address,address,address,address,bytes32,uint64,uint256,uint256,address))"
  ]);
  const txData = iface.encodeFunctionData("cancelLimitOrder", [order]);
  const tx = await signer.sendTransaction({ to: contractAddress, data: txData, gasLimit: 300000 });
  alert("撤单已提交：" + tx.hash);
}

window.addEventListener("load", () => {
  loadOrderbook();
  setInterval(loadOrderbook, 10000);
});
