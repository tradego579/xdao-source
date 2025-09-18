// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title XDAO Token
 * @dev XDAO代币合约 - 2100万总量，买卖1%税收，无推广奖励，不打黑洞
 * @notice 简化版代币合约，专注于基本功能
 */
contract XDAO is ERC20, Ownable, ReentrancyGuard, Pausable {
    
    // ============ 常量 ============
    
    uint256 public constant TOTAL_TAX_RATE = 100; // 1% 总税率 (基于10000)
    uint256 public constant OPERATION_RATE = 50;  // 0.5% 给项目运营
    uint256 public constant MARKETING_RATE = 50;  // 0.5% 给营销团队
    
    // ============ 状态变量 ============
    
    address public operationWallet; // 运营钱包
    address public marketingWallet; // 营销钱包
    mapping(address => bool) public taxExempt; // 税务豁免地址
    
    // ============ 事件 ============
    
    event TaxCollected(address indexed from, uint256 totalTax, uint256 operationFee, uint256 marketingFee);
    event OperationWalletUpdated(address indexed oldWallet, address indexed newWallet);
    event MarketingWalletUpdated(address indexed oldWallet, address indexed newWallet);
    
    // ============ 构造函数 ============
    
    constructor(
        address _operationWallet,
        address _marketingWallet,
        uint256 _initialSupply
    ) ERC20("XDAO Token", "XDAO") Ownable() {
        require(_operationWallet != address(0), "Invalid operation wallet");
        require(_marketingWallet != address(0), "Invalid marketing wallet");

        operationWallet = _operationWallet;
        marketingWallet = _marketingWallet;

        // 铸造2100万代币给部署者
        _mint(msg.sender, _initialSupply);

        // 设置税务豁免地址
        taxExempt[owner()] = true;
        taxExempt[address(this)] = true;
        taxExempt[_operationWallet] = true;
        taxExempt[_marketingWallet] = true;
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
            _processTaxDistribution(from, totalTax);
        }
    }

    /**
     * @dev 处理税务分配
     */
    function _processTaxDistribution(address from, uint256 totalTax) internal {
        // 计算各项费用
        uint256 operationFee = (totalTax * OPERATION_RATE) / TOTAL_TAX_RATE; // 0.5%给运营
        uint256 marketingFee = (totalTax * MARKETING_RATE) / TOTAL_TAX_RATE; // 0.5%给营销

        // 分配运营费用
        if (operationFee > 0) {
            super._transfer(address(this), operationWallet, operationFee);
        }

        // 分配营销费用
        if (marketingFee > 0) {
            super._transfer(address(this), marketingWallet, marketingFee);
        }

        emit TaxCollected(from, totalTax, operationFee, marketingFee);
    }

    // ============ 查询函数 ============
    
    /**
     * @dev 获取合约统计信息
     */
    function getContractStats() external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
            totalSupply(), // 总供应量
            balanceOf(operationWallet), // 运营钱包余额
            balanceOf(marketingWallet), // 营销钱包余额
            address(this).balance, // OKB 余额
            balanceOf(address(this)) // 合约代币余额
        );
    }

    // ============ 管理员功能 ============
    
    function setOperationWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid address");
        address oldWallet = operationWallet;
        operationWallet = _wallet;
        
        // 更新税务豁免状态
        taxExempt[oldWallet] = false;
        taxExempt[_wallet] = true;
        
        emit OperationWalletUpdated(oldWallet, _wallet);
    }
    
    function setMarketingWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid address");
        address oldWallet = marketingWallet;
        marketingWallet = _wallet;
        
        // 更新税务豁免状态
        taxExempt[oldWallet] = false;
        taxExempt[_wallet] = true;
        
        emit MarketingWalletUpdated(oldWallet, _wallet);
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
