//
//  ContentView.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  主界面 - 果效 | OS-AI 数字生活合伙人
//

import SwiftUI

struct ContentView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var osaiEngine: OSAIEngine
    @EnvironmentObject var purchaseService: PurchaseService
    @EnvironmentObject var cloudService: CloudService
    @EnvironmentObject var notificationService: NotificationService

    // MARK: - State
    @State private var selectedTab: Tab = .home
    @State private var showingOnboarding = false
    @State private var showingPurchaseSheet = false
    @State private var userInput: String = ""
    @State private var processingResult: String = ""

    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(Tab.home)

            TodoView()
                .tabItem {
                    Label("待办", systemImage: "checkmark.circle.fill")
                }
                .tag(Tab.todo)

            CalendarView()
                .tabItem {
                    Label("日程", systemImage: "calendar.fill")
                }
                .tag(Tab.calendar)

            DeliveryView()
                .tabItem {
                    Label("快递", systemImage: "box.truck.fill")
                }
                .tag(Tab.delivery)

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
        .accentColor(.green)
        .onAppear {
            setupView()
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView(isPresented: $showingOnboarding)
        }
        .sheet(isPresented: $showingPurchaseSheet) {
            PurchaseView()
        }
    }

    // MARK: - Setup
    private func setupView() {
        // 设置通知分类
        notificationService.setupNotificationCategories()

        // 检查是否显示引导页
        if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            showingOnboarding = true
        }
    }
}

// MARK: - Tab Enum

enum Tab: CaseIterable {
    case home
    case todo
    case calendar
    case delivery
    case profile
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var osaiEngine: OSAIEngine
    @EnvironmentObject var purchaseService: PurchaseService

    @State private var userInput: String = ""
    @State private var processingResult: String = ""
    @State private var isProcessing = false
    @State private var suggestions: [Suggestion] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 引导区
                    greetingSection

                    // AI助手输入区
                    aiAssistantSection

                    // 情绪状态
                    emotionSection

                    // 智能建议
                    if !suggestions.isEmpty {
                        suggestionsSection
                    }

                    // 快捷功能
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("果效 | OS-AI")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                    }
                }
            }
        }
        .onAppear {
            loadSuggestions()
        }
    }

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("你好，")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("我是你的AI生活助手")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
    }

    private var aiAssistantSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("想帮你做什么？")
                .font(.headline)
                .foregroundColor(.secondary)

            // 输入框
            HStack {
                TextField("例如：提醒我明天下午3点开会", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isProcessing)

                Button(action: processInput) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
                .disabled(userInput.isEmpty || isProcessing)
            }

            // 结果展示
            if !processingResult.isEmpty {
                HStack(alignment: .top) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.green)

                    Text(processingResult)
                        .font(.body)
                        .foregroundColor(.primary)

                    Spacer()

                    Button(action: { processingResult = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var emotionSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("当前状态")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(osaiEngine.currentEmotion.description)
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Spacer()

            Image(systemName: getEmotionIcon())
                .font(.title)
                .foregroundColor(getEmotionColor())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("为你推荐")
                .font(.headline)
                .foregroundColor(.secondary)

            ForEach(suggestions.indices, id: \.self) { index in
                SuggestionCard(suggestion: suggestions[index])
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快捷功能")
                .font(.headline)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    icon: "checklist",
                    title: "创建待办",
                    color: .blue
                ) {
                    // 导航到待办页面
                }

                QuickActionButton(
                    icon: "calendar",
                    title: "添加日程",
                    color: .green
                ) {
                    // 导航到日程页面
                }

                QuickActionButton(
                    icon: "magnifyingglass",
                    title: "查快递",
                    color: .orange
                ) {
                    // 导航到快递页面
                }

                QuickActionButton(
                    icon: "doc.text",
                    title: "扫描文档",
                    color: .purple
                ) {
                    // 打开文档扫描
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private func processInput() {
        isProcessing = true

        Task {
            let result = await osaiEngine.processNaturalLanguageInput(userInput)
            await MainActor.run {
                processingResult = result.message
                userInput = ""
                isProcessing = false

                // 清空结果，5秒后自动消失
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    processingResult = ""
                }
            }
        }
    }

    private func loadSuggestions() {
        Task {
            suggestions = await osaiEngine.getPersonalizedSuggestions()
        }
    }

    private func getEmotionIcon() -> String {
        switch osaiEngine.currentEmotion {
        case .neutral:
            return "face.smiling"
        case .highPressure:
            return "exclamationmark.triangle.fill"
        case .relaxed:
            return "face.smiling.inverse"
        case .low:
            return "cloud.rain.fill"
        }
    }

    private func getEmotionColor() -> Color {
        switch osaiEngine.currentEmotion {
        case .neutral:
            return .blue
        case .highPressure:
            return .red
        case .relaxed:
            return .green
        case .low:
            return .gray
        }
    }
}

// MARK: - Suggestion Card

struct SuggestionCard: View {
    let suggestion: Suggestion

    var body: some View {
        HStack {
            Image(systemName: getSuggestionIcon())
                .font(.title2)
                .foregroundColor(getSuggestionColor())
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(suggestion.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            suggestion.action?()
        }
    }

    private func getSuggestionIcon() -> String {
        switch suggestion.type {
        case .relaxation:
            return "heart.fill"
        case .social:
            return "person.2.fill"
        case .task:
            return "checkmark.circle.fill"
        case .travel:
            return "airplane"
        case .entertainment:
            return "sparkles"
        }
    }

    private func getSuggestionColor() -> Color {
        switch suggestion.type {
        case .relaxation:
            return .pink
        case .social:
            return .blue
        case .task:
            return .green
        case .travel:
            return .orange
        case .entertainment:
            return .purple
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Todo View

struct TodoView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("待办事项")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("待办")
        }
    }
}

// MARK: - Calendar View

struct CalendarView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("日程管理")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("日程")
        }
    }
}

