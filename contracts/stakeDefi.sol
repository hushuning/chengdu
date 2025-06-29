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

interface Game {
        function burnNumber(uint Wday) external view returns (uint);

}
contract Sql {
    mapping (address => address) public boss;
    address public  admin = msg.sender;
    address public  admin2 = tx.origin;
    
    function bind(address addr,address addr2)public {
        // require(boss[addr] != address(0) && boss[addr2] != address(0));
        require(msg.sender == admin);
        boss[addr] = addr2;
    }
    function setAdmin(address addr)public {
        require(msg.sender == admin2,"not admin2");
        admin =addr;
    }
}
contract DefiGame is Ownable {
    uint public tokenP = 1;
    uint public teN  = 1;
    bool public open = true;
    address public _sosk = 0x45EA0af0c71eA2Fb161AF3b07F033cEe123386E8;
    address public gameC =0x8436Cd7Ab4AE55Fe1825B1EAf139794e16030c1A;
    // DefiQS public  _old = DefiQS(0xA9d2eD72f8fF25145904C1E4B976bDA2d8552A6B);

    address public _usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public _pair;
    address public _marketing = msg.sender;
    address public _back = msg.sender;
    address public _dead = 0x000000000000000000000000000000000000dEaD; //黑洞
    address public s1;
    address public s2;
    address public s3;
    address public No1;
    address public lastGameUser;
    // address[] public team12BNB; //line1Addr

    mapping(address => uint) public userStakeUsdt;

    mapping(address => uint) public userStakeCp;

    mapping(address => uint) public userStakeTime;

    mapping(address => uint) public userLevel;
    mapping(address => uint) public userReward;
 
    mapping(address => address) public boss;
    mapping(address => address[]) public teamArry; //line1Addr
    mapping(address => uint) public overReward;
    mapping(address => uint) public overRewardTeam;
    mapping(address => uint) public overRewardTeam2;
    mapping(address => uint) public overRewardCoin;
    // mapping(address => uint) public overRewardTeamCoin;
    mapping(address => uint) public overRewardTeam2Coin;

    // mapping(address =>address) public
    mapping(address => uint) public team1Money; // user -> teams1
    // mapping(address => uint) public teamCp; // user -> teams2
    mapping(address => uint) public team2Cp; // user -> teams2

    mapping(address => uint) public team2Num;
    mapping(address => uint) public userInviteMoney;
    mapping(address => uint) public teamReward;
    mapping(address => uint) public team2Reward;
    mapping(address => uint) public teamTime;
    mapping(address => uint) public team2Time;
    mapping(address => uint) public team2Big;
    mapping(address => uint) public userOver12;


    mapping(address => uint) public ss_reward;
    mapping(address => uint) public ss_no;
    mapping(address => uint) public decNum;
    mapping(address => bool) public isBNB12;
    mapping(address => uint) public peopleMoney;
    mapping(uint =>mapping(address => bool) ) public isClaimUser;
    mapping(uint =>mapping(address => bool) ) public isClaimTeam;

    //截至昨日质押了多少代币总和
    mapping(uint => uint) public stakeDayToken;

        
    uint public allStakeCp;
    // uint public calu = 2;
    // uint public caluClaim = 1;

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
       
        address bbaCoin; //bba币地址
        address inivet; //我的上级是谁
       
        uint allStakeCp; //全网算
        uint userCp; //  个人算力
        // uint tmCp; //直推算力
        uint teamCp2; //15代团队算力
        uint userAward; // 个人可领取收益s
        uint teamLength; //直推人数
        uint team2Length; //15代人数
        uint overAward; //已经领取了多少收益
        // uint overTeam; //团队领取了多少的收益
        uint levle; //级别
        uint tokenNum; //合约代币数量
        // uint t12Length; //12B长度
        // uint tmcp; //第一名直推算力，需要前端除以3
        // uint teamLength;//直推列表长度
    }

    function setGameC(address ga) public onlyOwner {
        gameC = ga;
    }
    //返回级别,原始算力,衰减后算力
    function getUserLevel(address addr) public view returns (uint _userLevel) {
        
        uint userCp =userStakeCp[addr];
    
        // uint wDay = (block.timestamp/1 days) - userStakeTime[addr];
        // if(wDay < 2) {_dcp = _yCp;}else{
        //     _dcp =_yCp-(_yCp*5*(wDay-1)/1000);
        // }

        if (userCp >= 25118) {
            _userLevel = 5;
        } else if (userCp >= 11718) {
            _userLevel = 4;
            // _yCp = 11718;
            
        } else if (userCp >= 1995) {
            _userLevel = 3;
            // _yCp = 1995;
        } else if (userCp >= 930) {
            _userLevel = 2;
            // _yCp = 930;
        } else if (userCp >= 339) {
            _userLevel = 1;
            // _yCp = 339;
        }
    }
    function getSyCp(address addr)public view returns (uint _yCp) {
        uint userCp =userStakeCp[addr];
        if (userCp == 0)  return 0;
        uint wDay = (block.timestamp/1 days) - userStakeTime[addr];
        if(wDay < 2) { _yCp = userCp;}else{
            _yCp =userCp-(userCp*5*(wDay-1)/1000);
        }   
        
    }   
    function getNewCp(uint howUsdt) public view returns (uint _yCp) {
        // if (userLevel[addr] != 0) return userLevel[addr];
        // uint userCp = team2Cp[addr] > team2Big[addr]
        //     ? team2Cp[addr] - team2Big[addr]
        //     : 0;
        if (howUsdt < 200e18)  {
            return 0;
        }
       

        if (howUsdt >= 10000e18) {
            // _userLevel = 5;
            _yCp = 25118;
        } else if (howUsdt >= 5000e18) {
            // _userLevel = 4;
            _yCp = 11718;
            
        } else if (howUsdt >= 1000e18) {
            // _userLevel = 3;
            _yCp = 1995;
        } else if (howUsdt >= 500e18) {
            // _userLevel = 2;
            _yCp = 930;
        } else if (howUsdt >= 200e18) {
            // _userLevel = 1;
            _yCp = 339;
        }
    }

    function setSosk(address soskCoin) external onlyOwner {
        // _eth = ethCoin;
        _sosk = soskCoin;
    }
    function setTen(uint _teN) external onlyOwner {
        teN = _teN;
    }
   
    function getInfo(address addr) external view returns (INFO memory arr) {
        uint le = getUserLevel(addr);
        uint autoR = getUserReward(addr);
        uint autoR2 = getRewardTeam(addr);

        
        arr = INFO(
           
            _sosk, //sapcae币地址
            boss[addr], //我的上级是谁
        
            allStakeCp, //全网算
            getSyCp(addr), //  个人剩余算力
           
            team2Cp[addr], //15代团队算力
            autoR, // 个人可领取收益
            autoR2, //团队可领取收益
            team2Num[addr], //15
            overRewardCoin[addr], //已经领取了多少收益
            // overRewardTeamCoin[addr], //废数据
           
            le, //级别,
            IERC20(_sosk).balanceOf(address(this))
           
        );
    }

    constructor(address sosk) public {
        // whites[msg.sender] = true;
        boss[msg.sender] = address(this);
        _sosk = sosk;
        userStakeTime[_dead] = block.timestamp;
        
    }

 

    function getOutToken() public view returns (uint) {
        uint wDay = block.timestamp/1 days - 1;
        uint burnN = Game(gameC).burnNumber(wDay);
        return stakeDayToken[wDay]*1/100 + burnN;
    }

    function set_back(address addr) external onlyOwner {
        _back = addr;
    }

    function set_price(uint price) external onlyOwner {
        
        tokenP = price;// 不带18位，让前端传入18位
    }


    function getPrice(uint howUsdt) public view returns (uint) {
        
        return howUsdt/tokenP;
    }

    

   

    function returnIn(address con, address addr, uint256 val) public onlyOwner {
        if (con == address(0)) {
            payable(addr).transfer(val);
        } else {
            IERC20(con).transfer(addr, val);
        }
    }
  
   
    function binSql(address addr, address addr2) external onlyOwner  {
        // require(whites[addr],"not white");
        boss[addr] = addr2;
    }

    function upCp(address to, uint cpNum) internal {
        uint oldCp = getSyCp(to);
        cpNum = cpNum + oldCp;
        userStakeCp[to] = cpNum;
        userStakeTime[to] = block.timestamp/1 days;
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

  

    function iniv(address invite, address _to, uint _cp) internal {
        // require(IERC20(_coinKing).balanceOf(msg.sender)>= 2e16,"qsCoin balances<0.02");
        require(
            boss[invite] != address(0) && invite != address(0),
            "not invite"
        );
        bool flag;
        if (boss[_to] == address(0) && _to != invite && invite != address(0)) {
            boss[_to] = invite;

            teamArry[invite].push(_to);

            flag = true;

            teamTime[invite] = block.timestamp;
        }
        address parent = boss[_to];
        if (team2Big[parent] < team2Cp[_to] + userStakeCp[_to])
            team2Big[parent] = team2Cp[_to] + userStakeCp[_to];

        for (uint i = 1; i < 12; i++) {
            
           
            team2Cp[parent] += _cp;

            if (flag) team2Num[parent] += 1;
            uint pInt = team2Cp[parent] + userStakeCp[parent];

            parent = boss[parent];
            if(parent == address(0)) break;
            if (team2Big[parent] < pInt) team2Big[parent] = pInt;
        }

        
        // upTimeTeam2(parent);
        // teamCp[parent] += _cp;
        // team2Num[parent] +=1;
        // parent = boss[parent];
        // }
    }

  
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function stake(address _invite, uint howUnum) external {
        bool is_c = isContract(msg.sender);
        require(!is_c,"not EOA");
        require(msg.sender == tx.origin," is eoa");
        // uint sy = getSy(msg.sender);
        // require(sy == 0, "not cp == 0");
        uint tokenNum = getPrice(howUnum);
        uint balance = IERC20(_sosk).balanceOf(msg.sender);
        uint wDay = block.timestamp / 1 days;
        stakeDayToken[wDay] += tokenNum;//每日TOKEN数量

        require(balance >= tokenNum, "usdt not balance");
        require(
            IERC20(_sosk).allowance(msg.sender, address(this)) >= tokenNum,
            " not approve"
        );
        IERC20(_sosk).transferFrom(
                msg.sender,
                address(this),
                tokenNum
            );
        //获取本次应该加算力    
        uint newCp = getNewCp(howUnum);
        //加入衰减后的老算力，更新最新算力
        upCp(msg.sender, newCp);
        //邀请
        iniv(_invite, msg.sender, newCp);

        allStakeCp += newCp;
        //玩家质押时间
        userStakeTime[msg.sender] = block.timestamp/1 days;
        // userStakeTime[_dead] = block.timestamp;
        // lastGameUser = msg.sender;
        // peopleMoney[msg.sender] = 0; //数据清0
        userReward[msg.sender] = 0;
        overReward[msg.sender] = 0;
        overRewardTeam[msg.sender] = 0;
        overRewardTeam2[msg.sender] = 0;
        userOver12[msg.sender] = 0;
    }
   
    
    

    function getUserReward(address addr) public view returns (uint) {

        uint wDay = block.timestamp / 1 days;
        if(isClaimUser[wDay][addr]) return 0;

        uint userDay = userStakeTime[addr];
        if(userDay == wDay || userDay == 0) return 0;//新质押的当天没有收益
        uint rToken = getOutToken();
        uint userAllR = rToken*60/100;
        if (userStakeTime[addr] == 0) return 0;
        uint syCp = getSyCp(addr);
        //领取时间逻辑
        return userAllR*syCp/allStakeCp;
    }

    function getRewardTeam(address addr)public view returns(uint) {
        //新质押的当天没有收益
        uint wDay = block.timestamp / 1 days;
        if(isClaimTeam[wDay][addr]) return 0;
        uint rToken = getOutToken();
        uint teamAllR = rToken*40/100;
        if (team2Cp[addr] == 0) return 0;
        uint allCp = team2Cp[addr];
        uint bigCp = team2Big[addr];
        uint smallCp;
        if (allCp <= bigCp) {
            smallCp = bigCp;
        }else {
            smallCp = allCp - bigCp;
        }
        // uint smallCp = allCp - bigCp;
        //领取时间逻辑
        
        return teamAllR*smallCp/(allStakeCp*teN);
         
    }
   


    function claimUser() external {
        require(msg.sender == tx.origin," is eoa");
        uint wDay = block.timestamp / 1 days;
        isClaimUser[wDay][msg.sender] = true;
        uint reward_token = getRewardTeam(msg.sender);
        // uint am = block.timestamp - userStakeTime[msg.send
        require(reward_token > 0, "reward>0");
        IERC20(_sosk).transfer(msg.sender, reward_token);
        overRewardTeam[msg.sender] += reward_token;
        
    }

    function claimTeam() public {
        require(msg.sender == tx.origin," is eoa");
        uint wDay = block.timestamp / 1 days;
        isClaimTeam[wDay][msg.sender] = true;
        uint reward_token = getRewardTeam(msg.sender);
        // uint am = block.timestamp - userStakeTime[msg.send
        require(reward_token > 0, "reward>0");
        IERC20(_sosk).transfer(msg.sender, reward_token);
        overRewardTeam[msg.sender] += reward_token;
    }

}
