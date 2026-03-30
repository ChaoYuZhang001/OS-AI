# OS-AI 项目架构设计

## 目录结构

```
OS-AI/
├── OS-AI.xcodeproj/          # Xcode项目文件
├── OS-AI/                    # 主应用源码
│   ├── App/                  # 应用入口
│   ├── Core/                 # 核心引擎
│   ├── Features/             # 功能模块
│   ├── Services/             # 服务层
│   ├── Resources/            # 资源文件
│   ├── Supporting Files/     # 支持文件
│   └── Tests/                # 测试
├── OS-AITests/               # 单元测试
├── OS-AIUITests/             # UI测试
├── Docs/                     # 文档
├── Scripts/                  # 脚本工具
└── README.md                 # 项目说明
```

## 核心模块设计

### 1. App/ - 应用入口
- `OSAIApp.swift` - 应用主入口
- `AppConfiguration.swift` - 应用配置
- `Environment.swift` - 环境变量

### 2. Core/ - 核心引擎
- `OSAIEngine/` - OS-AI核心引擎
  - `OSAIEngine.swift` - 引擎主类
  - `IntentProcessor/` - 意图处理
  - `EmotionAnalyzer/` - 情绪分析
  - `BehaviorLearner/` - 行为学习
  - `LocalizationAdapter/` - 本地化适配
- `SystemIntegration/` - 系统集成
  - `SiriIntegration.swift` - Siri集成
  - `HealthKitIntegration.swift` - 健康数据集成
  - `EventKitIntegration.swift` - 日历集成
  - `LocationIntegration.swift` - 位置服务集成
- `DeviceManager/` - 设备管理
  - `DeviceAdapter.swift` - 设备适配器
  - `SyncManager.swift` - 同步管理器

### 3. Features/ - 功能模块
- `TodoModule/` - 待办事项
- `CalendarModule/` - 日程管理
- `DeliveryModule/` - 快递管理
- `PaymentModule/` - 便民缴费
- `TravelModule/` - 出行调度
- `ContentProcessingModule/` - 内容处理

### 4. Services/ - 服务层
- `PurchaseService.swift` - 内购服务
- `CloudService.swift` - 云服务
- `LocalizationService.swift` - 本地化服务
- `NotificationService.swift` - 通知服务
- `AnalyticsService.swift` - 分析服务

### 5. Resources/ - 资源文件
- `Assets.xcassets/` - 图片资源
- `Localizable.xcstrings/` - 多语言文件
- `Models/` - 数据模型
- `Views/` - SwiftUI视图
