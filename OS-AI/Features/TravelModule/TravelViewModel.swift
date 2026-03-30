//
//  TravelViewModel.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  出行规划模块 - ViewModel
//

import Foundation
import SwiftData
import Observation

@Observable
final class TravelViewModel {

    // MARK: - Properties
    private let modelContext: ModelContext
    private var items: [TravelPlan] = []

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadItems()
    }

    // MARK: - Public Methods

    /// 加载出行计划
    func loadItems() {
        let fetchDescriptor = FetchDescriptor<TravelPlan>(
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )

        do {
            items = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to load travel plans: \(error)")
        }
    }

    /// 创建出行计划
    func createTravelPlan(
        title: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        transportation: Transportation,
        accommodation: Accommodation,
        budget: Double? = nil
    ) -> TravelPlan? {
        let plan = TravelPlan(
            title: title,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            transportation: transportation,
            accommodation: accommodation,
            budget: budget
        )

        modelContext.insert(plan)

        do {
            try modelContext.save()
            items.append(plan)
            print("✅ Travel plan created: \(title)")
            return plan
        } catch {
            print("❌ Failed to create travel plan: \(error)")
            return nil
        }
    }

    /// 更新出行计划
    func updateTravelPlan(
        _ plan: TravelPlan,
        title: String? = nil,
        destination: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        budget: Double? = nil
    ) {
        if let title = title { plan.title = title }
        if let destination = destination { plan.destination = destination }
        if let startDate = startDate { plan.startDate = startDate }
        if let endDate = endDate { plan.endDate = endDate }
        if let budget = budget { plan.budget = budget }

        plan.updatedAt = Date()

        do {
            try modelContext.save()
            print("✅ Travel plan updated: \(plan.title)")
        } catch {
            print("❌ Failed to update travel plan: \(error)")
        }
    }

    /// 删除出行计划
    func deleteTravelPlan(_ plan: TravelPlan) {
        modelContext.delete(plan)

        do {
            try modelContext.save()
            items.removeAll { $0.id == plan.id }
            print("✅ Travel plan deleted: \(plan.title)")
        } catch {
            print("❌ Failed to delete travel plan: \(error)")
        }
    }

    /// 添加行程项
    func addItineraryItem(to plan: TravelPlan, item: ItineraryItem) {
        plan.itinerary.append(item)
        plan.updatedAt = Date()

        do {
            try modelContext.save()
            print("✅ Itinerary item added: \(item.title)")
        } catch {
            print("❌ Failed to add itinerary item: \(error)")
        }
    }

    /// 获取即将到来的出行计划
    func getUpcomingPlans() -> [TravelPlan] {
        let now = Date()

        return items
            .filter { $0.startDate >= now && !$0.isCompleted }
            .sorted { $0.startDate < $1.startDate }
    }

    /// 获取进行中的出行计划
    func getCurrentPlans() -> [TravelPlan] {
        let now = Date()

        return items
            .filter { $0.startDate <= now && $0.endDate >= now && !$0.isCompleted }
            .sorted { $0.startDate < $1.startDate }
    }

    /// 搜索出行计划
    func searchPlans(_ query: String) -> [TravelPlan] {
        let lowercaseQuery = query.lowercased()
        return items.filter { plan in
            return plan.title.lowercased().contains(lowercaseQuery) ||
                   plan.destination.lowercased().contains(lowercaseQuery)
        }
    }
}
