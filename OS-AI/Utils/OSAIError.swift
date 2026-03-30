//
//  OSAIError.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  错误处理 - 统一的错误定义和处理
//

import Foundation

/// OS-AI自定义错误类型
enum OSAIError: LocalizedError, CustomStringConvertible {

    // MARK: - General Errors
    case unknown
    case operationFailed(String)

    // MARK: - Data Errors
    case dataNotFound
    case dataCorrupted
    case dataSaveFailed(underlying: Error?)
    case dataLoadFailed(underlying: Error?)

    // MARK: - Network Errors
    case networkUnavailable
    case networkTimeout
    case serverError(code: Int, message: String)
    case invalidURL
    case requestFailed(reason: String)

    // MARK: - Authentication Errors
    case unauthorized
    case tokenExpired
    case invalidCredentials
    case permissionDenied

    // MARK: - Validation Errors
    case invalidInput(field: String, reason: String)
    case missingRequiredField(field: String)
    case valueOutOfRange(field: String, value: String, range: String)

    // MARK: - Feature Errors
    case featureNotAvailable(feature: String)
    case featureRequiresUpgrade(feature: String)
    case featureLimitExceeded(feature: String, limit: Int)

    // MARK: - Integration Errors
    case integrationFailed(service: String, reason: String)
    case serviceNotConfigured(service: String)
    case rateLimitExceeded(service: String)

    // MARK: - Storage Errors
    case storageQuotaExceeded
    case fileNotFound(path: String)
    case fileCorrupted(path: String)

    // MARK: - System Errors
    case systemUnavailable
    case osVersionNotSupported(minVersion: String)
    case deviceNotSupported(reason: String)

    var errorDescription: String? {
        return self.localizedDescription
    }

    var failureReason: String? {
        return "OS-AI Error"
    }

    var localizedDescription: String {
        switch self {
        case .unknown:
            return "未知错误"
        case .operationFailed(let reason):
            return "操作失败: \(reason)"

        case .dataNotFound:
            return "数据未找到"
        case .dataCorrupted:
            return "数据已损坏"
        case .dataSaveFailed(let error):
            return "数据保存失败: \(error?.localizedDescription ?? "未知原因")"
        case .dataLoadFailed(let error):
            return "数据加载失败: \(error?.localizedDescription ?? "未知原因")"

        case .networkUnavailable:
            return "网络不可用"
        case .networkTimeout:
            return "网络请求超时"
        case .serverError(let code, let message):
            return "服务器错误 (\(code)): \(message)"
        case .invalidURL:
            return "无效的URL"
        case .requestFailed(let reason):
            return "请求失败: \(reason)"

        case .unauthorized:
            return "未授权"
        case .tokenExpired:
            return "令牌已过期"
        case .invalidCredentials:
            return "无效的凭证"
        case .permissionDenied:
            return "权限被拒绝"

        case .invalidInput(let field, let reason):
            return "无效的输入: \(field) - \(reason)"
        case .missingRequiredField(let field):
            return "缺少必填字段: \(field)"
        case .valueOutOfRange(let field, let value, let range):
            return "\(field)的值超出范围: \(value) (范围: \(range))"

        case .featureNotAvailable(let feature):
            return "功能不可用: \(feature)"
        case .featureRequiresUpgrade(let feature):
            return "功能\(feature)需要升级到Pro版本"
        case .featureLimitExceeded(let feature, let limit):
            return "功能\(feature)超出限制，最大\(limit)个"

        case .integrationFailed(let service, let reason):
            return "服务\(service)集成失败: \(reason)"
        case .serviceNotConfigured(let service):
            return "服务\(service)未配置"
        case .rateLimitExceeded(let service):
            return "服务\(service)超过速率限制"

        case .storageQuotaExceeded:
            return "存储空间已满"
        case .fileNotFound(let path):
            return "文件未找到: \(path)"
        case .fileCorrupted(let path):
            return "文件已损坏: \(path)"

        case .systemUnavailable:
            return "系统不可用"
        case .osVersionNotSupported(let version):
            return "系统版本不支持，最低要求: \(version)"
        case .deviceNotSupported(let reason):
            return "设备不支持: \(reason)"
        }
    }

    var description: String {
        return localizedDescription
    }

