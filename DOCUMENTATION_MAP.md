# Documentation Map / 文档导航

## 📚 Documentation Structure / 文档结构

This repository contains comprehensive documentation for choosing and using RK3399 boards. Here's how to navigate:

本仓库包含RK3399板卡选择和使用的完整文档。导航指南如下：

### �� Quick Start / 快速开始

| Document | Purpose | Time to Read | Audience |
|----------|---------|--------------|----------|
| [QUICK_GUIDE.md](QUICK_GUIDE.md) | 30-second board selection | 5 min | Beginners, Quick Decision |
| [README.md](README.md) | Project overview & quick start | 10 min | All users |

### 📊 Technical Comparison / 技术对比

| Document | Purpose | Time to Read | Audience |
|----------|---------|--------------|----------|
| [COMPARISON.md](COMPARISON.md) | Detailed board comparison | 15-20 min | Developers, Technical |
| [CHANGES.md](CHANGES.md) | Android to Linux conversion | 5 min | Developers |

### 🔧 Integration Guides / 集成指南

| Document | Purpose | Time to Read | Audience |
|----------|---------|--------------|----------|
| [ARMBIAN_INTEGRATION.md](ARMBIAN_INTEGRATION.md) | Armbian setup guide | 15 min | Armbian users |
| [BUILD_INTEGRATION.md](BUILD_INTEGRATION.md) | Build system integration | 20 min | Advanced users |

## 🗺️ Document Flow / 文档流程

```
Start Here / 从这里开始
    ↓
README.md (Overview)
    ↓
    ├─→ [Need Quick Decision?] → QUICK_GUIDE.md (30 sec)
    │                                ↓
    │                           [Choose Board]
    │                                ↓
    ├─→ [Need Technical Details?] → COMPARISON.md (15 min)
    │                                ↓
    │                          [Understand Differences]
    │                                ↓
    └─→ [Ready to Install?] → ARMBIAN_INTEGRATION.md
                              BUILD_INTEGRATION.md
                                    ↓
                              [Start Building!]
```

## 📖 Documentation Summary / 文档摘要

### QUICK_GUIDE.md (227 lines, 7KB)
**Chinese Only / 仅中文**

快速决策指南：
- ⚡ 30秒决策树
- 📊 对比表格
- 💡 5个实际案例
- ❓ 常见问题解答
- 🎯 应用场景推荐

### COMPARISON.md (694 lines, 20KB)
**Bilingual: Chinese + English / 双语：中英文**

完整技术对比：
- 📋 10个详细对比章节
- 🔍 逐组件分析
- 💻 硬件规格
- 🔧 电源管理
- 📡 GPIO和引脚
- 🚀 迁移指南
- 📖 参考资源

### ARMBIAN_INTEGRATION.md (254 lines, 6KB)
**Chinese with English sections / 中文为主含英文**

Armbian集成指南：
- 安装步骤
- 内核配置
- WiFi/蓝牙固件
- 驱动验证
- 故障排除

### BUILD_INTEGRATION.md (391 lines, 10KB)
**Chinese + English / 中英文**

构建系统集成：
- 构建脚本
- GitHub Actions
- Makefile使用
- 自定义配置
- 故障排除

### README.md (311 lines, 9KB)
**Bilingual: Chinese + English / 双语：中英文**

项目总览：
- 硬件支持列表
- 快速开始指南
- 文件说明
- 集成方式
- WiFi配置

### CHANGES.md (122 lines, 3KB)
**English / 英文**

转换记录：
- Android到Linux的变更
- 兼容性调整
- 编译说明
- 测试验证

## 🎯 Usage Scenarios / 使用场景

### Scenario 1: "I just want to choose a board quickly"
### 场景1："我只想快速选择一个板卡"

```
README.md → QUICK_GUIDE.md
⏱️ Total time: 10 minutes
```

### Scenario 2: "I need to understand technical differences"
### 场景2："我需要了解技术差异"

```
README.md → COMPARISON.md
⏱️ Total time: 25 minutes
```

### Scenario 3: "I want to install Armbian"
### 场景3："我想安装Armbian"

```
README.md → QUICK_GUIDE.md → ARMBIAN_INTEGRATION.md
⏱️ Total time: 30 minutes
```

### Scenario 4: "I want to build custom firmware"
### 场景4："我想构建自定义固件"

```
README.md → COMPARISON.md → BUILD_INTEGRATION.md
⏱️ Total time: 45 minutes
```

### Scenario 5: "I'm migrating from Android"
### 场景5："我从Android迁移过来"

```
README.md → CHANGES.md → COMPARISON.md → ARMBIAN_INTEGRATION.md
⏱️ Total time: 50 minutes
```

## 📊 Documentation Statistics / 文档统计

| Metric | Value |
|--------|-------|
| Total Documentation Files | 6 |
| Total Lines | 1,999 |
| Total Size | ~54 KB |
| Languages | Chinese + English |
| Sections Covered | 30+ |
| Code Examples | 50+ |
| Comparison Tables | 20+ |
| Use Cases | 10+ |

## 🌟 Key Features / 核心特性

✅ **Comprehensive** / 全面：涵盖从选择到部署的全流程
✅ **Bilingual** / 双语：中英文支持
✅ **Practical** / 实用：包含真实案例和常见问题
✅ **Structured** / 结构化：清晰的文档层次
✅ **Up-to-date** / 及时更新：保持最新信息

## 🔗 Quick Links / 快速链接

| I want to... | Go to... |
|--------------|----------|
| Choose a board in 30 seconds | [QUICK_GUIDE.md](QUICK_GUIDE.md) |
| Compare boards in detail | [COMPARISON.md](COMPARISON.md) |
| Install Armbian | [ARMBIAN_INTEGRATION.md](ARMBIAN_INTEGRATION.md) |
| Build firmware | [BUILD_INTEGRATION.md](BUILD_INTEGRATION.md) |
| Understand changes | [CHANGES.md](CHANGES.md) |
| Get started | [README.md](README.md) |

## 📞 Need Help? / 需要帮助？

1. Check the relevant documentation above
2. Search existing issues
3. Create a new issue
4. Reference similar projects (Fine3399, etc.)

---

**Total Documentation**: 1,999 lines across 6 files covering board selection, technical comparison, and integration guides in both Chinese and English.

**文档总览**：6个文件共1,999行，涵盖板卡选择、技术对比和集成指南，支持中英文双语。
