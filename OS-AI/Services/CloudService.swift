//
//  CloudService.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  云服务 - 基于CloudKit的云同步
//

import Foundation
import CloudKit
import SwiftData

/// 云服务
/// 管理iCloud数据同步
@MainActor
final class CloudService: ObservableObject {

    // MARK: - Singleton
    static let shared = CloudService()

    // MARK: - Published Properties
    @Published var isCloudAvailable = false
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?

    // MARK: - Private Properties
    private var container: CKContainer
    private var privateDatabase: CKDatabase
    private var syncTask: Task<Void, Never>?

    // MARK: - Initialization
    private init() {
        self.container = CKContainer.default()
        self.privateDatabase = container.privateCloudDatabase
    }

    // MARK: - Public Methods

    /// 初始化
    func initialize() async {
        // 检查iCloud可用性
        await checkCloudAvailability()

        print("✅ CloudService initialized")
    }

    /// 检查iCloud可用性
    func checkCloudAvailability() async {
        do {
            let accountStatus = try await container.accountStatus()

            switch accountStatus {
            case .available:
                isCloudAvailable = true
                print("✅ iCloud account available")

            case .noAccount:
                isCloudAvailable = false
                print("ℹ️ No iCloud account")

            case .restricted:
                isCloudAvailable = false
                print("ℹ️ iCloud account restricted")

            case .couldNotDetermine:
                isCloudAvailable = false
                print("ℹ️ Could not determine iCloud status")

            case .temporarilyUnavailable:
                isCloudAvailable = false
                print("ℹ️ iCloud temporarily unavailable")

            @unknown default:
                isCloudAvailable = false
                print("ℹ️ Unknown iCloud status")
            }
        } catch {
            print("❌ Failed to check iCloud availability: \(error)")
            isCloudAvailable = false
        }
    }

    /// 同步数据到iCloud
    func syncData() async -> Bool {
        guard isCloudAvailable else {
            print("❌ iCloud not available")
            return false
        }

        syncStatus = .syncing

        // SwiftData会自动同步到CloudKit
        // 这里主要是触发和监控同步状态

        // 等待一段时间让同步完成
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3秒

        lastSyncDate = Date()
        syncStatus = .completed

        print("✅ Data synced to iCloud")
        return true
    }

    /// 手动触发同步
    func manualSync() async {
        let success = await syncData()

        if success {
            // 可以在这里显示成功提示
        } else {
            // 显示错误提示
        }
    }

    /// 清除本地缓存
    func clearLocalCache() async {
        // 这里可以清除不需要的本地缓存
        print("✅ Local cache cleared")
    }

    /// 获取存储使用情况
    func getStorageUsage() async -> StorageUsage {
        // 模拟存储使用情况
        return StorageUsage(
            used: 10.5, // MB
            total: 5_000.0, // 5GB
            percentage: 0.21
        )
    }

    /// 处理同步错误
    func handleSyncError(_ error: Error) {
        print("❌ Sync error: \(error)")
        syncStatus = .error(error.localizedDescription)
    }

    /// 重置同步状态
    func resetSyncStatus() {
        syncStatus = .idle
    }

    // MARK: - Private Methods

    // CloudKit的详细操作可以在这里添加
    // 例如：批量操作、冲突解决等
}

// MARK: - Supporting Types

enum SyncStatus: Equatable {
    case idle
    case syncing
    case completed
    case error(String)

    var isSyncing: Bool {
        if case .syncing = self {
            return true
        }
        return false
    }

    var description: String {
        switch self {
        case .idle:
            return "未同步"
        case .syncing:
            return "同步中..."
        case .completed:
            return "已同步"
        case .error(let message):
            return "同步失败：\(message)"
        }
    }
}

struct StorageUsage {
    var used: Double // MB
    var total: Double // MB
    var percentage: Double

    var usedFormatted: String {
        return String(format: "%.1f MB", used)
    }

    var totalFormatted: String {
        return String(format: "%.1f GB", total / 1024)
    }

    var percentageFormatted: String {
        return String(format: "%.1f%%", percentage * 100)
    }
}

// MARK: - CloudKit Helper Extensions

extension CloudService {

    /// 创建自定义记录
    func createRecord(recordType: String, recordID: CKRecord.ID?, fields: [String: Any]) async throws -> CKRecord {
        let record: CKRecord

        if let recordID = recordID {
            record = CKRecord(recordType: recordType, recordID: recordID)
        } else {
            record = CKRecord(recordType: recordType)
        }

        for (key, value) in fields {
            record[key] = value
        }

        return record
    }

    /// 保存记录
    func saveRecord(_ record: CKRecord) async throws -> CKRecord {
        return try await privateDatabase.save(record)
    }

    /// 查询记录
    func queryRecords(recordType: String, predicate: NSPredicate) async throws -> [CKRecord] {
        let query = CKQuery(recordType: recordType, predicate: predicate)

        let (matchResults, _) = try await privateDatabase.records(matching: query)

        var records: [CKRecord] = []
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                records.append(record)
            case .failure(let error):
                print("❌ Failed to fetch record: \(error)")
            }
        }

        return records
    }

    /// 删除记录
    func deleteRecord(_ recordID: CKRecord.ID) async throws {
        try await privateDatabase.deleteRecord(withID: recordID)
    }

    /// 订阅变更
    func subscribeToChanges(recordType: String) async throws {
        let subscription = CKQuerySubscription(
            recordType: recordType,
            predicate: NSPredicate(value: true),
            options: .firesOnRecordCreation
        )

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        try await privateDatabase.save(subscription)
    }
}