// MARK: - Delivery View

struct DeliveryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("快递查询")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("快递")
        }
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @EnvironmentObject var purchaseService: PurchaseService

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)

                        VStack(alignment: .leading) {
                            Text("果效用户")
                                .font(.headline)

                            Text(purchaseService.isProUser ? "Pro会员" : "免费用户")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if purchaseService.isProUser {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("订阅") {
                    if purchaseService.isProUser {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Pro会员")
                                    .font(.headline)

                                Text(purchaseService.subscriptionStatus.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                    } else {
                        Button(action: {}) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("升级到Pro")
                                        .font(.headline)
                                        .foregroundColor(.green)

                                    Text("解锁全部功能")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section("设置") {
                    HStack {
                        Image(systemName: "gear")
                        Text("通用设置")
                    }

                    HStack {
                        Image(systemName: "bell")
                        Text("通知设置")
                    }

                    HStack {
                        Image(systemName: "icloud")
                        Text("云同步")
                    }

                    HStack {
                        Image(systemName: "info.circle")
                        Text("关于果效")
                    }
                }
            }
            .navigationTitle("我的")
        }
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Logo
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(.green)

            // Title
            VStack(spacing: 8) {
                Text("果效 | OS-AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("懂你所想，办你所盼")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "brain", title: "AI智能", description: "自然语言理解，主动感知需求")
                FeatureRow(icon: "lock.shield", title: "隐私安全", title: "端侧本地处理，零数据收集")
                FeatureRow(icon: "globe", title: "全球通用", description: "自动适配地区服务，无缝跨境使用")
            }
            .padding()

            Spacer()

            // Button
            Button(action: {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                isPresented = false
            }) {
                Text("开始使用")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding()
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Purchase View

struct PurchaseView: View {
    @EnvironmentObject var purchaseService: PurchaseService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)

                        Text("升级到Pro")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("解锁全部AI功能")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()

                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pro功能")
                            .font(.headline)

                        ProFeatureRow(icon: "brain", title: "三层共情式智能")
                        ProFeatureRow(icon: "siri", title: "Siri深度集成")
                        ProFeatureRow(icon: "ipad", title: "全设备原生适配")
                        ProFeatureRow(icon: "person.3", title: "家庭共享(最多6人)")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)

                    // Pricing
                    VStack(spacing: 12) {
                        if let monthlyProduct = purchaseService.getMonthlyProduct() {
                            PurchaseOptionRow(
                                product: monthlyProduct,
                                isPopular: false
                            )
                        }

                        if let yearlyProduct = purchaseService.getYearlyProduct() {
                            PurchaseOptionRow(
                                product: yearlyProduct,
                                isPopular: true
                            )
                        }
                    }
                    .padding()

                    // Terms
                    VStack(alignment: .leading, spacing: 8) {
                        Text("订阅说明")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("• 订阅自动续费，可随时取消")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("• 7天免费试用")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("• 支持苹果家庭共享")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle("升级到Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProFeatureRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
            Text(title)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundColor(.green)
        }
    }
}

struct PurchaseOptionRow: View {
    let product: Product
    let isPopular: Bool

    @EnvironmentObject var purchaseService: PurchaseService

    var body: some View {
        Button(action: {}) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(product.displayPrice)
                        .font(.headline)
                        .foregroundColor(.green)

                    if isPopular {
                        Text("最受欢迎")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(isPopular ? Color.green.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isPopular ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .disabled(purchaseService.isLoading)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
