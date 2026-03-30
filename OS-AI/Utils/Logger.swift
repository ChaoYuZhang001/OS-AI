//
//  Logger.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  日志系统 - 统一的日志管理
//

import Foundation
import os.log

/// OS-AI日志系统
/// 提供统一的日志记录、分级输出和日志管理
final class Logger {

    // MARK: - Singleton
    static let shared = Logger()

    // MARK: - Properties
    private let subsystem = "com.osai.app"
    private let isDebugMode: Bool

    // MARK: - Log Categories
    enum Category: String {
        case app = "App"
        case core = "Core"
        case network = "Network"
        case database = "Database"
        case ui = "UI"
        case performance = "Performance"
        case security = "Security"
    }

    // MARK: - Log Levels
    enum Level: Int, Comparable {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3
        case critical = 4

        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .critical: return "🚨"
            }
        }

        static func < (lhs: Level, rhs: Level) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    // MARK: - Configuration
    private var currentLevel: Level = .debug

    // MARK: - Initialization
    private init() {
        #if DEBUG
        isDebugMode = true
        currentLevel = .debug
        #else
        isDebugMode = false
        currentLevel = .info
        #endif
    }

    // MARK: - Public Methods

    /// 设置日志级别
    func setLevel(_ level: Level) {
        currentLevel = level
    }

    /// Debug日志
    func debug(_ message: String, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message, category: category, file: file, function: function, line: line)
    }

    /// Info日志
    func info(_ message: String, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message, category: category, file: file, function: function, line: line)
    }

    /// Warning日志
    func warning(_ message: String, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message, category: category, file: file, function: function, line: line)
    }

    /// Error日志
    func error(_ message: String, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message, category: category, file: file, function: function, line: line)
    }

    /// Critical日志
    func critical(_ message: String, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(.critical, message, category: category, file: file, function: function, line: line)
    }

    /// 记录API调用
    func apiCall(_ endpoint: String, method: String = "GET", file: String = #file, line: Int = #line) {
        debug("API Call: \(method) \(endpoint)", category: .network, file: file, line: line)
    }

    /// 记录数据库操作
    func database(_ operation: String, file: String = #file, line: Int = #line) {
        debug("Database: \(operation)", category: .database, file: file, line: line)
    }

    /// 记录性能指标
    func performance(_ metric: String, value: TimeInterval, file: String = #file, line: Int = #line) {
        info("Performance: \(metric) = \(value)s", category: .performance, file: file, line: line)
    }

    /// 记录安全事件
    func security(_ event: String, file: String = #file, line: Int = #line) {
        warning("Security: \(event)", category: .security, file: file, line: line)
    }

    /// 记录错误信息
    func error(_ error: Error, category: Category = .app, file: String = #file, function: String = #function, line: Int = #line) {
        let errorMessage = "\(error.localizedDescription)"
        log(.error, errorMessage, category: category, file: file, function: function, line: line)
    }

    // MARK: - Private Methods

    private func log(_ level: Level, _ message: String, category: Category, file: String, function: String, line: Int) {
        // 检查日志级别
        if level < currentLevel {
            return
        }

        // 获取文件名和函数名
        let fileName = (file as NSString).lastPathComponent
        let functionName = function

        // 格式化日志
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(level.emoji)] [\(timestamp)] [\(category.rawValue)] \(message)"

        // 输出到控制台
        print(logMessage)

        // 使用OSLog记录（仅生产环境）
        if !isDebugMode {
            let osLog = OSLog(subsystem: subsystem, category: category.rawValue)
            switch level {
            case .debug:
                osLog.debug("%{public}@", message)
            case .info:
                osLog.info("%{public}@", message)
            case .warning:
                osLog.default("%{public}@", message)
            case .error:
                osLog.error("%{public}@", message)
            case .critical:
                osLog.fault("%{public}@", message)
            }
        }
    }
}

// MARK: - Convenience Extensions

extension Logger {

    /// 记录用户操作
    func userAction(_ action: String) {
        info("User Action: \(action)", category: .ui)
    }

    /// 记录视图切换
    func viewTransition(from: String, to: String) {
        debug("View Transition: \(from) → \(to)", category: .ui)
    }

    /// 记录网络请求开始
    func networkRequestStarted(url: String) {
        debug("Network Request Started: \(url)", category: .network)
    }

    /// 记录网络请求成功
    func networkRequestSucceeded(url: String, duration: TimeInterval) {
        info("Network Request Succeeded: \(url) (\(duration)s)", category: .network)
    }

    /// 记录网络请求失败
    func networkRequestFailed(url: String, error: Error) {
        error("Network Request Failed: \(url) - \(error.localizedDescription)", category: .network)
    }
}

// MARK: - Global Convenience Functions

/// 全局日志记录器
let log = Logger.shared

/// Debug日志
func debugLog(_ message: String, category: Logger.Category = .app, file: String = #file, line: Int = #line) {
    log.debug(message, category: category, file: file, line: line)
}

/// Info日志
func infoLog(_ message: String, category: Logger.Category = .app, file: String = #file, line: Int = #line) {
    log.info(message, category: category, file: file, line: line)
}

/// Warning日志
func warningLog(_ message: String, category: Logger.Category = .app, file: String = #file, line: Int = #line) {
    log.warning(message, category: category, file: file, line: line)
}

/// Error日志
func errorLog(_ message: String, category: Logger.Category = .app, file: String = #file, line: Int = #line) {
    log.error(message, category: category, file: file, line: line)
}

/// Critical日志
func criticalLog(_ message: String, category: Logger.Category = .app, file: String = #file, line: Int = #line) {
    log.critical(message, category: category, file: file, line: line)
}

/// 记录错误
func logError(_ error: Error, category: Logger.Category = .app, file: String = #file, line: Int = #line) {
    log.error(error, category: category, file: file, line: line)
}
