// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
// 管理员抽象合约，提供管理员权限控制
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
abstract contract Admin {
    address public admin; // 管理员地址

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call"); // 只有管理员可以调用
        _;
    }

    constructor() {
        admin = msg.sender; // 初始管理员为部署者
    }

    // 转移管理员权限
    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        admin = newAdmin;
    }
}

contract BombGame is Admin {
    // using EnumerableSet for EnumerableSet.AddressSet;
    mapping(uint256 => RankingInfo[]) private top10Daily;
    mapping(uint256 => RankingInfo[]) private top10Weekly;
    mapping(uint256 => uint) public burnNumber;
    
    mapping(uint256 => mapping(address => uint256)) public dailyRanking;  // 每日排行榜具体数据
    mapping(uint256 => mapping(address => uint256)) public weeklyRanking; // 每周排行榜具体数据

    uint8 public constant roomCount = 10; // 房间总数
    uint256 public roundId; // 当前游戏轮次 ID
    address public TEAM_ADDRESS = msg.sender; // 团队地址
    address public constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD); // 黑洞地址用于销毁
    address public  gameToken;// 游戏代币地址
//钱钱钱
    struct Player {
        uint256 amount; // 玩家投入金额
        uint8 room;     // 玩家选择房间
    }

    struct Round {
        mapping(address => Player) players; // 每轮玩家数据
        address[] participants;            // 参与者地址列表
    }

    struct PlayerStat {
        address player; // 玩家地址
        uint256 amount; // 玩家投入金额
    }

    struct RankingInfo {
        address player; // 玩家地址
        uint256 amount; // 排行榜上的投入金额
    }

    mapping(uint256 => Round) internal  rounds; // 所有轮次的游戏记录
    mapping(address => bool) public hasJoined; // 是否参与过游戏
    address[] public allPlayers; // 所有历史参与者

    mapping(uint256 => uint256) public weekMoney; //周排名奖励累计
    mapping(uint256 => uint256) public dayMoney; //周排名奖励累计

    constructor() {
        roundId = 1; // 初始轮次设为1
    }
    function setGameToken(address token) external onlyAdmin {
        require(token != address(0), "Invalid token address");
        gameToken = token; // 设置游戏代币地址
    }
    // 设置团队地址
    function setTeamAddress(address team) external onlyAdmin {
        require(team != address(0), "Invalid team address");
        TEAM_ADDRESS = team; // 设置团队地址
    }
    // 玩家加入游戏函数
    // 玩家加入游戏时更新排行榜
