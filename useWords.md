游戏合约 0xb90A58D6E5CB2534719d78cCee3669eb666c1e2b
游戏代币 ：0x45EA0af0c71eA2Fb161AF3b07F033cEe123386E8
// 查询用户个人信息
function getMyStats(address user) external view returns (
    uint256 currentRound,    // 当前游戏轮次编号
    uint256 roundAmount,     // 当前轮次该用户的投入金额
    uint8 roundRoom,         // 当前轮次该用户选择的房间编号（0~9）
    uint256 todayAmount,     // 今日该用户的累计投入金额（用于日排行）
    uint256 weekAmount       // 本周该用户的累计投入金额（用于周排行）

// 查询整体游戏数据统计
function getGameStatistics() external view returns (
    uint256 currentRound,                   // 当前游戏轮次编号
    PlayerStat[] memory allPlayersInRound,  // 当前轮所有参与者及其投入金额
    RankingInfo[] memory top10Daily,        // 当日排行榜前10玩家及其金额
    RankingInfo[] memory top10Weekly        // 当周排行榜前10玩家及其金额
代币授权。可以动态调用获取TOKEN。需要查询gameToken()返回的地址。
授权后调用参与游戏
function joinGame(uint8 room, uint256 amount) external     
第一个参数是1到10选择房间号，第二个是参与代币数量，需要乘以1e18;




defi合约部分     DEFI地址 0xa7aa6034573d9e251d8cea23b03D40fb5314bd0e

