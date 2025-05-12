// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
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
contract RoomBattleGame is Ownable {
    uint256 public constant ROOM_COUNT = 10;
    uint256 public constant ROUND_DURATION = 90; // 90秒每轮

    address public owner;
    uint256 public roundId = 1; // 当前轮次ID
    uint256 public currentRoundStartTime;
    uint256 public seed = 42;
    uint public nB; // 积分兑换比例
    // 玩家信息：轮次 => 房间号 => 玩家地址列表
    mapping(uint256 => mapping(uint256 => address[])) public roomPlayers;
    // 玩家每轮投入金额：轮次 => 玩家 => 金额
    mapping(uint256 => mapping(address => uint256)) public playerBets;
    // 每轮是否已结算
    mapping(uint256 => bool) public roundSettled;

    // 玩家历史总投入
    mapping(address => uint256) public totalVolume;
    //玩家已经兑换数量
    mapping(address => uint256) public overtotalVolume;

    // 每日统计：用户 => 天编号 => 金额
    mapping(address => mapping(uint256 => uint256)) public dailyVolume;
    // 每周统计：用户 => 周编号 => 金额
    mapping(address => mapping(uint256 => uint256)) public weeklyVolume;

    // 每日第一名
    mapping(uint256 => address) public dailyLeader;
    mapping(uint256 => uint256) public dailyMaxVolume;

    // 每周第一名
    mapping(uint256 => address) public weeklyLeader;
    mapping(uint256 => uint256) public weeklyMaxVolume;

    constructor() {
        owner = msg.sender;
    }
    function setN(uint  num) external onlyOwner {
        nB = num;
    }
    function duiHuan() external   {
        return nB;
    }
    // 玩家参与当前轮
    function deposit(uint256 roomId) external payable {
        require(roomId < ROOM_COUNT, "非法房间编号");
        require(msg.value > 0, "投入金额必须大于0");

        // 如果当前轮未开始，开始轮次并记录开始时间
        if (currentRoundStartTime == 0  block.timestamp >= currentRoundStartTime + ROUND_DURATION) {
            if (roundId > 1 && !roundSettled[roundId - 1]) {
                settleRound(roundId - 1);
            }
            currentRoundStartTime = block.timestamp;
        }

        require(block.timestamp < currentRoundStartTime + ROUND_DURATION, "本轮已结束");

        roomPlayers[roundId][roomId].push(msg.sender);
        playerBets[roundId][msg.sender] += msg.value;
        totalVolume[msg.sender] += msg.value;

        _updateStats(msg.sender, msg.value);
    }

    // 结算上一轮：由下一轮第一个参与者自动触发
    function settleRound(uint256 round) public {
        require(!roundSettled[round], "本轮已结算");

        // 生成随机数（不完全安全，但足够用于低价值博弈）
        bytes32 hashInput = keccak256(abi.encodePacked(blockhash(block.number - 1), seed, round));
        uint256 rand1 = uint256(hashInput) % ROOM_COUNT;
        uint256 rand2 = uint256(keccak256(abi.encodePacked(hashInput))) % ROOM_COUNT;
        if (rand2 == rand1) {
            rand2 = (rand2 + 1) % ROOM_COUNT;
        }

        // 所有房间玩家投入总额
        uint256 totalPool = 0;
        for (uint256 i = 0; i < ROOM_COUNT; i++) {
            address[] memory players = roomPlayers[round][i];
            for (uint256 j = 0; j < players.length; j++) {
                totalPool += playerBets[round][players[j]];
            }
        }

        // 胜利房间分得奖励
        uint256 burnedPool = 0;
        address[] memory loser1 = roomPlayers[round][rand1];
        address[] memory loser2 = roomPlayers[round][rand2];

        for (uint256 i = 0; i < loser1.length; i++) {
            burnedPool += playerBets[round][loser1[i]];
        }
        for (uint256 i = 0; i < loser2.length; i++) {
            burnedPool += playerBets[round][loser2[i]];
        }

        uint256 rewardPool = totalPool - burnedPool;

        // 给所有胜利者按比例发放奖励
        for (uint256 i = 0; i < ROOM_COUNT; i++) {
            if (i == rand1  i == rand2) continue;
            address[] memory winners = roomPlayers[round][i];
            for (uint256 j = 0; j < winners.length; j++) {
                address winner = winners[j];
                uint256 userBet = playerBets[round][winner];
                uint256 reward = (userBet * rewardPool) / (totalPool - burnedPool);
                if (reward > 0) {
                    payable(winner).transfer(reward);
                }
            }
        }

        roundSettled[round] = true;
        roundId += 1;
        currentRoundStartTime = 0;
        seed += 1;
    }

    // 更新用户的每日/每周统计和排行榜
    function _updateStats(address user, uint256 amount) internal {
        uint256 day = block.timestamp / 1 days;
        uint256 week = block.timestamp / 1 weeks;
        dailyVolume[user][day] += amount;
        if (dailyVolume[user][day] > dailyMaxVolume[day]) {
            dailyMaxVolume[day] = dailyVolume[user][day];
            dailyLeader[day] = user;
        }

        weeklyVolume[user][week] += amount;
        if (weeklyVolume[user][week] > weeklyMaxVolume[week]) {
            weeklyMaxVolume[week] = weeklyVolume[user][week];
            weeklyLeader[week] = user;
        }
    }

    // 返回某玩家完整数据统计
    function getUserInfo(address user) external view returns (
        uint256 _totalVolume,
        uint256 _todayVolume,
        uint256 _weekVolume,
        bool _isTodayLeader,
        bool _isWeekLeader
    ) {
        uint256 day = block.timestamp / 1 days;
        uint256 week = block.timestamp / 1 weeks;

        _totalVolume = totalVolume[user];
        _todayVolume = dailyVolume[user][day];
        _weekVolume = weeklyVolume[user][week];
        _isTodayLeader = (dailyLeader[day] == user);
        _isWeekLeader = (weeklyLeader[week] == user);
    }
}