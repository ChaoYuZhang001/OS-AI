//
//  ThirdPartyIntegration.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  第三方平台集成 - 数据模型
//

import Foundation
import SwiftData

@Model
final class ThirdPartyService {
    var id: UUID
    var name: String
    var displayName: String
    var description: String
    var icon: String
    var category: ServiceCategory
    var isEnabled: Bool
    var apiKey: String?
    var apiSecret: String?
    var configuration: [String: String]
    var features: [ServiceFeature]
    var rateLimit: RateLimit?
    var lastSyncedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        displayName: String,
        description: String,
        icon: String,
        category: ServiceCategory,
        isEnabled: Bool = false,
        apiKey: String? = nil,
        apiSecret: String? = nil,
        configuration: [String: String] = [:],
        features: [ServiceFeature] = [],
        rateLimit: RateLimit? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.description = description
        self.icon = icon
        self.category = category
        self.isEnabled = isEnabled
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.configuration = configuration
        self.features = features
        self.rateLimit = rateLimit
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum ServiceCategory: String, Codable {
    case delivery = "快递"
    case payment = "支付"
    case travel = "出行"
    case social = "社交"
    case entertainment = "娱乐"
    case productivity = "效率"
    case finance = "金融"

    var icon: String {
        switch self {
        case .delivery: return "box.truck.fill"
        case .payment: return "creditcard.fill"
        case .travel: return "airplane"
        case .social: return "person.2.fill"
        case .entertainment: return "sparkles"
        case .productivity: return "checkmark.circle.fill"
        case .finance: return "dollarsign.circle.fill"
        }
    }
}

struct ServiceFeature: Codable {
    var id: String
    var name: String
    var description: String
    var isEnabled: Bool
    var requiresAuth: Bool

    init(id: String, name: String, description: String, isEnabled: Bool = true, requiresAuth: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.isEnabled = isEnabled
        self.requiresAuth = requiresAuth
    }
}

struct RateLimit: Codable {
    var maxRequests: Int
    var timeWindow: TimeInterval // 秒
    var currentRequests: Int
    var windowStart: Date

    init(maxRequests: Int = 1000, timeWindow: TimeInterval = 3600) {
        self.maxRequests = maxRequests
        self.timeWindow = timeWindow
        self.currentRequests = 0
        self.windowStart = Date()
    }

    mutating func canMakeRequest() -> Bool {
        let now = Date()

        // 重置计数器
        if now.timeIntervalSince(windowStart) > timeWindow {
            currentRequests = 0
            windowStart = now
        }

        return currentRequests < maxRequests
    }

    mutating func recordRequest() {
        currentRequests += 1
    }
}

@Model
final class IntegrationEvent {
    var id: UUID
    var serviceId: UUID
    var serviceName: String
    var eventType: IntegrationEventType
    var eventDescription: String
    var requestData: [String: Any]
    var responseData: [String: Any]?
    var status: IntegrationStatus
    var errorMessage: String?
    var duration: TimeInterval
    var timestamp: Date

    init(
        id: UUID = UUID(),
        serviceId: UUID,
        serviceName: String,
        eventType: IntegrationEventType,
        eventDescription: String,
        requestData: [String: Any] = [:],
        responseData: [String: Any]? = nil,
        status: IntegrationStatus = .pending,
        errorMessage: String? = nil,
        duration: TimeInterval = 0,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.serviceId = serviceId
        self.serviceName = serviceName
        self.eventType = eventType
        self.eventDescription = eventDescription
        self.requestData = requestData
        self.responseData = responseData
        self.status = status
        self.errorMessage = errorMessage
        self.duration = duration
        self.timestamp = timestamp
    }
}

enum IntegrationEventType: String, Codable {
    case request = "请求"
    case response = "响应"
    case error = "错误"
    case webhook = "Webhook"
}

enum IntegrationStatus: String, Codable {
    case pending = "待处理"
    case success = "成功"
    case failed = "失败"
    case timeout = "超时"
}

// MARK: - Service Adapters

protocol ThirdPartyServiceAdapter {
    var service: ThirdPartyService { get }
    var name: String { get }
    var isConfigured: Bool { get }

