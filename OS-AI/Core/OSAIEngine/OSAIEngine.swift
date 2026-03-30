//
//  OSAIEngine.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  OS-AI核心引擎 - 原生智能数字生活合伙人
//

import Foundation
import SwiftData
import EventKit
import HealthKit
import CoreLocation
import NaturalLanguage

/// OS-AI核心引擎
/// 负责处理所有智能决策、意图识别、情绪感知、行为学习
@MainActor
final class OSAIEngine: ObservableObject {

    // MARK: - Singleton
    static let shared = OSAIEngine()

    // MARK: - Published Properties
    @Published var isInitialized = false
    @Published var isProcessing = false
    @Published var engineStatus: EngineStatus = .idle
    @Published var currentEmotion: EmotionState = .neutral
    @Published var currentLocation: CLLocation?

    // MARK: - Private Properties
    private var intentProcessor: IntentProcessor
    private var emotionAnalyzer: EmotionAnalyzer
    private var behaviorLearner: BehaviorLearner
    private var localizationAdapter: LocalizationAdapter

    private var backgroundTask: Task<Void, Never>?
    private let queue = DispatchQueue(label: "com.osai.engine.queue", qos: .userInitiated)

    // MARK: - Initialization
    private init() {
        self.intentProcessor = IntentProcessor()
        self.emotionAnalyzer = EmotionAnalyzer()
        self.behaviorLearner = BehaviorLearner()
        self.localizationAdapter = LocalizationAdapter()
    }

    // MARK: - Public Methods

    /// 初始化引擎
    func initialize() async {
        guard !isInitialized else { return }

        engineStatus = .initializing

        // 初始化各个子模块
        await intentProcessor.initialize()
        await emotionAnalyzer.initialize()
        await behaviorLearner.initialize()
        await localizationAdapter.initialize()

        // 启动后台任务
        startBackgroundTask()

        isInitialized = true
        engineStatus = .idle

        print("✅ OS-AI Engine initialized successfully")
    }

    /// 处理用户自然语言指令
    /// - Parameter text: 用户输入的自然语言文本
    /// - Returns: 处理结果
    func processNaturalLanguageInput(_ text: String) async -> OSAIResult {
        isProcessing = true
        engineStatus = .processing

        defer {
            isProcessing = false
            engineStatus = .idle
        }

        do {
            // 1. 识别用户意图
            let intent = await intentProcessor.recognizeIntent(from: text)

            // 2. 提取关键信息
            let entities = await intentProcessor.extractEntities(from: text, intent: intent)

            // 3. 执行意图
            let result = await executeIntent(intent, entities: entities)

            // 4. 记录行为用于学习
            await behaviorLearner.recordBehavior(
                input: text,
                intent: intent,
                result: result
            )

            return result
        } catch {
            print("❌ Failed to process natural language: \(error)")
            return OSAIResult.error(error.localizedDescription)
        }
    }

    /// 执行后台同步任务
    func performBackgroundSync() async {
        await behaviorLearner.syncBehaviors()
        await localizationAdapter.updateLocalization()
    }

    /// 更新当前位置
    func updateLocation(_ location: CLLocation) {
        self.currentLocation = location
        Task {
            await intentProcessor.updateContext(location: location)
        }
    }

    /// 获取当前情绪状态
    func getCurrentEmotion() async -> EmotionState {
        return await emotionAnalyzer.analyzeCurrentEmotion()
    }

    /// 获取个性化建议
    func getPersonalizedSuggestions() async -> [Suggestion] {
        let emotion = await getCurrentEmotion()
        let preferences = await behaviorLearner.getUserPreferences()
        let location = currentLocation

        return await localizationAdapter.getSuggestions(
            emotion: emotion,
            preferences: preferences,
            location: location
        )
    }

    // MARK: - Private Methods

    private func startBackgroundTask() {
        backgroundTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30 * 60 * 1_000_000_000) // 30分钟

                // 定期分析情绪
                let emotion = await emotionAnalyzer.analyzeCurrentEmotion()
                self.currentEmotion = emotion

