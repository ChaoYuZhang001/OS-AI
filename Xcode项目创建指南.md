# Xcode项目创建指南

本指南将指导你如何手动创建OS-AI V3.2.0项目的Xcode项目文件。

## 📋 前置要求

- macOS 15.0+
- Xcode 28.0+
- iOS 27.0+ SDK
- Apple Developer Account（用于真机调试和上架）

## 🚀 创建步骤

### 步骤1：创建新项目

1. 打开Xcode 28.0+
2. 选择 `File` → `New` → `Project...`
3. 选择模板：
   - **iOS** → **App**
4. 填写项目信息：
   ```
   Product Name: OS-AI
   Team: [选择你的开发团队]
   Organization Identifier: com.osai
   Bundle Identifier: com.osai.app
   Language: Swift
   Interface: SwiftUI
   Use Core Data: ✅ 勾选
   Include Tests: ✅ 勾选
   ```

5. 点击 `Next`

### 步骤2：选择项目位置

```
Project Location: /Users/[你的用户名]/Desktop/OS-AI
Add to: [取消勾选]
Create Git repository: ✅ 勾选（可选）
```

6. 点击 `Create`

### 步骤3：删除默认文件

在项目导航器中，删除以下默认生成的文件（保留项目结构）：

**删除文件夹内容：**
- OS-AI/App/ 下的所有文件
- OS-AI/Models/ 下的所有文件（如果有）
- OS-AI/Views/ 下的所有文件
- OS-AITests/
- OS-AIUITests/

**保留：**
- 项目结构
- OS-AI.xcodeproj

### 步骤4：导入源代码

#### 4.1 导入主应用代码

1. 在Finder中，打开 `/tmp/OS-AI/OS-AI/` 目录
2. 将以下文件夹**完整**复制到新项目的 `OS-AI/` 文件夹中：

```
OS-AI/
├── App/                    # 应用入口
├── Core/                   # 核心引擎
├── Features/               # 功能模块
├── Services/               # 服务层
├── Utils/                  # 工具类（V3.1.0+）
└── Resources/              # 资源文件
```

3. 在Xcode中，右键点击 `OS-AI` 文件夹 → `Add Files to "OS-AI"...`
4. 选择复制过来的所有文件夹
5. 勾选 `Copy items if needed`
6. 勾选 `Create groups`
7. 勾选 `Add to targets: OS-AI`
8. 点击 `Add`

#### 4.2 导入测试文件

1. 在Xcode中，右键点击项目 → `New File`
2. 选择 `Unit Test Bundle`
3. 填写：
   ```
   Product Name: OS-AITests
   Team: [你的开发团队]
   Test Target: OS-AI
   ```
4. 点击 `Create`

5. 重复步骤，创建 `OS-AIUITests`

6. 将 `/tmp/OS-AI/OS-AITests/` 和 `/tmp/OS-AI/OS-AIUITests/` 中的测试文件导入到对应的Test Target中

### 步骤5：配置项目设置

#### 5.1 General 设置

1. 选择项目 → TARGETS → OS-AI → `General` 标签

2. **Display Name**：
   ```
   Display Name: OS-AI
   ```

3. **Deployment Info**：
   ```
   iOS Deployment Target: 27.0
   iPhone Orientation: Portrait, Landscape Left, Landscape Right
   iPad Orientation: All supported orientations
   ```

4. **Frameworks, Libraries, and Embedded Content**：
   - 添加 `SwiftData`
   - 添加 `StoreKit`
   - 添加 `CloudKit`
   - 添加 `HealthKit`
   - 添加 `EventKit`
   - 添加 `CoreLocation`
   - 添加 `NaturalLanguage`
   - 添加 `Vision`
   - 添加 `AppIntents`
   - 添加 `CoreML`（V3.2.0新增）

5. **Supported Destinations**：
   - iPhone ✅
   - iPad ✅
   - Mac（Designed for iPad）✅

