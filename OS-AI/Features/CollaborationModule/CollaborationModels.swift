//
//  CollaborationModels.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  多人协作 - 数据模型
//

import Foundation
import SwiftData

@Model
final class CollaborationWorkspace {
    var id: UUID
    var name: String
    var description: String
    var ownerId: String
    var ownerName: String
    var members: [WorkspaceMember]
    var settings: WorkspaceSettings
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        ownerId: String,
        ownerName: String,
        members: [WorkspaceMember] = [],
        settings: WorkspaceSettings = WorkspaceSettings(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.members = members
        self.settings = settings
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct WorkspaceMember: Codable {
    var userId: String
    var userName: String
    var role: MemberRole
    var joinedAt: Date
    var isActive: Bool

    init(userId: String, userName: String, role: MemberRole, joinedAt: Date = Date(), isActive: Bool = true) {
        self.userId = userId
        self.userName = userName
        self.role = role
        self.joinedAt = joinedAt
        self.isActive = isActive
    }
}

enum MemberRole: String, Codable {
    case owner = "所有者"
    case admin = "管理员"
    case editor = "编辑者"
    case viewer = "查看者"

    var canEdit: Bool {
        return self == .owner || self == .admin || self == .editor
    }

    var canDelete: Bool {
        return self == .owner
    }

    var canInvite: Bool {
        return self == .owner || self == .admin
    }
}

struct WorkspaceSettings: Codable {
    var isPublic: Bool
    var allowAnyoneToEdit: Bool
    var requireApprovalToJoin: Bool
    var enableComments: Bool
    var enableHistory: Bool
    var maxMembers: Int

    init(
        isPublic: Bool = false,
        allowAnyoneToEdit: Bool = false,
        requireApprovalToJoin: Bool = true,
        enableComments: Bool = true,
        enableHistory: Bool = true,
        maxMembers: Int = 10
    ) {
        self.isPublic = isPublic
        self.allowAnyoneToEdit = allowAnyoneToEdit
        self.requireApprovalToJoin = requireApprovalToJoin
        self.enableComments = enableComments
        self.enableHistory = enableHistory
        self.maxMembers = maxMembers
    }
}

@Model
final class CollaborativeItem {
    var id: UUID
    var workspaceId: UUID
    var type: CollaborationItemType
    var title: String
    var content: String
    var creatorId: String
    var creatorName: String
    var assignedTo: [String]
    var status: CollaborationItemStatus
    var priority: ItemPriority
    var dueDate: Date?
    var tags: [String]
    var attachments: [String]
    var history: [ItemHistory]
    var comments: [CollaborativeComment]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        workspaceId: UUID,
        type: CollaborationItemType,
        title: String,
        content: String,
        creatorId: String,
        creatorName: String,
        assignedTo: [String] = [],
        status: CollaborationItemStatus = .todo,
        priority: ItemPriority = .normal,
        dueDate: Date? = nil,
        tags: [String] = [],
        attachments: [String] = [],
        history: [ItemHistory] = [],
        comments: [CollaborativeComment] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.workspaceId = workspaceId
        self.type = type
        self.title = title
        self.content = content
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.assignedTo = assignedTo
        self.status = status
        self.priority = priority
        self.dueDate = dueDate
        self.tags = tags
        self.attachments = attachments
        self.history = history
        self.comments = comments
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum CollaborationItemType: String, Codable {
    case task = "任务"
    case note = "笔记"
    case document = "文档"
    case discussion = "讨论"
}

enum CollaborationItemStatus: String, Codable {
    case todo = "待办"
    case inProgress = "进行中"
    case review = "审核中"
    case done = "已完成"
    case cancelled = "已取消"
}

enum ItemPriority: String, Codable {
    case low = "低"
    case normal = "正常"
    case high = "高"
    case urgent = "紧急"
}

struct ItemHistory: Codable {
    var id: UUID
    var userId: String
    var userName: String
    var action: String
    var changeDescription: String
    var timestamp: Date

    init(id: UUID = UUID(), userId: String, userName: String, action: String, changeDescription: String, timestamp: Date = Date()) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.action = action
        self.changeDescription = changeDescription
        self.timestamp = timestamp
    }
}

struct CollaborativeComment: Codable {
    var id: UUID
    var userId: String
    var userName: String
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), userId: String, userName: String, content: String, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class Invitation {
    var id: UUID
    var workspaceId: UUID
    var workspaceName: String
    var inviterId: String
    var inviterName: String
    var inviteeId: String
    var inviteeName: String
    var role: MemberRole
    var status: InvitationStatus
    var message: String?
    var createdAt: Date
    var expiresAt: Date

    init(
        id: UUID = UUID(),
        workspaceId: UUID,
        workspaceName: String,
        inviterId: String,
        inviterName: String,
        inviteeId: String,
        inviteeName: String,
        role: MemberRole,
        status: InvitationStatus = .pending,
        message: String? = nil,
        createdAt: Date = Date(),
        expiresAt: Date = Date().addingTimeInterval(7 * 24 * 60 * 60) // 7天后过期
    ) {
        self.id = id
        self.workspaceId = workspaceId
        self.workspaceName = workspaceName
        self.inviterId = inviterId
        self.inviterName = inviterName
        self.inviteeId = inviteeId
        self.inviteeName = inviteeName
        self.role = role
        self.status = status
        self.message = message
        self.createdAt = createdAt
        self.expiresAt = expiresAt
    }
}

enum InvitationStatus: String, Codable {
    case pending = "待处理"
    case accepted = "已接受"
    case declined = "已拒绝"
    case expired = "已过期"
}
