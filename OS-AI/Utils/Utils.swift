//
//  Utils.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  工具类 - 常用工具函数
//

import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {

    /// 格式化为日期字符串
    func formatted(_ style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    /// 格式化为时间字符串
    func formattedTime(_ style: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = style
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    /// 格式化为日期时间字符串
    func formattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    /// 判断是否为今天
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    /// 判断是否为明天
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }

    /// 判断是否为本周
    var isThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// 判断是否为过去
    var isPast: Bool {
        return self < Date()
    }

    /// 判断是否为未来
    var isFuture: Bool {
        return self > Date()
    }

    /// 相对时间描述
    var relativeDescription: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: self)

        if components.day == 0 {
            if let hour = components.hour, hour > 0 {
                return "\(hour)小时后"
            }
            if let minute = components.minute, minute > 0 {
                return "\(minute)分钟后"
            }
            return "刚刚"
        } else if components.day == 1 {
            return "明天"
        } else if components.day == -1 {
            return "昨天"
        } else if components.day! > 0 {
            return "\(components.day!)天后"
        } else if components.day! < 0 {
            return "\(abs(components.day!))天前"
        }

        return formatted()
    }

    /// 获取星期几
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    /// 获取月初
    var startOfMonth: Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }

    /// 获取月末
    var endOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let month = calendar.date(from: components) else { return self }
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: month)!
    }
}

// MARK: - String Extensions

extension String {

    /// 判断是否为空或只包含空格
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 判断是否为空字符串
    var isEmptyOrWhitespace: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 去除首尾空格
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 判断是否为有效的URL
    var isValidURL: Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return false
        }
        return detector.firstMatch(in: self, range: NSRange(location: 0, length: self.utf16.count)) != nil
    }

    /// 判断是否为有效的邮箱
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// 判断是否为有效的手机号
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^1[3-9]\\d{9}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }

    /// 转换为Date对象
    var toDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self)
    }

    /// 转换为Double
    var toDouble: Double? {
        return Double(self)
    }

    /// 转换为Int
    var toInt: Int? {
        return Int(self)
    }

    /// 截断字符串
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count <= length {
            return self
        }
        return String(self.prefix(length)) + trailing
    }

    /// 首字母大写
    var capitalizedFirst: String {
        return prefix(1).capitalized + dropFirst()
    }
}

// MARK: - Array Extensions

extension Array {

    /// 安全获取索引处的元素
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    /// 去重
    func unique() -> [Element] where Element: Hashable {
        return Array(Set(self))
    }

    /// 分组
    func group<Key: Hashable>(by keyPath: KeyPath<Element, Key>) -> [Key: [Element]] {
        return Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }

    /// 排序
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        return sorted {
            if ascending {
                return $0[keyPath: keyPath] < $1[keyPath: keyPath]
            } else {
                return $0[keyPath: keyPath] > $1[keyPath: keyPath]
            }
        }
    }

    /// 过滤非空
    func compacted<T>() -> [T] where Element == T? {
        return compactMap { $0 }
    }

    /// 分块
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Double Extensions

extension Double {

    /// 格式化为货币
    func formattedCurrency(currencyCode: String = "CNY") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }

    /// 格式化为百分比
    func formattedPercentage(digits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }

    /// 格式化为KB/MB/GB
    func formattedBytes() -> String {
        let byteUnits = ["B", "KB", "MB", "GB", "TB"]
        var value = self
        var unitIndex = 0

        while value >= 1024 && unitIndex < byteUnits.count - 1 {
            value /= 1024
            unitIndex += 1
        }

        return String(format: "%.1f %@", value, byteUnits[unitIndex])
    }

    /// 四舍五入到指定小数位
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    /// 判断是否为整数
    var isInteger: Bool {
        return self == self.rounded()
    }
}

// MARK: - Color Extensions

extension Color {

    /// 从十六进制字符串创建颜色
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// 转换为十六进制字符串
    func toHex() -> String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return String(format: "#%06x", rgb)
        #else
        return "#000000"
        #endif
    }
}

// MARK: - View Extensions

extension View {

    /// 条件显示
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// 隐藏
    @ViewBuilder
    func hidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }

    /// 条件隐藏
    @ViewBuilder
    func hidden(_ condition: Bool) -> some View {
        if condition {
            self.hidden()
        } else {
            self
        }
    }

    /// 添加边框
    func border(width: CGFloat, color: Color) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(color, lineWidth: width)
        )
    }

    /// 添加圆角边框
    func roundedBorder(width: CGFloat, color: Color, cornerRadius: CGFloat) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color, lineWidth: width)
        )
    }

    /// 添加阴影
    func shadow(color: Color = .black, radius: CGFloat = 5, x: CGFloat = 0, y: CGFloat = 2) -> some View {
        self.shadow(color: color, radius: radius, x: x, y: y)
    }

    /// 玻璃效果
    func glassBackground(radius: CGFloat = 10) -> some View {
        self.background(
            Color.white.opacity(0.3)
                .blur(radius: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Throttle

/// 节流工具
class Throttle {
    private var workItem: DispatchWorkItem?
    private let delay: TimeInterval
    private let queue: DispatchQueue

    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    func throttle(_ block: @escaping () -> Void) {
        workItem?.cancel()

        let newWorkItem = DispatchWorkItem(block: block)
        workItem = newWorkItem

        queue.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
}

// MARK: - Debounce

/// 防抖工具
class Debounce {
    private var workItem: DispatchWorkItem?
    private let delay: TimeInterval
    private let queue: DispatchQueue

    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    func debounce(_ block: @escaping () -> Void) {
        workItem?.cancel()

        let newWorkItem = DispatchWorkItem(block: block)
        workItem = newWorkItem

        queue.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
}

// MARK: - Constants

/// 应用常量
struct AppConstants {
    struct UserDefaults {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastSyncDate = "lastSyncDate"
        static let userPreferencesVersion = "userPreferencesVersion"
    }

    struct Notification {
        static let todoReminder = "todo.reminder"
        static let calendarReminder = "calendar.reminder"
        static let deliveryUpdate = "delivery.update"
        static let billReminder = "bill.reminder"
        static let suggestion = "suggestion"
    }

    struct Storage {
        static let maxFileSize = 50 * 1024 * 1024 // 50MB
        static let maxCacheSize = 100 * 1024 * 1024 // 100MB
    }

    struct Animation {
        static let defaultDuration = 0.3
        static let fastDuration = 0.15
        static let slowDuration = 0.6
    }
}

// MARK: - Helper Functions

/// 延迟执行
func delay(_ seconds: TimeInterval, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

/// 主线程执行
func onMain(_ completion: @escaping () -> Void) {
    DispatchQueue.main.async(execute: completion)
}

/// 后台线程执行
func onBackground(_ completion: @escaping () -> Void) {
    DispatchQueue.global(qos: .userInitiated).async(execute: completion)
}

/// 生成随机ID
func generateID() -> String {
    return UUID().uuidString
}

/// 验证手机号
func isValidPhoneNumber(_ phone: String) -> Bool {
    let phoneRegex = "^1[3-9]\\d{9}$"
    let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
    return phonePredicate.evaluate(with: phone)
}

/// 验证邮箱
func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}
