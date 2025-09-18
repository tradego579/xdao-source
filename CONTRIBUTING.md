# 贡献指南

感谢您对 XDAO Token 项目的关注！我们欢迎各种形式的贡献。

## 🤝 如何贡献

### 1. Fork 项目
1. 点击项目页面的 "Fork" 按钮
2. 克隆您的 Fork 到本地：
```bash
git clone https://github.com/your-username/xdao-token.git
cd xdao-token
```

### 2. 创建分支
```bash
git checkout -b feature/your-feature-name
```

### 3. 进行修改
- 编写代码
- 添加测试
- 更新文档

### 4. 提交更改
```bash
git add .
git commit -m "Add: 描述您的更改"
```

### 5. 推送分支
```bash
git push origin feature/your-feature-name
```

### 6. 创建 Pull Request
1. 访问您的 Fork 页面
2. 点击 "New Pull Request"
3. 填写详细的描述

## 📋 贡献类型

### 🐛 Bug 修复
- 修复代码中的错误
- 改进错误处理
- 优化性能问题

### ✨ 新功能
- 添加新的合约功能
- 改进现有功能
- 添加新的管理脚本

### 📚 文档改进
- 更新 README 文件
- 添加 API 文档
- 改进代码注释

### 🔧 工具优化
- 改进部署脚本
- 添加新的管理工具
- 优化开发环境

### 🛡️ 安全增强
- 修复安全漏洞
- 改进安全机制
- 添加安全测试

## 📝 代码规范

### Solidity 代码规范
```solidity
// 使用 4 个空格缩进
contract XDAO {
    // 函数名使用 camelCase
    function transferTokens() public {
        // 代码逻辑
    }
    
    // 事件名使用 PascalCase
    event TokenTransferred(address indexed from, address indexed to, uint256 amount);
}
```

### JavaScript 代码规范
```javascript
// 使用 2 个空格缩进
function deployContract() {
  // 函数名使用 camelCase
  const contract = await deployer.deploy('XDAO');
  return contract;
}

// 常量使用 UPPER_SNAKE_CASE
const CONTRACT_ADDRESS = '0x...';
```

### 提交信息规范
```
类型: 简短描述

详细描述（可选）

- 修复了什么问题
- 添加了什么功能
- 改进了什么

Closes #123
```

**类型包括**:
- `Add`: 新功能
- `Fix`: Bug 修复
- `Update`: 更新现有功能
- `Remove`: 删除功能
- `Docs`: 文档更新
- `Style`: 代码格式
- `Refactor`: 代码重构
- `Test`: 测试相关

## 🧪 测试要求

### 单元测试
```javascript
describe('XDAO Token', () => {
  it('should transfer tokens correctly', async () => {
    // 测试逻辑
  });
});
```

### 集成测试
```javascript
describe('Deployment', () => {
  it('should deploy with correct parameters', async () => {
    // 部署测试
  });
});
```

## 📖 文档要求

### README 更新
- 更新功能列表
- 添加使用示例
- 更新安装说明

### API 文档
- 添加新函数说明
- 更新参数描述
- 添加使用示例

### 代码注释
```solidity
/**
 * @title XDAO Token
 * @dev 基于 ERC20 的代币合约
 * @author Your Name
 */
contract XDAO is ERC20, Ownable {
    /**
     * @dev 设置税收豁免状态
     * @param account 账户地址
     * @param exempt 是否豁免税收
     */
    function setTaxExempt(address account, bool exempt) external onlyOwner {
        // 实现逻辑
    }
}
```

## 🔍 代码审查

### 审查标准
- ✅ 代码逻辑正确
- ✅ 遵循代码规范
- ✅ 包含适当测试
- ✅ 文档更新完整
- ✅ 安全考虑充分

### 审查流程
1. **自动检查**: CI/CD 自动运行测试
2. **人工审查**: 维护者审查代码
3. **反馈修改**: 根据反馈进行修改
4. **合并代码**: 审查通过后合并

## 🏷️ Issue 标签

### Bug 报告
- `bug`: 代码错误
- `security`: 安全问题
- `performance`: 性能问题

### 功能请求
- `enhancement`: 功能增强
- `feature`: 新功能
- `improvement`: 改进建议

### 文档
- `documentation`: 文档问题
- `readme`: README 更新
- `api-docs`: API 文档

### 其他
- `question`: 问题咨询
- `help-wanted`: 需要帮助
- `good-first-issue`: 适合新手

## 🎯 贡献奖励

### 贡献者认可
- 在 README 中列出贡献者
- 在发布说明中提及贡献
- 提供贡献者证书

### 特殊贡献
- 重大功能贡献
- 安全漏洞发现
- 重要文档改进

## 📞 联系方式

### 讨论渠道
- **GitHub Discussions**: 项目讨论
- **Issues**: 问题报告
- **Pull Requests**: 代码贡献

### 维护者联系
- **Email**: maintainer@xdao.com
- **GitHub**: @maintainer

## ⚠️ 注意事项

### 法律声明
- 贡献的代码将采用 MIT 许可证
- 请确保您有权贡献代码
- 不要包含受版权保护的内容

### 安全提醒
- 不要提交私钥或敏感信息
- 安全漏洞请通过安全邮箱报告
- 遵循负责任的披露原则

## 🎉 感谢

感谢所有为项目做出贡献的开发者！您的贡献让项目变得更好。

---

**贡献指南版本**: v1.0  
**最后更新**: 2024年
