//
//  AutomationTemplate.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  自动化模板 - 数据模型
//

import Foundation
import SwiftData

@Model
final class AutomationTemplate {
    var id: UUID
    var name: String
    var description: String
    var icon: String
    var category: TemplateCategory
    var steps: [AutomationStep]
    var parameters: [TemplateParameter]
    var creatorId: String
    var creatorName: String
    var isOfficial: Bool
    var downloadCount: Int
    var rating: Double
    var reviewCount: Int
    var price: Double
    var isFree: Bool
    var tags: [String]
    var version: String
    var minOSVersion: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        icon: String = "sparkles",
        category: TemplateCategory,
        steps: [AutomationStep],
        parameters: [TemplateParameter] = [],
        creatorId: String,
        creatorName: String,
        isOfficial: Bool = false,
        downloadCount: Int = 0,
        rating: Double = 0.0,
        reviewCount: Int = 0,
        price: Double = 0.0,
        isFree: Bool = true,
        tags: [String] = [],
        version: String = "1.0.0",
        minOSVersion: String = "17.0",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.category = category
        self.steps = steps
        self.parameters = parameters
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.isOfficial = isOfficial
        self.downloadCount = downloadCount
        self.rating = rating
        self.reviewCount = reviewCount
        self.price = price
        self.isFree = isFree
        self.tags = tags
        self.version = version
        self.minOSVersion = minOSVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum TemplateCategory: String, Codable, CaseIterable {
    case productivity = "效率"
    case health = "健康"
    case finance = "财务"
    case travel = "出行"
    case social = "社交"
    case entertainment = "娱乐"
    case learning = "学习"
    case home = "家居"

    var icon: String {
        switch self {
        case .productivity: return "checkmark.circle.fill"
        case .health: return "heart.fill"
        case .finance: return "dollarsign.circle.fill"
        case .travel: return "airplane"
        case .social: return "person.2.fill"
        case .entertainment: return "sparkles"
        case .learning: return "book.fill"
        case .home: return "house.fill"
        }
    }
}

struct AutomationStep: Codable {
    var id: UUID
    var type: StepType
    var title: String
    var description: String
    var configuration: [String: Any]

    init(
        id: UUID = UUID(),
        type: StepType,
        title: String,
        description: String,
        configuration: [String: Any] = [:]
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.configuration = configuration
    }
}

enum StepType: String, Codable {
    case trigger = "触发器"
    case action = "动作"
    case condition = "条件"
    case delay = "延迟"
}

struct TemplateParameter: Codable {
    var id: UUID
    var name: String
    var type: ParameterType
    var defaultValue: String
    var required: Bool
    var description: String

    init(
        id: UUID = UUID(),
        name: String,
        type: ParameterType,
        defaultValue: String = "",
        required: Bool = false,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
        self.required = required
        self.description = description
    }
}

enum ParameterType: String, Codable {
    case text = "文本"
    case number = "数字"
    case date = "日期"
    case time = "时间"
    case boolean = "布尔值"
    case select = "选择"
}

@Model
final class TemplateReview {
    var id: UUID
    var templateId: UUID
    var userId: String
    var userName: String
    var rating: Int
    var comment: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        templateId: UUID,
        userId: String,
        userName: String,
        rating: Int,
        comment: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.templateId = templateId
        self.userId = userId
        self.userName = userName
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
