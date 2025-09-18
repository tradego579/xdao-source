// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title xBurn Invitation Pool with Enhanced Statistics
 * @dev 集成邀请统计功能的 xBurn 代币合约
 * @notice 这个版本包含了详细的邀请统计功能
 */
contract xBurnInvitationPoolWithStats is ERC20, Ownable, ReentrancyGuard, Pausable {
    
    // ============ 常量 ============
    
    uint256 public constant TOTAL_TAX_RATE = 400; // 4% 总税率 (基于10000)
    uint256 public constant DIRECT_INVITER_RATE = 100; // 1% 给直接邀请人
    uint256 public constant SECOND_INVITER_RATE = 50;  // 0.5% 给二级邀请人
    uint256 public constant OPERATION_RATE = 100;      // 1% 给项目运营
    uint256 public constant MARKETING_RATE = 50;      // 0.5% 给营销团队
    uint256 public constant BURN_RATE = 100;            // 1% 直接燃烧账户
    
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    
    // ============ 状态变量 ============
    
    address public operationWallet; // 运营钱包
    address public marketingWallet; // 营销钱包
    address public burnWallet; // 燃烧钱包
    
    // 邀请码系统
    struct UserInfo {
        string invitationCode; // 用户自己的邀请码
        string usedInvitationCode; // 用户使用的邀请码
        address directInviter; // 用户直接邀请人
        address secondInviter; // 用户二级邀请人
        uint256 totalReceived; // 用户总接收奖励
        uint256 invitationsSent; // 发送的邀请数量
        uint256 lastInvitationTime; // 最后邀请时间
    }
    
    // 邀请统计结构体
    struct InvitationStats {
        uint256 totalInvitations;           // 总邀请数量
        uint256 totalActiveInviters;        // 活跃邀请人数量
        uint256 totalRewardsDistributed;    // 总奖励分发
        uint256 totalDirectRewards;         // 直接邀请奖励总额
        uint256 totalSecondLevelRewards;    // 二级邀请奖励总额
        uint256 totalBurnedFromInvitations; // 因无邀请人而燃烧的奖励
        uint256 lastUpdateTime;             // 最后更新时间
    }
    
    // 每日统计结构体
    struct DailyStats {
        uint256 date;                       // 日期 (YYYYMMDD格式)
        uint256 invitationsToday;           // 今日邀请数
        uint256 rewardsToday;               // 今日奖励分发
        uint256 activeInvitersToday;        // 今日活跃邀请人
    }
    
    mapping(address => UserInfo) public userInfo; // 用户信息映射
    mapping(address => address[]) public userInvitees; // 用户的被邀请人列表
    mapping(string => address) public invitationCodeOwners; // 邀请码拥有者映射
    mapping(address => bool) public taxExempt; // 税务豁免地址
    
    // 统计信息
    InvitationStats public globalStats;
    mapping(uint256 => DailyStats) public dailyStats; // date => stats
    
    // ============ 事件 ============
    
    event InvitationCodeCreated(string indexed code, address indexed owner);
    event InvitationCodeUsed(string indexed code, address indexed user, address indexed inviter);
    event RewardDistributed(address indexed user, address indexed inviter, uint256 amount, uint256 level);
    event TaxCollected(address indexed from, uint256 totalTax, uint256 directReward, uint256 secondReward, uint256 operationFee, uint256 marketingFee, uint256 burnAmount);
    event DailyStatsUpdated(uint256 date, uint256 invitations, uint256 rewards, uint256 activeInviters);
    event GlobalStatsUpdated(uint256 totalInvitations, uint256 totalRewards);
    
    // ============ 构造函数 ============
    
    constructor(
        address _operationWallet,
        address _marketingWallet,
        address _burnWallet,
        uint256 _initialSupply
    ) ERC20("xBurn Token", "xBurn") Ownable() {
        require(_operationWallet != address(0), "Invalid operation wallet");
        require(_marketingWallet != address(0), "Invalid marketing wallet");
        require(_burnWallet != address(0), "Invalid burn wallet");

        operationWallet = _operationWallet;
        marketingWallet = _marketingWallet;
        burnWallet = _burnWallet;

        // 铸造初始代币给部署者
        _mint(msg.sender, _initialSupply);

        // 设置税务豁免地址
        taxExempt[owner()] = true;
        taxExempt[address(this)] = true;
        taxExempt[_operationWallet] = true;
        taxExempt[_marketingWallet] = true;
        taxExempt[_burnWallet] = true;
        taxExempt[DEAD_ADDRESS] = true;
        
        // 初始化统计信息
        globalStats.lastUpdateTime = block.timestamp;
    }

    // ============ 邀请码管理 ============
    
    /**
     * @dev 创建邀请码
     * @param code 邀请码
     */
    function createInvitationCode(string calldata code) external nonReentrant whenNotPaused {
        require(bytes(code).length >= 6 && bytes(code).length <= 12, "Code length must be 6-12 chars");
        require(invitationCodeOwners[code] == address(0), "Code already exists");
        require(bytes(userInfo[msg.sender].invitationCode).length == 0, "User already has an invitation code");

        userInfo[msg.sender].invitationCode = code;
        invitationCodeOwners[code] = msg.sender;

        emit InvitationCodeCreated(code, msg.sender);
    }

    /**
     * @dev 使用邀请码
     * @param code 邀请码
     */
    function useInvitationCode(string calldata code) external nonReentrant whenNotPaused {
        require(bytes(code).length >= 6 && bytes(code).length <= 12, "Code length must be 6-12 chars");
        require(invitationCodeOwners[code] != address(0), "Code does not exist");
        require(invitationCodeOwners[code] != msg.sender, "Cannot use own code");
        require(bytes(userInfo[msg.sender].usedInvitationCode).length == 0, "Already used invitation code");

        address inviter = invitationCodeOwners[code];
        address secondInviter = userInfo[inviter].directInviter;

        userInfo[msg.sender].usedInvitationCode = code;
        userInfo[msg.sender].directInviter = inviter;
        userInfo[msg.sender].secondInviter = secondInviter;
        
        // 更新邀请统计
        _updateInvitationStats(inviter, msg.sender);

        emit InvitationCodeUsed(code, msg.sender, inviter);
    }
    
    /**
     * @dev 更新邀请统计
     * @param inviter 邀请人
     * @param invitee 被邀请人
     */
    function _updateInvitationStats(address inviter, address invitee) internal {
        // 更新全局统计
        globalStats.totalInvitations++;
        globalStats.lastUpdateTime = block.timestamp;
        
        // 更新用户统计
        userInfo[inviter].invitationsSent++;
        userInfo[inviter].lastInvitationTime = block.timestamp;
        userInvitees[inviter].push(invitee);
        
        // 更新每日统计
        uint256 today = getTodayDate();
        dailyStats[today].date = today;
        dailyStats[today].invitationsToday++;
        
        emit GlobalStatsUpdated(globalStats.totalInvitations, globalStats.totalRewardsDistributed);
    }

    // ============ 转账和税务处理 ============
    
    /**
     * @dev 重写转账函数，添加税务逻辑
     */
    function _transfer(address from, address to, uint256 amount) internal override {
        require(!paused(), "Contract is paused");

        // 检查税务豁免
        if (taxExempt[from] || taxExempt[to]) {
            super._transfer(from, to, amount);
            return;
        }

         // 计算税务
         uint256 totalTax = (amount * TOTAL_TAX_RATE) / 10000;
         uint256 transferAmount = amount - totalTax;

         // 执行转账
         super._transfer(from, to, transferAmount);
         
         // 将税务转到合约地址，然后分配
         if (totalTax > 0) {
             super._transfer(from, address(this), totalTax);
             _processTaxDistribution(from, to, amount, totalTax);
         }
    }

    /**
     * @dev 不收取税务的转账函数
     */
    function _transferWithoutTax(address from, address to, uint256 amount) internal {
        super._transfer(from, to, amount);
    }

    /**
     * @dev 处理税务分配
     */
    function _processTaxDistribution(address from, address to, uint256 originalAmount, uint256 totalTax) internal {
        // 计算各项税务
        uint256 directReward = (originalAmount * DIRECT_INVITER_RATE) / 10000;
        uint256 secondReward = (originalAmount * SECOND_INVITER_RATE) / 10000;
        uint256 operationFee = (originalAmount * OPERATION_RATE) / 10000;
        uint256 marketingFee = (originalAmount * MARKETING_RATE) / 10000;
        uint256 burnAmount = (originalAmount * BURN_RATE) / 10000;

         // 分发邀请奖励（从合约地址转出）
         _distributeRewards(from, directReward, secondReward);

         // 分配其他费用（从合约地址转出）
         _convertAndDistributeTax(operationFee, marketingFee, burnAmount);

        // 更新统计
        globalStats.totalRewardsDistributed += directReward + secondReward;
        globalStats.lastUpdateTime = block.timestamp;
        
        // 更新每日统计
        uint256 today = getTodayDate();
        dailyStats[today].rewardsToday += directReward + secondReward;

        emit TaxCollected(from, totalTax, directReward, secondReward, operationFee, marketingFee, burnAmount);
    }

     /**
      * @dev 分发邀请奖励
      */
     function _distributeRewards(address user, uint256 directReward, uint256 secondReward) internal {
        address directInviter = userInfo[user].directInviter;
        address secondInviter = userInfo[user].secondInviter;

        // 分发直接邀请奖励
        if (directInviter != address(0) && directReward > 0) {
            super._transfer(address(this), directInviter, directReward);
            userInfo[directInviter].totalReceived += directReward;
            globalStats.totalDirectRewards += directReward;
            _updateDailyRewardStats(directReward, 1);
            emit RewardDistributed(user, directInviter, directReward, 1);
        } else if (directReward > 0) {
            // 如果没有直接邀请人，将奖励发送到燃烧钱包
            super._transfer(address(this), burnWallet, directReward);
            globalStats.totalBurnedFromInvitations += directReward;
            emit RewardDistributed(user, burnWallet, directReward, 1);
        }

        // 分发二级邀请奖励
        if (secondInviter != address(0) && secondReward > 0) {
            super._transfer(address(this), secondInviter, secondReward);
            userInfo[secondInviter].totalReceived += secondReward;
            globalStats.totalSecondLevelRewards += secondReward;
            _updateDailyRewardStats(secondReward, 2);
            emit RewardDistributed(user, secondInviter, secondReward, 2);
        } else if (secondReward > 0) {
            // 如果没有二级邀请人，将奖励发送到燃烧钱包
            super._transfer(address(this), burnWallet, secondReward);
            globalStats.totalBurnedFromInvitations += secondReward;
            emit RewardDistributed(user, burnWallet, secondReward, 2);
        }
    }
    
    /**
     * @dev 更新每日奖励统计
     */
    function _updateDailyRewardStats(uint256 amount, uint256 level) internal {
        uint256 today = getTodayDate();
        dailyStats[today].rewardsToday += amount;
    }

     /**
      * @dev 将税务代币分配给各个钱包
      */
     function _convertAndDistributeTax(uint256 operationFee, uint256 marketingFee, uint256 burnAmount) internal {
         if (operationFee > 0) {
             super._transfer(address(this), operationWallet, operationFee);
         }
         if (marketingFee > 0) {
             super._transfer(address(this), marketingWallet, marketingFee);
         }
         if (burnAmount > 0) {
             super._transfer(address(this), burnWallet, burnAmount);
         }
     }

    // ============ 查询函数 ============
    
    /**
     * @dev 获取全局统计信息
     */
    function getGlobalStats() external view returns (InvitationStats memory) {
        return globalStats;
    }
    
    /**
     * @dev 获取用户的被邀请人列表
     * @param user 用户地址
     */
    function getUserInvitees(address user) external view returns (address[] memory) {
        return userInvitees[user];
    }
    
     /**
      * @dev 获取用户的被邀请人数量
      * @param user 用户地址
      */
     function getUserInviteesCount(address user) external view returns (uint256) {
         return userInvitees[user].length;
     }

     /**
      * @dev 检查邀请码是否存在
      * @param code 邀请码
      */
     function isInvitationCodeExists(string calldata code) external view returns (bool) {
         return invitationCodeOwners[code] != address(0);
     }

     /**
      * @dev 获取邀请码的拥有者
      * @param code 邀请码
      */
     function getInvitationCodeOwner(string calldata code) external view returns (address) {
         return invitationCodeOwners[code];
     }
    
    /**
     * @dev 获取指定日期的统计信息
     * @param date 日期 (YYYYMMDD格式)
     */
    function getDailyStats(uint256 date) external view returns (DailyStats memory) {
        return dailyStats[date];
    }
    
    /**
     * @dev 获取最近N天的统计信息
     * @param numDays 天数
     */
    function getRecentDailyStats(uint256 numDays) external view returns (DailyStats[] memory) {
        require(numDays > 0 && numDays <= 365, "Invalid days");
        
        DailyStats[] memory recentStats = new DailyStats[](numDays);
        uint256 today = getTodayDate();
        
        for (uint256 i = 0; i < numDays; i++) {
            uint256 date = today - i;
            recentStats[i] = dailyStats[date];
            recentStats[i].date = date;
        }
        
        return recentStats;
    }
    
    /**
     * @dev 获取合约统计信息（兼容原版本）
     */
    function getContractStats() external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
            globalStats.totalInvitations,
            globalStats.totalRewardsDistributed,
            0, // totalBurned (如果需要可以添加)
            balanceOf(operationWallet),
            balanceOf(marketingWallet),
            balanceOf(burnWallet),
            address(this).balance, // OKB 余额
            balanceOf(address(this)) // 合约代币余额
        );
    }

    // ============ 工具函数 ============
    
    /**
     * @dev 获取今天的日期 (YYYYMMDD格式)
     */
    function getTodayDate() public view returns (uint256) {
        // 简化实现，实际应该使用更精确的时间计算
        return (block.timestamp / 86400) * 10000 + 19700101;
    }

    // ============ 管理员功能 ============
    
    function setOperationWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid address");
        operationWallet = _wallet;
    }
    
    function setMarketingWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid address");
        marketingWallet = _wallet;
    }
    
    function setBurnWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid address");
        burnWallet = _wallet;
    }
    
    function setTaxExempt(address _address, bool _exempt) external onlyOwner {
        taxExempt[_address] = _exempt;
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
    
    function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
        require(token != address(0), "Invalid token");
        require(amount > 0, "Invalid amount");
        
        IERC20(token).transfer(owner(), amount);
    }

    // ============ 接收函数 ============
    
    receive() external payable {
        // 可以接收ETH但不做处理
    }
}
