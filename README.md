# XDAO Token - 开源智能合约

## 🚀 项目简介

XDAO Token 是一个基于以太坊的 ERC20 代币，具有简化的税收机制和治理功能。本项目开源了完整的智能合约代码、部署脚本和管理工具。

## 📋 合约特性

### 核心功能
- **ERC20 标准**: 完全兼容 ERC20 代币标准
- **税收机制**: 1% 的买卖税收，分配给运营和营销钱包
- **税收豁免**: 支持设置税收豁免地址
- **所有权管理**: 基于 OpenZeppelin 的 Ownable 合约
- **暂停功能**: 紧急情况下可暂停合约
- **重入保护**: 防止重入攻击

### 代币信息
- **名称**: XDAO Token
- **符号**: XDAO
- **精度**: 18 位小数
- **总供应量**: 21,000,000 XDAO
- **税收率**: 1% (0.5% 运营 + 0.5% 营销)

## 🏗️ 项目结构

```
open-source/
├── contracts/                 # 智能合约源码
│   ├── contracts/
│   │   └── XDAO.sol          # 主合约文件
│   ├── scripts/
│   │   ├── deploy-xdao.js    # 部署脚本
│   │   ├── manage-tax-exempt.js # 税收豁免管理
│   │   └── ...               # 其他管理脚本
│   ├── artifacts/            # 编译产物
│   ├── cache/                # 编译缓存
│   ├── hardhat.config.js     # Hardhat 配置
│   ├── package.json          # 依赖管理
│   ├── LICENSE               # MIT 许可证
│   └── README.md             # 详细说明文档
├── docs/                     # 文档目录
│   ├── deployment.md         # 部署指南
│   ├── api.md               # API 文档
│   └── security.md          # 安全说明
└── README.md                # 项目总览（本文件）
```

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone <repository-url>
cd open-source
```

### 2. 安装依赖
```bash
cd contracts
npm install
```

### 3. 编译合约
```bash
npx hardhat compile
```

### 4. 部署合约
```bash
# 部署到 X Layer 主网
npx hardhat run scripts/deploy-xdao.js --network xlayer

# 部署到测试网
npx hardhat run scripts/deploy-xdao.js --network xlayer-testnet
```

## 📖 详细文档

- [合约部署指南](contracts/README.md)
- [API 接口文档](docs/api.md)
- [安全审计报告](docs/security.md)

## 🔧 主要功能

### 智能合约
- **XDAO.sol**: 主代币合约，包含所有核心功能
- **税收机制**: 自动收取和分配交易税收
- **权限管理**: 基于角色的访问控制
- **紧急暂停**: 紧急情况下的合约暂停机制

### 部署脚本
- **deploy-xdao.js**: 一键部署合约到指定网络
- **manage-tax-exempt.js**: 管理税收豁免地址
- **transfer-ownership.js**: 转移合约所有权
- **renounce-ownership.js**: 放弃合约所有权

### 管理工具
- **check-address.js**: 检查地址信息
- **check-liquidity.js**: 检查流动性信息
- **lock-liquidity.js**: 锁定流动性

## 🛡️ 安全特性

### 代码安全
- 使用 OpenZeppelin 标准库
- 重入攻击保护
- 整数溢出保护
- 权限控制机制

### 审计状态
- ✅ 代码审查完成
- ✅ 功能测试通过
- ✅ 安全检查完成
- 🔄 第三方审计进行中

## 📊 合约统计

**已部署合约信息**:
- **网络**: X Layer 主网
- **合约地址**: `0xaDd42293e8B04b9A6075b0353E95ebc14ae19131`
- **部署时间**: 2024年
- **验证状态**: ✅ 已验证

## 🔍 验证合约

### 在线验证
访问 [X Layer Explorer](https://www.oklink.com/xlayer) 查看合约详情。

### 本地验证
```bash
npx hardhat verify --network xlayer <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>
```

## 📝 许可证

本项目采用 MIT 许可证。详见 [LICENSE](contracts/LICENSE) 文件。

## 🤝 贡献指南

### 如何贡献
1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 贡献类型
- 🐛 Bug 修复
- ✨ 新功能开发
- 📚 文档改进
- 🔧 工具优化
- 🛡️ 安全增强

## ⚠️ 免责声明

本开源项目仅供学习和研究使用。使用前请确保：

- ✅ 充分理解合约逻辑和风险
- ✅ 进行充分的安全审计
- ✅ 遵守当地法律法规
- ✅ 承担使用风险和责任

**重要提醒**: 
- 智能合约部署后无法修改
- 请在生产环境使用前进行充分测试
- 建议寻求专业审计机构的审计

## 📞 联系方式

- **GitHub Issues**: 提交问题和建议
- **Discussions**: 参与社区讨论
- **Email**: 联系项目维护者

## 🌟 致谢

感谢以下开源项目：
- [OpenZeppelin](https://openzeppelin.com/) - 安全的智能合约库
- [Hardhat](https://hardhat.org/) - 以太坊开发环境
- [X Layer](https://www.okx.com/xlayer) - 区块链网络

---

**⭐ 如果这个项目对您有帮助，请给我们一个 Star！**
