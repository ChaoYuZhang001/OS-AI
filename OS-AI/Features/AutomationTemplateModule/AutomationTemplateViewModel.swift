//
//  AutomationTemplateViewModel.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  自动化模板市场 - ViewModel
//

import Foundation
import SwiftData
import Observation

@Observable
final class AutomationTemplateViewModel {

    // MARK: - Properties
    private let modelContext: ModelContext
    private var templates: [AutomationTemplate] = []
    private var reviews: [TemplateReview] = []
    private var myTemplates: [AutomationTemplate] = []

    // MARK: - Published Properties
    @Published var isRefreshing = false
    @Published var selectedCategory: TemplateCategory? = nil
    @Published var searchQuery: String = ""
    @Published var featuredTemplates: [AutomationTemplate] = []

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadTemplates()
        loadReviews()
        loadFeaturedTemplates()
    }

    // MARK: - Public Methods

    /// 加载模板
    func loadTemplates() {
        let fetchDescriptor = FetchDescriptor<AutomationTemplate>(
            sortBy: [SortDescriptor(\.downloadCount, order: .reverse)]
        )

        do {
            templates = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to load templates: \(error)")
        }
    }

    /// 加载评论
    func loadReviews() {
        let fetchDescriptor = FetchDescriptor<TemplateReview>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            reviews = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to load reviews: \(error)")
        }
    }

    /// 加载精选模板
    func loadFeaturedTemplates() {
        featuredTemplates = templates.filter { $0.isOfficial || $0.rating >= 4.5 }
            .sorted { $0.downloadCount > $1.downloadCount }
            .prefix(5)
            .map { $0 }
    }

    /// 获取所有模板
    func getAllTemplates() -> [AutomationTemplate] {
        var result = templates

        // 应用分类过滤
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // 应用搜索过滤
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter { template in
                return template.name.lowercased().contains(query) ||
                       template.description.lowercased().contains(query) ||
                       template.tags.contains(where: { $0.lowercased().contains(query) })
            }
        }

        return result.sorted { $0.downloadCount > $1.downloadCount }
    }

    /// 获取热门模板
    func getPopularTemplates(limit: Int = 10) -> [AutomationTemplate] {
        return templates
            .sorted { $0.downloadCount > $1.downloadCount }
            .prefix(limit)
            .map { $0 }
    }

    /// 获取最新模板
    func getLatestTemplates(limit: Int = 10) -> [AutomationTemplate] {
        return templates
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }

    /// 获取官方模板
    func getOfficialTemplates() -> [AutomationTemplate] {
        return templates.filter { $0.isOfficial }
    }

    /// 获取我的模板
    func getMyTemplates(userId: String) -> [AutomationTemplate] {
        return templates.filter { $0.creatorId == userId }
    }

    /// 创建模板
    func createTemplate(
        name: String,
        description: String,
        category: TemplateCategory,
        steps: [AutomationStep],
        icon: String = "sparkles",
        parameters: [TemplateParameter] = [],
        tags: [String] = [],
        price: Double = 0.0,
        isFree: Bool = true,
        creatorId: String,
        creatorName: String
    ) -> AutomationTemplate? {
        let template = AutomationTemplate(
            name: name,
            description: description,
            icon: icon,
            category: category,
            steps: steps,
            parameters: parameters,
            creatorId: creatorId,
            creatorName: creatorName,
            price: price,
            isFree: isFree,
            tags: tags
        )

        modelContext.insert(template)

        do {
            try modelContext.save()
            templates.append(template)
            print("✅ Template created: \(name)")
            return template
        } catch {
            print("❌ Failed to create template: \(error)")
            return nil
        }
    }

    /// 更新模板
    func updateTemplate(
        _ template: AutomationTemplate,
        name: String? = nil,
        description: String? = nil,
        steps: [AutomationStep]? = nil,
        tags: [String]? = nil,
        price: Double? = nil
    ) {
        if let name = name { template.name = name }
        if let description = description { template.description = description }
        if let steps = steps { template.steps = steps }
        if let tags = tags { template.tags = tags }
        if let price = price { template.price = price }

        template.updatedAt = Date()

        do {
            try modelContext.save()
            print("✅ Template updated: \(template.name)")
        } catch {
            print("❌ Failed to update template: \(error)")
        }
    }

    /// 删除模板
    func deleteTemplate(_ template: AutomationTemplate) {
        modelContext.delete(template)

        do {
            try modelContext.save()
            templates.removeAll { $0.id == template.id }
            print("✅ Template deleted: \(template.name)")
        } catch {
            print("❌ Failed to delete template: \(error)")
        }
    }

    /// 下载模板
    func downloadTemplate(_ template: AutomationTemplate, userId: String) -> Bool {
        // 创建模板实例
        let instance = TemplateInstance(
            templateId: template.id,
            templateName: template.name,
            userId: userId
        )

        modelContext.insert(instance)

        // 增加下载计数
        template.downloadCount += 1

        do {
            try modelContext.save()
            print("✅ Template downloaded: \(template.name)")
            return true
        } catch {
            print("❌ Failed to download template: \(error)")
            return false
        }
    }

    /// 添加评论
    func addReview(
        templateId: UUID,
        userId: String,
        userName: String,
        rating: Int,
        comment: String
    ) -> TemplateReview? {
        // 检查是否已经评论过
        if reviews.contains(where: { $0.templateId == templateId && $0.userId == userId }) {
            print("⚠️ User already reviewed this template")
            return nil
        }

        let review = TemplateReview(
            templateId: templateId,
            userId: userId,
            userName: userName,
            rating: rating,
            comment: comment
        )

        modelContext.insert(review)
        reviews.append(review)

        // 更新模板评分
        updateTemplateRating(templateId)

        do {
            try modelContext.save()
            print("✅ Review added")
            return review
        } catch {
            print("❌ Failed to add review: \(error)")
            return nil
        }
    }

    /// 获取模板评论
    func getReviews(for templateId: UUID) -> [TemplateReview] {
        return reviews.filter { $0.templateId == templateId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// 更新模板评分
    private func updateTemplateRating(_ templateId: UUID) {
        guard let template = templates.first(where: { $0.id == templateId }) else { return }

        let templateReviews = reviews.filter { $0.templateId == templateId }
        guard !templateReviews.isEmpty else { return }

        let totalRating = templateReviews.reduce(0) { $0 + $1.rating }
        template.rating = Double(totalRating) / Double(templateReviews.count)
        template.reviewCount = templateReviews.count
    }

    /// 执行模板
    func executeTemplate(_ template: AutomationTemplate, parameters: [String: Any]) async -> Bool {
        print("🚀 Executing template: \(template.name)")

        for step in template.steps {
            let success = await executeStep(step, parameters: parameters)

            if !success {
                print("❌ Template execution failed at step: \(step.title)")
                return false
            }
        }

        print("✅ Template execution completed")
        return true
    }

    /// 执行步骤
    private func executeStep(_ step: AutomationStep, parameters: [String: Any]) async -> Bool {
        switch step.type {
        case .trigger:
            return await executeTrigger(step, parameters: parameters)
        case .action:
            return await executeAction(step, parameters: parameters)
        case .condition:
            return await executeCondition(step, parameters: parameters)
        case .delay:
            return await executeDelay(step, parameters: parameters)
        }
    }

    private func executeTrigger(_ step: AutomationStep, parameters: [String: Any]) async -> Bool {
        print("🔔 Executing trigger: \(step.title)")
        return true
    }

    private func executeAction(_ step: AutomationStep, parameters: [String: Any]) async -> Bool {
        print("⚡ Executing action: \(step.title)")
        return true
    }

    private func executeCondition(_ step: AutomationStep, parameters: [String: Any]) async -> Bool {
        print("❓ Executing condition: \(step.title)")
        return true
    }

    private func executeDelay(_ step: AutomationStep, parameters: [String: Any]) async -> Bool {
        let delay: TimeInterval
        if let delayValue = step.configuration["seconds"] as? Double {
            delay = delayValue
        } else {
            delay = 1.0
        }

        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        print("⏱️ Executing delay: \(delay)s")
        return true
    }

    /// 搜索模板
    func searchTemplates(_ query: String) -> [AutomationTemplate] {
        let lowercaseQuery = query.lowercased()
        return templates.filter { template in
            return template.name.lowercased().contains(lowercaseQuery) ||
                   template.description.lowercased().contains(lowercaseQuery) ||
                   template.tags.contains(where: { $0.lowercased().contains(lowercaseQuery) })
        }
    }

    /// 获取模板统计
    func getTemplateStatistics() -> TemplateStatistics {
        let totalTemplates = templates.count
        let totalDownloads = templates.reduce(0) { $0 + $1.downloadCount }
        let averageRating = templates.isEmpty ? 0.0 : templates.reduce(0.0) { $0 + $1.rating } / Double(templates.count)

        // 按分类统计
        var categoryCounts: [TemplateCategory: Int] = [:]
        for category in TemplateCategory.allCases {
            categoryCounts[category] = templates.filter { $0.category == category }.count
        }

        return TemplateStatistics(
            totalTemplates: totalTemplates,
            totalDownloads: totalDownloads,
            averageRating: averageRating,
            categoryCounts: categoryCounts,
            officialTemplates: templates.filter { $0.isOfficial }.count,
            freeTemplates: templates.filter { $0.isFree }.count
        )
    }
}

// MARK: - Supporting Types

@Model
final class TemplateInstance {
    var id: UUID
    var templateId: UUID
    var templateName: String
    var userId: String
    var parameters: [String: String]
    var isActive: Bool
    var createdAt: Date
    var lastExecutedAt: Date?

    init(
        id: UUID = UUID(),
        templateId: UUID,
        templateName: String,
        userId: String,
        parameters: [String: String] = [:],
        isActive: Bool = true,
        createdAt: Date = Date(),
        lastExecutedAt: Date? = nil
    ) {
        self.id = id
        self.templateId = templateId
        self.templateName = templateName
        self.userId = userId
        self.parameters = parameters
        self.isActive = isActive
        self.createdAt = createdAt
        self.lastExecutedAt = lastExecutedAt
    }
}

struct TemplateStatistics {
    var totalTemplates: Int
    var totalDownloads: Int
    var averageRating: Double
    var categoryCounts: [TemplateCategory: Int]
    var officialTemplates: Int
    var freeTemplates: Int
}
