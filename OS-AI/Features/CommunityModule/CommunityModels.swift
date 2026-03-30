//
//  Community.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  用户社区 - 数据模型
//

import Foundation
import SwiftData

@Model
final class CommunityPost {
    var id: UUID
    var authorId: String
    var authorName: String
    var authorAvatar: String?
    var title: String
    var content: String
    var category: PostCategory
    var tags: [String]
    var images: [String]
    var likes: Int
    var comments: Int
    var views: Int
    var isPinned: Bool
    var isOfficial: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        authorId: String,
        authorName: String,
        authorAvatar: String? = nil,
        title: String,
        content: String,
        category: PostCategory,
        tags: [String] = [],
        images: [String] = [],
        likes: Int = 0,
        comments: Int = 0,
        views: Int = 0,
        isPinned: Bool = false,
        isOfficial: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.title = title
        self.content = content
        self.category = category
        self.tags = tags
        self.images = images
        self.likes = likes
        self.comments = comments
        self.views = views
        self.isPinned = isPinned
        self.isOfficial = isOfficial
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum PostCategory: String, Codable, CaseIterable {
    case discussion = "讨论"
    case question = "问答"
    case share = "分享"
    case feedback = "反馈"
    case tutorial = "教程"
    case news = "资讯"

    var icon: String {
        switch self {
        case .discussion: return "bubble.left.and.bubble.right.fill"
        case .question: return "questionmark.circle.fill"
        case .share: return "square.and.arrow.up.fill"
        case .feedback: return "exclamationmark.bubble.fill"
        case .tutorial: return "book.fill"
        case .news: return "newspaper.fill"
        }
    }
}

@Model
final class Comment {
    var id: UUID
    var postId: UUID
    var authorId: String
    var authorName: String
    var authorAvatar: String?
    var content: String
    var parentId: UUID?
    var likes: Int
    var isReply: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        postId: UUID,
        authorId: String,
        authorName: String,
        authorAvatar: String? = nil,
        content: String,
        parentId: UUID? = nil,
        likes: Int = 0,
        isReply: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.postId = postId
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.content = content
        self.parentId = parentId
        self.likes = likes
        self.isReply = isReply
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class UserProfile {
    var id: String
    var name: String
    var avatar: String?
    var bio: String?
    var location: String?
    var website: String?
    var followers: Int
    var following: Int
    var postsCount: Int
    var likesReceived: Int
    var joinedAt: Date
    var isVerified: Bool
    var badges: [String]

    init(
        id: String,
        name: String,
        avatar: String? = nil,
        bio: String? = nil,
        location: String? = nil,
        website: String? = nil,
        followers: Int = 0,
        following: Int = 0,
        postsCount: Int = 0,
        likesReceived: Int = 0,
        joinedAt: Date = Date(),
        isVerified: Bool = false,
        badges: [String] = []
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.bio = bio
        self.location = location
        self.website = website
        self.followers = followers
        self.following = following
        self.postsCount = postsCount
        self.likesReceived = likesReceived
        self.joinedAt = joinedAt
        self.isVerified = isVerified
        self.badges = badges
    }
}

@Model
final class CommunityNotification {
    var id: UUID
    var userId: String
    var type: NotificationType
    var title: String
    var content: String
    var relatedPostId: UUID?
    var relatedCommentId: UUID?
    var relatedUserId: String?
    var isRead: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        userId: String,
        type: NotificationType,
        title: String,
        content: String,
        relatedPostId: UUID? = nil,
        relatedCommentId: UUID? = nil,
        relatedUserId: String? = nil,
        isRead: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.content = content
        self.relatedPostId = relatedPostId
        self.relatedCommentId = relatedCommentId
        self.relatedUserId = relatedUserId
        self.isRead = isRead
        self.createdAt = createdAt
    }
}

enum NotificationType: String, Codable {
    case like = "点赞"
    case comment = "评论"
    case reply = "回复"
    case follow = "关注"
    case mention = "提及"
    case system = "系统"

    var icon: String {
        switch self {
        case .like: return "heart.fill"
        case .comment: return "bubble.left.and.bubble.right.fill"
        case .reply: return "arrow.reply"
        case .follow: return "person.crop.circle.badge.plus"
        case .mention: return "at"
        case .system: return "bell.fill"
        }
    }
}
