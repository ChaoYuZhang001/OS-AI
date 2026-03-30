//
//  OSAIUITests.swift
//  OS-AIUITests
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  UI测试
//

import XCTest
@testable import OS_AI

final class OSAIUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments += ["-uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Launch Tests

    func testAppLaunch() {
        // 测试应用启动
        XCTAssertTrue(app.exists, "App should be launched")

        // 验证主界面存在
        XCTAssertTrue(app.navigationBars.firstMatch.exists, "Should have navigation bar")
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Should have tab bar")
    }

    // MARK: - Tab Navigation Tests

    func testTabBarNavigation() {
        // 验证所有tab存在
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")

        // 测试切换tab
        // 首页
        XCTAssertTrue(tabBar.buttons["首页"].exists)
        tabBar.buttons["首页"].tap()

        // 待办
        XCTAssertTrue(tabBar.buttons["待办"].exists)
        tabBar.buttons["待办"].tap()

        // 日程
        XCTAssertTrue(tabBar.buttons["日程"].exists)
        tabBar.buttons["日程"].tap()

        // 快递
        XCTAssertTrue(tabBar.buttons["快递"].exists)
        tabBar.buttons["快递"].tap()

        // 我的
        XCTAssertTrue(tabBar.buttons["我的"].exists)
        tabBar.buttons["我的"].tap()
    }

    // MARK: - Home View Tests

    func testHomeViewElements() {
        // 切换到首页
        app.tabBars.firstMatch.buttons["首页"].tap()

        // 验证主要元素存在
        XCTAssertTrue(app.navigationBars.firstMatch.staticTexts["果效 | OS-AI"].exists, "Should show app title")

        // 验证AI助手输入框
        XCTAssertTrue(app.textFields.containing(NSPredicate(format: "placeholder CONTAINS %@", "想帮你做什么")).firstMatch.exists)

        // 验证快捷功能按钮
        XCTAssertTrue(app.buttons["创建待办"].exists)
        XCTAssertTrue(app.buttons["添加日程"].exists)
        XCTAssertTrue(app.buttons["查快递"].exists)
        XCTAssertTrue(app.buttons["扫描文档"].exists)
    }

    func testAIAssistantInput() {
        // 切换到首页
        app.tabBars.firstMatch.buttons["首页"].tap()

        // 找到输入框
        let inputField = app.textFields.containing(NSPredicate(format: "placeholder CONTAINS %@", "想帮你做什么")).firstMatch
        XCTAssertTrue(inputField.exists)

        // 输入文本
        inputField.tap()
        inputField.typeText("提醒我明天下午3点开会")

        // 点击发送按钮
        let sendButton = app.buttons.matching(identifier: "arrow.up.circle.fill").firstMatch
        XCTAssertTrue(sendButton.exists)
        sendButton.tap()

        // 等待处理结果
        let result = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "已为您创建")).firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 5), "Should show processing result")
    }

    // MARK: - Todo View Tests

    func testTodoViewElements() {
        // 切换到待办tab
        app.tabBars.firstMatch.buttons["待办"].tap()

        // 验证导航标题
        XCTAssertTrue(app.navigationBars.firstMatch.staticTexts["待办事项"].exists)

        // 验证添加按钮
        XCTAssertTrue(app.navigationBars.buttons.matching(identifier: "plus").exists)

        // 验证搜索栏
        XCTAssertTrue(app.searchFields.firstMatch.exists)
    }

    func testCreateTodo() {
        // 切换到待办tab
        app.tabBars.firstMatch.buttons["待办"].tap()

        // 点击添加按钮
        app.navigationBars.buttons["plus"].tap()

        // 验证添加页面打开
        XCTAssertTrue(app.alerts.firstMatch.exists || app.navigationBars.staticTexts["添加待办"].exists)

        // 如果是sheet，输入待办内容
        if app.alerts.firstMatch.exists {
            let textField = app.alerts.firstMatch.textFields.firstMatch
            textField.tap()
            textField.typeText("测试待办事项")

            // 点击添加
            app.alerts.firstMatch.buttons["添加"].tap()
        } else {
            // 如果是导航页面
            let textField = app.textFields.element(boundBy: 0)
            textField.tap()
            textField.typeText("测试待办事项")

            app.navigationBars.buttons["添加"].tap()
        }

        // 验证待办已创建
        XCTAssertTrue(app.staticTexts["测试待办事项"].exists)
    }

    // MARK: - Profile View Tests

    func testProfileViewElements() {
        // 切换到我的tab
        app.tabBars.firstMatch.buttons["我的"].tap()

        // 验证导航标题
        XCTAssertTrue(app.navigationBars.firstMatch.staticTexts["我的"].exists)

        // 验证用户信息
        XCTAssertTrue(app.staticTexts["果效用户"].exists)

        // 验证订阅部分
        XCTAssertTrue(app.staticTexts["Pro会员"].exists || app.staticTexts["免费用户"].exists)

        // 验证设置部分
        XCTAssertTrue(app.cells.staticTexts["通用设置"].exists)
        XCTAssertTrue(app.cells.staticTexts["通知设置"].exists)
        XCTAssertTrue(app.cells.staticTexts["云同步"].exists)
    }

    // MARK: - Onboarding Tests

    func testOnboardingFlow() {
        // 清除onboarding标记
        UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaults.hasCompletedOnboarding)
        app.launch()

        // 验证引导页显示
        let startButton = app.buttons["开始使用"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 3), "Should show onboarding start button")

        // 点击开始使用
        startButton.tap()

        // 验证主界面显示
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Should show main app after onboarding")
    }

    // MARK: - Purchase View Tests

    func testPurchaseFlow() {
        // 切换到我的tab
        app.tabBars.firstMatch.buttons["我的"].tap()

        // 点击升级到Pro
        let upgradeButton = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "升级")).firstMatch
        if upgradeButton.exists {
            upgradeButton.tap()

            // 验证购买页面显示
            XCTAssertTrue(app.navigationBars.staticTexts["升级到Pro"].exists || app.navigationBars.staticTexts["Pro会员"].exists)
        }
    }

    // MARK: - Navigation Tests

    func testBackNavigation() {
        // 从我的tab切换回首页
        app.tabBars.firstMatch.buttons["我的"].tap()
        app.tabBars.firstMatch.buttons["首页"].tap()

        // 验证返回首页
        XCTAssertTrue(app.staticTexts["我是你的AI生活助手"].exists || app.staticTexts["果效 | OS-AI"].exists)
    }

    // MARK: - Performance Tests

    func testTabSwitchPerformance() {
        measure {
            app.tabBars.firstMatch.buttons["首页"].tap()
            app.tabBars.firstMatch.buttons["待办"].tap()
            app.tabBars.firstMatch.buttons["日程"].tap()
            app.tabBars.firstMatch.buttons["快递"].tap()
            app.tabBars.firstMatch.buttons["我的"].tap()
        }
    }
}
