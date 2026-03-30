//
//  EmotionAnalyzer.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  情绪分析器 - 感知用户情绪状态
//

import Foundation
import HealthKit

/// 情绪分析器
/// 基于健康数据、使用习惯等分析用户当前情绪状态
actor EmotionAnalyzer {

    // MARK: - Properties
    private var healthStore: HKHealthStore?
    private var recentDataPoints: [EmotionDataPoint] = []

    // MARK: - HealthKit Data Types
    private let healthDataTypes: Set<HKSampleType> = [
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!
    ]

    // MARK: - Initialization
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
        }
    }

    // MARK: - Public Methods

    /// 初始化
    func initialize() async {
        print("✅ EmotionAnalyzer initialized")
    }

    /// 请求健康数据权限
    func requestHealthDataAuthorization() async -> Bool {
        guard let healthStore = healthStore else {
            return false
        }

        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: healthDataTypes) { success, error in
                continuation.resume(returning: success)
            }
        }
    }

    /// 分析当前情绪状态
    /// - Returns: 情绪状态
    func analyzeCurrentEmotion() async -> EmotionState {
        // 收集数据
        let sleepData = await fetchSleepData()
        let heartRateData = await fetchHeartRateData()
        let stepCountData = await fetchStepCountData()
        let screenTimeData = await fetchScreenTimeData()

        // 构建数据点
        let dataPoint = EmotionDataPoint(
            sleepHours: sleepData,
            avgHeartRate: heartRateData,
            stepCount: stepCountData,
            screenTimeHours: screenTimeData,
            timestamp: Date()
        )

        recentDataPoints.append(dataPoint)

        // 保持最近7天数据
        if recentDataPoints.count > 7 {
            recentDataPoints.removeFirst()
        }

        // 分析情绪
        return analyzeEmotion(from: dataPoint, withHistory: recentDataPoints)
    }

    // MARK: - Private Methods

    private func analyzeEmotion(from data: EmotionDataPoint, withHistory history: [EmotionDataPoint]) -> EmotionState {
        var score = 0.0

        // 1. 睡眠分析
        if let sleepHours = data.sleepHours {
            if sleepHours < 5 {
                score += 30 // 睡眠不足，高压风险高
            } else if sleepHours >= 7 {
                score -= 10 // 睡眠充足
            }
        }

        // 2. 心率分析
        if let heartRate = data.avgHeartRate {
            if heartRate > 100 {
                score += 20 // 心率过高，可能紧张
            } else if heartRate < 60 && heartRate > 0 {
                score -= 10 // 心率平稳
            }
        }

        // 3. 运动分析
        if let stepCount = data.stepCount {
            if stepCount < 3000 {
                score += 10 // 缺乏运动
            } else if stepCount > 8000 {
                score -= 10 // 运动充足
            }
        }

        // 4. 屏幕时间分析
        if let screenTime = data.screenTimeHours {
            if screenTime > 10 {
                score += 25 // 屏幕时间过长，可能疲劳
            } else if screenTime < 4 {
                score -= 15 // 屏幕时间合理
            }
        }

        // 5. 历史趋势分析
        if history.count > 2 {
            let recentTrend = calculateTrend(history)
            score += recentTrend * 10
        }

        // 根据分数判断情绪状态
        return determineEmotionState(from: score)
    }

    private func determineEmotionState(from score: Double) -> EmotionState {
        if score >= 50 {
            return .highPressure
        } else if score <= -20 {
            return .low
        } else if score >= 20 {
            return .neutral
        } else {
            return .relaxed
        }
    }

    private func calculateTrend(_ history: [EmotionDataPoint]) -> Double {
        // 计算最近数据的趋势
        guard history.count >= 3 else { return 0 }

        let recent = history.suffix(3)
        let avgSleep = recent.compactMap { $0.sleepHours }.reduce(0, +) / Double(recent.count)
        let avgScreenTime = recent.compactMap { $0.screenTimeHours }.reduce(0, +) / Double(recent.count)

        // 如果睡眠减少且屏幕时间增加，趋势为负面
        if avgSleep < 6 && avgScreenTime > 8 {
            return 1.0
        }

        return 0
    }

    // MARK: - Health Data Fetching

    private func fetchSleepData() async -> Double? {
        guard let healthStore = healthStore,
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return nil
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }

                var totalSleepTime: TimeInterval = 0
                for sample in sleepSamples {
                    if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                        totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                }

                let sleepHours = totalSleepTime / 3600
                continuation.resume(returning: sleepHours)
            }

            healthStore.execute(query)
        }
    }

    private func fetchHeartRateData() async -> Double? {
        guard let healthStore = healthStore,
              let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return nil
        }

        let calendar = Calendar.current
        let now = Date()
        let oneHourAgo = calendar.date(byAdding: .hour, value: -1, to: now)!

        let predicate = HKQuery.predicateForSamples(
            withStart: oneHourAgo,
            end: now,
            options: .strictStartDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, _ in
                let avgHeartRate = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: avgHeartRate)
            }

            healthStore.execute(query)
        }
    }

    private func fetchStepCountData() async -> Double? {
        guard let healthStore = healthStore,
              let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return nil
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let stepCount = result?.sumQuantity()?.doubleValue(for: HKUnit.count())
                continuation.resume(returning: stepCount)
            }

            healthStore.execute(query)
        }
    }

    private func fetchScreenTimeData() async -> Double? {
        // 屏幕时间需要使用DeviceActivity框架（iOS 16+）
        // 这里返回模拟数据
        return 6.5 // 6.5小时
    }
}

// MARK: - Supporting Types

struct EmotionDataPoint {
    let sleepHours: Double?
    let avgHeartRate: Double?
    let stepCount: Double?
    let screenTimeHours: Double?
    let timestamp: Date
}