#### 5.2 Signing & Capabilities

1. 选择 `Signing & Capabilities` 标签
2. **Team**: 选择你的开发团队
3. **Capabilities** - 点击 `+ Capability` 添加以下：

   **必需的Capabilities：**
   - `iCloud` (CloudKit)
     - 勾选 `CloudKit`
     - 点击 `CloudKit` → 选择或创建Container：`iCloud.com.osai.app`

   - `Push Notifications`

   - `Background Modes`
     - 勾选 `Background fetch`
     - 勾选 `Remote notifications`

   - `HealthKit`

   - `Siri` (App Intents)

   **可选的Capabilities：**
   - `In-App Purchase`（StoreKit 2）

#### 5.3 Build Settings

1. 选择 `Build Settings` 标签
2. 搜索以下配置并设置：

   **Swift设置：**
   ```
   Swift Language Version: Swift 6
   Swift Compiler Mode: complete
   Swift Optimisation Level: {-O, -size}
   Swift Strict Concurrency: complete
   ```

   **编译设置：**
   ```
   Enable Modules (C and Objective-C): Yes
   Generate Test Coverage Files: Yes
   Instrument Program Flow: Yes
   ```

   **代码质量：**
   ```
   Analyze During 'Build': Yes
   Static Analyzer: Yes
   ```

#### 5.4 Info 配置

1. 选择 `Info` 标签
2. 确保 `Bundle identifier` 为 `com.osai.app`
3. 确保 `Version` 为 `1.0.0`
4. 确保 `Build` 为 `1`

### 步骤6：配置Info.plist

在 `Info.plist` 中添加以下权限描述（如果没有Info.plist文件，在`Info`标签页中添加自定义键值）：

```xml
<!-- 健康数据权限 -->
<key>NSHealthShareUsageDescription</key>
<string>需要访问您的健康数据来分析您的情绪状态，提供个性化建议</string>

<key>NSHealthUpdateUsageDescription</key>
<string>需要记录您的正念会话</string>

<key>NSHealthClinicalHealthRecordsShareUsageDescription</key>
<string>需要访问您的健康记录来提供更准确的建议</string>

<!-- 日历和提醒 -->
<key>NSCalendarsUsageDescription</key>
<string>需要访问您的日历来管理日程</string>

<key>NSRemindersUsageDescription</key>
<string>需要访问您的提醒事项来创建待办</string>

<!-- 位置权限 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要获取您的位置信息来提供本地化服务</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>需要获取您的位置信息来提供后台服务</string>

<!-- Siri权限 -->
<key>NSSiriUsageDescription</key>
<string>需要Siri权限来提供语音助手服务</string>

<!-- 相机和相册 -->
<key>NSCameraUsageDescription</key>
<string>需要访问相机来扫描文档</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册来选择文档</string>

<!-- Face ID -->
<key>NSFaceIDUsageDescription</key>
<string>需要使用Face ID来保护您的隐私数据</string>
```

### 步骤7：配置Scheme

1. 选择 `Product` → `Scheme` → `Edit Scheme...`

2. **Run** → **Info**：
   ```
   Build Configuration: Debug
   Executable: OS-AI.app
   ```

3. **Test** → **Info**：
   ```
   Build Configuration: Debug
   ```

4. **Profile** → **Info**：
   ```
   Build Configuration: Release
   ```

5. **Analyze** → **Info**：
   ```
   Build Configuration: Debug
   ```

6. **Archive** → **Info**：
   ```
   Build Configuration: Release
   ```

### 步骤8：配置App Intent（Siri集成）

1. 在项目导航器中，找到 `OS-AI/Intents/` 文件夹（如果有）
2. 确保所有Intent文件已导入
3. 在 `Signing & Capabilities` 中确认 `Siri` Capability已启用

### 步骤9：配置数据模型（SwiftData）

