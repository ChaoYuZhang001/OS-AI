//
//  AppConfiguration.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  应用配置
//

import Foundation

/// 应用配置
struct AppConfiguration {

    // MARK: - App Info
    static let appName = "果效 | OS-AI"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    static let bundleIdentifier = "com.osai.app"

    // MARK: - URLs
    static let websiteURL = URL(string: "https://osai.com")!
    static let privacyPolicyURL = URL(string: "https://osai.com/privacy")!
    static let termsOfServiceURL = URL(string: "https://osai.com/terms")!
    static let supportURL = URL(string: "https://osai.com/support")!

    // MARK: - StoreKit Product IDs
    static let proMonthlyProductID = "com.osai.pro.monthly"
    static let proYearlyProductID = "com.osai.pro.yearly"

    // MARK: - Feature Flags
    static let isProFeatureEnabled = true
    static let isSiriIntegrationEnabled = true
    static let isCloudSyncEnabled = true
    static let isHealthKitEnabled = true

    // MARK: - Limits
    static let maxFreeTodos = 50
    static let maxFreeCalendarEvents = 20
    static let maxFreeDeliveryItems = 10
    static let maxFreePaymentItems = 5

    // MARK: - AI Settings
    static let maxIntentContext = 10  // 最大上下文轮数
    static let maxBehaviorRecords = 100 // 最大行为记录数
    static let emotionAnalysisInterval: TimeInterval = 30 * 60 // 30分钟
    static let backgroundSyncInterval: TimeInterval = 60 * 60 // 1小时

    // MARK: - Notification Settings
    static let defaultQuietHoursStart = 22 * 60 * 60 // 22:00
    static let defaultQuietHoursEnd = 8 * 60 * 60  // 8:00
    static let maxPendingNotifications = 64

    // MARK: - Supported Regions
    static let supportedRegions: Set<String> = [
        "CN", "US", "GB", "JP", "KR", "DE", "FR",
        "IT", "ES", "AU", "CA", "SG", "HK", "TW",
        "MY", "TH", "VN", "PH", "ID", "IN", "BR",
        "MX", "AR", "CL", "CO", "PE", "ZA", "EG",
        "SA", "AE", "TR", "RU", "UA", "PL", "SE",
        "NO", "DK", "FI", "NL", "BE", "AT", "CH",
        "CZ", "GR", "PT", "IE", "HU", "RO", "BG"
    ]

    // MARK: - Supported Languages
    static let supportedLanguages: Set<String> = [
        "zh-Hans", "zh-Hant", "en-US", "en-GB",
        "ja", "ko", "de", "fr", "es", "it",
        "pt-BR", "ru", "ar", "hi", "th", "vi"
    ]

    // MARK: - Development Settings
    static let isDebugMode = false
    static let enableLogging = true
    static let logLevel: LogLevel = .info

    // MARK: - Analytics
    static let isAnalyticsEnabled = false // 端侧优先，默认关闭
    static let isCrashReportingEnabled = true

    // MARK: - Environment
    static let environment: Environment = .production

    enum Environment {
        case development
        case staging
        case production

        var apiBaseURL: String {
            switch self {
            case .development:
                return "https://dev-api.osai.com"
            case .staging:
                return "https://staging-api.osai.com"
            case .production:
                return "https://api.osai.com"
            }
        }
    }

    enum LogLevel: Int, Comparable {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3

        static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
}

// MARK: - Feature Limits

struct FeatureLimits {

    // 免费版限制
    static let free = FeatureLimits(
        maxTodos: 50,
        maxCalendarEvents: 20,
        maxDeliveryItems: 10,
        maxPaymentItems: 5,
        maxTravelPlans: 2,
        maxContentProcessingPerDay: 10,
        maxSiriShortcuts: 5,
        maxAutomationTemplates: 0
    )

    // Pro版限制
    static let pro = FeatureLimits(
        maxTodos: .max,
        maxCalendarEvents: .max,
        maxDeliveryItems: .max,
        maxPaymentItems: .max,
        maxTravelPlans: .max,
        maxContentProcessingPerDay: .max,
        maxSiriShortcuts: .max,
        maxAutomationTemplates: .max
    )

    let maxTodos: Int
    let maxCalendarEvents: Int
    let maxDeliveryItems: Int
    let maxPaymentItems: Int
    let maxTravelPlans: Int
    let maxContentProcessingPerDay: Int
    let maxSiriShortcuts: Int
    let maxAutomationTemplates: Int
}
