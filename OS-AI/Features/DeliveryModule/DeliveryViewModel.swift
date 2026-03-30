//
//  DeliveryViewModel.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  快递查询模块 - ViewModel
//

import Foundation
import SwiftData
import Observation

@Observable
final class DeliveryViewModel {

    // MARK: - Properties
    private let modelContext: ModelContext
    private var items: [DeliveryItem] = []

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadItems()
    }

    // MARK: - Public Methods

    /// 加载快递
    func loadItems() {
        let fetchDescriptor = FetchDescriptor<DeliveryItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            items = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to load delivery items: \(error)")
        }
    }

    /// 添加快递
    func addDelivery(
        trackingNumber: String,
        carrier: String,
        sender: String? = nil,
        receiver: String? = nil
    ) -> DeliveryItem? {
        let delivery = DeliveryItem(
            trackingNumber: trackingNumber,
            carrier: carrier,
            status: .pending,
            sender: sender,
            receiver: receiver
        )

        modelContext.insert(delivery)

        do {
            try modelContext.save()
            items.append(delivery)
            print("✅ Delivery added: \(trackingNumber)")
            return delivery
        } catch {
            print("❌ Failed to add delivery: \(error)")
            return nil
        }
    }

    /// 更新快递状态
    func updateDeliveryStatus(
        _ delivery: DeliveryItem,
        status: DeliveryStatus,
        currentLocation: String? = nil
    ) {
        delivery.status = status
        delivery.currentLocation = currentLocation

        if status == .delivered {
            delivery.actualDeliveryDate = Date()
        }

        delivery.updatedAt = Date()

        // 添加追踪记录
        let update = TrackingUpdate(
            status: status.rawValue,
            location: currentLocation,
            timestamp: Date()
        )
        delivery.trackingHistory.append(update)

        do {
            try modelContext.save()
            print("✅ Delivery status updated: \(delivery.trackingNumber) -> \(status.rawValue)")
        } catch {
            print("❌ Failed to update delivery status: \(error)")
        }
    }

    /// 删除快递
    func deleteDelivery(_ delivery: DeliveryItem) {
        modelContext.delete(delivery)

        do {
            try modelContext.save()
            items.removeAll { $0.id == delivery.id }
            print("✅ Delivery deleted: \(delivery.trackingNumber)")
        } catch {
            print("❌ Failed to delete delivery: \(error)")
        }
    }

    /// 获取运输中的快递
    func getInTransitDeliveries() -> [DeliveryItem] {
        return items.filter { $0.status == .inTransit || $0.status == .outForDelivery }
    }

    /// 获取已送达的快递
    func getDeliveredDeliveries() -> [DeliveryItem] {
        return items.filter { $0.status == .delivered }
    }

    /// 搜索快递
    func searchDeliveries(_ query: String) -> [DeliveryItem] {
        let lowercaseQuery = query.lowercased()
        return items.filter { delivery in
            return delivery.trackingNumber.lowercased().contains(lowercaseQuery) ||
                   delivery.carrier.lowercased().contains(lowercaseQuery) ||
                   (delivery.sender?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }

    /// 从短信/邮件中提取快递信息
    func extractDeliveryInfo(from text: String) -> (trackingNumber: String?, carrier: String?)? {
        // 简单的快递单号识别
        let patterns = [
            ("顺丰", "SF"),
            ("中通", "ZTO"),
            ("圆通", "YTO"),
            ("韵达", "YD"),
            ("申通", "STO"),
            ("FedEx", "FedEx"),
            ("DHL", "DHL"),
            ("UPS", "UPS")
        ]

        for (name, code) in patterns {
            if text.contains(name) {
                // 提取单号（10-20位数字/字母）
                let numberPattern = "[A-Z0-9]{10,20}"
                if let range = text.range(of: numberPattern, options: .regularExpression) {
                    let trackingNumber = String(text[range])
                    return (trackingNumber, name)
                }
            }
        }

        return nil
    }
}
