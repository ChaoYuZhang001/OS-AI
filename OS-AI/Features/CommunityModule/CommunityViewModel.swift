//
//  CommunityViewModel.swift
//  OS-AI
//
//  Created by ChaoYu Zhang on 2026-03-30.
//  用户社区 - ViewModel
//

import Foundation
import SwiftData
import Observation

@Observable
final class CommunityViewModel {

    // MARK: - Properties
    private let modelContext: ModelContext
    private var posts: [CommunityPost] = []
    private var comments: [Comment] = []
    private var notifications: [CommunityNotification] = []

    // MARK: - Published Properties
    @Published var currentUser: UserProfile?
    @Published var selectedCategory: PostCategory? = nil
    @Published var searchQuery: String = ""
    @Published var unreadNotificationCount: Int = 0

    // MARK: - Initialization
    init(modelContext: ModelContext, currentUser: UserProfile? = nil) {
        self.modelContext = modelContext
        self.currentUser = currentUser
        loadPosts()
        loadComments()
        loadNotifications()
    }

    // MARK: - Public Methods

    /// 加载帖子
    func loadPosts() {
        let fetchDescriptor = FetchDescriptor<CommunityPost>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            posts = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to load posts: \(error)")
        }
    }

    /// 加载评论
    func loadComments() {
        let fetchDescriptor = FetchDescriptor<Comment>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            comments = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to load comments: \(error)")
        }
    }

    /// 加载通知
    func loadNotifications() {
        guard let userId = currentUser?.id else { return }

        let fetchDescriptor = FetchDescriptor<CommunityNotification>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            notifications = try modelContext.fetch(fetchDescriptor)
            updateUnreadCount()
        } catch {
            print("❌ Failed to load notifications: \(error)")
        }
    }

    /// 获取所有帖子
    func getAllPosts() -> [CommunityPost] {
        var result = posts

        // 应用分类过滤
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // 应用搜索过滤
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter { post in
                return post.title.lowercased().contains(query) ||
                       post.content.lowercased().contains(query) ||
                       post.tags.contains(where: { $0.lowercased().contains(query) })
            }
        }

        // 置顶帖子优先
        let pinnedPosts = result.filter { $0.isPinned }.sorted { $0.createdAt > $1.createdAt }
        let normalPosts = result.filter { !$0.isPinned }.sorted { $0.createdAt > $1.createdAt }

        return pinnedPosts + normalPosts
    }

    /// 获取热门帖子
    func getPopularPosts(limit: Int = 10) -> [CommunityPost] {
        return posts
            .sorted { $0.likes > $1.likes }
            .prefix(limit)
            .map { $0 }
    }

    /// 获取官方帖子
    func getOfficialPosts() -> [CommunityPost] {
        return posts.filter { $0.isOfficial }
    }

    /// 获取我的帖子
    func getMyPosts() -> [CommunityPost] {
        guard let userId = currentUser?.id else { return [] }
        return posts.filter { $0.authorId == userId }
    }

    /// 创建帖子
    func createPost(
        title: String,
        content: String,
        category: PostCategory,
        tags: [String] = [],
        images: [String] = []
    ) -> CommunityPost? {
        guard let user = currentUser else {
            print("❌ No current user")
            return nil
        }

        let post = CommunityPost(
            authorId: user.id,
            authorName: user.name,
            authorAvatar: user.avatar,
            title: title,
            content: content,
            category: category,
            tags: tags,
            images: images
        )

        modelContext.insert(post)

        // 更新用户发帖数
        user.postsCount += 1

        do {
            try modelContext.save()
            posts.append(post)
            print("✅ Post created: \(title)")
            return post
        } catch {
            print("❌ Failed to create post: \(error)")
            return nil
        }
    }

    /// 更新帖子
    func updatePost(
        _ post: CommunityPost,
        title: String? = nil,
        content: String? = nil,
        tags: [String]? = nil
    ) {
        if let title = title { post.title = title }
        if let content = content { post.content = content }
        if let tags = tags { post.tags = tags }

        post.updatedAt = Date()

        do {
            try modelContext.save()
            print("✅ Post updated: \(post.title)")
        } catch {
            print("❌ Failed to update post: \(error)")
        }
    }

    /// 删除帖子
    func deletePost(_ post: CommunityPost) {
        // 删除所有评论
        let postComments = comments.filter { $0.postId == post.id }
        for comment in postComments {
            modelContext.delete(comment)
        }

        // 删除帖子
        modelContext.delete(post)

        do {
            try modelContext.save()
            posts.removeAll { $0.id == post.id }
            print("✅ Post deleted: \(post.title)")
        } catch {
            print("❌ Failed to delete post: \(error)")
        }
    }

    /// 点赞帖子
    func likePost(_ post: CommunityPost) {
        post.likes += 1

        do {
            try modelContext.save()
            print("✅ Post liked: \(post.title)")

            // 通知作者
            if let authorId = currentUser?.id, authorId != post.authorId {
                createNotification(
                    userId: post.authorId,
                    type: .like,
                    title: "收到新点赞",
                    content: "\(currentUser?.name ?? "有人")赞了你的帖子",
                    relatedPostId: post.id,
                    relatedUserId: authorId
                )
            }
        } catch {
            print("❌ Failed to like post: \(error)")
        }
    }

    /// 添加评论
    func addComment(
        postId: UUID,
        content: String,
        parentId: UUID? = nil
    ) -> Comment? {
        guard let user = currentUser else {
            print("❌ No current user")
            return nil
        }

        let comment = Comment(
            postId: postId,
            authorId: user.id,
            authorName: user.name,
            authorAvatar: user.avatar,
            content: content,
            parentId: parentId,
            isReply: parentId != nil
        )

        modelContext.insert(comment)
        comments.append(comment)

        // 更新帖子评论数
        if let post = posts.first(where: { $0.id == postId }) {
            post.comments += 1
            post.updatedAt = Date()

            // 通知作者
            if user.id != post.authorId {
                createNotification(
                    userId: post.authorId,
                    type: .comment,
                    title: "收到新评论",
                    content: "\(user.name)评论了你的帖子",
                    relatedPostId: postId,
                    relatedCommentId: comment.id,
                    relatedUserId: user.id
                )
            }
        }

        // 如果是回复，通知被回复的用户
        if let parentId = parentId, let parentComment = comments.first(where: { $0.id == parentId }) {
            if user.id != parentComment.authorId {
                createNotification(
                    userId: parentComment.authorId,
                    type: .reply,
                    title: "收到新回复",
                    content: "\(user.name)回复了你的评论",
                    relatedPostId: postId,
                    relatedCommentId: comment.id,
                    relatedUserId: user.id
                )
            }
        }

        do {
            try modelContext.save()
            print("✅ Comment added")
            return comment
        } catch {
            print("❌ Failed to add comment: \(error)")
            return nil
        }
    }

    /// 获取帖子的评论
    func getComments(for postId: UUID) -> [Comment] {
        return comments
            .filter { $0.postId == postId && $0.parentId == nil }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// 获取评论的回复
    func getReplies(for commentId: UUID) -> [Comment] {
        return comments
            .filter { $0.parentId == commentId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// 创建通知
    func createNotification(
        userId: String,
        type: NotificationType,
        title: String,
        content: String,
        relatedPostId: UUID? = nil,
        relatedCommentId: UUID? = nil,
        relatedUserId: String? = nil
    ) {
        let notification = CommunityNotification(
            userId: userId,
            type: type,
            title: title,
            content: content,
            relatedPostId: relatedPostId,
            relatedCommentId: relatedCommentId,
            relatedUserId: relatedUserId
        )

        modelContext.insert(notification)

        do {
            try modelContext.save()
            updateUnreadCount()
        } catch {
            print("❌ Failed to create notification: \(error)")
        }
    }

    /// 标记通知为已读
    func markNotificationAsRead(_ notification: CommunityNotification) {
        notification.isRead = true

        do {
            try modelContext.save()
            updateUnreadCount()
        } catch {
            print("❌ Failed to mark notification as read: \(error)")
        }
    }

    /// 标记所有通知为已读
    func markAllNotificationsAsRead() {
        for notification in notifications {
            notification.isRead = true
        }

        do {
            try modelContext.save()
            updateUnreadCount()
        } catch {
            print("❌ Failed to mark all notifications as read: \(error)")
        }
    }

    /// 删除通知
    func deleteNotification(_ notification: CommunityNotification) {
        modelContext.delete(notification)

        do {
            try modelContext.save()
            updateUnreadCount()
        } catch {
            print("❌ Failed to delete notification: \(error)")
        }
    }

    /// 更新未读数量
    private func updateUnreadCount() {
        unreadNotificationCount = notifications.filter { !$0.isRead }.count
    }

    /// 搜索帖子
    func searchPosts(_ query: String) -> [CommunityPost] {
        let lowercaseQuery = query.lowercased()
        return posts.filter { post in
            return post.title.lowercased().contains(lowercaseQuery) ||
                   post.content.lowercased().contains(lowercaseQuery) ||
                   post.tags.contains(where: { $0.lowercased().contains(lowercaseQuery) })
        }
    }

    /// 获取社区统计
    func getCommunityStatistics() -> CommunityStatistics {
        let totalPosts = posts.count
        let totalComments = comments.count
        let totalUsers = Set(posts.map { $0.authorId }).count

        // 按分类统计
        var categoryCounts: [PostCategory: Int] = [:]
        for category in PostCategory.allCases {
            categoryCounts[category] = posts.filter { $0.category == category }.count
        }

        // 活跃用户（最近7天发帖）
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let activeUsers = Set(
            posts.filter { $0.createdAt >= sevenDaysAgo }.map { $0.authorId }
        ).count

        return CommunityStatistics(
            totalPosts: totalPosts,
            totalComments: totalComments,
            totalUsers: totalUsers,
            activeUsers: activeUsers,
            categoryCounts: categoryCounts,
            averageLikesPerPost: posts.isEmpty ? 0.0 : Double(posts.reduce(0) { $0 + $1.likes }) / Double(posts.count)
        )
    }
}

// MARK: - Supporting Types

struct CommunityStatistics {
    var totalPosts: Int
    var totalComments: Int
    var totalUsers: Int
    var activeUsers: Int
    var categoryCounts: [PostCategory: Int]
    var averageLikesPerPost: Double
}