                // 定期同步行为数据
                await behaviorLearner.syncBehaviors()
            }
        }
    }

    private func executeIntent(_ intent: Intent, entities: [Entity]) async -> OSAIResult {
        switch intent {
        case .createTodo:
            return await executeCreateTodoIntent(entities: entities)
        case .createCalendarEvent:
            return await executeCreateCalendarEventIntent(entities: entities)
        case .checkDelivery:
            return await executeCheckDeliveryIntent(entities: entities)
        case .payBill:
            return await executePayBillIntent(entities: entities)
        case .planTravel:
            return await executePlanTravelIntent(entities: entities)
        case .processContent:
            return await executeProcessContentIntent(entities: entities)
        case .unknown:
            return OSAIResult.error("无法识别您的意图，请重新描述")
        }
    }

    // MARK: - Intent Execution Methods

    private func executeCreateTodoIntent(entities: [Entity]) async -> OSAIResult {
        guard let content = entities.first(where: { $0.type == .text })?.value else {
            return OSAIResult.error("无法识别待办事项内容")
        }

        let dueDate = entities.first(where: { $0.type == .date })?.dateValue
        let location = entities.first(where: { $0.type == .location })?.locationValue

        // 创建待办事项
        let todo = TodoItem(
            content: content,
            dueDate: dueDate,
            location: location,
            isCompleted: false
        )

        // 保存到SwiftData
        // 这里需要访问ModelContext，实际使用时从环境获取

        return OSAIResult.success(
            message: "已为您创建待办事项：\(content)",
            data: todo
        )
    }

    private func executeCreateCalendarEventIntent(entities: [Entity]) async -> OSAIResult {
        guard let title = entities.first(where: { $0.type == .text })?.value else {
            return OSAIResult.error("无法识别日程标题")
        }

        let startDate = entities.first(where: { $0.type == .date })?.dateValue ?? Date()
        let location = entities.first(where: { $0.type == .location })?.locationValue

        let event = CalendarEvent(
            title: title,
            startDate: startDate,
            endDate: startDate.addingTimeInterval(3600),
            location: location
        )

        return OSAIResult.success(
            message: "已为您创建日程：\(title)",
            data: event
        )
    }

    private func executeCheckDeliveryIntent(entities: [Entity]) async -> OSAIResult {
        // 快递查询逻辑
        return OSAIResult.success(message: "快递查询功能正在开发中")
    }

    private func executePayBillIntent(entities: [Entity]) async -> OSAIResult {
        // 缴费逻辑
        return OSAIResult.success(message: "缴费功能正在开发中")
    }

    private func executePlanTravelIntent(entities: [Entity]) async -> OSAIResult {
        // 出行规划逻辑
        return OSAIResult.success(message: "出行规划功能正在开发中")
    }

    private func executeProcessContentIntent(entities: [Entity]) async -> OSAIResult {
        // 内容处理逻辑
        return OSAIResult.success(message: "内容处理功能正在开发中")
    }
}

// MARK: - Supporting Types

enum EngineStatus {
    case idle
    case initializing
    case processing
    case error(String)
}

enum EmotionState {
    case neutral      // 中性
    case highPressure // 高压
    case relaxed      // 休闲
    case low          // 低落

    var description: String {
        switch self {
        case .neutral: return "正常状态"
        case .highPressure: return "高压状态"
        case .relaxed: return "休闲状态"
        case .low: return "低落状态"
        }
    }
}

enum Intent {
    case createTodo
    case createCalendarEvent
    case checkDelivery
    case payBill
    case planTravel
    case processContent
    case unknown
}

struct Entity {
    let type: EntityType
    let value: String

    var dateValue: Date? {
        return ISO8601DateFormatter().date(from: value)
    }

    var locationValue: CLLocation? {
        // 解析位置信息
        return nil
    }
}

enum EntityType {
    case text
    case date
    case time
    case location
    case person
    case amount
}

struct OSAIResult {
    let success: Bool
    let message: String
    let data: Any?

    static func success(message: String, data: Any? = nil) -> OSAIResult {
        return OSAIResult(success: true, message: message, data: data)
    }

    static func error(_ message: String) -> OSAIResult {
        return OSAIResult(success: false, message: message, data: nil)
    }
}

struct Suggestion {
    let type: SuggestionType
    let title: String
    let description: String
    let action: (() -> Void)?
}

enum SuggestionType {
    case relaxation
    case social
    case task
    case travel
    case entertainment
}
