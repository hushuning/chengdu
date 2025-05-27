// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Admin {
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        admin = newAdmin;
    }
}

contract BombGame is Admin {
    struct Player {
        uint256 amount; // 投入金额
        uint8 room;     // 选择的房间
    }

    struct Round {
        mapping(address => Player) players;
        address[] participants;
    }

    struct PlayerStat {
        address player;
        uint256 amount;
    }

    struct RankingInfo {
        address player;
        uint256 amount;
    }

    uint8 public constant roomCount = 10;
    uint256 public roundId;
    address public TEAM_ADDRESS;
    address public constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);
    address public gameToken;

    // 轮次 → 房间总投入
    mapping(uint256 => uint256[roomCount]) public roomMoney;
    // 轮次 → Round 数据
    mapping(uint256 => Round) internal rounds;

    // 参与记录
    mapping(address => bool) public hasJoined;
    address[] public allPlayers;

    // 日周榜数据
    mapping(uint256 => mapping(address => uint256)) public dailyRanking;
    mapping(uint256 => mapping(address => uint256)) public weeklyRanking;
    mapping(uint256 => RankingInfo[]) private top10Daily;
    mapping(uint256 => RankingInfo[]) private top10Weekly;

    // 销毁统计
    mapping(uint256 => uint256) public burnNumber;
    // 结果记录：爆炸的两个房间
    mapping(uint256 => uint8[2]) public gameResult;

    constructor(address _token) {
        require(_token != address(0), "Invalid token");
        gameToken = _token;
        TEAM_ADDRESS = msg.sender;
        roundId = 1;
    }

    function setGameToken(address token) external onlyAdmin {
        require(token != address(0), "Invalid token");
        gameToken = token;
    }

    function setTeamAddress(address team) external onlyAdmin {
        require(team != address(0), "Invalid address");
        TEAM_ADDRESS = team;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function joinGame(uint8 room, uint256 amount) external {
        require(!isContract(msg.sender), "Only EOA");
        require(msg.sender == tx.origin, "No contracts");
        require(room < roomCount, "Invalid room");
        require(amount > 0, "Amount > 0");

        IERC20 token = IERC20(gameToken);
        require(token.allowance(msg.sender, address(this)) >= amount, "Allowance too low");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        Round storage round = rounds[roundId];

        if (!hasJoined[msg.sender]) {
            hasJoined[msg.sender] = true;
            allPlayers.push(msg.sender);
        }
        if (round.players[msg.sender].amount == 0) {
            round.participants.push(msg.sender);
        }

        round.players[msg.sender].amount += amount;
        round.players[msg.sender].room = room;
        roomMoney[roundId][room] += amount;

        uint256 currentDay = block.timestamp / 1 days;
        uint256 currentWeek = block.timestamp / 1 weeks;

        dailyRanking[currentDay][msg.sender] += amount;
        weeklyRanking[currentWeek][msg.sender] += amount;

        _insertTop10(top10Daily[currentDay], msg.sender, dailyRanking[currentDay][msg.sender]);
        _insertTop10(top10Weekly[currentWeek], msg.sender, weeklyRanking[currentWeek][msg.sender]);
    }

    function _insertTop10(
        RankingInfo[] storage top10,
        address user,
        uint256 amount
    ) internal {
        bool updated = false;
        for (uint256 i = 0; i < top10.length; i++) {
            if (top10[i].player == user) {
                top10[i].amount = amount;
                updated = true;
                break;
            }
        }
        if (!updated) {
            if (top10.length < 10) {
                top10.push(RankingInfo(user, amount));
            } else if (amount > top10[9].amount) {
                top10[9] = RankingInfo(user, amount);
            } else {
                return;
            }
        }
        // 插排法排序到正确位置
        for (uint256 i = top10.length - 1; i > 0; i--) {
            if (top10[i].amount > top10[i - 1].amount) {
                RankingInfo memory tmp = top10[i];
                top10[i] = top10[i - 1];
                top10[i - 1] = tmp;
            } else {
                break;
            }
        }
    }

    function endGame(uint256 randN) external onlyAdmin {
        Round storage round = rounds[roundId];
        // 若无人参与，直接开启下一轮
        if (round.participants.length == 0) {
            roundId++;
            return;
        }

        // 生成两个不同的爆炸房间
        bytes32 seed = keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, randN));
        uint8 bomb1 = uint8(uint256(seed) % roomCount);
        uint8 bomb2 = uint8(uint256(seed >> 8) % roomCount);
        if (bomb1 == bomb2) {
            bomb2 = (bomb2 + 1) % roomCount;
        }
        gameResult[roundId] = [bomb1, bomb2];

        // 计算各项金额
        uint256 totalIn;
        uint256 bombIn;
        for (uint256 i = 0; i < round.participants.length; i++) {
            Player storage p = round.players[round.participants[i]];
            totalIn += p.amount;
            if (p.room == bomb1 || p.room == bomb2) {
                bombIn += p.amount;
            }
        }

        uint256 generalFee = (totalIn * 5) / 1000;      // 0.5%
        uint256 bombFee    = (bombIn * 5) / 100;        // 5%
        uint256 totalFee   = generalFee + bombFee;
        uint256 rewardPool = (bombIn * 95) / 100;       // 95% of bombIn

        IERC20 token = IERC20(gameToken);

        // 给存活玩家退本金 + 分红
        for (uint256 i = 0; i < round.participants.length; i++) {
            address user = round.participants[i];
            Player storage p = round.players[user];
            if (p.room == bomb1 || p.room == bomb2) {
                continue;
            }
            uint256 share = (rewardPool * p.amount) / (totalIn - bombIn);
            uint256 payout = p.amount + share;
            require(token.transfer(user, payout), "Payout failed");
        }
        
        // 抽水分配
        uint256 toTeam    = (totalFee * 40) / 100;
        uint256 toDayTop  = (totalFee * 10) / 100;
        uint256 toWeekTop = (totalFee * 10) / 100;
        uint256 toBurn    = totalFee - toTeam - toDayTop - toWeekTop;

        // 销毁
        require(token.transfer(BURN_ADDRESS, toBurn), "Burn failed");
        uint256 today = block.timestamp / 1 days;
        burnNumber[today] += toBurn;

        // 团队分成
        require(token.transfer(TEAM_ADDRESS, toTeam), "Team transfer failed");

        // 下一轮
        roundId++;
    }

    function getRoomMoney() external view returns (uint256[roomCount] memory) {
        return roomMoney[roundId];
    }

    function getGameResult(uint256 rid) external view returns (uint8[2] memory) {
        return gameResult[rid];
    }

    function getGameStatistics()
        external
        view
        returns (
            uint256 currentRound,
            PlayerStat[] memory playersInRound,
            RankingInfo[] memory topDaily,
            RankingInfo[] memory topWeekly
        )
    {
        currentRound = roundId;
        Round storage round = rounds[currentRound];
        uint256 n = round.participants.length;
        playersInRound = new PlayerStat[](n);
        for (uint256 i = 0; i < n; i++) {
            address addr = round.participants[i];
            playersInRound[i] = PlayerStat(addr, round.players[addr].amount);
        }
        uint256 day = block.timestamp / 1 days;
        uint256 week = block.timestamp / 1 weeks;
        topDaily  = top10Daily[day];
        topWeekly = top10Weekly[week];
    }

    function getMyStats(address user)
        external
        view
        returns (
            uint256 currentRound,
            uint256 roundAmount,
            uint8 roundRoom,
            uint256 todayAmount,
            uint256 weekAmount
        )
    {
        currentRound = roundId;
        Round storage round = rounds[currentRound];
        roundAmount = round.players[user].amount;
        roundRoom   = round.players[user].room;
        uint256 day  = block.timestamp / 1 days;
        uint256 week = block.timestamp / 1 weeks;
        todayAmount = dailyRanking[day][user];
        weekAmount  = weeklyRanking[week][user];
    }

    function getTopRankingInfo(uint256 period, bool isDaily)
        public
        view
        returns (RankingInfo[] memory)
    {
        return isDaily ? top10Daily[period] : top10Weekly[period];
    }

    // 管理提取
    function withdrawBNB(address payable to, uint256 amount) external onlyAdmin {
        require(to != address(0), "Invalid address");
        to.transfer(amount);
    }

    function withdrawToken(address tokenAddr, address to, uint256 amount) external onlyAdmin {
        require(to != address(0), "Invalid address");
        IERC20(tokenAddr).transfer(to, amount);
    }

    receive() external payable {}
}