    // MARK: - Error Type
    var type: ErrorType {
        switch self {
        case .unknown, .operationFailed:
            return .general
        case .dataNotFound, .dataCorrupted, .dataSaveFailed, .dataLoadFailed:
            return .data
        case .networkUnavailable, .networkTimeout, .serverError, .invalidURL, .requestFailed:
            return .network
        case .unauthorized, .tokenExpired, .invalidCredentials, .permissionDenied:
            return .authentication
        case .invalidInput, .missingRequiredField, .valueOutOfRange:
            return .validation
        case .featureNotAvailable, .featureRequiresUpgrade, .featureLimitExceeded:
            return .feature
        case .integrationFailed, .serviceNotConfigured, .rateLimitExceeded:
            return .integration
        case .storageQuotaExceeded, .fileNotFound, .fileCorrupted:
            return .storage
        case .systemUnavailable, .osVersionNotSupported, .deviceNotSupported:
            return .system
        }
    }

    // MARK: - Recovery Suggestion
    var recoverySuggestion: String {
        switch self {
        case .networkUnavailable:
            return "请检查网络连接"
        case .networkTimeout:
            return "请稍后重试"
        case .tokenExpired:
            return "请重新登录"
        case .permissionDenied:
            return "请检查权限设置"
        case .featureRequiresUpgrade:
            return "请升级到Pro版本"
        case .storageQuotaExceeded:
            return "请清理存储空间"
        case .osVersionNotSupported:
            return "请更新系统版本"
        default:
            return "请稍后重试，如果问题持续存在，请联系客服"
        }
    }
}

enum ErrorType {
    case general
    case data
    case network
    case authentication
    case validation
    case feature
    case integration
    case storage
    case system
}

// MARK: - Error Handler

/// 错误处理器
final class ErrorHandler {

    static let shared = ErrorHandler()

    private init() {}

    /// 处理错误
    func handle(_ error: Error) {
        if let osaiError = error as? OSAIError {
            log.error(osaiError.description)
            print("❌ [\(osaiError.type)] \(osaiError.description)")
            print("💡 建议: \(osaiError.recoverySuggestion)")
        } else {
            log.error(error.localizedDescription)
            print("❌ \(error.localizedDescription)")
        }
    }

    /// 处理错误并返回用户友好的消息
    func handle(_ error: Error) -> (title: String, message: String) {
        if let osaiError = error as? OSAIError {
            log.error(osaiError.description)

            switch osaiError {
            case .featureRequiresUpgrade:
                return (
                    title: "需要升级",
                    message: osaiError.description
                )
            case .networkUnavailable, .networkTimeout:
                return (
                    title: "网络错误",
                    message: osaiError.description
                )
            case .unauthorized, .tokenExpired:
                return (
                    title: "授权错误",
                    message: osaiError.description
                )
            default:
                return (
                    title: "错误",
                    message: osaiError.description
                )
            }
        } else {
            log.error(error.localizedDescription)
            return (
                title: "错误",
                message: error.localizedDescription
            )
        }
    }

    /// 转换为OSAIError
    func convert(_ error: Error) -> OSAIError {
        if let osaiError = error as? OSAIError {
            return osaiError
        }

        // 根据NSError类型转换
        let nsError = error as NSError

        switch nsError.domain {
        case NSURLErrorDomain:
            return convertNetworkError(nsError)
        default:
            return .operationFailed(nsError.localizedDescription)
        }
    }

    private func convertNetworkError(_ error: NSError) -> OSAIError {
        let code = error.code

        switch code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return .networkUnavailable
        case NSURLErrorTimedOut:
            return .networkTimeout
        case NSURLErrorBadURL:
            return .invalidURL
        default:
            return .requestFailed(reason: error.localizedDescription)
        }
    }
}

// MARK: - Result Extensions

extension Result {

    /// 获取值或处理错误
    func unwrap() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }

    /// 执行操作或处理错误
    func map<T>(_ transform: (Success) -> T) -> Result<T, Failure> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }

    /// 链式操作
    func flatMap<T>(_ transform: (Success) -> Result<T, Failure>) -> Result<T, Failure> {
        switch self {
        case .success(let value):
            return transform(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Global Error Handler

let errorHandler = ErrorHandler.shared

/// 便捷的错误处理函数
func handleError(_ error: Error) {
    errorHandler.handle(error)
}

/// 便捷的错误信息获取函数
func getErrorMessage(_ error: Error) -> (title: String, message: String) {
    return errorHandler.handle(error)
}
