//
//  IntentProcessor.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  意图处理器 - 识别和解析用户意图
//

import Foundation
import NaturalLanguage
import CoreLocation

/// 意图处理器
/// 负责将自然语言转换为结构化的意图和实体
actor IntentProcessor {

    // MARK: - Properties
    private var naturalLanguageProcessor: NLTagger
    private var currentContext: Context

    // MARK: - Initialization
    init() {
        self.naturalLanguageProcessor = NLTagger(tagSchemes: [.lexicalClass, .nameType])
        self.currentContext = Context()
    }

    // MARK: - Public Methods

    /// 初始化
    func initialize() async {
        print("✅ IntentProcessor initialized")
    }

    /// 识别用户意图
    /// - Parameter text: 用户输入的文本
    /// - Returns: 识别出的意图
    func recognizeIntent(from text: String) async -> Intent {
        let keywords = [
            Intent.createTodo: ["待办", "任务", "提醒", "记得", "别忘了"],
            Intent.createCalendarEvent: ["日程", "会议", "约会", "安排", "计划"],
            Intent.checkDelivery: ["快递", "物流", "包裹", "查件"],
            Intent.payBill: ["缴费", "账单", "付", "水电", "话费"],
            Intent.planTravel: ["出差", "旅行", "行程", "订票", "酒店"],
            Intent.processContent: ["扫描", "识别", "摘要", "总结", "提取"]
        ]

        // 简单的关键词匹配
        for (intent, words) in keywords {
            for word in words {
                if text.contains(word) {
                    return intent
                }
            }
        }

        // 如果没有匹配到关键词，使用NaturalLanguage进行更复杂的分析
        return analyzeIntentWithNLP(text)
    }

    /// 提取实体
    /// - Parameters:
    ///   - text: 用户输入的文本
    ///   - intent: 识别出的意图
    /// - Returns: 提取出的实体列表
    func extractEntities(from text: String, intent: Intent) async -> [Entity] {
        var entities: [Entity] = []

        // 提取文本内容
        let contentText = extractContentText(from: text, intent: intent)
        if !contentText.isEmpty {
            entities.append(Entity(type: .text, value: contentText))
        }

        // 提取日期时间
        if let dateEntity = extractDateEntity(from: text) {
            entities.append(dateEntity)
        }

        // 提取位置
        if let locationEntity = extractLocationEntity(from: text) {
            entities.append(locationEntity)
        }

        return entities
    }

    /// 更新上下文
    func updateContext(location: CLLocation?) {
        self.currentContext.location = location
    }

    // MARK: - Private Methods

    private func analyzeIntentWithNLP(_ text: String) -> Intent {
        naturalLanguageProcessor.string = text

        // 使用机器学习模型进行意图分类
        // 这里简化处理，实际应该使用训练好的NLModel
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        let tags: [NLTag] = naturalLanguageProcessor.tags(
            unit: .sentence,
            scheme: .lexicalClass,
            options: options
        )

        // 简单的逻辑判断
        if text.contains("扫描") || text.contains("识别") {
            return .processContent
        }

        return .unknown
    }

    private func extractContentText(from text: String, intent: Intent) -> String {
        // 移除关键词，保留核心内容
        let keywords = getKeywords(for: intent)
        var content = text

        for keyword in keywords {
            content = content.replacingOccurrences(of: keyword, with: "")
        }

        return content.trimmingCharacters(in: .whitespacesAndPunctuation)
    }

    private func extractDateEntity(from text: String) -> Entity? {
        naturalLanguageProcessor.string = text

        let tags: [NLTag] = naturalLanguageProcessor.tags(
            unit: .word,
            scheme: .nameType
        )

        // 查找日期类型的词
        for (index, tag) in tags.enumerated() {
            if tag == .date {
                // 提取日期词
                let words = text.components(separatedBy: .whitespaces)
                if index < words.count {
                    return Entity(type: .date, value: words[index])
                }
            }
        }

        // 检查是否包含相对时间词（明天、下周等）
        let relativeTimeKeywords = ["明天", "后天", "下周", "下个月", "今天"]
        for keyword in relativeTimeKeywords {
            if text.contains(keyword) {
                // 转换为实际日期
                if let date = parseRelativeDate(keyword) {
                    let formatter = ISO8601DateFormatter()
                    return Entity(type: .date, value: formatter.string(from: date))
                }
            }
        }

        return nil
    }

    private func extractLocationEntity(from text: String) -> Entity? {
        naturalLanguageProcessor.string = text

        let tags: [NLTag] = naturalLanguageProcessor.tags(
            unit: .word,
            scheme: .nameType
        )

        // 查找地点类型的词
        for (index, tag) in tags.enumerated() {
            if tag == .placeName {
                let words = text.components(separatedBy: .whitespaces)
                if index < words.count {
                    return Entity(type: .location, value: words[index])
                }
            }
        }

        return nil
    }

    private func getKeywords(for intent: Intent) -> [String] {
        switch intent {
        case .createTodo:
            return ["待办", "任务", "提醒", "记得", "别忘了", "帮我"]
        case .createCalendarEvent:
            return ["日程", "会议", "约会", "安排", "计划", "在"]
        case .checkDelivery:
            return ["快递", "物流", "包裹", "查件", "我的"]
        case .payBill:
            return ["缴费", "账单", "付", "水电", "话费"]
        case .planTravel:
            return ["出差", "旅行", "行程", "订票", "酒店", "去"]
        case .processContent:
            return ["扫描", "识别", "摘要", "总结", "提取"]
        case .unknown:
            return []
        }
    }

    private func parseRelativeDate(_ keyword: String) -> Date? {
        let calendar = Calendar.current
        let now = Date()

        switch keyword {
        case "明天":
            return calendar.date(byAdding: .day, value: 1, to: now)
        case "后天":
            return calendar.date(byAdding: .day, value: 2, to: now)
        case "下周":
            return calendar.date(byAdding: .weekOfYear, value: 1, to: now)
        case "下个月":
            return calendar.date(byAdding: .month, value: 1, to: now)
        case "今天":
            return now
        default:
            return nil
        }
    }
}

// MARK: - Context

struct Context {
    var location: CLLocation?
    var time: Date = Date()
    var recentIntents: [Intent] = []
    var userPreferences: [String: Any] = [:]
}
