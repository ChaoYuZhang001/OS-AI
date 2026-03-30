//
//  BehaviorLearner.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  行为学习器 - 学习用户习惯和偏好
//

import Foundation
import SwiftData

/// 行为学习器
/// 端侧学习用户行为模式，实现个性化推荐
actor BehaviorLearner {

    // MARK: - Properties
    private var behaviorRecords: [BehaviorRecord] = []
    private var userPreferences: UserPreference?
    private var context: ModelContext?

    // MARK: - Initialization
    init() {}

    // MARK: - Public Methods

    /// 初始化
    func initialize() async {
        print("✅ BehaviorLearner initialized")
    }

    /// 设置数据上下文
    func setContext(_ context: ModelContext) {
        self.context = context
    }

    /// 记录用户行为
    /// - Parameters:
    ///   - input: 用户输入
    ///   - intent: 识别出的意图
    ///   - result: 执行结果
    func recordBehavior(input: String, intent: Intent, result: OSAIResult) async {
        let record = BehaviorRecord(
            id: UUID(),
            input: input,
            intent: String(describing: intent),
            success: result.success,
            timestamp: Date()
        )

        behaviorRecords.append(record)

        // 保持最近100条记录
        if behaviorRecords.count > 100 {
            behaviorRecords.removeFirst()
        }

        // 保存到数据库
        await saveBehaviorRecord(record)
    }

    /// 获取用户偏好
    /// - Returns: 用户偏好
    func getUserPreferences() async -> UserPreference? {
        if let existingPreferences = userPreferences {
            return existingPreferences
        }

        // 从数据库加载
        if let context = context {
            let fetchDescriptor = FetchDescriptor<UserPreference>()
            if let preferences = try? context.fetch(fetchDescriptor).first {
                self.userPreferences = preferences
                return preferences
            }
        }

        // 创建默认偏好
        let defaultPreferences = UserPreference.createDefault()
        self.userPreferences = defaultPreferences
        return defaultPreferences
    }

    /// 更新用户偏好
    /// - Parameter preferences: 新的偏好设置
    func updateUserPreferences(_ preferences: UserPreference) async {
        self.userPreferences = preferences
        await saveUserPreferences(preferences)
    }

    /// 学习出行习惯
    func learnTravelHabits(from record: BehaviorRecord) async {
        // 提取出行相关信息
        // 学习用户常选的座位、车型、航司、酒店品牌
    }

    /// 学习饮食偏好
    func learnDietaryPreferences(from record: BehaviorRecord) async {
        // 提取饮食相关信息
        // 学习用户忌口、口味、常去餐厅
    }

    /// 学习时间节奏
    func learnTimePatterns(from records: [BehaviorRecord]) async {
        // 分析用户的作息时间
        // 学习起床、通勤、午休时间
    }

    /// 同步行为数据到iCloud
    func syncBehaviors() async {
        guard let context = context else { return }

        do {
            try context.save()
            print("✅ Behaviors synced to iCloud")
        } catch {
            print("❌ Failed to sync behaviors: \(error)")
        }
    }

    /// 预测用户可能的需求
    func predictNextActions() async -> [Intent] {
        // 基于历史行为预测用户的下一步操作
        return []
    }

    // MARK: - Private Methods

    private func saveBehaviorRecord(_ record: BehaviorRecord) async {
        guard let context = context else { return }

        context.insert(record)

        do {
            try context.save()
        } catch {
            print("❌ Failed to save behavior record: \(error)")
        }
    }

    private func saveUserPreferences(_ preferences: UserPreference) async {
        guard let context = context else { return }

        // 如果已存在则更新，否则插入
        if let existing = try? context.fetch(FetchDescriptor<UserPreference>()).first {
            // 更新现有记录
            existing.update(from: preferences)
        } else {
            // 插入新记录
            context.insert(preferences)
        }

        do {
            try context.save()
        } catch {
            print("❌ Failed to save user preferences: \(error)")
        }
    }

    // MARK: - Analytics

    /// 分析行为模式
    func analyzeBehaviorPatterns() async -> BehaviorPattern {
        let pattern = BehaviorPattern()

        // 分析最常用的意图
        let intentCounts = Dictionary(grouping: behaviorRecords, by: { $0.intent })
            .mapValues { $0.count }

        pattern.mostUsedIntents = intentCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }

        // 分析使用时间段
        let hourCounts = Dictionary(grouping: behaviorRecords, by: {
            Calendar.current.component(.hour, from: $0.timestamp)
        }).mapValues { $0.count }

        pattern.peakUsageHours = hourCounts
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }

        return pattern
    }
}

// MARK: - Supporting Types

struct BehaviorPattern {
    var mostUsedIntents: [String] = []
    var peakUsageHours: [Int] = []
    var avgSuccessRate: Double = 0.0
}

// MARK: - SwiftData Models

@Model
final class BehaviorRecord {
    var id: UUID
    var input: String
    var intent: String
    var success: Bool
    var timestamp: Date

    init(id: UUID = UUID(), input: String, intent: String, success: Bool, timestamp: Date = Date()) {
        self.id = id
        self.input = input
        self.intent = intent
        self.success = success
        self.timestamp = timestamp
    }
}

