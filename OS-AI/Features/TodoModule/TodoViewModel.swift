//
//  TodoViewModel.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  待办事项模块 - ViewModel
//

import Foundation
import SwiftData
import Observation

@Observable
final class TodoViewModel {

    // MARK: - Properties
    private let modelContext: ModelContext
    private var items: [TodoItem] = []

    // MARK: - Computed Properties
    var todoItems: [TodoItem] {
        items.filter { !$0.isCompleted }
            .sorted { todo1, todo2 in
                // 按优先级排序：紧急 > 高 > 正常 > 低
                if todo1.priority != todo2.priority {
                    return todo1.priority.rawValue > todo2.priority.rawValue
                }
                // 相同优先级按时间排序
                if let date1 = todo1.dueDate, let date2 = todo2.dueDate {
                    return date1 < date2
                }
                return todo1.createdAt < todo2.createdAt
            }
    }

    var completedItems: [TodoItem] {
        items.filter { $0.isCompleted }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var upcomingItems: [TodoItem] {
        items.filter { !$0.isCompleted && $0.dueDate != nil && $0.dueDate! > Date() }
            .sorted { $0.dueDate! < $1.dueDate! }
            .prefix(5)
            .map { $0 }
    }

    var overdueItems: [TodoItem] {
        items.filter { !$0.isCompleted && $0.dueDate != nil && $0.dueDate! < Date() }
            .sorted { $0.dueDate! < $1.dueDate! }
    }

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadItems()
    }

    // MARK: - Public Methods

    /// 加载待办事项
    func loadItems() {
        let fetchDescriptor = FetchDescriptor<TodoItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            items = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to load todo items: \(error)")
        }
    }

    /// 创建待办事项
    func createTodo(
        content: String,
        dueDate: Date? = nil,
        location: String? = nil,
        priority: TodoPriority = .normal,
        category: String? = nil
    ) -> TodoItem? {
        let todo = TodoItem(
            content: content,
            dueDate: dueDate,
            location: location,
            priority: priority,
            category: category,
            isCompleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        modelContext.insert(todo)

        do {
            try modelContext.save()
            items.append(todo)
            print("✅ Todo created: \(content)")
            return todo
        } catch {
            print("❌ Failed to create todo: \(error)")
            return nil
        }
    }

    /// 更新待办事项
    func updateTodo(
        _ todo: TodoItem,
        content: String? = nil,
        dueDate: Date? = nil,
        location: String? = nil,
        priority: TodoPriority? = nil,
        category: String? = nil
    ) {
        if let content = content {
            todo.content = content
        }
        if let dueDate = dueDate {
            todo.dueDate = dueDate
        }
        if let location = location {
            todo.location = location
        }
        if let priority = priority {
            todo.priority = priority
        }
        if let category = category {
            todo.category = category
        }

        todo.updatedAt = Date()

        do {
            try modelContext.save()
            print("✅ Todo updated: \(todo.content)")
        } catch {
            print("❌ Failed to update todo: \(error)")
        }
    }

    /// 完成待办事项
    func completeTodo(_ todo: TodoItem) {
        todo.isCompleted = true
        todo.updatedAt = Date()

        do {
            try modelContext.save()
            print("✅ Todo completed: \(todo.content)")
        } catch {
            print("❌ Failed to complete todo: \(error)")
        }
    }

    /// 取消完成待办事项
    func uncompleteTodo(_ todo: TodoItem) {
        todo.isCompleted = false
        todo.updatedAt = Date()

        do {
            try modelContext.save()
            print("✅ Todo uncompleted: \(todo.content)")
        } catch {
            print("❌ Failed to uncomplete todo: \(error)")
        }
    }

    /// 删除待办事项
    func deleteTodo(_ todo: TodoItem) {
        modelContext.delete(todo)

        do {
            try modelContext.save()
            items.removeAll { $0.id == todo.id }
            print("✅ Todo deleted: \(todo.content)")
        } catch {
            print("❌ Failed to delete todo: \(error)")
        }
    }

    /// 批量完成待办事项
    func completeMultipleTodos(_ todos: [TodoItem]) {
        for todo in todos {
            todo.isCompleted = true
            todo.updatedAt = Date()
        }

        do {
            try modelContext.save()
            print("✅ \(todos.count) todos completed")
        } catch {
            print("❌ Failed to complete todos: \(error)")
        }
    }

    /// 清除已完成的待办事项
    func clearCompletedTodos() {
        let completedTodos = items.filter { $0.isCompleted }

        for todo in completedTodos {
            modelContext.delete(todo)
        }

        do {
            try modelContext.save()
            items.removeAll { $0.isCompleted }
            print("✅ Cleared \(completedTodos.count) completed todos")
        } catch {
            print("❌ Failed to clear completed todos: \(error)")
        }
    }

    /// 获取指定日期的待办事项
    func getTodos(for date: Date) -> [TodoItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return items.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return dueDate >= startOfDay && dueDate < endOfDay
        }
    }

    /// 搜索待办事项
    func searchTodos(_ query: String) -> [TodoItem] {
        let lowercaseQuery = query.lowercased()
        return items.filter { todo in
            return todo.content.lowercased().contains(lowercaseQuery) ||
                   (todo.location?.lowercased().contains(lowercaseQuery) ?? false) ||
                   (todo.category?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }

    /// 获取待办事项统计
    func getTodoStatistics() -> TodoStatistics {
        let total = items.count
        let completed = items.filter { $0.isCompleted }.count
        let pending = total - completed
        let overdue = overdueItems.count
        let upcoming = upcomingItems.count

        // 按优先级统计
        var priorityCounts: [TodoPriority: Int] = [:]
        for priority in TodoPriority.allCases {
            priorityCounts[priority] = items.filter { $0.priority == priority && !$0.isCompleted }.count
        }

        return TodoStatistics(
            total: total,
            completed: completed,
            pending: pending,
            overdue: overdue,
            upcoming: upcoming,
            priorityCounts: priorityCounts,
            completionRate: total > 0 ? Double(completed) / Double(total) : 0.0
        )
    }

    /// 导出待办事项
    func exportTodos() -> String {
        var output = "待办事项清单\n"
        output += "========\n\n"

        // 未完成的待办
        output += "未完成 (\(todoItems.count))\n"
        output += String(repeating: "-", count: 30) + "\n"

        for (index, todo) in todoItems.enumerated() {
            output += "\(index + 1). \(todo.content)\n"
            if let dueDate = todo.dueDate {
                output += "   截止时间: \(formatDate(dueDate))\n"
            }
            if let location = todo.location {
                output += "   地点: \(location)\n"
            }
            output += "   优先级: \(todo.priority.rawValue)\n"
            output += "\n"
        }

        // 已完成的待办
        if !completedItems.isEmpty {
            output += "\n已完成 (\(completedItems.count))\n"
            output += String(repeating: "-", count: 30) + "\n"

            for (index, todo) in completedItems.prefix(10).enumerated() {
                output += "\(index + 1). \(todo.content)\n"
            }

            if completedItems.count > 10 {
                output += "... 还有 \(completedItems.count - 10) 项\n"
            }
        }

        return output
    }

    // MARK: - Private Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Types

struct TodoStatistics {
    var total: Int
    var completed: Int
    var pending: Int
    var overdue: Int
    var upcoming: Int
    var priorityCounts: [TodoPriority: Int]
    var completionRate: Double

    var formattedCompletionRate: String {
        return String(format: "%.1f%%", completionRate * 100)
    }
}