    func configure(apiKey: String, configuration: [String: String]) async throws
    func executeAction(_ action: String, parameters: [String: Any]) async throws -> [String: Any]
    func testConnection() async throws -> Bool
}

// MARK: - Delivery Service Adapter

struct DeliveryServiceAdapter: ThirdPartyServiceAdapter {
    var service: ThirdPartyService

    var name: String {
        return service.name
    }

    var isConfigured: Bool {
        return service.apiKey != nil && !service.apiKey!.isEmpty
    }

    func configure(apiKey: String, configuration: [String: String]) async throws {
        service.apiKey = apiKey
        service.configuration = configuration
        service.isEnabled = true
    }

    func executeAction(_ action: String, parameters: [String: Any]) async throws -> [String: Any] {
        switch action {
        case "track":
            return try await trackPackage(parameters)
        case "batchTrack":
            return try await batchTrackPackages(parameters)
        default:
            throw IntegrationError.unsupportedAction(action)
        }
    }

    func testConnection() async throws -> Bool {
        guard isConfigured else {
            throw IntegrationError.notConfigured
        }

        // 模拟测试连接
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
        return true
    }

    private func trackPackage(_ parameters: [String: Any]) async throws -> [String: Any] {
        guard let trackingNumber = parameters["trackingNumber"] as? String else {
            throw IntegrationError.invalidParameters("缺少trackingNumber")
        }

        // 模拟API调用
        return [
            "trackingNumber": trackingNumber,
            "status": "运输中",
            "location": "上海",
            "estimatedDelivery": "2026-04-05"
        ]
    }

    private func batchTrackPackages(_ parameters: [String: Any]) async throws -> [String: Any] {
        guard let trackingNumbers = parameters["trackingNumbers"] as? [String] else {
            throw IntegrationError.invalidParameters("缺少trackingNumbers")
        }

        var results: [[String: Any]] = []

        for number in trackingNumbers {
            let result = try await trackPackage(["trackingNumber": number])
            results.append(result)
        }

        return ["results": results]
    }
}

// MARK: - Payment Service Adapter

struct PaymentServiceAdapter: ThirdPartyServiceAdapter {
    var service: ThirdPartyService

    var name: String {
        return service.name
    }

    var isConfigured: Bool {
        return service.apiKey != nil && !service.apiKey!.isEmpty
    }

    func configure(apiKey: String, configuration: [String: String]) async throws {
        service.apiKey = apiKey
        service.apiSecret = configuration["secret"]
        service.configuration = configuration
        service.isEnabled = true
    }

    func executeAction(_ action: String, parameters: [String: Any]) async throws -> [String: Any] {
        switch action {
        case "queryBill":
            return try await queryBill(parameters)
        case "payBill":
            return try await payBill(parameters)
        default:
            throw IntegrationError.unsupportedAction(action)
        }
    }

    func testConnection() async throws -> Bool {
        guard isConfigured else {
            throw IntegrationError.notConfigured
        }

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return true
    }

    private func queryBill(_ parameters: [String: Any]) async throws -> [String: Any] {
        guard let accountNumber = parameters["accountNumber"] as? String else {
            throw IntegrationError.invalidParameters("缺少accountNumber")
        }

        return [
            "accountNumber": accountNumber,
            "amount": 150.00,
            "dueDate": "2026-04-15",
            "status": "未支付"
        ]
    }

    private func payBill(_ parameters: [String: Any]) async throws -> [String: Any] {
        guard let accountNumber = parameters["accountNumber"] as? String,
              let amount = parameters["amount"] as? Double else {
            throw IntegrationError.invalidParameters("缺少必要参数")
        }

        // 模拟支付
        return [
            "accountNumber": accountNumber,
            "amount": amount,
            "status": "支付成功",
            "transactionId": UUID().uuidString
        ]
    }
}

// MARK: - Errors

enum IntegrationError: Error {
    case notConfigured
    case unsupportedAction(String)
    case invalidParameters(String)
    case apiError(String)
    case timeout
    case networkError

    var localizedDescription: String {
        switch self {
        case .notConfigured:
            return "服务未配置"
        case .unsupportedAction(let action):
            return "不支持的操作: \(action)"
        case .invalidParameters(let message):
            return "参数错误: \(message)"
        case .apiError(let message):
            return "API错误: \(message)"
        case .timeout:
            return "请求超时"
        case .networkError:
            return "网络错误"
        }
    }
}
