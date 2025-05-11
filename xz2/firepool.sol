/**
 *Submitted for verification at BscScan.com on 2022-07-10
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

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

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract CS {}

contract Fire is Ownable {
    // address public _old = 0x0D8d2526B9313101880394Ef9b0CeB316FF7C698;
    // DefiQS oldC = DefiQS(_old);
    uint public speed = 43200;
    uint poolCoinN = 2040e22;
    bool public open = true;
    address public _sosk;
    // address public _lpOskUsdt = 0x470A47e71DA6fe907d4C48D499c3465d1151D13A;
    // address public _lpFistOsk = 0x2CD7CA738e568589BC1c0875c0D6DEC867f41bfA;
    address public _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // address public _osk = 0x3bbadcE24FC5258D70F9fF6ee1C22DD45864428b;
    // address public _fist = 0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A;
    // address public _eth = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    // address public _coinQs = ;
    // address public _usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public _usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public _wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public _marketing = msg.sender;
    address public _back = msg.sender;
    address public _dead = 0x000000000000000000000000000000000000dEaD; //黑洞
    address public lp = 0x930d8cF42FF71EfeEB63b62b0948F0c27d17416b;

    // PgPg代币
    address public pgpg = 0xC534165f8EA9998E878F4350536cAA9765b22222;

    mapping(address => uint) public userCp;

    mapping(address => uint) public userStakeTime;
    mapping(address => uint) public userReward;
    mapping(address => uint) public userDay;
    mapping(address => uint) public userStakeTime2;
    mapping(address => uint) public userReward2;
    mapping(address => uint) public userDay2;
    mapping(address => uint) public overReward;
    mapping(address => bool) public isStake;
    mapping(address => bool) public isStake2;

    uint public allStakeCp;
    uint public timeC = 1 minutes;
    // uint public rewardNum = 5e18;
    // uint public oneDayReward = 2328e16;
    uint public toDeadTime = block.timestamp;
    uint public for_num;
    event SaveInvite(address indexed from, address indexed to, uint256 value);
    // struct CONF {
    //     bool mode1;
    //     bool mode2;
    //     bool mode3;
    //     // uint times;
    //     // uint fire;
    //     // uint maxLimit;
    //     // uint level2;
    //     // uint level3;
    // }
    // CONF public cf = CONF(true, true, true);

    struct INFO {
        address lp; //lp地址
        address pgpgCoin; //pgpg币地址
        uint allStakeCp; //全网质押B价值U
        uint userCp; //  个人质押价值U
        uint userCp2; //  个人质押价值U
        uint userAward; // 个人可领取收益 模式1
        uint userAward2; // 个人可领取收益 模式2
        uint overAward; //已经领取了多少收益
        uint tokenNumPool; //矿池代币数量
    }

    function setTimC_min() external onlyOwner {
        timeC = 1 minutes;
    }

    function setTimC_day() external onlyOwner {
        timeC = 1 days;
    }

    function setLp(address pool) external onlyOwner {
        // _eth = ethCoin;
        lp = pool;
    }

    function setPgpg(address pool) external onlyOwner {
        // _eth = ethCoin;
        pgpg = pool;
    }

    function getInfo(address addr) external view returns (INFO memory arr) {
        // uint le = getUserLevel(addr);
        uint autoR = getReward(addr, 1);
        uint autoR2 = getReward(addr, 2);

        uint basPool = IERC20(lp).balanceOf(address(this));

        arr = INFO(
            lp, //WBNB地址
            pgpg,
            allStakeCp, //全网算
            userReward[addr], //待领取价值LP，USDT本位
            userReward2[addr], //待领取价值LP，USDT本位
            autoR, // 个人可领取多少LP
            autoR2, // 个人可领取多少LP
            overReward[addr], //已经领取了多少个LP代币
            basPool //矿池中还有多少LP
        );
    }

    constructor() public {
        // _sosk = sosk;
        // IERC20(pgpg).approve(_router, type(uint256).max);
        // IERC20(_usdt).approve(_router, type(uint256).max);
        // IERC20(_usdt).approve(_router, type(uint256).max);
        // boss[msg.sender] = msg.sender;
        // userStakeTime[_dead] = block.timestamp;
        // lastGameUser = msg.sender;
    }

    function set_back(address addr) external onlyOwner {
        _back = addr;
    }

    function getUsdtWbnb(
        // address coin,
        uint usdtNum
    ) public view returns (uint) {
        address[] memory path3 = new address[](2);
        // path3[0] = sfast;//用第二个币计算
        path3[0] = _wbnb;
        path3[1] = _usdt;
        uint[] memory amounts3 = IPancakeRouter02(_router).getAmountsIn(
            usdtNum,
            path3
        );
        return amounts3[0];
    }

    function getWbnbPrice(
        address coin,
        uint bnbNum
    ) public view returns (uint) {
        address[] memory path3 = new address[](2);
        // path3[0] = sfast;//用第二个币计算
        path3[0] = coin;
        path3[1] = _wbnb;
        uint[] memory amounts3 = IPancakeRouter02(_router).getAmountsIn(
            bnbNum,
            path3
        );
        return amounts3[0];
    }

    function getUsdtPrice(
        address coin,
        uint usdtNum
    ) public view returns (uint) {
        address[] memory path3 = new address[](3);
        // path3[0] = sfast;//用第二个币计算
        path3[0] = coin;
        path3[1] = _wbnb;
        path3[2] = _usdt;
        uint[] memory amounts3 = IPancakeRouter02(_router).getAmountsIn(
            usdtNum,
            path3
        );
        return amounts3[0];
    }

    //返回WBNB TOKEN
    function getLpNumber(
        address lpAddr
    ) public view returns (uint112, uint112) {
        uint112 token0Num;
        uint112 token1Num;
        (token0Num, token1Num, ) = Pair(lpAddr).getReserves();
        if (_wbnb == Pair(lpAddr).token0()) {
            return (token0Num, token1Num);
        }
        return (token1Num, token0Num);
    }

    //返回每个LP价值多少BNB
    function getLpPriceWBNB(address lpAddr) public view returns (uint) {
        uint balanceWbnb;
        uint balanceToken;
        (balanceWbnb, balanceToken) = getLpNumber(lpAddr);
        uint total = IERC20(lpAddr).totalSupply();
        return ((balanceWbnb * 2) * 1e18) / total;
    }

    //每个LP价值多少BNB，然后放入参数，返回该数量BNB价值多少USDT
    function getOneLpPrice(
        uint bnbN
    ) public view returns (uint oneLpPrice_usdt) {
        oneLpPrice_usdt = getWbnbPrice(_usdt, bnbN);
    }

    function getUsdt_Ntoken(uint bnbN, uint howU) public view returns (uint) {
        uint lpPrice_usdt = getOneLpPrice(bnbN);
        return (howU * 1e18) / lpPrice_usdt;
    }

    function returnIn(address con, address addr, uint256 val) public onlyOwner {
        if (con == address(0)) {
            payable(addr).transfer(val);
        } else {
            IERC20(con).transfer(addr, val);
        }
    }

    function stakeToken(uint howUsdt, uint howDay) external {
        require(isStake[msg.sender] == false, "over Stake");
        require(msg.sender == tx.origin, "No contract calls");

        require(userReward[msg.sender] == 0, "not 0");
        require(msg.sender == tx.origin, "No contract calls");
        uint balance = IERC20(pgpg).balanceOf(msg.sender);
        require(balance >= 0, "not v1 balance");
        require(
            IERC20(pgpg).allowance(msg.sender, address(this)) > 0,
            "not approve"
        );
        require(
            howUsdt == 100 || howUsdt == 300 || howUsdt == 500,
            "error HOWusdt"
        );
        require(howDay == 3 || howDay == 7 || howDay == 5, "error howDay");

        if (howDay == 3) userReward[msg.sender] = 225;
        if (howDay == 7) userReward[msg.sender] = 255;
        if (howDay == 15) userReward[msg.sender] = 300;
        if (howUsdt == 300) userReward[msg.sender] *= 3;
        if (howUsdt == 500) userReward[msg.sender] *= 5;
        userDay[msg.sender] = howDay;
        userStakeTime[msg.sender] = block.timestamp;
        uint byNum = getUsdtPrice(pgpg, howUsdt*1e18);
        IERC20(pgpg).transferFrom(msg.sender, _dead, byNum);
        userStakeTime[msg.sender] = block.timestamp;
        isStake[msg.sender] = true;
        allStakeCp += userReward[msg.sender];
    }

    function stakeBnb(uint howUsdt, uint howDay) external payable {
        require(isStake2[msg.sender] == false, "over Stake");

        require(msg.sender == tx.origin, "No contract calls");

        require(userReward2[msg.sender] == 0, "not 0");
        require(msg.sender == tx.origin, "No contract calls");

        require(
            howUsdt == 100 || howUsdt == 300 || howUsdt == 500,
            "error HOWusdt"
        );
        require(howDay == 3 || howDay == 7 || howDay == 5, "error howDay");

        if (howDay == 3) userReward2[msg.sender] = 225;
        if (howDay == 7) userReward2[msg.sender] = 255;
        if (howDay == 15) userReward2[msg.sender] = 300;
        if (howUsdt == 300) userReward2[msg.sender] *= 3;
        if (howUsdt == 500) userReward2[msg.sender] *= 5;
        userDay2[msg.sender] = howDay;
        userStakeTime2[msg.sender] = block.timestamp;
        uint bnbN = getUsdtWbnb(howUsdt * 1e18);
        require(msg.value>((bnbN * 99) / 100) , "not msg.value");
        payable(_back).transfer(msg.value);
        isStake2[msg.sender] = true;
        allStakeCp += userReward2[msg.sender];
    }

    function getReward(address addr, uint mode) public view returns (uint) {
        require(mode == 1 || mode == 2, "mode eerror");
        uint rN;
        if (mode == 1) rN = userReward[addr];
        if (mode == 2) rN = userReward2[addr];
        uint oneLP_WBNB = getLpPriceWBNB(lp);
        uint oneLP_USDT = getOneLpPrice(oneLP_WBNB);
        return (rN * 1e36) / oneLP_USDT;
        // return ward;
    }

    // function claim(uint mode) external {
    //     require(msg.sender == tx.origin, "No contract calls");
    //     uint rN = userReward[msg.sender];
    //     uint usertime = userStakeTime[msg.sender];
    //     uint userD = userDay[msg.sender];

    //     require(rN != 0 && usertime != 0 && userD != 0, "not 0");
    //     require(block.timestamp > (usertime + (userD * 1 days)), "not < time");
    // }

    function claim(uint mode) external {
        require(msg.sender == tx.origin, "No contract calls");
        require(mode == 1 || mode == 2, "mode eerror");
        uint rewardLp = getReward(msg.sender, mode);
        require(rewardLp > 0, "reward>0");
        if (mode == 1) {
            //时间限制
            uint rN = userReward[msg.sender];
            uint usertime = userStakeTime[msg.sender];
            uint userD = userDay[msg.sender];
            require(rN != 0 && usertime != 0 && userD != 0, "not 0");
            require(
                block.timestamp > (usertime + (userD * timeC)),
                "not < time"
            );
            userReward[msg.sender] = 0;
            IERC20(lp).transfer(msg.sender, rewardLp);
        }
        if (mode == 2) {
            //时间限制
            uint rN = userReward2[msg.sender];
            uint usertime = userStakeTime2[msg.sender];
            uint userD = userDay2[msg.sender];
            require(rN != 0 && usertime != 0 && userD != 0, "not 0");
            require(
                block.timestamp > (usertime + (userD * timeC)),
                "not < time"
            );
            userReward2[msg.sender] = 0;
            IERC20(lp).transfer(msg.sender, rewardLp);
        }
        overReward[msg.sender] += rewardLp;
    }
    //  function claimTeam()external {
    //      uint am =  block.timestamp - teamTime[msg.sender];
    //     // require(am >= cf.times,"not times");
    //     //必须有池子
    //     uint soskPrice = getPrice(_sosk);
    //     // uint ethPrice = getPriceEth();
    //     uint reward_usdt = getRewardTeam1(msg.sender);
    //     require(reward_usdt >0,"reward>0");
    //     teamReward[msg.sender] = 0;
    //     if(userStakeCp[msg.sender]>reward_usdt){
    //         userStakeCp[msg.sender] -= reward_usdt;
    //     }else{
    //         // userStakeCp[msg.sender] = 0;
    //         require(false,"not stakeCP");
    //     }
    //     reward_usdt  = reward_usdt*95/100;
    //     teamTime[msg.sender] = block.timestamp;
    //     uint userRew = reward_usdt*soskPrice/1e18;
    //     // uint userRew1 = reward_usdt*cf.ethRate/100*ethPrice/1e18;
    //     IERC20(_sosk).transfer(msg.sender,userRew);
    //     // IERC20(_eth).transfer(msg.sender,userRew1);
    //     overRewardTeam[msg.sender] += reward_usdt;

    //  }
    //  function claimTeam2()external {
    //      uint am =  block.timestamp - team2Time[msg.sender];
    //     // require(am >= cf.times,"not times");
    //     //必须有池子
    //     uint soskPrice = getPrice(_sosk);
    //     // uint ethPrice = getPriceEth();
    //     uint reward_usdt = getRewardTeam2(msg.sender);
    //     require(reward_usdt >0,"reward>0");
    //     team2Reward[msg.sender] = 0;
    //     if(userStakeCp[msg.sender]>reward_usdt){
    //         userStakeCp[msg.sender] -= reward_usdt;
    //     }else{
    //         // userStakeCp[msg.sender] = 0;
    //         require(false,"not stakeCP");

    //     }
    //     reward_usdt  = reward_usdt*95/100;
    //     team2Time[msg.sender] = block.timestamp;
    //     uint userRew = reward_usdt*soskPrice/1e18;
    //     // uint userRew1 = reward_usdt*cf.ethRate/100*ethPrice/1e18;
    //     IERC20(_sosk).transfer(msg.sender,userRew);
    //     // IERC20(_eth).transfer(msg.sender,userRew1);
    //     overRewardTeam2[msg.sender] += reward_usdt;

    //  }

    // function dataC(address addr)public onlyOwner {
    //     INFO memory inf = oldC.getInfo(addr);

    //         // _osk,_sosk,_lpOskUsdt,_lpFistOsk,
    //         boss[addr] = inf.inivet;
    //         team1[inf.inivet].push(addr);
    //         userStakeUsdt[addr] = inf.stakeUsdt;
    //             //   autoR,
    //         userStakeLpNum[addr][_lpOskUsdt] =inf.userStakeQsLpNum;
    //         userStakeLpNum[addr][_lpFistOsk] = inf.userStakeKingLpNum;
    //               allStakeUsdt = inf.allUsdt;
    //               //team1[addr].length,
    //               userStakeTime[addr] = oldC.userStakeTime(addr);
    //               userInviteMoney[addr] = inf.userInviteMoney;
    //               ss_reward[addr] = inf.ssOver;
    //               ss_no[addr] = inf.ssT;
    //               overReward[addr] =inf.overReward;
    //               userLevel[addr] = inf.userLevel;
    //               decNum[addr] = inf.decNum;
    //             //   team1[addr] =

    // }
}
