//
//  PaymentViewModel.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  缴费模块 - ViewModel
//

import Foundation
import SwiftData
import Observation

@Observable
final class PaymentViewModel {

    // MARK: - Properties
    private let modelContext: ModelContext
    private var items: [PaymentItem] = []

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadItems()
    }

    // MARK: - Public Methods

    /// 加载账单
    func loadItems() {
        let fetchDescriptor = FetchDescriptor<PaymentItem>(
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )

        do {
            items = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to load payment items: \(error)")
        }
    }

    /// 添加账单
    func addBill(
        billType: BillType,
        provider: String,
        amount: Double,
        dueDate: Date,
        accountNumber: String? = nil
    ) -> PaymentItem? {
        let payment = PaymentItem(
            billType: billType,
            provider: provider,
            amount: amount,
            dueDate: dueDate,
            accountNumber: accountNumber
        )

        modelContext.insert(payment)

        do {
            try modelContext.save()
            items.append(payment)
            print("✅ Bill added: \(provider) - \(billType.rawValue)")
            return payment
        } catch {
            print("❌ Failed to add bill: \(error)")
            return nil
        }
    }

    /// 更新账单状态
    func updateBillStatus(_ payment: PaymentItem, isPaid: Bool) {
        payment.isPaid = isPaid

        if isPaid {
            payment.paidDate = Date()
        }

        payment.updatedAt = Date()

        do {
            try modelContext.save()
            print("✅ Bill status updated: \(payment.provider) - \(isPaid ? "已支付" : "未支付")")
        } catch {
            print("❌ Failed to update bill status: \(error)")
        }
    }

    /// 删除账单
    func deleteBill(_ payment: PaymentItem) {
        modelContext.delete(payment)

        do {
            try modelContext.save()
            items.removeAll { $0.id == payment.id }
            print("✅ Bill deleted: \(payment.provider)")
        } catch {
            print("❌ Failed to delete bill: \(error)")
        }
    }

    /// 获取即将到期的账单（7天内）
    func getUpcomingBills() -> [PaymentItem] {
        let now = Date()
        let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: now)!

        return items
            .filter { !$0.isPaid && $0.dueDate >= now && $0.dueDate <= sevenDaysLater }
            .sorted { $0.dueDate < $1.dueDate }
    }

    /// 获取已逾期的账单
    func getOverdueBills() -> [PaymentItem] {
        let now = Date()

        return items
            .filter { !$0.isPaid && $0.dueDate < now }
            .sorted { $0.dueDate < $1.dueDate }
    }

    /// 获取本月账单总额
    func getTotalAmountForMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!

        return items
            .filter {
                let itemMonth = calendar.dateComponents([.year, .month], from: $0.dueDate)
                let currentMonth = calendar.dateComponents([.year, .month], from: startOfMonth)
                return itemMonth.year == currentMonth.year && itemMonth.month == currentMonth.month
            }
            .reduce(0) { $0 + $1.amount }
    }

    /// 搜索账单
    func searchBills(_ query: String) -> [PaymentItem] {
        let lowercaseQuery = query.lowercased()
        return items.filter { payment in
            return payment.provider.lowercased().contains(lowercaseQuery) ||
                   payment.billType.rawValue.lowercased().contains(lowercaseQuery) ||
                   (payment.accountNumber?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }
}
