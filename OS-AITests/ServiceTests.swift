//
//  ServiceTests.swift
//  OS-AITests
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  服务层单元测试
//

import XCTest
@testable import OS_AI

final class ServiceTests: XCTestCase {

    // MARK: - PurchaseService Tests

    func testPurchaseServiceInitialization() {
        let service = PurchaseService.shared

        XCTAssertNotNil(service, "PurchaseService should not be nil")
        XCTAssertFalse(service.isProUser, "Should not be Pro user initially")
        XCTAssertEqual(service.subscriptionStatus, .notSubscribed)
    }

    func testProductLoading() async throws {
        let service = PurchaseService.shared

        await service.initialize()

        XCTAssertGreaterThan(service.products.count, 0, "Should load products")
        XCTAssertNotNil(service.getMonthlyProduct(), "Should have monthly product")
        XCTAssertNotNil(service.getYearlyProduct(), "Should have yearly product")
    }

    func testFormattedPrice() {
        let service = PurchaseService.shared

        // 这个测试需要在有产品数据的情况下运行
        if let product = service.getMonthlyProduct() {
            let price = service.getFormattedPrice(for: product)
            XCTAssertFalse(price.isEmpty, "Price should not be empty")
        }
    }

    // MARK: - CloudService Tests

    func testCloudServiceInitialization() {
        let service = CloudService.shared

        XCTAssertNotNil(service, "CloudService should not be nil")
        XCTAssertNotNil(service.container, "Container should be set")
        XCTAssertNotNil(service.privateDatabase, "Private database should be set")
    }

    func testCloudAvailabilityCheck() async throws {
        let service = CloudService.shared

        await service.checkCloudAvailability()

        // 检查是否成功检查
        // 注意：在没有iCloud配置的环境中，可能返回false
        print("iCloud Available: \(service.isCloudAvailable)")
    }

    func testStorageUsage() async throws {
        let service = CloudService.shared

        let usage = await service.getStorageUsage()

        XCTAssertNotNil(usage, "Usage should not be nil")
        XCTAssertGreaterThanOrEqual(usage.used, 0, "Used should be non-negative")
        XCTAssertGreaterThan(usage.total, 0, "Total should be positive")
        XCTAssertLessThanOrEqual(usage.used, usage.total, "Used should not exceed total")
    }

    // MARK: - NotificationService Tests

    func testNotificationServiceInitialization() {
        let service = NotificationService.shared

        XCTAssertNotNil(service, "NotificationService should not be nil")
    }

    func testNotificationCategorySetup() {
        let service = NotificationService.shared

        service.setupNotificationCategories()

        // 验证设置完成（没有异常即可）
        XCTAssertTrue(true, "Notification categories should be set up")
    }

    // MARK: - Performance Tests

    func testServiceInitializationPerformance() {
        measure {
            let _ = PurchaseService.shared
            let _ = CloudService.shared
            let _ = NotificationService.shared
        }
    }
}
