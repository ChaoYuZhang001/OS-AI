//
//  TodoView.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  待办事项模块 - 视图
//

import SwiftUI
import SwiftData

struct TodoView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var purchaseService: PurchaseService

    @State private var viewModel: TodoViewModel?
    @State private var showingAddTodo = false
    @State private var showingFilterSheet = false
    @State private var filter: TodoFilter = .all
    @State private var searchQuery: String = ""
    @State private var selectedTodo: TodoItem?

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                searchSection

                // 过滤器
                filterSection

                // 列表
                if let viewModel = viewModel {
                    todoList(using: viewModel)
                } else {
                    loadingView
                }
            }
            .navigationTitle("待办事项")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTodo = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView(viewModel: viewModel)
            }
            .sheet(item: $selectedTodo) { todo in
                EditTodoView(todo: todo, viewModel: viewModel)
            }
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheet(filter: $filter)
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = TodoViewModel(modelContext: modelContext)
                }
            }
        }
    }

    // MARK: - Views

    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("搜索待办事项", text: $searchQuery)
                .textFieldStyle(.plain)

            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TodoFilter.allCases, id: \.self) { filterOption in
                    FilterChip(
                        title: filterOption.title,
                        count: getFilterCount(for: filterOption),
                        isSelected: filter == filterOption
                    ) {
                        filter = filterOption
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private func todoList(using viewModel: TodoViewModel) -> some View {
        Group {
            if filteredTodos.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(filteredTodos) { todo in
                        TodoRow(todo: todo)
                            .onTapGesture {
                                selectedTodo = todo
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteTodo(todo)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }

                                Button {
                                    if todo.isCompleted {
                                        viewModel.uncompleteTodo(todo)
                                    } else {
                                        viewModel.completeTodo(todo)
                                    }
                                } label: {
                                    Label(todo.isCompleted ? "未完成" : "完成", systemImage: todo.isCompleted ? "xmark.circle" : "checkmark.circle")
                                }
                                .tint(todo.isCompleted ? .orange : .green)
                            }
                    }

                    // 清除已完成按钮
                    if !viewModel.completedItems.isEmpty {
                        Section {
                            Button(action: { viewModel.clearCompletedTodos() }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("清除已完成")
                                    Text("(\(viewModel.completedItems.count))")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("加载中...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("暂无待办事项")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("点击右上角 + 添加第一个待办")
                .foregroundColor(.secondary)

            Button(action: { showingAddTodo = true }) {
                Text("添加待办")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Computed Properties

    private var filteredTodos: [TodoItem] {
        guard let viewModel = viewModel else { return [] }

        var todos: [TodoItem]

        // 应用搜索
        if !searchQuery.isEmpty {
            todos = viewModel.searchTodos(searchQuery)
        } else {
            todos = viewModel.items
        }

        // 应用过滤器
        switch filter {
        case .all:
            return todos.filter { !$0.isCompleted }
        case .completed:
            return todos.filter { $0.isCompleted }
        case .overdue:
            return viewModel.overdueItems
        case .today:
            return viewModel.getTodos(for: Date())
        case .upcoming:
            return Array(viewModel.upcomingItems)
        case .highPriority:
            return todos.filter { $0.priority == .urgent || $0.priority == .high && !$0.isCompleted }
        }
    }

    private func getFilterCount(for filter: TodoFilter) -> Int {
        guard let viewModel = viewModel else { return 0 }

        switch filter {
        case .all:
            return viewModel.todoItems.count
        case .completed:
            return viewModel.completedItems.count
        case .overdue:
            return viewModel.overdueItems.count
        case .today:
            return viewModel.getTodos(for: Date()).count
        case .upcoming:
            return viewModel.upcomingItems.count
        case .highPriority:
            return viewModel.todoItems.filter { $0.priority == .urgent || $0.priority == .high }.count
        }
    }
}

// MARK: - Todo Row

struct TodoRow: View {
    let todo: TodoItem

    var body: some View {
        HStack(spacing: 12) {
            // 完成按钮
            Button(action: {}) {
                ZStack {
                    Circle()
                        .stroke(todo.priority.borderColor, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if todo.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(todo.priority.borderColor)
                            .clipShape(Circle())
                    }
                }
            }

            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.content)
                    .font(.body)
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    // 截止时间
                    if let dueDate = todo.dueDate {
                        Label(formatDueDate(dueDate), systemImage: dueDateIcon(dueDate))
                            .font(.caption)
                            .foregroundColor(dueDateColor(dueDate))
                    }

                    // 优先级
                    Label(todo.priority.rawValue, systemImage: "flag.fill")
                        .font(.caption)
                        .foregroundColor(todo.priority.borderColor)

                    // 分类
                    if let category = todo.category {
                        Label(category, systemImage: "tag.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // 位置
            if let location = todo.location {
                Image(systemName: "location.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDueDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDateInTomorrow(date) {
            return "明天"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }

    private func dueDateIcon(_ date: Date) -> String {
        let calendar = Calendar.current

        if date < Date() {
            return "exclamationmark.triangle.fill"
        } else if calendar.isDateInToday(date) {
            return "clock.fill"
        } else if calendar.isDateInTomorrow(date) {
            return "sun.max.fill"
        } else {
            return "calendar"
        }
    }

    private func dueDateColor(_ date: Date) -> Color {
        if date < Date() {
            return .red
        } else {
            return .secondary
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                Text("(\(count))")
                    .font(.caption)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.green : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Add Todo View

struct AddTodoView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: TodoViewModel?

    @State private var content: String = ""
    @State private var dueDate: Date = Date()
    @State private var hasDueDate: Bool = false
    @State private var location: String = ""
    @State private var priority: TodoPriority = .normal
    @State private var category: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("待办事项", text: $content)
                        .textFieldStyle(.plain)

                    Picker("优先级", selection: $priority) {
                        ForEach(TodoPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.borderColor)
                                    .frame(width: 10)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                }

                Section("可选") {
                    Toggle("设置截止时间", isOn: $hasDueDate)
                        .onChange(of: hasDueDate) { _, _ in
                            if hasDueDate {
                                dueDate = Date()
                            }
                        }

                    if hasDueDate {
                        DatePicker("截止时间", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }

                    TextField("地点", text: $location)
                    TextField("分类", text: $category)
                }
            }
            .navigationTitle("添加待办")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        addTodo()
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }

    private func addTodo() {
        let finalDueDate = hasDueDate ? dueDate : nil
        let finalLocation = location.isEmpty ? nil : location
        let finalCategory = category.isEmpty ? nil : category

        viewModel?.createTodo(
            content: content,
            dueDate: finalDueDate,
            location: finalLocation,
            priority: priority,
            category: finalCategory
        )

        dismiss()
    }
}

// MARK: - Edit Todo View

struct EditTodoView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var todo: TodoItem
    let viewModel: TodoViewModel?

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("待办事项", text: $todo.content)
                        .textFieldStyle(.plain)

                    Picker("优先级", selection: $todo.priority) {
                        ForEach(TodoPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.borderColor)
                                    .frame(width: 10)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                }

                Section("截止时间") {
                    if let dueDate = todo.dueDate {
                        DatePicker("截止时间", selection: Binding(
                            get: { dueDate },
                            set: { todo.dueDate = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])

                        Button("清除截止时间") {
                            todo.dueDate = nil
                        }
                        .foregroundColor(.red)
                    } else {
                        Button("设置截止时间") {
                            todo.dueDate = Date()
                        }
                    }
                }

                Section("其他") {
                    TextField("地点", text: Binding(
                        get: { todo.location ?? "" },
                        set: { todo.location = $0.isEmpty ? nil : $0 }
                    ))

                    TextField("分类", text: Binding(
                        get: { todo.category ?? "" },
                        set: { todo.category = $0.isEmpty ? nil : $0 }
                    ))
                }

                Section {
                    Button(role: .destructive) {
                        viewModel?.deleteTodo(todo)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Label("删除待办", systemImage: "trash")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("编辑待办")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewModel?.updateTodo(todo)
                        dismiss()
                    }
                    .disabled(todo.content.isEmpty)
                }
            }
        }
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var filter: TodoFilter

    var body: some View {
        NavigationView {
            List {
                ForEach(TodoFilter.allCases, id: \.self) { filterOption in
                    Button(action: {
                        filter = filterOption
                        dismiss()
                    }) {
                        HStack {
                            Text(filterOption.title)
                                .foregroundColor(.primary)

                            Spacer()

                            if filter == filterOption {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("筛选")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - TodoFilter

enum TodoFilter: CaseIterable {
    case all
    case completed
    case overdue
    case today
    case upcoming
    case highPriority

    var title: String {
        switch self {
        case .all: return "全部"
        case .completed: return "已完成"
        case .overdue: return "已逾期"
        case .today: return "今天"
        case .upcoming: return "即将到来"
        case .highPriority: return "高优先级"
        }
    }
}

// MARK: - Priority Extension

extension TodoPriority {
    var borderColor: Color {
        switch self {
        case .low: return .green
        case .normal: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }

    var rawValue: Int {
        switch self {
        case .low: return 1
        case .normal: return 2
        case .high: return 3
        case .urgent: return 4
        }
    }
}

// MARK: - Preview

#Preview {
    TodoView()
}
