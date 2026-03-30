//
//  LocalizationAdapter.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  本地化适配器 - 全球场景适配
//

import Foundation
import CoreLocation

/// 本地化适配器
/// 根据用户所在地区自动适配服务、合规、支付体系
actor LocalizationAdapter {

    // MARK: - Properties
    private var currentRegion: String
    private var currentLanguage: String
    private var currentCurrency: String

    // MARK: - Service Mappings
    private let regionalServiceMappings: [String: RegionalServices] = [
        "CN": RegionalServices(
            delivery: ["顺丰快递", "中通快递", "圆通快递", "韵达快递", "申通快递"],
            ride: ["滴滴出行", "高德打车", "美团打车"],
            map: ["高德地图", "百度地图"],
            hotel: ["携程酒店", "飞猪酒店", "美团酒店"],
            airline: ["中国国航", "东方航空", "南方航空", "海南航空"],
            payment: ["支付宝", "微信支付", "银联"]
        ),
        "US": RegionalServices(
            delivery: ["FedEx", "UPS", "USPS", "Amazon Logistics"],
            ride: ["Uber", "Lyft"],
            map: ["Google Maps", "Apple Maps"],
            hotel: ["Booking.com", "Expedia", "Hotels.com"],
            airline: ["American Airlines", "Delta", "United", "Southwest"],
            payment: ["Apple Pay", "Visa", "Mastercard", "PayPal"]
        ),
        "GB": RegionalServices(
            delivery: ["Royal Mail", "DPD", "Hermes", "Yodel"],
            ride: ["Uber", "Bolt"],
            map: ["Google Maps", "Apple Maps"],
            hotel: ["Booking.com", "Expedia", "Hotels.com"],
            airline: ["British Airways", "easyJet", "Ryanair", "Virgin Atlantic"],
            payment: ["Apple Pay", "Visa", "Mastercard"]
        ),
        "JP": RegionalServices(
            delivery: ["佐川急便", "ヤマト運輸", "日本郵政", "西濃運輸"],
            ride: ["Uber", "DiDi"],
            map: ["Google Maps", "Yahoo!カーナビ"],
            hotel: ["楽天トラベル", "じゃらんnet", "一休.com"],
            airline: ["全日空", "日本航空", " Peach", "ジェットスター・ジャパン"],
            payment: ["PayPay", "LINE Pay", "Apple Pay", "楽天ペイ"]
        ),
        "DE": RegionalServices(
            delivery: ["DHL", "Hermes", "DPD", "GLS"],
            ride: ["Uber", "Bolt", "Freenow"],
            map: ["Google Maps", "Apple Maps"],
            hotel: ["Booking.com", "Expedia", "HRS"],
            airline: ["Lufthansa", "Eurowings", "Condor", "Ryanair"],
            payment: ["Apple Pay", "PayPal", "SEPA"]
        ),
        "FR": RegionalServices(
            delivery: ["La Poste", "Chronopost", "Colissimo", "DPD"],
            ride: ["Uber", "Bolt", "Marcel"],
            map: ["Google Maps", "Apple Maps"],
            hotel: ["Booking.com", "Expedia", "Accor"],
            airline: ["Air France", "easyJet", "Transavia", "Ryanair"],
            payment: ["Apple Pay", "PayPal", "Carte Bleue"]
        )
    ]

    // MARK: - Currency Mappings
    private let currencyMappings: [String: String] = [
        "CN": "CNY",
        "US": "USD",
        "GB": "GBP",
        "JP": "JPY",
        "DE": "EUR",
        "FR": "EUR",
        "KR": "KRW",
        "SG": "SGD",
        "AU": "AUD",
        "CA": "CAD"
    ]

    // MARK: - Language Mappings
    private let languageMappings: [String: String] = [
        "zh-Hans": "CN",
        "zh-Hant": "TW",
        "en-US": "US",
        "en-GB": "GB",
        "ja": "JP",
        "ko": "KR",
        "de": "DE",
        "fr": "FR",
        "es": "ES",
        "it": "IT",
        "pt-BR": "BR"
    ]

    // MARK: - Initialization
    init() {
        let locale = Locale.current
        self.currentRegion = locale.region?.identifier ?? "CN"
        self.currentLanguage = locale.language.languageCode?.identifier ?? "zh-Hans"
        self.currentCurrency = currencyMappings[currentRegion] ?? "CNY"
    }

    // MARK: - Public Methods

    /// 初始化
    func initialize() async {
        print("✅ LocalizationAdapter initialized")
        print("📍 Current Region: \(currentRegion)")
        print("🌐 Current Language: \(currentLanguage)")
        print("💰 Current Currency: \(currentCurrency)")
    }

    /// 更新本地化设置
    /// - Parameter region: 新的地区代码
    func updateRegion(_ region: String) {
        self.currentRegion = region
        if let currency = currencyMappings[region] {
            self.currentCurrency = currency
        }
    }

    /// 更新语言设置
    /// - Parameter language: 新的语言代码
    func updateLanguage(_ language: String) {
        self.currentLanguage = language
        if let region = languageMappings[language] {
            self.currentRegion = region
        }
    }

    /// 获取当前地区的服务列表
    func getRegionalServices() -> RegionalServices {
        return regionalServiceMappings[currentRegion] ?? RegionalServices()
    }

    /// 获取特定类型的服务
    /// - Parameter type: 服务类型
    /// - Returns: 服务提供商列表
    func getServices(ofType type: ServiceType) -> [String] {
        let services = getRegionalServices()
        switch type {
        case .delivery:
            return services.delivery
        case .ride:
            return services.ride
        case .map:
            return services.map
        case .hotel:
            return services.hotel
        case .airline:
            return services.airline
        case .payment:
            return services.payment
        }
    }

    /// 获取建议
    /// - Parameters:
    ///   - emotion: 用户情绪状态
    ///   - preferences: 用户偏好
    ///   - location: 用户位置
    /// - Returns: 建议列表
    func getSuggestions(
        emotion: EmotionState,
        preferences: UserPreference?,
        location: CLLocation?
    ) async -> [Suggestion] {
        var suggestions: [Suggestion] = []

        switch emotion {
        case .highPressure:
            // 高压状态：推荐放松场所
            suggestions += getRelaxationSuggestions()

        case .relaxed:
            // 休闲状态：推荐娱乐活动
            suggestions += getEntertainmentSuggestions(location: location)

        case .low:
            // 低落状态：推荐社交活动
            suggestions += getSocialSuggestions()

        case .neutral:
            // 中性状态：推荐日常生活建议
            suggestions += getDailySuggestions(preferences: preferences)
        }

        return suggestions
    }

    /// 获取服务跳转URL
    /// - Parameters:
    ///   - serviceType: 服务类型
    ///   - serviceName: 服务名称
    ///   - parameters: 跳转参数
    /// - Returns: URL
    func getServiceURL(
        for serviceType: ServiceType,
        serviceName: String,
        parameters: [String: Any]
    ) -> URL? {
        // 根据服务类型和服务名称生成对应的URL
        // 这里需要实现具体的URL生成逻辑
        return nil
    }

    /// 获取格式化的金额
    /// - Parameter amount: 金额数值
    /// - Returns: 格式化后的字符串
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currentCurrency
        formatter.locale = Locale(identifier: currentLanguage)
        return formatter.string(from: NSNumber(value: amount)) ?? ""
    }

    /// 检查合规要求
    /// - Parameter region: 地区代码
    /// - Returns: 合规要求
    func getComplianceRequirements(for region: String) -> ComplianceRequirements {
        switch region {
        case "CN":
            return ComplianceRequirements(
                needRealNameAuth: true,
                needPhoneVerification: true,
                dataLocalizationRequired: true,
                minAge: 18
            )
        case "US", "GB":
            return ComplianceRequirements(
                needRealNameAuth: false,
                needPhoneVerification: false,
                dataLocalizationRequired: false,
                minAge: 13
            )
        case "JP", "KR":
            return ComplianceRequirements(
                needRealNameAuth: true,
                needPhoneVerification: true,
                dataLocalizationRequired: false,
                minAge: 18
            )
        default:
            return ComplianceRequirements()
        }
    }

    /// 更新本地化
    func updateLocalization() async {
        // 定期检查用户的地区和语言设置
        // 更新本地化配置
    }

    // MARK: - Private Methods

    private func getRelaxationSuggestions() -> [Suggestion] {
        let services = getRegionalServices()
        return [
            Suggestion(
                type: .relaxation,
                title: "放松一下",
                description: "推荐您去附近的公园或咖啡厅休息",
                action: nil
            )
        ]
    }

    private func getEntertainmentSuggestions(location: CLLocation?) -> [Suggestion] {
        return [
            Suggestion(
                type: .entertainment,
                title: "休闲时光",
                description: "推荐您去看电影或展览",
                action: nil
            )
        ]
    }

    private func getSocialSuggestions() -> [Suggestion] {
        return [
            Suggestion(
                type: .social,
                title: "社交聚会",
                description: "约上朋友一起吃饭聊天吧",
                action: nil
            )
        ]
    }

    private func getDailySuggestions(preferences: UserPreference?) -> [Suggestion] {
        return [
            Suggestion(
                type: .task,
                title: "今日待办",
                description: "查看今天的待办事项",
                action: nil
            )
        ]
    }
}

// MARK: - Supporting Types

struct RegionalServices {
    var delivery: [String] = []
    var ride: [String] = []
    var map: [String] = []
    var hotel: [String] = []
    var airline: [String] = []
    var payment: [String] = []
}

enum ServiceType {
    case delivery
    case ride
    case map
    case hotel
    case airline
    case payment
}

struct ComplianceRequirements {
    var needRealNameAuth: Bool = false
    var needPhoneVerification: Bool = false
    var dataLocalizationRequired: Bool = false
    var minAge: Int = 0
}