@Model
final class UserPreference {
    var id: UUID
    var preferredLanguage: String
    var preferredCurrency: String
    var travelPreferences: TravelPreferences
    var dietaryPreferences: DietaryPreferences
    var timePreferences: TimePreferences
    var notificationPreferences: NotificationPreferences
    var socialPreferences: SocialPreferences
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        preferredLanguage: String = "zh-Hans",
        preferredCurrency: String = "CNY",
        travelPreferences: TravelPreferences,
        dietaryPreferences: DietaryPreferences,
        timePreferences: TimePreferences,
        notificationPreferences: NotificationPreferences,
        socialPreferences: SocialPreferences,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.preferredLanguage = preferredLanguage
        self.preferredCurrency = preferredCurrency
        self.travelPreferences = travelPreferences
        self.dietaryPreferences = dietaryPreferences
        self.timePreferences = timePreferences
        self.notificationPreferences = notificationPreferences
        self.socialPreferences = socialPreferences
        self.updatedAt = updatedAt
    }

    static func createDefault() -> UserPreference {
        return UserPreference(
            travelPreferences: TravelPreferences(),
            dietaryPreferences: DietaryPreferences(),
            timePreferences: TimePreferences(),
            notificationPreferences: NotificationPreferences(),
            socialPreferences: SocialPreferences()
        )
    }

    func update(from preferences: UserPreference) {
        self.preferredLanguage = preferences.preferredLanguage
        self.preferredCurrency = preferences.preferredCurrency
        self.travelPreferences = preferences.travelPreferences
        self.dietaryPreferences = preferences.dietaryPreferences
        self.timePreferences = preferences.timePreferences
        self.notificationPreferences = preferences.notificationPreferences
        self.socialPreferences = preferences.socialPreferences
        self.updatedAt = Date()
    }
}

@Model
final class TravelPreferences {
    var preferredAirlines: [String]
    var preferredSeatType: String
    var preferredHotelChains: [String]
    var preferredCarTypes: [String]
    var frequentDestinations: [String]

    init(
        preferredAirlines: [String] = [],
        preferredSeatType: String = "经济舱",
        preferredHotelChains: [String] = [],
        preferredCarTypes: [String] = [],
        frequentDestinations: [String] = []
    ) {
        self.preferredAirlines = preferredAirlines
        self.preferredSeatType = preferredSeatType
        self.preferredHotelChains = preferredHotelChains
        self.preferredCarTypes = preferredCarTypes
        self.frequentDestinations = frequentDestinations
    }
}

@Model
final class DietaryPreferences {
    var allergies: [String]
    var dietaryRestrictions: [String]
    var cuisinePreferences: [String]
    var spicyTolerance: Int // 0-10
    var frequentRestaurants: [String]

    init(
        allergies: [String] = [],
        dietaryRestrictions: [String] = [],
        cuisinePreferences: [String] = [],
        spicyTolerance: Int = 5,
        frequentRestaurants: [String] = []
    ) {
        self.allergies = allergies
        self.dietaryRestrictions = dietaryRestrictions
        self.cuisinePreferences = cuisinePreferences
        self.spicyTolerance = spicyTolerance
        self.frequentRestaurants = frequentRestaurants
    }
}

@Model
final class TimePreferences {
    var wakeUpTime: Date
    var sleepTime: Date
    var workStartTime: Date
    var workEndTime: Date
    var commuteDuration: TimeInterval // in seconds
    var lunchStartTime: Date

    init(
        wakeUpTime: Date = Date(),
        sleepTime: Date = Date(),
        workStartTime: Date = Date(),
        workEndTime: Date = Date(),
        commuteDuration: TimeInterval = 1800,
        lunchStartTime: Date = Date()
    ) {
        self.wakeUpTime = wakeUpTime
        self.sleepTime = sleepTime
        self.workStartTime = workStartTime
        self.workEndTime = workEndTime
        self.commuteDuration = commuteDuration
        self.lunchStartTime = lunchStartTime
    }
}

@Model
final class NotificationPreferences {
    var quietHoursStart: Date
    var quietHoursEnd: Date
    var enabledCategories: [String]
    var notificationFrequency: String

    init(
        quietHoursStart: Date = Date(),
        quietHoursEnd: Date = Date(),
        enabledCategories: [String] = ["all"],
        notificationFrequency: String = "normal"
    ) {
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
        self.enabledCategories = enabledCategories
        self.notificationFrequency = notificationFrequency
    }
}

@Model
final class SocialPreferences {
    var familyMembers: [String]
    var closeFriends: [String]
    var socialComfortLevel: Int // 0-10
    var preferredGatherings: [String]
    var culturalTaboos: [String]

    init(
        familyMembers: [String] = [],
        closeFriends: [String] = [],
        socialComfortLevel: Int = 5,
        preferredGatherings: [String] = [],
        culturalTaboos: [String] = []
    ) {
        self.familyMembers = familyMembers
        self.closeFriends = closeFriends
        self.socialComfortLevel = socialComfortLevel
        self.preferredGatherings = preferredGatherings
        self.culturalTaboos = culturalTaboos
    }
}
