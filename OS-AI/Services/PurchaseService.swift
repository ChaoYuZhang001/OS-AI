//
//  PurchaseService.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  内购服务 - 基于StoreKit的内购管理
//

import Foundation
import StoreKit

/// 内购服务
/// 管理应用内购买、订阅、权益控制
@MainActor
final class PurchaseService: ObservableObject {

    // MARK: - Singleton
    static let shared = PurchaseService()

    // MARK: - Published Properties
    @Published var isProUser = false
    @Published var subscriptionStatus: SubscriptionStatus = .notSubscribed
    @Published var products: [Product] = []
    @Published var isLoading = false

    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    private var productIDs: Set<String> {
        return [
            "com.osai.pro.monthly",
            "com.osai.pro.yearly"
        ]
    }

    // MARK: - Initialization
    private init() {
        updateListenerTask = listenForTransactions()
    }

    // MARK: - Public Methods

    /// 初始化
    func initialize() async {
        isLoading = true
        defer { isLoading = false }

        // 加载产品
        await loadProducts()

        // 检查订阅状态
        await checkSubscriptionStatus()

        print("✅ PurchaseService initialized")
    }

    /// 加载产品
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            print("✅ Loaded \(products.count) products")
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    /// 购买产品
    /// - Parameter product: 要购买的产品
    /// - Returns: 购买结果
    func purchase(_ product: Product) async -> PurchaseResult {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                print("✅ Purchase successful: \(verification)")
                await handlePurchaseSuccess(verification)

                return .success

            case .userCancelled:
                print("ℹ️ Purchase cancelled by user")
                return .cancelled

            case .pending:
                print("ℹ️ Purchase pending")
                return .pending

            @unknown default:
                print("❌ Unknown purchase result")
                return .failed
            }
        } catch {
            print("❌ Purchase failed: \(error)")
            return .failed
        }
    }

    /// 恢复购买
    func restorePurchases() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
            return true
        } catch {
            print("❌ Failed to restore purchases: \(error)")
            return false
        }
    }

    /// 检查订阅状态
    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .autoRenewable {
                    isProUser = true
                    subscriptionStatus = .active(transaction.expirationDate)
                    print("✅ Active subscription found")
                    return
                }
            }
        }

        isProUser = false
        subscriptionStatus = .notSubscribed
        print("ℹ️ No active subscription found")
    }

    /// 检查Pro功能是否可用
    func isProFeatureAvailable() -> Bool {
        return isProUser
    }

    /// 获取月度订阅产品
    func getMonthlyProduct() -> Product? {
        return products.first { $0.id == "com.osai.pro.monthly" }
    }

    /// 获取年度订阅产品
    func getYearlyProduct() -> Product? {
        return products.first { $0.id == "com.osai.pro.yearly" }
    }

    /// 获取产品价格（格式化）
    func getFormattedPrice(for product: Product) -> String {
        return product.displayPrice
    }

    // MARK: - Private Methods

    private func handlePurchaseSuccess(_ verification: Transaction.Verification) async {
        if case .verified(let transaction) = verification {
            await transaction.finish()
            await checkSubscriptionStatus()
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await MainActor.run {
                        Task {
                            await self.handlePurchaseSuccess(result)
                        }
                    }
                    await transaction.finish()
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
            }
        }
    }
}

// MARK: - Supporting Types

enum SubscriptionStatus: Equatable {
    case notSubscribed
    case active(Date?)
    case expired
    case pending
    case cancelled

    var isActive: Bool {
        if case .active = self {
            return true
        }
        return false
    }

    var description: String {
        switch self {
        case .notSubscribed:
            return "未订阅"
        case .active(let date):
            if let date = date {
                return "订阅中，到期：\(formatDate(date))"
            } else {
                return "订阅中"
            }
        case .expired:
            return "已过期"
        case .pending:
            return "等待确认"
        case .cancelled:
            return "已取消"
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

enum PurchaseResult {
    case success
    case cancelled
    case pending
    case failed
}

// MARK: - Helper Functions

func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .unverified:
        throw PurchaseError.verificationFailed
    case .verified(let safe):
        return safe
    }
}

enum PurchaseError: Error {
    case verificationFailed
    case productNotFound
    case transactionFailed
}
