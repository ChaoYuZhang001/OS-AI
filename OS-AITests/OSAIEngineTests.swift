//
//  OSAIEngineTests.swift
//  OS-AITests
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  OS-AI引擎单元测试
//

import XCTest
import SwiftData
@testable import OS_AI

final class OSAIEngineTests: XCTestCase {

    var engine: OSAIEngine!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // 设置测试数据容器
        let schema = Schema([
            TodoItem.self,
            CalendarEvent.self,
            DeliveryItem.self,
            PaymentItem.self,
            UserPreference.self
        ])

        modelContainer = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )

        modelContext = modelContainer.mainContext

        // 初始化引擎
        engine = OSAIEngine.shared

        // 等待引擎初始化
        await engine.initialize()
    }

    override func tearDown() async throws {
        try await super.tearDown()

        // 清理测试数据
        modelContext.deleteAll()
        try modelContext.save()
    }

    // MARK: - Initialization Tests

    func testEngineInitialization() async throws {
        XCTAssertNotNil(engine, "Engine should not be nil")
        XCTAssertTrue(engine.isInitialized, "Engine should be initialized")
        XCTAssertEqual(engine.engineStatus, .idle, "Engine status should be idle after initialization")
    }

    // MARK: - Intent Processing Tests

    func testIntentRecognition() async throws {
        // 测试创建待办意图
        let result = await engine.processNaturalLanguageInput("提醒我明天下午3点开会")

        XCTAssertTrue(result.success, "Should successfully process todo intent")
        XCTAssertTrue(result.message.contains("创建"), "Should mention creating todo")
    }

    func testCalendarIntent() async throws {
        // 测试创建日程意图
        let result = await engine.processNaturalLanguageInput("下周三上午10点有个会议")

        XCTAssertTrue(result.success, "Should successfully process calendar intent")
        XCTAssertTrue(result.message.contains("日程") || result.message.contains("会议"), "Should mention calendar or meeting")
    }

    func testDeliveryIntent() async throws {
        // 测试查询快递意图
        let result = await engine.processNaturalLanguageInput("查一下我的快递")

        XCTAssertTrue(result.success, "Should successfully process delivery intent")
    }

    // MARK: - Entity Extraction Tests

    func testDateExtraction() async throws {
        // 测试日期提取
        let result1 = await engine.processNaturalLanguageInput("明天下午3点开会")
        let result2 = await engine.processNaturalLanguageInput("下周五上午10点")

        XCTAssertTrue(result1.success)
        XCTAssertTrue(result2.success)
    }

    func testLocationExtraction() async throws {
        // 测试位置提取
        let result = await engine.processNaturalLanguageInput("在公司开会")

        XCTAssertTrue(result.success)
    }

    // MARK: - Emotion Analysis Tests

    func testEmotionAnalysis() async throws {
        let emotion = await engine.getCurrentEmotion()

        // 情绪状态应该是有效的枚举值
        let validEmotions: [EmotionState] = [.neutral, .highPressure, .relaxed, .low]
        XCTAssertTrue(validEmotions.contains(emotion), "Emotion should be a valid state")
    }

    // MARK: - Personalization Tests

    func testPersonalizedSuggestions() async throws {
        let suggestions = await engine.getPersonalizedSuggestions()

        // 应该返回建议数组
        XCTAssertTrue(suggestions is [Suggestion], "Should return array of suggestions")
    }

    // MARK: - Location Tests

    func testLocationUpdate() {
        // 测试位置更新
        let location = CLLocation(latitude: 31.2304, longitude: 121.4737)
        engine.updateLocation(location)

        XCTAssertNotNil(engine.currentLocation, "Location should be set")
        XCTAssertEqual(engine.currentLocation?.coordinate.latitude, 31.2304, accuracy: 0.001)
        XCTAssertEqual(engine.currentLocation?.coordinate.longitude, 121.4737, accuracy: 0.001)
    }

    // MARK: - Data Persistence Tests

    func testTodoCreation() async throws {
        // 创建待办事项
        let todo = TodoItem(
            content: "测试待办",
            dueDate: Date(),
            isCompleted: false
        )

        modelContext.insert(todo)
        try modelContext.save()

        // 验证保存
        let fetchDescriptor = FetchDescriptor<TodoItem>()
        let todos = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(todos.count, 1, "Should have one todo")
        XCTAssertEqual(todos.first?.content, "测试待办")
    }

    func testCalendarEventCreation() async throws {
        // 创建日程
        let event = CalendarEvent(
            title: "测试会议",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            location: "会议室"
        )

        modelContext.insert(event)
        try modelContext.save()

        // 验证保存
        let fetchDescriptor = FetchDescriptor<CalendarEvent>()
        let events = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(events.count, 1, "Should have one event")
        XCTAssertEqual(events.first?.title, "测试会议")
    }

    // MARK: - Performance Tests

    func testProcessingPerformance() async throws {
        // 测试处理性能
        measure {
            let expectation = self.expectation(description: "Processing")

            Task {
                let _ = await engine.processNaturalLanguageInput("测试输入")
                expectation.fulfill()
            }

            await fulfillment(of: [expectation], timeout: 1.0)
        }
    }
}
