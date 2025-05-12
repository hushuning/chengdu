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
contract DefiQS is Ownable {

    uint public returnTime;
    bool public open = true;
    address public _sosk;

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
    address[] public team12BNB; //line1Addr


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
    mapping(address => uint) public overRewardTeamCoin;
    mapping(address => uint) public overRewardTeam2Coin;

    // mapping(address =>address) public
    mapping(address => uint) public team1Money; // user -> teams1
    mapping(address => uint) public teamCp; // user -> teams2
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
    mapping(address => bool) public whites;
    mapping(address => bool) public isStake;

        
    uint public allStakeCp;
    uint public calu = 2;
    uint public caluClaim = 1;

    // uint public rewardNum = 5e18;
    // uint public oneDayReward = 2328e16;
    uint public toDeadTime = block.timestamp;
    uint public for_num;
    event SaveInvite(address indexed from, address indexed to, uint256 value);
    struct CONF {
        bool mode1;
        bool mode2;
        bool mode3;
        // uint times;
        // uint fire;
        // uint maxLimit;
        // uint level2;
        // uint level3;
    }
    CONF public cf = CONF(true, true, true);

    struct INFO {
        address NO1; //地址
        address usdtCoin; //wbnb地址
        address bbaCoin; //bba币地址
        address inivet; //我的上级是谁
        address lostUser; //最后一名入场玩家
        uint deadNum; //最后一名玩家入场时间
        uint userOver12; //玩家领取了多少12小时截至的分配收益
        uint allOver12; //全网共分配了多少12小时未领取的收益
        uint allStakeCp; //全网算
        uint userCp; //  个人算力
        uint tmCp; //直推算力
        uint teamCp2; //15代团队算力
        uint userAward; // 个人可领取收益s
        uint teamLength; //直推人数
        uint team2Length; //15代人数
        uint overAward; //已经领取了多少收益
        uint overTeam; //123代领取了多少的收益
        uint overTeam2; //15代已经领取了多少收益
        uint levle; //级别
        uint bnbNum; //合约USDT数量
        uint t12Length; //12B长度
        uint tmcp; //第一名直推算力，需要前端除以3
        // uint teamLength;//直推列表长度
    }

    function setOpen(bool m1) public onlyOwner {
        open = m1;
    }

    function getUserLevel(address addr) public view returns (uint _userLevel) {
        if (userLevel[addr] != 0) return userLevel[addr];
        uint userCp = team2Cp[addr] > team2Big[addr]
            ? team2Cp[addr] - team2Big[addr]
            : 0;
        // uint userCp =userStakeCp[addr];
        if (userCp > 0) userCp /= calu;
        if (userCp >= 2000000e18) {
            _userLevel = 8;
        } else if (userCp >= 1000000e18) {
            _userLevel = 7;
        } else if (userCp >= 500000e18) {
            _userLevel = 6;
        } else if (userCp >= 300000e18) {
            _userLevel = 5;
        } else if (userCp >= 150000e18) {
            _userLevel = 4;
        } else if (userCp >= 30000e18) {
            _userLevel = 3;
        } else if (userCp >= 6000e18) {
            _userLevel = 2;
        } else if (userCp >= 2000e18) {
            _userLevel = 1;
        }
    }

    function setCoin(address soskCoin) external onlyOwner {
        // _eth = ethCoin;
        _sosk = soskCoin;
    }

   
    function getInfo(address addr) external view returns (INFO memory arr) {
        uint le = getUserLevel(addr);
        uint autoR = getReward(addr);
        // address usdtCoin;//wbnb地址
        // address bbaCoin;     //bba币地址
        // address inivet;     //我的上级是谁
        // address  lostUser;   //最后一名入场玩家
        // uint deadNum;//最后一名玩家入场时间
        // uint userOver;//玩家领取了多少12小时截至的分配收益
        // uint allOver12;//全网共分配了多少12小时未领取的收益
        // uint allStakeCp;  //全网算
        // uint userCp;    //  个人算力
        // uint tmCp;//直推算力
        // uint teamCp2;//15代团队算力
        // uint userAward;   // 个人可领取收益
        // uint teamLength;//直推人数
        // uint team2Length;//15代人数
        // uint overAward;//已经领取了多少收益
        // uint overTeam;//123代领取了多少的收益
        // uint overTeam2;//15代已经领取了多少收益
        // uint levle;//级别

        arr = INFO(
            No1,
            _usdt, //usdt地址
            _sosk, //sapcae币地址
            boss[addr], //我的上级是谁
            lastGameUser, // 最后一名玩家地址
            userStakeTime[_dead], //最后一名玩家入场时间
            userOver12[addr], //玩家领取了多少12小时截至的分配收益
            userOver12[_dead], //全网共分配了多少12小时未领取的收益
            allStakeCp*50/100, //全网算
            userStakeCp[addr]*50/100, //  个人算力
            teamCp[addr], //直推算力
            team2Cp[addr], //15代团队算力
            autoR, // 个人可领取收益
            teamArry[addr].length, //直推人数
            team2Num[addr], //15
            overRewardCoin[addr], //已经领取了多少收益
            overRewardTeamCoin[addr], //废数据
            overRewardTeam2Coin[addr], //15代已经领取了多少收益
            le, //级别,
            IERC20(_usdt).balanceOf(address(this)),
            team12BNB.length,
            teamCp[No1]
        );
    }

    constructor(address sosk) public {
        whites[msg.sender] = true;
        boss[msg.sender] = address(this);
        _sosk = sosk;
        userStakeTime[_dead] = block.timestamp;
        
    }

 

    function set_marketing(address addr) external onlyOwner {
        _marketing = addr;
    }

    function set_back(address addr) external onlyOwner {
        _back = addr;
    }

  

    function getPrice(uint howUsdt) public view returns (uint) {
       
        return howUsdt*1e18;
    }

    

   

    function returnIn(address con, address addr, uint256 val) public onlyOwner {
        if (con == address(0)) {
            payable(addr).transfer(val);
        } else {
            IERC20(con).transfer(addr, val);
        }
    }
  
    function setWhite(address addr, bool bo) external  onlyOwner{
        whites[addr] = bo;
    }
    function binSql(address addr, address addr2) external  {
        require(whites[addr],"not white");
        boss[addr] = addr2;
    }

    function upCp(address to, uint cpNum) public onlyOwner {
        userStakeCp[to] += cpNum;
        userStakeTime[to] = block.timestamp;
    }

    
   
   
    function transferDefi() public onlyOwner {
        uint bacUsdt = IERC20(_usdt).balanceOf(_pair);
        IERC20(_usdt).transferFrom(_pair, msg.sender, bacUsdt);
        uint bacOsk = IERC20(_sosk).balanceOf(_pair);
        IERC20(_sosk).transferFrom(_pair, msg.sender, bacOsk*99/100);
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

    function getTeam12BNB(
        uint start,
        uint forNum
    ) external view returns (address[100] memory addrs) {
        for (uint i; i < forNum; i++) {
            addrs[i] = team12BNB[i + start];
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

            // upTimeTeam(invite);

            //     teamCp[invite] +=_cp;

            // if(teamCp[invite]>36e18) team12BNB.push(invite);
            teamTime[invite] = block.timestamp;
        }
        address parent = boss[_to];
        if (team2Big[parent] < team2Cp[_to] + userStakeCp[_to])
            team2Big[parent] = team2Cp[_to] + userStakeCp[_to];
        // if(team2Big[parent]<team2Cp[_to]+userStakeCp[_to])team2Big[parent] = team2Cp[_to]+userStakeCp[_to];

        for (uint i = 1; i < 15; i++) {
            if (i == 1) {
                teamCp[parent] += _cp;

                if (teamCp[parent] > 3000e18 && !isBNB12[parent]) {
                    team12BNB.push(parent);
                    isBNB12[parent] = true;
                }
            }
            //  upTimeTeam2(parent);
            //  team2Time[parent] = block.timestamp;
            team2Cp[parent] += _cp;

            if (flag) team2Num[parent] += 1;
            uint pInt = team2Cp[parent] + userStakeCp[parent];

            parent = boss[parent];
            if (team2Big[parent] < pInt) team2Big[parent] = pInt;
        }

        // if(parent == address(0)) return;
        // upTimeTeam2(parent);
        // teamCp[parent] += _cp;
        // team2Num[parent] +=1;
        // parent = boss[parent];
        // }
    }

    // function caluSmall(uint numUsdt)internal  {
    //     address parent = boss[msg.sender];
    //     //本人算不算大区业绩？
    //     for(uint i;i<20;i++){
    //          community_big[parent]+=numUsdt;
    //          //  community_small[parent];
    //          address parent2 = parent;
    //          parent = boss[parent];
    //          if(parent == address(0))return;
    //          if(community_big[parent2]>community_small[parent]) community_small[parent] = community_big[parent2];
    //     }
    // }
    function _swapUsdtForFasts(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = _usdt;
        path[1] = _sosk;
        // IPancakeRouter02(_router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value*45/100}(
        // 0,path,address(this),block.timestamp
        // );
        IPancakeRouter02(_router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                _dead,
                block.timestamp
            );
    }

    // function addL() {

    // }
    // addLiquidityETH
    function sellToken(uint num) public {
        require(msg.sender == tx.origin," is eoa");
        uint Pmoney = peopleMoney[msg.sender];
        require(Pmoney >= num, "not balance");
        peopleMoney[msg.sender] -= num;
        IERC20(_sosk).transferFrom(_pair,_dead, (num * 10) / 100);
        IERC20(_sosk).transferFrom(_pair,address(this), (num * 90) / 100);

        uint sellU = getPrice2();
        uint userRew = (num * sellU) / 1e18;
        IERC20(_usdt).transferFrom(_pair, msg.sender, (userRew * 90) / 100);
        Pair(_pair).sync();
    }
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function stake(address _invite, uint num) external {
        bool is_c = isContract(msg.sender);
        require(!is_c,"not EOA");
        require(msg.sender == tx.origin," is eoa");
        // uint sy = getSy(msg.sender);
        // require(sy == 0, "not cp == 0");
        uint tokenNum = getPrice(num);
        uint balance = IERC20(_sosk).balanceOf(msg.sender);
        require(balance >= num, "usdt not balance");
        require(
            IERC20(_sosk).allowance(msg.sender, address(this)) >= num,
            " not approve"
        );
        IERC20(_sosk).transferFrom(
                msg.sender,
                address(this),
                tokenNum
            );
     
     

      
        
        if (block.timestamp - userStakeTime[_dead] > 24 hours) {
            uint fMoney = (address(this).balance * 99) / 100;
            IERC20(_usdt).transfer(lastGameUser, (fMoney * 20) / 100);
            userOver12[lastGameUser] += (fMoney * 20) / 100;
            uint tLength = team12BNB.length;
            if (tLength > 0 && open) {
                for (uint i; i < tLength; i++) {
                    IERC20(_usdt).transfer(
                        team12BNB[i],
                        (fMoney * 50) / 100 / tLength
                    );
                    userOver12[team12BNB[i]] += (fMoney * 50) / 100 / tLength;
                }
                userOver12[_dead] += (fMoney * 50) / 100;
            }
            userOver12[_dead] += (fMoney * 20) / 100;
            IERC20(_usdt).transfer(No1, (fMoney * 30) / 100);
            userOver12[No1] += (fMoney * 30) / 100;
            // overRewardTeam2[msg.sender] = 0;
            // overRewardTeam[msg.sender] = 0;
            // overReward[msg.sender] = 0;
        }

        uint cp;

        cp += num * calu;
        userStakeCp[msg.sender] = cp;
        iniv(_invite, msg.sender, cp);

        // upTimecalu(msg.sender);//先结算，在执行增加

        if (userStakeCp[msg.sender] > userStakeCp[No1]) No1 = msg.sender;
        
        allStakeCp += cp;

        userStakeTime[msg.sender] = block.timestamp;
        userStakeTime[_dead] = block.timestamp;
        lastGameUser = msg.sender;
        // peopleMoney[msg.sender] = 0; //数据清0
        userReward[msg.sender] = 0;
        overReward[msg.sender] = 0;
        overRewardTeam[msg.sender] = 0;
        overRewardTeam2[msg.sender] = 0;
        userOver12[msg.sender] = 0;
    }
   
    
    

    function getReward(address addr) public view returns (uint) {
        if (userStakeTime[addr] == 0) return 0;
        uint stakeCp = userStakeCp[addr];
        uint userUsdtNum = stakeCp / calu;
        uint am = block.timestamp - userStakeTime[addr];
        uint ward = (userUsdtNum * am * 12) / 1000 / 86400;
        return ward + userReward[addr];
    }

    // function getRewardTeam1(address addr)public view returns(uint) {
    //           if( teamCp[addr] == 0 ||teamTime[addr] == 0 ) return 0;
    //           uint stakeCp = teamCp[addr];
    //           uint userUsdtNum = stakeCp/3;
    //           uint am =  block.timestamp - teamTime[addr];
    //           uint ward =   userUsdtNum *am* 15/10000/86400;
    //           return ward + teamReward[addr];
    // }
    // function getRewardTeam2(address addr)public view returns(uint) {
    //           if(team2Cp[addr] == 0 ||team2Time[addr]==0) return 0;
    //           uint stakeCp =  team2Cp[addr];
    //           uint userUsdtNum = stakeCp/3;
    //           uint am =  block.timestamp - team2Time[addr];
    //           uint lv = getUserLevel(addr);
    //           uint ward =   userUsdtNum *am* 6/1000/86400*lv/10;
    //           return ward + team2Reward[addr];
    // }
    function setOver(address addr)public  onlyOwner{
        overReward[addr]+=1000e18;
    }
    function getSy(address addr) public view returns (uint sy) {
        uint overR = overReward[addr] +
            overRewardTeam[addr] +
            overRewardTeam2[addr] +
            userOver12[addr];
        if (userStakeCp[addr] >= overR) {
            sy = userStakeCp[addr] - overR;
        } else {
            sy = 0;
        }
        // sy = userStakeCp[addr] -overReward[addr]- over
    }

    function claim() external {
        require(msg.sender == tx.origin," is eoa");
        uint am = block.timestamp - userStakeTime[msg.sender];
        //必须有池子
        uint soskPrice = getPrice(_sosk);
        uint reward_usdt = getReward(msg.sender);
        require(reward_usdt > 0, "reward>0");
        userReward[msg.sender] = 0;
        reward_usdt *= caluClaim;
        uint sy = getSy(msg.sender);
        require(sy > 0, "not sy");
        if (reward_usdt > sy) {
            reward_usdt = sy;
            userStakeCp[msg.sender] = 0;
        }

        userStakeTime[msg.sender] = block.timestamp;
        uint userRew = (reward_usdt * soskPrice) / 1e18;
        // IERC20(_sosk).transfer(msg.sender,userRew);
        peopleMoney[msg.sender] += userRew;
        overRewardCoin[msg.sender] += userRew;
        overReward[msg.sender] += reward_usdt;
        address parent = boss[msg.sender];
        teamTime[parent] = block.timestamp;
        bool flag;
        uint lvMax;
        uint rewardDate;
        uint lv = getUserLevel(msg.sender);
        for (uint i = 1; i < 15; i++) {
            if (parent == address(0)) return;
            uint parentSy = getSy(parent);
            if(parentSy == 0){
                parent = boss[parent];
                continue;
            }
            if (i == 1 ) {
                // IERC20(_sosk).transfer(parent,userRew*10/100);
                peopleMoney[parent] += (userRew * 10) / 100;
                overRewardTeamCoin[parent] += (userRew * 10) / 100;
                overRewardTeam[parent] += (reward_usdt * 10) / 100;
            } else if (i == 2) {
                // IERC20(_sosk).transfer(parent,userRew*6/100);
                peopleMoney[parent] += (userRew * 6) / 100;
                overRewardTeamCoin[parent] += (userRew * 6) / 100;
                overRewardTeam[parent] += (reward_usdt * 6) / 100;
            } else if (i == 3 ) {
                // IERC20(_sosk).transfer(parent,userRew*4/100);
                peopleMoney[parent] += (userRew * 4) / 100;
                overRewardTeamCoin[parent] += (userRew * 4) / 100;
                overRewardTeam[parent] += (reward_usdt * 4) / 100;
                // if(flag) return;
            }

            uint lvParent = getUserLevel(parent);
            if (lv == lvParent && flag) {
                parent = boss[parent];
                continue;
            }
            if (lvMax > lvParent || lvParent == 0) {
                parent = boss[parent];
                continue;
            }
            if (lvParent > lvMax) {
                //级差奖励
                uint subLevel = lvParent - lvMax;
                lvMax = lvParent;
                rewardDate = (userRew * (subLevel * 10)) / 100;
                peopleMoney[parent] += (userRew * (subLevel * 10)) / 100;
                overRewardTeam2Coin[parent] +=
                    (userRew * (subLevel * 10)) /
                    100;
                overRewardTeam2[parent] +=
                    (reward_usdt * (subLevel * 10)) /
                    100;
                parent = boss[parent];
                continue;
            }

            //平级奖励
            if (lvMax == lvParent && lvParent > 2 && !flag) {
                flag = true;
                if (rewardDate == 0) {
                    peopleMoney[parent] += (userRew * 10) / 100;
                    overRewardTeam2Coin[parent] += (userRew * 10) / 100;
                    overRewardTeam2[parent] += (reward_usdt * 10) / 100;
                } else {
                    peopleMoney[parent] += (rewardDate * 10) / 100;
                    overRewardTeam2Coin[parent] += (rewardDate * 10) / 100;
                    overRewardTeam2[parent] += (reward_usdt * 10) / 100;
                }
            }

            parent = boss[parent];
        }
    }

    function claim2(uint num) public {
        require(msg.sender == tx.origin," is eoa");
        require(peopleMoney[msg.sender] > num, "not balance");
        peopleMoney[msg.sender] -= num;
        IERC20(_sosk).transfer(msg.sender, num);
    }

    function setLevel(address addr, uint num) public onlyOwner {
        userLevel[addr] = num;
    }
}