1. 在项目导航器中，找到 `DataModels.swift`
2. 确保所有 `@Model` 类正确导入
3. 在 `AppConfiguration.swift` 中验证 `ModelContainer` 配置

```swift
// 确保配置类似这样
let modelContainer: ModelContainer = {
    let schema = Schema([
        TodoItem.self,
        CalendarEvent.self,
        DeliveryPackage.self,
        PaymentBill.self,
        TravelPlan.self,
        ContentTask.self,
        AutomationTemplate.self,
        CommunityPost.self,
        Workspace.self,
        IntegrationService.self
        // 添加其他模型...
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
```

### 步骤10：配置性能优化（V3.2.0）

1. 在 `Build Settings` 中搜索并设置：
   ```
   Enable Testability: Yes (Debug)
   Enable Testability: No (Release)
   ```

2. 在 `Build Phases` → `Compile Sources` 中，确保所有Swift文件都已添加

3. 在 `Build Phases` → `Link Binary With Libraries` 中，确认所有框架已链接

### 步骤11：验证项目结构

确保项目导航器中的文件结构如下：

```
OS-AI/
├── OS-AI/
│   ├── App/
│   │   ├── OSAIApp.swift
│   │   └── AppConfiguration.swift
│   ├── Core/
│   │   ├── OSAIEngine/
│   │   ├── SystemIntegration/
│   │   └── DeviceManager/
│   ├── Features/
│   │   ├── TodoModule/
│   │   ├── CalendarModule/
│   │   ├── DeliveryModule/
│   │   ├── PaymentModule/
│   │   ├── TravelModule/
│   │   ├── ContentProcessingModule/
│   │   ├── AutomationTemplateModule/
│   │   ├── CommunityModule/
│   │   ├── CollaborationModule/
│   │   ├── ThirdPartyIntegrationModule/
│   │   └── ModuleViews.swift
│   ├── Services/
│   │   ├── PurchaseService.swift
│   │   ├── CloudService.swift
│   │   ├── NotificationService.swift
│   │   ├── LocalizationService.swift
│   │   └── AnalyticsService.swift
│   ├── Utils/
│   │   ├── Logger.swift
│   │   ├── Utils.swift
│   │   ├── OSAIError.swift
│   │   ├── PerformanceOptimizer.swift
│   │   └── SwiftDataExtensions.swift
│   ├── Resources/
│   │   ├── Models/
│   │   ├── Views/
│   │   ├── Assets.xcassets/
│   │   └── Localizable.xcstrings/
│   └── Supporting Files/
├── OS-AITests/
│   ├── OSAIEngineTests.swift
│   ├── ServiceTests.swift
│   └── UtilityTests.swift
├── OS-AIUITests/
│   └── OSAIUITests.swift
└── Docs/
```

### 步骤12：编译验证

1. 选择模拟器（建议 iPhone 15 Pro）
2. 点击 `Product` → `Clean Build Folder` (`⇧⌘K`)
3. 点击 ▶️ 运行（或按 `⌘R`）
4. 检查是否有编译错误

## 🐛 常见问题与解决方案

### 问题1：编译错误 - Module not found

**症状**：`No such module 'SwiftData'`

**解决方案**：
1. 检查 `Frameworks, Libraries, and Embedded Content` 中是否已添加SwiftData
2. 选择 `Product` → `Clean Build Folder`
3. 关闭Xcode，删除 `~/Library/Developer/Xcode/DerivedData/OS-AI-*`
4. 重新打开项目并编译

### 问题2：SwiftData模型错误

**症状**：`Type ... has no member 'schema'`

**解决方案**：
1. 确保 `DataModels.swift` 中的所有模型都标记为 `@Model`
2. 检查 `AppConfiguration.swift` 中的 `ModelContainer` 配置
3. 确保 Schema 中包含了所有模型类型

### 问题3：权限错误

**症状**：运行时崩溃，提示权限被拒绝

