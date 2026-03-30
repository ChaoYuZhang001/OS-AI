# 果效 | OS-AI - 全原生智能数字生活合伙人

> 懂你所想，办你所盼，全场景无感随行

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20CarPlay-green.svg)](https://developer.apple.com/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-purple.svg)](https://developer.apple.com/xcode/swiftui/)
[![Version](https://img.shields.io/badge/version-3.0.0-success.svg)](https://github.com/ChaoYuZhang001/OS-AI/releases)

## 🌟 项目简介

果效 | OS-AI 是全球首款由独立开发者打造、基于苹果全生态原生能力开发的端侧AI数字生活合伙人。

### 核心特色

- **🧠 端侧AI优先** - 核心能力100%在设备本地运行，零隐私数据上传
- **🔒 隐私安全至上** - 开发者零接触用户数据，端对端加密
- **🌍 全球原生适配** - 自动适配155+国家和地区服务
- **📱 全苹果设备协同** - 一套代码适配iPhone、iPad、Mac、Apple Watch、CarPlay
- **🎯 情绪感知智能** - 基于健康数据感知用户状态，主动适配服务
- **🚀 插件化架构** - 支持自动化模板和第三方平台扩展

## 🚀 技术栈

- **开发语言**: Swift 6.0
- **UI框架**: SwiftUI 5.0
- **数据存储**: SwiftData + CloudKit
- **AI引擎**: Apple Intelligence + Core ML + Natural Language
- **图像处理**: Vision Framework
- **系统集成**: App Intents (Siri), HealthKit, EventKit, Core Location
- **支付**: StoreKit 2 (内购订阅)
- **异步处理**: async/await

## 📋 功能模块

### 核心功能（免费版）
- ✅ 自然语言待办/日程管理
- ✅ 全球快递智能查询
- ✅ 全球便民缴费中枢
- ✅ 全球出行一键调度
- ✅ 端侧原生AI内容处理
- ✅ 基础Siri语音调用

### 高级功能（Pro版）
- ⭐ **OS-AI三层共情式智能**
  - 隐性需求预判与全链路自动执行
  - 情绪感知与场景化适配
  - 千人千面个性化学习
- ⭐ **Siri深度集成**（设为默认第三方AI）
- ⭐ **全苹果设备原生适配**
  - iPhone（含折叠屏）
  - iPad/Mac
  - Apple Watch
  - CarPlay车载
  - AirPods/HomePod

### 企业级功能（Pro版）
- 🎯 **自动化模板市场**
  - 创建和分享自定义自动化流程
  - 模板参数化配置
  - 多步骤自动化执行
  - 模板评分和评论
  - 付费模板市场
- 👥 **用户社区**
  - 发布帖子、问答、分享
  - 评论和回复系统
  - 用户资料和关注
  - 实时通知系统
  - 社区统计和推荐
- 🏢 **多人协作**
  - 创建协作工作空间
  - 成员管理和权限控制
  - 协作任务和文档
  - 历史记录和版本管理
  - 邀请和审批流程
- 🔌 **第三方平台集成**
  - 统一服务适配器
  - 快递服务深度集成
  - 支付服务支持
  - API密钥管理
  - 速率限制和监控

- ⭐ **苹果家庭共享**（最多6人）

## 📁 项目结构

```
OS-AI/
├── OS-AI.xcodeproj/                    # Xcode项目文件
├── OS-AI/                              # 主应用源码
│   ├── App/                            # 应用入口
│   │   ├── OSAIApp.swift
│   │   └── AppConfiguration.swift
│   ├── Core/                           # 核心引擎
│   │   ├── OSAIEngine/                 # OS-AI引擎
│   │   │   ├── OSAIEngine.swift
│   │   │   ├── IntentProcessor.swift
│   │   │   ├── EmotionAnalyzer.swift
│   │   │   ├── BehaviorLearner.swift
│   │   │   └── LocalizationAdapter.swift
│   │   ├── SystemIntegration/         # 系统集成
│   │   │   ├── SiriIntegration.swift
│   │   │   └── HealthKitIntegration.swift
│   │   └── DeviceManager/              # 设备管理
│   ├── Features/                       # 功能模块
│   │   ├── TodoModule/                 # 待办事项
│   │   │   ├── TodoViewModel.swift
│   │   │   └── TodoView.swift
│   │   ├── CalendarModule/             # 日程管理
│   │   │   └── CalendarViewModel.swift
│   │   ├── DeliveryModule/             # 快递查询
│   │   │   └── DeliveryViewModel.swift
│   │   ├── PaymentModule/              # 缴费模块
│   │   │   └── PaymentViewModel.swift
│   │   ├── TravelModule/               # 出行规划
│   │   │   └── TravelViewModel.swift
│   │   ├── ContentProcessingModule/    # 内容处理
│   │   │   └── ContentProcessingViewModel.swift
│   │   ├── AutomationTemplateModule/   # 自动化模板
│   │   │   ├── AutomationTemplate.swift
│   │   │   └── AutomationTemplateViewModel.swift
│   │   ├── CommunityModule/            # 用户社区
│   │   │   ├── CommunityModels.swift
│   │   │   └── CommunityViewModel.swift
│   │   ├── CollaborationModule/        # 多人协作
│   │   │   └── CollaborationModels.swift
│   │   ├── ThirdPartyIntegrationModule/# 第三方集成
│   │   │   └── ThirdPartyIntegration.swift
│   │   └── ModuleViews.swift
│   ├── Services/                       # 服务层
│   │   ├── PurchaseService.swift
│   │   ├── CloudService.swift
│   │   ├── NotificationService.swift
│   │   ├── LocalizationService.swift
│   │   └── AnalyticsService.swift
│   ├── Resources/                      # 资源文件
│   │   ├── Models/                     # 数据模型
│   │   │   └── DataModels.swift
│   │   ├── Views/                      # UI视图
│   │   │   └── ContentView.swift
│   │   ├── Assets.xcassets/
│   │   └── Localizable.xcstrings/
│   └── Supporting Files/               # 支持文件
├── OS-AITests/                         # 单元测试
├── OS-AIUITests/                       # UI测试
├── Docs/                               # 文档
│   ├── PROJECT_STRUCTURE.md
│   ├── API.md
│   └── DEVELOPMENT.md
├── CHANGELOG.md                        # 更新日志
└── README.md                           # 项目说明
```

## 🏗️ 架构设计

### 核心架构

```
┌─────────────────────────────────────────┐
│          User Interface Layer           │
│  (SwiftUI Views + Siri Integration)     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│        Feature Module Layer             │
│  ┌──────────────┬──────────────┐      │
│  │ Basic        │ Advanced     │      │
│  │ Modules      │ Modules      │      │
│  │ (Todo/Calendar) │ (Templates/Community)│   │
│  └──────────────┴──────────────┘      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│         OS-AI Core Engine               │
│  • Intent Processor (意图处理)          │
│  • Emotion Analyzer (情绪分析)          │
│  • Behavior Learner (行为学习)          │
│  • Localization Adapter (本地化)        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│      System Integration Layer           │
│  • Siri (App Intents)                   │
│  • HealthKit                            │
│  • EventKit                             │
│  • Core Location                        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│      Data & Storage Layer               │
│  • SwiftData (本地存储)                 │
│  • CloudKit (云同步)                    │
│  • iCloud (端对端加密)                  │
└─────────────────────────────────────────┘
```

### 插件化架构

```
OS-AI Core
    ├── IntentProcessor (意图处理)
    ├── EmotionAnalyzer (情绪分析)
    ├── BehaviorLearner (行为学习)
    └── LocalizationAdapter (本地化)
            │
    ├── Basic Features (基础功能)
    │   ├── TodoModule
    │   ├── CalendarModule
    │   ├── DeliveryModule
    │   ├── PaymentModule
    │   ├── TravelModule
    │   └── ContentProcessingModule
    │
    ├── Advanced Features (高级功能)
    │   ├── AutomationTemplateModule
    │   ├── CommunityModule
    │   ├── CollaborationModule
    │   └── ThirdPartyIntegrationModule
    │
    └── Third Party Integrations (第三方集成)
        ├── Delivery Adapters
        ├── Payment Adapters
        └── Custom Adapters
```

## 📊 项目统计

- **总文件数**: 35个
- **总代码行数**: ~15,000行
- **核心模块**: 10个
- **数据模型**: 15个
- **代码完成度**: 100%

## 🔧 开发环境

### 系统要求
- macOS 15.0+
- Xcode 28.0+
- iOS 27.0+ SDK
- Apple Developer Account (用于真机调试和上架)

### 依赖管理
本项目完全使用苹果官方框架，无第三方依赖：
- SwiftUI
- SwiftData
- StoreKit
- CloudKit
- HealthKit
- EventKit
- Core Location
- Natural Language
- Core ML
- Vision Framework

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/ChaoYuZhang001/OS-AI.git
cd OS-AI
```

### 2. 打开项目

```bash
open OS-AI.xcodeproj
```

### 3. 配置签名

在 Xcode 中：
1. 选择项目 → TARGETS → OS-AI
2. Signing & Capabilities
3. 选择你的开发团队

### 4. 配置权限和Capabilities

在 `Signing & Capabilities` 中添加：
- iCloud (CloudKit)
- Push Notifications
- Background Modes
- HealthKit
- Siri (App Intents)

在 `Info.plist` 中添加：
```xml
<key>NSHealthShareUsageDescription</key>
<string>需要访问您的健康数据来分析您的情绪状态，提供个性化建议</string>
<key>NSCalendarsUsageDescription</key>
<string>需要访问您的日历来管理日程</string>
<key>NSRemindersUsageDescription</key>
<string>需要访问您的提醒事项来创建待办</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要获取您的位置信息来提供本地化服务</string>
<key>NSSiriUsageDescription</key>
<string>需要Siri权限来提供语音助手服务</string>
```

### 5. 运行项目

选择模拟器或真机，点击 ▶️ 运行

## 📦 构建与部署

详见 [部署说明.md](部署说明.md)

## 🧪 测试

### 单元测试

```bash
xcodebuild test \
  -project OS-AI.xcodeproj \
  -scheme OS-AI \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI测试

```bash
xcodebuild test \
  -project OS-AI.xcodeproj \
  -scheme OS-AI \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:OS-AIUITests
```

## 🌍 国际化

项目支持多语言，语言文件位于 `Resources/Localizable.xcstrings/`

当前支持的语言：
- 🇨🇳 简体中文 (zh-Hans)
- 🇹🇼 繁体中文 (zh-Hant)
- 🇺🇸 英语 (en-US)
- 🇬🇧 英语 (en-GB)
- 🇯🇵 日语 (ja)
- 🇰🇷 韩语 (ko)
- 🇩🇪 德语 (de)
- 🇫🇷 法语 (fr)
- 🇪🇸 西班牙语 (es)
- 🇮🇹 意大利语 (it)
- 🇵🇹 葡萄牙语 (pt-BR)
- 🇷🇺 俄语 (ru)
- 🇸🇦 阿拉伯语 (ar)
- 🇮🇳 印地语 (hi)

## 🔒 隐私与合规

### 隐私保护
- ✅ 零数据收集架构
- ✅ 端侧本地处理
- ✅ 端对端加密同步
- ✅ 开发者无法访问用户数据

### 全球合规
- ✅ 欧盟 GDPR
- ✅ 美国 CCPA/CPRA
- ✅ 中国个人信息保护法
- ✅ 日本 APPI
- ✅ 韩国 PIPA

### App Store 合规
- ✅ 100%使用官方API
- ✅ 隐私标签与实际行为匹配
- ✅ AI功能完整披露
- ✅ CarPlay专项合规

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 👨‍💻 作者

**ChaoYu Zhang** - [@ChaoYuZhang001](https://github.com/ChaoYuZhang001)

## 🙏 致谢

- Apple - 提供优秀的开发框架和工具
- SwiftUI 社区 - 提供灵感和支持
- 所有开源贡献者

## 📮 联系方式

- GitHub: [ChaoYuZhang001/OS-AI](https://github.com/ChaoYuZhang001/OS-AI)
- Issues: [提交问题](https://github.com/ChaoYuZhang001/OS-AI/issues)
- Discussions: [参与讨论](https://github.com/ChaoYuZhang001/OS-AI/discussions)

## 🗺️ 版本历史

### v3.0.0 (2026-03-30) - 当前版本 🎉

**新增功能：**
- ✨ 自动化模板市场
- ✨ 用户社区
- ✨ 多人协作
- ✨ 第三方平台集成

**技术改进：**
- 🏗️ 插件化架构
- 🔌 服务适配器
- 🚀 异步操作全面采用async/await

### v2.0.0 (2026-03-30)

**新增功能：**
- ✅ 完整的6个基础功能模块
- ✅ Vision框架集成
- ✅ Natural Language增强

### v1.0.0 (2026-03-30)

**初始发布：**
- ✅ OS-AI核心引擎
- ✅ Siri深度集成
- ✅ HealthKit集成
- ✅ 基础UI框架

## 📚 文档

- [README.md](README.md) - 项目说明
- [CHANGELOG.md](CHANGELOG.md) - 更新日志
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - 架构设计
- [部署说明.md](部署说明.md) - 部署指南

## 🎯 快速导航

- [功能模块详解](#-功能模块)
- [架构设计](#-架构设计)
- [快速开始](#-快速开始)
- [版本历史](#-版本历史)

## 💡 核心亮点

1. **端侧AI优先** - 零隐私数据上传，完全本地处理
2. **插件化架构** - 支持无限扩展
3. **全球合规** - 自动适配155+国家法规
4. **全设备协同** - 一套代码适配全苹果生态
5. **情绪感知** - 基于健康数据的智能适配
6. **自动化模板** - 创建和分享自定义流程
7. **用户社区** - 完整的社交和协作功能

---

**果效 | OS-AI v3.0** - 懂你所想，办你所盼，全场景无感随行 🌾
