//
//  SiriIntegration.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  Siri集成 - 基于App Intents的Siri深度集成
//

import Foundation
import AppIntents
import SwiftData
import EventKit

// MARK: - Create Todo Intent

/// 创建待办事项Intent
struct CreateTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "创建待办事项"
    static var description = IntentDescription("创建一个新的待办事项")

    static var openAppWhenRun: Bool = false

    // 参数
    @Parameter(title: "内容")
    var content: String

    @Parameter(title: "截止日期")
    var dueDate: Date?

    @Parameter(title: "位置")
    var location: String?

    // 分类
    static var parameterSummary: some ParameterSummary {
        Summary("创建待办：\(\.$content)") {
            \.$dueDate
            \.$location
        }
    }

    // 执行
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<TodoItem> {
        // 创建待办事项
        let todo = TodoItem(
            content: content,
            dueDate: dueDate,
            location: location,
            isCompleted: false
        )

        // 保存到数据库
        // 这里需要访问ModelContext，实际使用时从环境获取

        // 返回结果
        return .result(value: todo, dialog: "已为您创建待办事项：\(content)")
    }
}

// MARK: - Create Calendar Event Intent

/// 创建日程Intent
struct CreateCalendarEventIntent: AppIntent {
    static var title: LocalizedStringResource = "创建日程"
    static var description = IntentDescription("创建一个新的日程事件")

    static var openAppWhenRun: Bool = false

    // 参数
    @Parameter(title: "标题")
    var title: String

    @Parameter(title: "开始时间")
    var startDate: Date

    @Parameter(title: "结束时间")
    var endDate: Date?

    @Parameter(title: "地点")
    var location: String?

    // 分类
    static var parameterSummary: some ParameterSummary {
        Summary("创建日程：\(\.$title)") {
            \.$startDate
            \.$endDate
            \.$location
        }
    }

    // 执行
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<CalendarEvent> {
        let end = endDate ?? startDate.addingTimeInterval(3600)

        // 创建日程
        let event = CalendarEvent(
            title: title,
            startDate: startDate,
            endDate: end,
            location: location
        )

        // 保存到数据库和系统日历
        // 这里需要访问ModelContext和EventKit

        // 返回结果
        return .result(value: event, dialog: "已为您创建日程：\(title)")
    }
}

// MARK: - Check Delivery Intent

/// 查询快递Intent
struct CheckDeliveryIntent: AppIntent {
    static var title: LocalizedStringResource = "查询快递"
    static var description = IntentDescription("查询快递状态")

    static var openAppWhenRun: Bool = false

    // 参数
    @Parameter(title: "快递单号")
    var trackingNumber: String

    @Parameter(title: "快递公司")
    var carrier: String?

    // 分类
    static var parameterSummary: some ParameterSummary {
        Summary("查询快递：\(\.$trackingNumber)") {
            \.$carrier
        }
    }

    // 执行
    @MainActor
    func perform() async throws -> some IntentResult {
        // 查询快递状态
        // 这里需要调用快递API

        return .result(dialog: "快递查询功能正在开发中")
    }
}

// MARK: - OSAI Assistant Intent (Pro版专属)

/// OS-AI助手Intent - Pro版专属的深度Siri集成
@available(iOS 18.0, *)
struct OSAIAssistantIntent: AppIntent {
    static var title: LocalizedStringResource = "果效助手"
    static var description = IntentDescription("使用果效AI助手处理您的请求")
    static var authenticationPolicy = .requiresAuthentication

    static var openAppWhenRun: Bool = false

    // 参数
    @Parameter(title: "您的请求")
    var request: String

    // 分类
    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$request)")
    }

    // 执行
    @MainActor
    func perform() async throws -> some IntentResult {
        // 调用OS-AI引擎处理请求
        let engine = OSAIEngine.shared
        let result = await engine.processNaturalLanguageInput(request)

        return .result(dialog: result.message)
    }
}

// MARK: - OSAI Assistant Entity (用于实体识别)

/// OS-AI助手实体
@available(iOS 18.0, *)
struct OSAIAssistantEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "果效助手")

    static var defaultQuery = OSAIAssistantEntityQuery()

    var id: String
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "果效助手")
    }

    init(id: String) {
        self.id = id
    }
}

@available(iOS 18.0, *)
struct OSAIAssistantEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [OSAIAssistantEntity] {
        return identifiers.map { OSAIAssistantEntity(id: $0) }
    }

    func suggestedEntities() async throws -> [OSAIAssistantEntity] {
        return [OSAIAssistantEntity(id: "osai_assistant")]
    }
}

// MARK: - OSAI Shortcut App Intent (快捷指令)

/// OS-AI快捷指令Intent
@available(iOS 18.0, *)
struct OSAIShortcutIntent: AppIntent {
    static var title: LocalizedStringResource = "果效快捷指令"
    static var description = IntentDescription("使用果效快捷指令")

    static var openAppWhenRun: Bool = false

    // 参数
    @Parameter(title: "指令类型")
    var shortcutType: OSAIShortcutType

    @Parameter(title: "参数")
    var parameters: String?

    // 执行
    @MainActor
    func perform() async throws -> some IntentResult {
        switch shortcutType {
        case .createTodo:
            // 创建待办
            return .result(dialog: "快捷指令：创建待办")

        case .createEvent:
            // 创建日程
            return .result(dialog: "快捷指令：创建日程")

        case .checkDelivery:
            // 查询快递
            return .result(dialog: "快捷指令：查询快递")

        case .payBill:
            // 缴费
            return .result(dialog: "快捷指令：缴费")

        case .processContent:
            // 处理内容
            return .result(dialog: "快捷指令：处理内容")
        }
    }
}

