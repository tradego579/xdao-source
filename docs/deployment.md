# XDAO Token 部署指南

## 📋 部署前准备

### 环境要求
- Node.js >= 16.0.0
- npm >= 8.0.0
- 足够的 X Layer 代币用于支付 Gas 费用

### 网络配置
- **主网**: X Layer (Chain ID: 196)
- **测试网**: X Layer Testnet (Chain ID: 195)

## ⚙️ 配置步骤

### 1. 安装依赖
```bash
cd contracts
npm install
```

### 2. 环境变量配置
创建 `.env` 文件：

```env
# 网络 RPC 地址
XLAYER_RPC_URL=https://rpc.xlayer.tech
XLAYER_TESTNET_RPC_URL=https://xlayertestrpc.okx.com/terigon

# 部署者私钥（请妥善保管）
PRIVATE_KEY=your_private_key_here

# 钱包地址配置
OPERATION_WALLET=0x...  # 运营钱包地址
MARKETING_WALLET=0x...  # 营销钱包地址

# 税收豁免地址列表（逗号分隔）
TAX_EXEMPT_LIST=0x000000000000000000000000000000000000dEaD,0x69C236E021F5775B0D0328ded5EaC708E3B869DF,0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
```

### 3. 编译合约
```bash
npx hardhat compile
```

## 🚀 部署流程

### 主网部署
```bash
npx hardhat run scripts/deploy-xdao.js --network xlayer
```

### 测试网部署
```bash
npx hardhat run scripts/deploy-xdao.js --network xlayer-testnet
```

## 📊 部署后验证

### 1. 检查部署状态
部署成功后，控制台会显示：
```
✅ XDAO Token 部署成功！
合约地址: 0x...
交易哈希: 0x...
```

### 2. 验证合约
```bash
npx hardhat verify --network xlayer <CONTRACT_ADDRESS> <OPERATION_WALLET> <MARKETING_WALLET> <INITIAL_SUPPLY>
```

### 3. 检查合约状态
```bash
npx hardhat run scripts/check-address.js --network xlayer
```

## 🔧 部署后配置

### 1. 设置税收豁免地址
```bash
npx hardhat run scripts/manage-tax-exempt.js --network xlayer --add 0x...
```

### 2. 转移所有权（可选）
```bash
npx hardhat run scripts/transfer-ownership.js --network xlayer
```

### 3. 放弃所有权（可选）
```bash
npx hardhat run scripts/renounce-ownership.js --network xlayer
```

## 📋 部署检查清单

### 部署前检查
- [ ] 环境变量配置正确
- [ ] 私钥有足够的 X Layer 代币
- [ ] 运营和营销钱包地址正确
- [ ] 合约编译成功

### 部署后检查
- [ ] 合约部署成功
- [ ] 合约验证通过
- [ ] 初始供应量正确
- [ ] 税收豁免地址设置正确
- [ ] 所有权转移完成（如需要）

## ⚠️ 注意事项

### 安全提醒
- 🔒 私钥请妥善保管，不要提交到代码仓库
- 🔒 部署前请仔细检查所有参数
- 🔒 建议先在测试网部署测试

### 成本估算
- **部署费用**: 约 0.01-0.05 X Layer
- **验证费用**: 约 0.001-0.005 X Layer
- **配置费用**: 约 0.001-0.01 X Layer

### 常见问题
1. **Gas 费用不足**: 确保钱包有足够的 X Layer 代币
2. **网络连接失败**: 检查 RPC 地址是否正确
3. **合约验证失败**: 确保构造函数参数正确

## 📞 技术支持

如遇到部署问题，请：
1. 检查控制台错误信息
2. 查看 [常见问题解答](troubleshooting.md)
3. 提交 GitHub Issue
4. 联系技术支持

---

**部署完成后，请妥善保存合约地址和部署信息！**
