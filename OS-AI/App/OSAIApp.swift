//
//  OSAIApp.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  果效 | OS-AI - 全原生智能数字生活合伙人
//

import SwiftUI
import SwiftData
import StoreKit

@main
struct OSAIApp: App {

    // MARK: - Environment Objects
    @StateObject private var osaiEngine = OSAIEngine.shared
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var cloudService = CloudService.shared
    @StateObject private var notificationService = NotificationService.shared

    // MARK: - SwiftData Container
    @StateObject private var dataController = DataController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(osaiEngine)
                .environmentObject(purchaseService)
                .environmentObject(cloudService)
                .environmentObject(notificationService)
                .environment(\.modelContext, dataController.container.mainContext)
                .onAppear {
                    setupApp()
                }
        }
        .modelContainer(dataController.container)
        .backgroundTask(.appRefresh("OSAISync")) {
            await osaiEngine.performBackgroundSync()
        }
    }

    // MARK: - Setup
    private func setupApp() {
        // 初始化OS-AI引擎
        Task {
            await osaiEngine.initialize()

            // 初始化购买服务
            await purchaseService.initialize()

            // 初始化云服务
            await cloudService.initialize()

            // 初始化通知服务
            await notificationService.requestAuthorization()
        }

        // 配置Siri集成
        configureSiriIntegration()

        // 配置健康数据集成
        configureHealthKitIntegration()
    }

    private func configureSiriIntegration() {
        // Siri快捷指令在首次使用时动态注册
    }

    private func configureHealthKitIntegration() {
        // 健康数据权限按需申请
    }
}

// MARK: - Data Controller
class DataController: ObservableObject {
    static let shared = DataController()

    @Published var container: ModelContainer

    private init() {
        let schema = Schema([
            TodoItem.self,
            CalendarEvent.self,
            DeliveryItem.self,
            PaymentItem.self,
            UserPreference.self,
            BehaviorRecord.self
        ])

        do {
            container = try ModelContainer(
                for: schema,
                configurations: [
                    ModelConfiguration(isStoredInMemoryOnly: false),
                    ModelConfiguration(for: TodoItem.self, cloudKitDatabase: .private),
                    ModelConfiguration(for: CalendarEvent.self, cloudKitDatabase: .private),
                    ModelConfiguration(for: DeliveryItem.self, cloudKitDatabase: .private),
                    ModelConfiguration(for: PaymentItem.self, cloudKitDatabase: .private),
                    ModelConfiguration(for: UserPreference.self, cloudKitDatabase: .private),
                    ModelConfiguration(for: BehaviorRecord.self, cloudKitDatabase: .private)
                ]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