**解决方案**：
1. 确保Info.plist中的所有权限描述已添加
2. 在真机上运行时，首次启动会弹出权限请求，全部允许
3. 检查 `Signing & Capabilities` 中对应的Capability是否已启用

### 问题4：Signing错误

**症状**：`Code signing is required for product type 'Application'`

**解决方案**：
1. 确保 `Signing & Capabilities` 中已选择Team
2. 检查Bundle Identifier是否唯一（不能与已有App冲突）
3. 如果是免费账号，确保每7天重新签名

### 问题5：UI编译错误

**症状**：`Cannot find type 'XXX' in scope`

**解决方案**：
1. 检查 `ModuleViews.swift` 是否正确导入
2. 确保所有ViewModel文件都在项目中
3. 检查文件是否添加到了正确的Target

### 问题6：性能优化编译警告

**症状**：`Concurrent execution of this code is unsafe`

**解决方案**：
1. 检查Swift 6并发警告
2. 使用 `@MainActor` 标记UI相关代码
3. 使用 `actor` 隔离共享状态
4. 参考代码中的并发模式

### 问题7：测试Target编译失败

**症状**：测试Target无法编译

**解决方案**：
1. 确保测试文件已添加到对应的Test Target
2. 在 `Build Phases` → `Target Dependencies` 中，确保测试Target依赖于主Target
3. 检查测试文件中的导入是否正确

## ✅ 验证清单

### 项目配置
- [ ] iOS Deployment Target设置为27.0
- [ ] Bundle Identifier为com.osai.app
- [ ] Swift Language Version为Swift 6
- [ ] 所有必需的Frameworks已添加
- [ ] 所有必需的Capabilities已启用
- [ ] Info.plist权限描述已添加

### 文件导入
- [ ] 所有源代码文件已导入
- [ ] 所有测试文件已导入
- [ ] 项目结构与文档一致
- [ ] 没有缺失的文件

### 编译验证
- [ ] Debug配置可以编译成功
- [ ] Release配置可以编译成功
- [ ] 没有编译错误
- [ ] 编译警告少于10个（如果有，记录）

### 运行验证
- [ ] 模拟器上可以运行
- [ ] 应用启动成功
- [ ] 主界面显示正常
- [ ] 所有模块可以访问

### 测试验证
- [ ] 单元测试可以运行
- [ ] 至少50%的测试通过
- [ ] UI测试可以运行（可选）

## 🎯 下一步

项目创建并验证完成后，你可以：

1. **功能测试**
   - 逐个测试每个功能模块
   - 验证UI界面是否正常
   - 测试性能优化是否生效

2. **真机调试**
   - 连接iPhone或iPad
   - 在真机上测试所有功能
   - 验证权限请求流程

3. **性能测试**
   - 使用Instruments检测性能瓶颈
   - 测试SwiftData查询性能
   - 监控内存使用情况

4. **国际化测试**
   - 切换系统语言
   - 验证多语言支持

5. **App Store准备**
   - 准备App截图
   - 编写App描述
   - 准备审核材料
   - 配置App Store Connect

## 📚 相关文档

- [README.md](README.md) - 项目总体说明
- [CHANGELOG.md](CHANGELOG.md) - 版本更新记录
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - 架构设计文档
- [部署说明.md](部署说明.md) - 部署指南

## 💡 提示

1. **使用Git版本控制**：创建项目后立即初始化Git仓库
2. **定期提交**：每完成一个阶段就提交代码
3. **备份项目**：在添加重要功能前先备份
4. **阅读错误信息**：编译错误通常会提示具体问题和解决方案
5. **查阅文档**：遇到问题时优先查阅苹果官方文档

---

**备注**：创建Xcode项目文件是必须的步骤，无法通过脚本自动完成。严格按照本指南操作即可成功创建OS-AI V3.2.0项目！

**创建时间**：2026-03-30
**适用版本**：V3.2.0
**作者**：ChaoYu Zhang