function joinGame(uint8 room, uint256 amount) external {
    require(room < roomCount, "Invalid room");
    require(amount > 0, "Amount must be > 0");

    // Round storage round = rounds[roundId];
    //检测游戏代币是否授权给游戏合约
    require(IERC20(gameToken).allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
    IERC20(gameToken).transferFrom(msg.sender, address(this), amount);
    Round storage round = rounds[roundId];

    // 首次加入全局玩家列表
    if (!hasJoined[msg.sender]) {
        hasJoined[msg.sender] = true;
        allPlayers.push(msg.sender);
    }

    // 首次参与当前轮，加入参与者列表
    if (round.players[msg.sender].amount == 0) {
        round.participants.push(msg.sender);
    }

    // 累计玩家投入和设置房间
    round.players[msg.sender].amount += amount;
    round.players[msg.sender].room = room;

    // 更新每日和每周排行榜数据
    uint256 currentDay = block.timestamp / 1 days;
    uint256 currentWeek = block.timestamp / 1 weeks;

    dailyRanking[currentDay][msg.sender] += amount;
    weeklyRanking[currentWeek][msg.sender] += amount;
    // 维护 top10 排行榜数组
    _insertTop10(top10Daily[currentDay], msg.sender, dailyRanking[currentDay][msg.sender]);
    _insertTop10(top10Weekly[currentWeek], msg.sender, weeklyRanking[currentWeek][msg.sender]);
   }

// 更新排行榜函数
function _insertTop10(
    RankingInfo[] storage top10,
    address user,
    uint256 amount
) internal {
    // 先检查是否已经存在该用户，更新后重新排序
    bool updated = false;
    for (uint256 i = 0; i < top10.length; i++) {
        if (top10[i].player == user) {
            top10[i].amount = amount;
            updated = true;
            break;
        }
    }

    if (!updated) {
        // 如果不足10人，直接插入
        if (top10.length < 10) {
            top10.push(RankingInfo(user, amount));
        } else if (amount > top10[9].amount) {
            // 如果当前用户金额大于第10名，替换
            top10[9] = RankingInfo(user, amount);
        } else {
            return; // 金额太少，进不了榜
        }
    }

    // 插入或更新后排序（冒泡或插排）
    for (uint256 i = top10.length - 1; i > 0; i--) {
        if (top10[i].amount > top10[i - 1].amount) {
            // 交换位置
            RankingInfo memory temp = top10[i];
            top10[i] = top10[i - 1];
            top10[i - 1] = temp;
        } else {
            break;
        }
    }
}


   

    // 游戏结算函数（由管理员调用）
    function endGame() external onlyAdmin {
        Round storage round = rounds[roundId];
        if(round.participants.length == 0){
            roundId++; // 没人参与，直接进入下一轮
            return;
        }

        // 使用前一区块的hash和当前时间生成伪随机种子
        bytes32 seed = keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp));
        uint8 bombRoom1 = uint8(uint256(seed) % roomCount);
        uint8 bombRoom2 = uint8(uint256(seed >> 8) % roomCount);

        if (bombRoom1 == bombRoom2) {
            bombRoom2 = (bombRoom2 + 1) % roomCount; // 保证两个爆炸房间不相同
        }

        uint256 totalAmount;  // 所有玩家总投入
        uint256 bombAmount;   // 被炸玩家总投入

        for (uint256 i = 0; i < round.participants.length; i++) {
            address user = round.participants[i];
            Player storage p = round.players[user];
            totalAmount += p.amount;
            if (p.room == bombRoom1 || p.room == bombRoom2) {
                bombAmount += p.amount;
            }
        }

        uint256 generalFee = (totalAmount * 5) / 1000; // 所有投入抽取0.5%
        uint256 bombFee = (bombAmount * 5) / 100;      // 爆炸房间抽取5%
        uint256 totalFee = generalFee + bombFee;       // 总抽水

        uint256 rewardPool = (bombAmount * 95) / 100; // 剩余爆炸金额用于分发

        // 分发爆炸收益给未爆炸玩家
        for (uint256 i = 0; i < round.participants.length; i++) {
            address user = round.participants[i];
            Player storage p = round.players[user];
            if (p.room == bombRoom1 || p.room == bombRoom2) continue;
            uint256 share = (rewardPool * p.amount) / (totalAmount - bombAmount);
            // 转账爆炸收益给未爆炸玩家
            // 这里可以添加 ERC20 代币转账逻辑
            IERC20(gameToken).transfer(user, share);
        }

        // 抽水分配
        uint256 toTeam = (totalFee * 40) / 100;      // 团队
        uint256 toDayTop = (totalFee * 10) / 100;    // 日排行
        uint256 toWeekTop = (totalFee * 10) / 100;   // 周排行
        uint256 toBurn = totalFee - toTeam - toDayTop - toWeekTop; // 销毁

        // toBurn 销毁逻辑应转账到 BURN_ADDRESS
        IERC20(gameToken).transfer(BURN_ADDRESS, toBurn);
        uint Wday = block.timestamp / 1 days; // 当前天数

        burnNumber[Wday] += toBurn; // 记录本轮销毁金额

        IERC20(gameToken).transfer(TEAM_ADDRESS, toTeam); // 团队地址
        roundId++; // 轮次+1 开启下一局
    }

    // 查询整体游戏数据统计
    function getGameStatistics() external view returns (
        uint256 currentRound,
        PlayerStat[] memory allPlayersInRound,
        RankingInfo[] memory top10Daily,
        RankingInfo[] memory top10Weekly
    ) {
        currentRound = roundId;
        Round storage round = rounds[currentRound];

        uint256 playerCount = round.participants.length;
        allPlayersInRound = new PlayerStat[](playerCount);

        for (uint256 i = 0; i < playerCount; i++) {
            address addr = round.participants[i];
            allPlayersInRound[i] = PlayerStat({
                player: addr,
                amount: round.players[addr].amount
            });
        }

        uint256 currentDay = block.timestamp / 1 days;
        uint256 currentWeek = block.timestamp / 1 weeks;

        top10Daily = getTopRankingInfo(currentDay, true); // 查询日榜前10
        top10Weekly = getTopRankingInfo(currentWeek, false); // 查询周榜前10
    }

    // 查询用户个人信息
    function getMyStats(address user) external view returns (
        uint256 currentRound,
        uint256 roundAmount,
        uint8 roundRoom,
        uint256 todayAmount,
        uint256 weekAmount
    ) {
        currentRound = roundId;
        Round storage round = rounds[currentRound];

        roundAmount = round.players[user].amount;
        roundRoom = round.players[user].room;

        uint256 currentDay = block.timestamp / 1 days;
        uint256 currentWeek = block.timestamp / 1 weeks;

        todayAmount = dailyRanking[currentDay][user];
        weekAmount = weeklyRanking[currentWeek][user];
    }

    // 排行榜前10查询函数（内部）
    // 查询前10名玩家
    /// @notice 查询排行榜前10（可供前端调用）
    /// @param period 时间段（以天或周为单位的时间戳）
    /// @param isDaily 是否为每日榜单（true为日榜，false为周榜）
    /// @return top 返回前10名的地址与金额数组
    function getTopRankingInfo(uint256 period, bool isDaily) public view returns (RankingInfo[] memory top) {
    top = isDaily ? top10Daily[period] : top10Weekly[period];
}




    // 管理员提取BNB
    function withdrawBNB(address payable to, uint256 amount) external onlyAdmin {
        require(to != address(0), "Invalid address");
        to.transfer(amount);
    }

    // 管理员提取任意ERC20代币
    function withdrawToken(address token, address to, uint256 amount) external onlyAdmin {
        require(to != address(0), "Invalid address");
            IERC20(token).transfer(to, amount); // 转账指定代币到指定地址

           }

    // 合约接收BNB
    receive() external payable {}
}
