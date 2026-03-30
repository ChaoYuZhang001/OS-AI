# 果效 | OS-AI - 全原生智能数字生活合伙人

> 懂你所想，办你所盼，全场景无感随行

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20CarPlay-green.svg)](https://developer.apple.com/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-purple.svg)](https://developer.apple.com/xcode/swiftui/)

## 🌟 项目简介

果效 | OS-AI 是全球首款由独立开发者打造、基于苹果全生态原生能力开发的端侧AI数字生活合伙人。

### 核心特色

- **🧠 端侧AI优先** - 核心能力100%在设备本地运行，零隐私数据上传
- **🔒 隐私安全至上** - 开发者零接触用户数据，端对端加密
- **🌍 全球原生适配** - 自动适配155+国家和地区服务
- **📱 全苹果设备协同** - 一套代码适配iPhone、iPad、Mac、Apple Watch、CarPlay
- **🎯 情绪感知智能** - 基于健康数据感知用户状态，主动适配服务

## 🚀 技术栈

- **开发语言**: Swift 6.0
- **UI框架**: SwiftUI 5.0
- **数据存储**: SwiftData + CloudKit
- **AI引擎**: Apple Intelligence + Core ML + Natural Language
- **系统集成**: App Intents (Siri), HealthKit, EventKit, Core Location
- **支付**: StoreKit 2 (内购订阅)

## 📋 功能模块

### 免费版功能
- ✅ 自然语言待办/日程管理
- ✅ 全球快递智能查询
- ✅ 全球便民缴费中枢
- ✅ 全球出行一键调度
- ✅ 端侧原生AI内容处理
- ✅ 基础Siri语音调用

### Pro版功能
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
- ⭐ **自动化模板市场**
- ⭐ **苹果家庭共享**（最多6人）

## 📁 项目结构

```
OS-AI/
├── OS-AI.xcodeproj/          # Xcode项目文件
├── OS-AI/                    # 主应用源码
│   ├── App/                  # 应用入口
│   │   ├── OSAIApp.swift
│   │   └── AppConfiguration.swift
│   ├── Core/                 # 核心引擎
│   │   ├── OSAIEngine/       # OS-AI引擎
│   │   │   ├── OSAIEngine.swift
│   │   │   ├── IntentProcessor.swift
│   │   │   ├── EmotionAnalyzer.swift
│   │   │   ├── BehaviorLearner.swift
│   │   │   └── LocalizationAdapter.swift
│   │   ├── SystemIntegration/  # 系统集成
│   │   └── DeviceManager/      # 设备管理
│   ├── Features/             # 功能模块
│   │   ├── TodoModule/
│   │   ├── CalendarModule/
│   │   ├── DeliveryModule/
│   │   ├── PaymentModule/
│   │   ├── TravelModule/
│   │   └── ContentProcessingModule/
│   ├── Services/             # 服务层
│   │   ├── PurchaseService.swift
│   │   ├── CloudService.swift
│   │   ├── NotificationService.swift
│   │   ├── LocalizationService.swift
│   │   └── AnalyticsService.swift
│   ├── Resources/            # 资源文件
│   │   ├── Models/
│   │   │   └── DataModels.swift
│   │   ├── Views/
│   │   │   └── ContentView.swift
│   │   ├── Assets.xcassets/
│   │   └── Localizable.xcstrings/
│   └── Supporting Files/     # 支持文件
├── OS-AITests/               # 单元测试
├── OS-AIUITests/             # UI测试
├── Docs/                     # 文档
│   ├── PROJECT_STRUCTURE.md
│   ├── API.md
│   └── DEVELOPMENT.md
└── README.md                 # 项目说明
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
│  (Todo / Calendar / Delivery / ...)     │
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

### 数据流

```
用户输入
    ↓
IntentProcessor (意图识别 + 实体提取)
    ↓
OSAIEngine (核心决策引擎)
    ↓
EmotionAnalyzer (情绪感知)
    ↓
BehaviorLearner (个性化适配)
    ↓
LocalizationAdapter (地区服务适配)
    ↓
功能执行
    ↓
SwiftData存储 + CloudKit同步
```

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

### 4. 运行项目

选择模拟器或真机，点击 ▶️ 运行

## 📦 构建与部署

### 开发版构建

```bash
# 命令行构建
xcodebuild -project OS-AI.xcodeproj \
  -scheme OS-AI \
  -configuration Debug \
  -sdk iphonesimulator
```

### 发布版构建

```bash
xcodebuild -project OS-AI.xcodeproj \
  -scheme OS-AI \
  -configuration Release \
  -sdk iphoneos \
  -archivePath OS-AI.xcarchive \
  archive
```

### App Store 上传

```bash
xcodebuild -exportArchive \
  -archivePath OS-AI.xcarchive \
  -exportPath ./export \
  -exportOptionsPlist ExportOptions.plist
```

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
- Email: [待补充]

## 🗺️ 路线图

### v1.0 (2026年Q4)
- [x] 基础架构搭建
- [x] 核心引擎实现
- [x] 主要功能开发
- [ ] iOS版首发
- [ ] App Store全球上架

### v1.1 (2027年Q1)
- [ ] iPad/Mac优化
- [ ] Apple Watch独立App
- [ ] CarPlay适配
- [ ] 更多语言支持

### v1.2 (2027年Q2)
- [ ] 自动化模板市场
- [ ] 用户社区功能
- [ ] 性能优化
- [ ] Bug修复

### v2.0 (2027年Q3)
- [ ] 更高级的AI能力
- [ ] 多人协作功能
- [ ] 企业版功能
- [ ] 第三方平台集成

## 📊 项目进度

- [ ] 项目初始化
- [ ] 核心引擎开发
- [ ] 功能模块开发
- [ ] UI界面开发
- [ ] 单元测试
- [ ] UI测试
- [ ] 性能优化
- [ ] 国际化
- [ ] 文档完善
- [ ] App Store审核准备

---

**果效 | OS-AI** - 懂你所想，办你所盼，全场景无感随行 🌾
