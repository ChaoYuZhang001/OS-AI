//
//  HealthKitIntegration.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  HealthKit集成 - 健康数据访问
//

import Foundation
import HealthKit

/// HealthKit集成
/// 访问用户的健康数据用于情绪分析
@MainActor
final class HealthKitIntegration: ObservableObject {

    // MARK: - Singleton
    static let shared = HealthKitIntegration()

    // MARK: - Published Properties
    @Published var isAuthorized = false
    @Published var healthData: HealthData?

    // MARK: - Private Properties
    private let healthStore = HKHealthStore()

    // MARK: - HealthKit Data Types
    private let dataTypesToRead: Set<HKSampleType> = [
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.categoryType(forIdentifier: .mindfulSession)!
    ]

    private let dataTypesToWrite: Set<HKSampleType> = [
        HKObjectType.categoryType(forIdentifier: .mindfulSession)!
    ]

    // MARK: - Initialization
    private init() {
        checkAvailability()
    }

    // MARK: - Public Methods

    /// 检查HealthKit是否可用
    func checkAvailability() {
        isAuthorized = HKHealthStore.isHealthDataAvailable()
        if !isAuthorized {
            print("❌ HealthKit not available on this device")
        }
    }

    /// 请求权限
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit not available")
            return false
        }

        do {
            try await healthStore.requestAuthorization(toShare: dataTypesToWrite, read: dataTypesToRead)
            isAuthorized = true
            print("✅ HealthKit authorization granted")
            return true
        } catch {
            print("❌ Failed to request HealthKit authorization: \(error)")
            isAuthorized = false
            return false
        }
    }

    /// 获取健康数据摘要
    func fetchHealthDataSummary() async -> HealthData? {
        guard isAuthorized else {
            print("❌ HealthKit not authorized")
            return nil
        }

        async let sleepHours = fetchSleepHours()
        async let avgHeartRate = fetchAverageHeartRate()
        async let stepCount = fetchStepCount()
        async let activeEnergy = fetchActiveEnergyBurned()
        async let restingHeartRate = fetchRestingHeartRate()
        async let hrv = fetchHeartRateVariability()

        let summary = HealthData(
            sleepHours: try? await sleepHours,
            averageHeartRate: try? await avgHeartRate,
            stepCount: try? await stepCount,
            activeEnergyBurned: try? await activeEnergy,
            restingHeartRate: try? await restingHeartRate,
            heartRateVariability: try? await hrv,
            lastUpdated: Date()
        )

        self.healthData = summary
        return summary
    }

    /// 获取今日睡眠数据
    func fetchSleepHours() async throws -> Double {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return 0
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0)
                    return
                }

                var totalSleepTime: TimeInterval = 0
                for sample in sleepSamples {
                    if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                        totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                }

                continuation.resume(returning: totalSleepTime / 3600)
            }

            healthStore.execute(query)
        }
    }

    /// 获取平均心率
    func fetchAverageHeartRate() async throws -> Double {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return 0
        }

        let calendar = Calendar.current
        let now = Date()
        let oneHourAgo = calendar.date(byAdding: .hour, value: -1, to: now)!

        let predicate = HKQuery.predicateForSamples(
            withStart: oneHourAgo,
            end: now,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let avgHeartRate = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: avgHeartRate ?? 0)
            }

            healthStore.execute(query)
        }
    }

    /// 获取步数
    func fetchStepCount() async throws -> Double {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let stepCount = result?.sumQuantity()?.doubleValue(for: HKUnit.count())
                continuation.resume(returning: stepCount ?? 0)
            }

            healthStore.execute(query)
        }
    }

    /// 获取活动能量消耗
    func fetchActiveEnergyBurned() async throws -> Double {
        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return 0
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let energy = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie())
                continuation.resume(returning: energy ?? 0)
            }

            healthStore.execute(query)
        }
    }

    /// 获取静息心率
    func fetchRestingHeartRate() async throws -> Double {
        guard let restingHeartRateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            return 0
        }

        let calendar = Calendar.current
        let now = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!

        let predicate = HKQuery.predicateForSamples(
            withStart: sevenDaysAgo,
            end: now,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: restingHeartRateType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: 0)
                    return
                }

                let restingHeartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: restingHeartRate)
            }

            healthStore.execute(query)
        }
    }

    /// 获取心率变异性
    func fetchHeartRateVariability() async throws -> Double {
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            return 0
        }

        let calendar = Calendar.current
        let now = Date()
        let oneHourAgo = calendar.date(byAdding: .hour, value: -1, to: now)!

        let predicate = HKQuery.predicateForSamples(
            withStart: oneHourAgo,
            end: now,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: hrvType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let hrv = result?.averageQuantity()?.doubleValue(for: HKUnit.secondUnit(with: .milli))
                continuation.resume(returning: hrv ?? 0)
            }

            healthStore.execute(query)
        }
    }

    /// 记录正念会话
    func recordMindfulSession(duration: TimeInterval, startDate: Date = Date()) async throws {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            return
        }

        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValueMindfulSession.notApplicable.rawValue,
            start: startDate,
            end: startDate.addingTimeInterval(duration)
        )

        try await withCheckedThrowingContinuation { continuation in
            healthStore.save(sample) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                if success {
                    print("✅ Mindful session saved: \(duration)s")
                }

                continuation.resume(returning: success)
            }
        }
    }

    /// 获取健康数据趋势（最近7天）
    func fetchHealthDataTrends() async -> HealthDataTrend {
        var trend = HealthDataTrend()

        guard isAuthorized else {
            return trend
        }

        let calendar = Calendar.current
        let now = Date()

        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: now)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            async let sleep = fetchSleepHours(for: startOfDay, end: endOfDay)
            async let steps = fetchStepCount(for: startOfDay, end: endOfDay)

            do {
                let sleepHours = try? await sleep
                let stepCount = try? await steps

                if let sleep = sleepHours {
                    trend.sleepTrend.append(sleep)
                }

                if let steps = stepCount {
                    trend.stepTrend.append(steps)
                }
            }
        }

        return trend
    }

    // MARK: - Private Helper Methods

    private func fetchSleepHours(for start: Date, end: Date) async throws -> Double {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return 0
        }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0)
                    return
                }

                var totalSleepTime: TimeInterval = 0
                for sample in sleepSamples {
                    if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                        totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                }

                continuation.resume(returning: totalSleepTime / 3600)
            }

            healthStore.execute(query)
        }
    }

    private func fetchStepCount(for start: Date, end: Date) async throws -> Double {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let stepCount = result?.sumQuantity()?.doubleValue(for: HKUnit.count())
                continuation.resume(returning: stepCount ?? 0)
            }

            healthStore.execute(query)
        }
    }
}

// MARK: - Supporting Types

struct HealthData {
    var sleepHours: Double?
    var averageHeartRate: Double?
    var stepCount: Double?
    var activeEnergyBurned: Double?
    var restingHeartRate: Double?
    var heartRateVariability: Double?
    var lastUpdated: Date
}

struct HealthDataTrend {
    var sleepTrend: [Double] = []
    var stepTrend: [Double] = []

    var averageSleep: Double {
        return sleepTrend.isEmpty ? 0 : sleepTrend.reduce(0, +) / Double(sleepTrend.count)
    }

    var averageSteps: Double {
        return stepTrend.isEmpty ? 0 : stepTrend.reduce(0, +) / Double(stepTrend.count)
    }
}
