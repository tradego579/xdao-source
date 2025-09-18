# XDAO Token API 文档

## 📋 合约接口概览

XDAO Token 合约提供了完整的 ERC20 标准接口，以及额外的税收管理和治理功能。

## 🔧 核心函数

### ERC20 标准函数

#### transfer
```solidity
function transfer(address to, uint256 amount) public override returns (bool)
```
**功能**: 转账代币到指定地址  
**参数**:
- `to`: 接收地址
- `amount`: 转账数量

**返回值**: 成功返回 `true`

#### transferFrom
```solidity
function transferFrom(address from, address to, uint256 amount) public override returns (bool)
```
**功能**: 从指定地址转账代币  
**参数**:
- `from`: 发送地址
- `to`: 接收地址
- `amount`: 转账数量

**返回值**: 成功返回 `true`

#### approve
```solidity
function approve(address spender, uint256 amount) public override returns (bool)
```
**功能**: 授权指定地址使用代币  
**参数**:
- `spender`: 被授权地址
- `amount`: 授权数量

**返回值**: 成功返回 `true`

#### allowance
```solidity
function allowance(address owner, address spender) public view override returns (uint256)
```
**功能**: 查询授权额度  
**参数**:
- `owner`: 代币持有者
- `spender`: 被授权地址

**返回值**: 授权额度

#### balanceOf
```solidity
function balanceOf(address account) public view override returns (uint256)
```
**功能**: 查询账户余额  
**参数**:
- `account`: 账户地址

**返回值**: 账户余额

### 税收管理函数

#### setTaxExempt
```solidity
function setTaxExempt(address account, bool exempt) external onlyOwner
```
**功能**: 设置税收豁免状态  
**参数**:
- `account`: 账户地址
- `exempt`: 是否豁免税收

**权限**: 仅合约所有者

#### isTaxExempt
```solidity
function isTaxExempt(address account) external view returns (bool)
```
**功能**: 查询税收豁免状态  
**参数**:
- `account`: 账户地址

**返回值**: 是否豁免税收

#### setMarketingWallet
```solidity
function setMarketingWallet(address _marketingWallet) external onlyOwner
```
**功能**: 设置营销钱包地址  
**参数**:
- `_marketingWallet`: 新的营销钱包地址

**权限**: 仅合约所有者

### 合约管理函数

#### pause
```solidity
function pause() external onlyOwner
```
**功能**: 暂停合约  
**权限**: 仅合约所有者

#### unpause
```solidity
function unpause() external onlyOwner
```
**功能**: 恢复合约  
**权限**: 仅合约所有者

#### renounceOwnership
```solidity
function renounceOwnership() external onlyOwner
```
**功能**: 放弃合约所有权  
**权限**: 仅合约所有者

### 查询函数

#### getContractStats
```solidity
function getContractStats() external view returns (uint256, uint256, uint256, uint256, uint256)
```
**功能**: 获取合约统计信息  
**返回值**:
- `totalSupply`: 总供应量
- `operationBalance`: 运营钱包余额
- `marketingBalance`: 营销钱包余额
- `contractETH`: 合约 ETH 余额
- `contractToken`: 合约代币余额

#### owner
```solidity
function owner() public view virtual returns (address)
```
**功能**: 查询合约所有者  
**返回值**: 所有者地址

#### paused
```solidity
function paused() public view virtual returns (bool)
```
**功能**: 查询合约暂停状态  
**返回值**: 是否暂停

## 📊 事件定义

### Transfer
```solidity
event Transfer(address indexed from, address indexed to, uint256 value)
```
**触发时机**: 代币转账时

### Approval
```solidity
event Approval(address indexed owner, address indexed spender, uint256 value)
```
**触发时机**: 授权额度变更时

### OwnershipTransferred
```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```
**触发时机**: 所有权转移时

### Paused
```solidity
event Paused(address account)
```
**触发时机**: 合约暂停时

### Unpaused
```solidity
event Unpaused(address account)
```
**触发时机**: 合约恢复时

## 🔍 使用示例

### JavaScript/TypeScript 示例

#### 连接合约
```javascript
import { ethers } from 'ethers';

const provider = new ethers.JsonRpcProvider('https://rpc.xlayer.tech');
const contractAddress = '0xaDd42293e8B04b9A6075b0353E95ebc14ae19131';
const contractABI = [...]; // 合约 ABI

const contract = new ethers.Contract(contractAddress, contractABI, provider);
```

#### 查询余额
```javascript
const balance = await contract.balanceOf('0x...');
console.log('余额:', ethers.formatEther(balance));
```

#### 转账代币
```javascript
const signer = new ethers.Wallet(privateKey, provider);
const contractWithSigner = contract.connect(signer);

const tx = await contractWithSigner.transfer(
  '0x...', // 接收地址
  ethers.parseEther('100') // 转账数量
);
await tx.wait();
```

#### 设置税收豁免
```javascript
const tx = await contractWithSigner.setTaxExempt(
  '0x...', // 地址
  true     // 是否豁免
);
await tx.wait();
```

### Python 示例

#### 使用 Web3.py
```python
from web3 import Web3

# 连接网络
w3 = Web3(Web3.HTTPProvider('https://rpc.xlayer.tech'))

# 合约地址和 ABI
contract_address = '0xaDd42293e8B04b9A6075b0353E95ebc14ae19131'
contract_abi = [...]  # 合约 ABI

# 创建合约实例
contract = w3.eth.contract(address=contract_address, abi=contract_abi)

# 查询余额
balance = contract.functions.balanceOf('0x...').call()
print(f'余额: {balance / 10**18} XDAO')
```

## ⚠️ 注意事项

### Gas 费用
- 转账操作需要支付 Gas 费用
- 税收计算会增加 Gas 消耗
- 建议在操作前估算 Gas 费用

### 税收机制
- 所有转账都会收取 1% 税收
- 税收豁免地址不收取税收
- 税收自动分配给运营和营销钱包

### 安全提醒
- 私钥请妥善保管
- 大额转账前请先小额测试
- 建议使用硬件钱包进行重要操作

## 📞 技术支持

如有 API 使用问题，请：
1. 查看 [常见问题解答](troubleshooting.md)
2. 提交 GitHub Issue
3. 联系技术支持

---

**API 文档版本**: v1.0  
**最后更新**: 2024年