/// 果效快捷指令类型
enum OSAIShortcutType: String, AppEnum {
    case createTodo = "创建待办"
    case createEvent = "创建日程"
    case checkDelivery = "查询快递"
    case payBill = "缴费"
    case processContent = "处理内容"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "快捷指令类型")

    static var caseDisplayRepresentations: [OSAIShortcutType: DisplayRepresentation] = [
        .createTodo: "创建待办",
        .createEvent: "创建日程",
        .checkDelivery: "查询快递",
        .payBill: "缴费",
        .processContent: "处理内容"
    ]
}

// MARK: - OSAI Widget Intent (小组件)

/// OS-AI小组件Intent
@available(iOS 18.0, *)
struct OSAIWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "果效小组件"
    static var description = IntentDescription("显示果效小组件")

    static var openAppWhenRun: Bool = true

    // 执行
    @MainActor
    func perform() async throws -> some IntentResult {
        // 打开App
        return .result()
    }
}

// MARK: - Siri Configuration

/// Siri配置类
@available(iOS 18.0, *)
@MainActor
final class SiriConfiguration {

    static let shared = SiriConfiguration()

    private init() {}

    /// 注册所有Siri快捷指令
    func registerAllShortcuts() {
        // 快捷指令会在用户首次使用时自动注册
        // 这里可以添加一些默认的快捷指令
        registerDefaultShortcuts()
    }

    /// 注册默认快捷指令
    private func registerDefaultShortcuts() {
        // 创建默认的快捷指令
        let createTodoShortcut = INShortcut(intent: CreateTodoIntent())
        let createEventShortcut = INShortcut(intent: CreateCalendarEventIntent())
        let checkDeliveryShortcut = INShortcut(intent: CheckDeliveryIntent())

        // 保存到系统
        INVoiceShortcutCenter.shared.setShortcutSuggestions([createTodoShortcut, createEventShortcut, checkDeliveryShortcut])
    }

    /// 设置Siri建议
    func setupSiriSuggestions() {
        // 设置Siri建议
        let suggestions = [
            INShortcut(intent: CreateTodoIntent()),
            INShortcut(intent: CreateCalendarEventIntent()),
            INShortcut(intent: CheckDeliveryIntent())
        ]

        INVoiceShortcutCenter.shared.setShortcutSuggestions(suggestions)
    }

    /// 获取可用的快捷指令
    func getAvailableShortcuts() -> [INVoiceShortcut] {
        // 获取所有快捷指令
        // 这里需要实现实际的获取逻辑
        return []
    }

    /// 创建自定义快捷指令
    func createCustomShortcut(intent: AppIntent, invocationPhrase: String) async throws -> INVoiceShortcut {
        let shortcut = INShortcut(intent: intent)
        let voiceShortcut = INVoiceShortcut(invocationPhrase: INPhrase(utterance: invocationPhrase), shortcut: shortcut)

        try await INVoiceShortcutCenter.shared.addShortcut(voiceShortcut)
        return voiceShortcut
    }
}

// MARK: - Siri Helper Functions

extension SiriConfiguration {

    /// 检查Siri权限
    func checkSiriAuthorization() -> Bool {
        return INPreferences.siriAuthorizationStatus() == .authorized
    }

    /// 请求Siri权限
    func requestSiriAuthorization() async -> Bool {
        return await INPreferences.requestSiriAuthorization() == .authorized
    }

    /// 语音识别
    func transcribe(audioURL: URL) async throws -> String {
        // 使用Apple的语音识别API
        // 这里需要实现实际的语音识别逻辑
        return ""
    }
}

// MARK: - Siri Integration Manager

/// Siri集成管理器
@MainActor
final class SiriIntegrationManager: ObservableObject {

    static let shared = SiriIntegrationManager()

    @Published var isSiriAuthorized = false
    @Published var availableShortcuts: [String] = []

    private init() {
        checkSiriStatus()
    }

    /// 检查Siri状态
    private func checkSiriStatus() {
        isSiriAuthorized = INPreferences.siriAuthorizationStatus() == .authorized
    }

    /// 配置Siri
    func configure() async {
        // 检查权限
        let authorized = await INPreferences.requestSiriAuthorization()
        isSiriAuthorized = (authorized == .authorized)

        if isSiriAuthorized {
            // 注册快捷指令
            SiriConfiguration.shared.registerAllShortcuts()

            // 设置建议
            SiriConfiguration.shared.setupSiriSuggestions()

            print("✅ Siri configured successfully")
        } else {
            print("❌ Siri authorization denied")
        }
    }

    /// 处理Siri语音指令
    func handleVoiceCommand(_ command: String) async -> String {
        // 调用OS-AI引擎处理
        let engine = OSAIEngine.shared
        let result = await engine.processNaturalLanguageInput(command)
        return result.message
    }
}

// MARK: - EventKit Integration Helper

/// EventKit集成辅助类
@MainActor
final class EventKitIntegration {

    static let shared = EventKitIntegration()

    private let eventStore = EKEventStore()

    private init() {}

    /// 请求日历权限
    func requestCalendarAuthorization() async -> Bool {
        return await withCheckedContinuation { continuation in
            eventStore.requestFullAccessToEvents { granted, error in
                if granted {
                    print("✅ Calendar access granted")
                } else {
                    print("❌ Calendar access denied: \(error?.localizedDescription ?? "")")
                }
                continuation.resume(returning: granted)
            }
        }
    }

    /// 创建系统日历事件
    func createCalendarEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        location: String?,
        notes: String?
    ) throws {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = location
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents

        try eventStore.save(event, span: .thisEvent)
        print("✅ Calendar event created: \(title)")
    }

    /// 获取日历事件
    func getEvents(startDate: Date, endDate: Date) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        return eventStore.events(matching: predicate)
    }
}
