//
//  NotificationService.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  通知服务 - 本地通知管理
//

import Foundation
import UserNotifications

/// 通知服务
/// 管理本地通知、定时提醒
@MainActor
final class NotificationService: ObservableObject {

    // MARK: - Singleton
    static let shared = NotificationService()

    // MARK: - Published Properties
    @Published var isAuthorized = false
    @Published var notificationSettings: UNNotificationSettings?

    // MARK: - Initialization
    private init() {}

    // MARK: - Public Methods

    /// 请求通知权限
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .sound, .badge]
            )

            isAuthorized = granted

            if granted {
                print("✅ Notification authorization granted")
            } else {
                print("ℹ️ Notification authorization denied")
            }

            // 获取当前设置
            await updateNotificationSettings()

            return granted
        } catch {
            print("❌ Failed to request notification authorization: \(error)")
            isAuthorized = false
            return false
        }
    }

    /// 检查通知权限
    func checkAuthorization() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        isAuthorized = settings.authorizationStatus == .authorized
        notificationSettings = settings
    }

    /// 更新通知设置
    func updateNotificationSettings() async {
        let center = UNUserNotificationCenter.current()
        notificationSettings = await center.notificationSettings()
    }

    /// 发送待办提醒通知
    /// - Parameters:
    ///   - todo: 待办事项
    ///   - scheduledDate: 计划时间
    func scheduleTodoReminder(for todo: TodoItem, at scheduledDate: Date) async {
        guard isAuthorized else {
            print("❌ Notification not authorized")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "待办提醒"
        content.body = "别忘了：\(todo.content)"
        content.sound = .default
        content.badge = 1

        // 添加分类标识
        content.categoryIdentifier = "TODO_REMINDER"

        // 创建触发器
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: scheduledDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )

        // 创建请求
        let request = UNNotificationRequest(
            identifier: "todo_\(todo.id.uuidString)",
            content: content,
            trigger: trigger
        )

        // 添加请求
        do {
            let center = UNUserNotificationCenter.current()
            try await center.add(request)
            print("✅ Todo reminder scheduled for: \(scheduledDate)")
        } catch {
            print("❌ Failed to schedule todo reminder: \(error)")
        }
    }

    /// 发送日程提醒通知
    /// - Parameters:
    ///   - event: 日程事件
    ///   - minutesBefore: 提前多少分钟提醒
    func scheduleEventReminder(for event: CalendarEvent, minutesBefore: Int) async {
        guard isAuthorized else {
            print("❌ Notification not authorized")
            return
        }

        let reminderDate = event.startDate.addingTimeInterval(-Double(minutesBefore * 60))

        let content = UNMutableNotificationContent()
        content.title = "日程提醒"
        content.body = "\(minutesBefore)分钟后：\(event.title)"
        content.sound = .default
        content.categoryIdentifier = "EVENT_REMINDER"

        // 创建触发器
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )

        // 创建请求
        let request = UNNotificationRequest(
            identifier: "event_\(event.id.uuidString)",
            content: content,
            trigger: trigger
        )

        // 添加请求
        do {
            let center = UNUserNotificationCenter.current()
            try await center.add(request)
            print("✅ Event reminder scheduled for: \(reminderDate)")
        } catch {
            print("❌ Failed to schedule event reminder: \(error)")
        }
    }

    /// 发送快递状态更新通知
    /// - Parameter delivery: 快递信息
    func sendDeliveryUpdateNotification(for delivery: DeliveryItem) async {
        guard isAuthorized else {
            print("❌ Notification not authorized")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "快递状态更新"
        content.body = "\(delivery.carrier)：\(delivery.status.rawValue)"
        content.sound = .default
        content.categoryIdentifier = "DELIVERY_UPDATE"

        // 立即发送
        let request = UNNotificationRequest(
            identifier: "delivery_\(delivery.id.uuidString)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // nil表示立即发送
        )

        // 添加请求
        do {
            let center = UNUserNotificationCenter.current()
            try await center.add(request)
            print("✅ Delivery update notification sent")
        } catch {
            print("❌ Failed to send delivery update notification: \(error)")
        }
    }

    /// 发送账单提醒通知
    /// - Parameters:
    ///   - payment: 账单信息
    ///   - daysBefore: 提前几天提醒
    func scheduleBillReminder(for payment: PaymentItem, daysBefore: Int) async {
        guard isAuthorized else {
            print("❌ Notification not authorized")
            return
        }

        let reminderDate = payment.dueDate.addingTimeInterval(-Double(daysBefore * 24 * 60 * 60))

        let content = UNMutableNotificationContent()
        content.title = "账单提醒"
        content.body = "\(daysBefore)天后：\(payment.provider) \(payment.billType.rawValue) \(formatCurrency(payment.amount))"
        content.sound = .default
        content.categoryIdentifier = "BILL_REMINDER"

        // 创建触发器
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )

        // 创建请求
        let request = UNNotificationRequest(
            identifier: "bill_\(payment.id.uuidString)",
            content: content,
            trigger: trigger
        )

        // 添加请求
        do {
            let center = UNUserNotificationCenter.current()
            try await center.add(request)
            print("✅ Bill reminder scheduled for: \(reminderDate)")
        } catch {
            print("❌ Failed to schedule bill reminder: \(error)")
        }
    }

    /// 发送个性化建议通知
    /// - Parameters:
    ///   - suggestion: 建议内容
    ///   - delaySeconds: 延迟多少秒发送
    func sendSuggestionNotification(_ suggestion: Suggestion, after delaySeconds: TimeInterval = 0) async {
        guard isAuthorized else {
            print("❌ Notification not authorized")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "智能建议"
        content.body = suggestion.description
        content.sound = .default
        content.categoryIdentifier = "SUGGESTION"

        // 创建触发器
        let trigger: UNNotificationTrigger
        if delaySeconds > 0 {
            trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: delaySeconds,
                repeats: false
            )
        } else {
            trigger = nil
        }

        // 创建请求
        let request = UNNotificationRequest(
            identifier: "suggestion_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        // 添加请求
        do {
            let center = UNUserNotificationCenter.current()
            try await center.add(request)
            print("✅ Suggestion notification sent")
        } catch {
            print("❌ Failed to send suggestion notification: \(error)")
        }
    }

    /// 取消所有通知
    func cancelAllNotifications() async {
        let center = UNUserNotificationCenter.current()
        await center.removeAllPendingNotificationRequests()
        await center.removeAllDeliveredNotifications()
        print("✅ All notifications cancelled")
    }

    /// 取消特定通知
    /// - Parameter identifier: 通知标识符
    func cancelNotification(withIdentifier identifier: String) async {
        let center = UNUserNotificationCenter.current()
        await center.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("✅ Notification cancelled: \(identifier)")
    }

    /// 获取待发送通知
    func getPendingNotifications() async -> [UNNotificationRequest] {
        let center = UNUserNotificationCenter.current()
        return await center.pendingNotificationRequests()
    }

    /// 设置通知分类
    func setupNotificationCategories() {
        let center = UNUserNotificationCenter.current()

        // 待办提醒分类
        let todoCategory = UNNotificationCategory(
            identifier: "TODO_REMINDER",
            actions: [
                UNNotificationAction(identifier: "MARK_DONE", title: "完成", options: .foreground),
                UNNotificationAction(identifier: "SNOOZE", title: "稍后", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )

        // 日程提醒分类
        let eventCategory = UNNotificationCategory(
            identifier: "EVENT_REMINDER",
            actions: [
                UNNotificationAction(identifier: "VIEW_EVENT", title: "查看", options: .foreground),
                UNNotificationAction(identifier: "DISMISS", title: "忽略", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )

        // 快递更新分类
        let deliveryCategory = UNNotificationCategory(
            identifier: "DELIVERY_UPDATE",
            actions: [
                UNNotificationAction(identifier: "TRACK", title: "追踪", options: .foreground)
            ],
            intentIdentifiers: [],
            options: []
        )

        // 账单提醒分类
        let billCategory = UNNotificationCategory(
            identifier: "BILL_REMINDER",
            actions: [
                UNNotificationAction(identifier: "PAY_NOW", title: "立即支付", options: .foreground),
                UNNotificationAction(identifier: "REMIND_LATER", title: "稍后提醒", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )

        // 建议分类
        let suggestionCategory = UNNotificationCategory(
            identifier: "SUGGESTION",
            actions: [
                UNNotificationAction(identifier: "ACCEPT", title: "接受", options: .foreground),
                UNNotificationAction(identifier: "DISMISS", title: "忽略", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([
            todoCategory,
            eventCategory,
            deliveryCategory,
            billCategory,
            suggestionCategory
        ])

        print("✅ Notification categories set up")
    }

    // MARK: - Private Methods

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: NSNumber(value: amount)) ?? ""
    }
}
