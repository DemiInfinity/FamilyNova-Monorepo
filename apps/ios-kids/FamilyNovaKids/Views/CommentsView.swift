//
//  CommentsView.swift
//  FamilyNovaKids
//

import SwiftUI

struct CommentsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    let postId: UUID
    let postAuthor: String
    let postContent: String
    let postAuthorId: String? // Add author ID to help fetch the post
    
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var comments: [Comment] = []
    @State private var isLoading = false
    @State private var newComment = ""
    @State private var isPostingComment = false
    @State private var toast: ToastNotificationData? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                VStack(spacing: 0) {
                    // Post Preview
                    VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                        HStack(spacing: CosmicSpacing.m) {
                            Circle()
                                .fill(CosmicColors.primaryGradient)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("👤")
                                        .font(.system(size: 20))
                                )
                            
                            VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                                Text(postAuthor)
                                    .font(CosmicFonts.headline)
                                    .foregroundColor(CosmicColors.textPrimary)
                                
                                Text(postContent)
                                    .font(CosmicFonts.body)
                                    .foregroundColor(CosmicColors.textSecondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                        .padding(CosmicSpacing.m)
                        .background(
                            RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                .fill(CosmicColors.glassBackground)
                        )
                    }
                    .padding(CosmicSpacing.m)
                    
                    // Comments List
                    if isLoading && comments.isEmpty {
                        LoadingStateView(message: "Loading comments...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if comments.isEmpty {
                        EmptyStateView(
                            icon: "message",
                            title: "No comments yet",
                            message: "Be the first to comment!"
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: CosmicSpacing.m) {
                                ForEach(comments) { comment in
                                    CommentRow(comment: comment)
                                }
                            }
                            .padding(CosmicSpacing.m)
                        }
                    }
                    
                    // Comment Input
                    VStack(spacing: 0) {
                        Divider()
                            .background(CosmicColors.nebulaBlue.opacity(0.3))
                        
                        HStack(spacing: CosmicSpacing.m) {
                            TextField("Write a comment...", text: $newComment)
                                .textFieldStyle(.plain)
                                .font(CosmicFonts.body)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(CosmicSpacing.m)
                                .background(
                                    RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                                        .fill(CosmicColors.glassBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                                                .stroke(CosmicColors.nebulaBlue.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            
                            Button(action: postComment) {
                                if isPostingComment {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: CosmicColors.nebulaPurple))
                                } else {
                                    ZStack {
                                        if newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            Circle()
                                                .fill(CosmicColors.glassBackground)
                                                .frame(width: 40, height: 40)
                                        } else {
                                            Circle()
                                                .fill(CosmicColors.primaryGradient)
                                                .frame(width: 40, height: 40)
                                        }
                                        Image(systemName: "arrow.up")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(
                                                newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                    ? CosmicColors.textMuted
                                                    : .white
                                            )
                                    }
                                }
                            }
                            .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPostingComment)
                        }
                        .padding(CosmicSpacing.m)
                        .background(CosmicColors.spaceTop.opacity(0.8))
                    }
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(CosmicFonts.button)
                    .foregroundColor(CosmicColors.nebulaPurple)
                }
            }
            .onAppear {
                print("[CommentsView] 👀 View appeared, loading comments...")
                loadComments()
            }
            .refreshable {
                await loadCommentsAsync()
            }
            .toastNotification($toast)
        }
    }
    
    private func loadComments() {
        isLoading = true
        Task {
            await loadCommentsAsync()
        }
    }
    
    private func loadCommentsAsync() async {
        let postIdString = postId.uuidString
        print("[CommentsView] 🔍 Loading comments for post: \(postIdString)")
        print("[CommentsView] 📝 Post author: \(postAuthor), authorId: \(postAuthorId ?? "nil")")
        
        guard let token = authManager.getValidatedToken() else {
            print("[CommentsView] ❌ ERROR: No valid token")
            await MainActor.run {
                isLoading = false
            }
            return
        }
        
        do {
            // Load all posts and find the one we need
            let apiService = ApiService.shared
            
            struct PostsResponse: Codable {
                let posts: [PostResponse]
            }
            
            struct PostResponse: Codable {
                let id: String
                let comments: [CommentResponse]?
            }
            
            struct CommentResponse: Codable {
                let id: String
                let content: String
                let author: AuthorResponse
                let createdAt: String
            }
            
            struct AuthorResponse: Codable {
                let id: String
                let profile: ProfileResponse?
            }
            
            struct ProfileResponse: Codable {
                let displayName: String?
            }
            
            // Try to fetch posts by the author first (more reliable)
            var post: PostResponse? = nil
            if let authorId = postAuthorId {
                print("[CommentsView] 🔄 Fetching posts by author: \(authorId)")
                let authorPostsResponse: PostsResponse = try await apiService.makeRequest(
                    endpoint: "posts?userId=\(authorId)",
                    method: "GET",
                    token: token
                )
                print("[CommentsView] 📊 Found \(authorPostsResponse.posts.count) posts by author")
                post = authorPostsResponse.posts.first { $0.id.lowercased() == postIdString.lowercased() }
                if post != nil {
                    print("[CommentsView] ✅ Found post in author's posts")
                } else {
                    print("[CommentsView] ⚠️ Post not found in author's posts. Post IDs in response:")
                    authorPostsResponse.posts.forEach { p in
                        print("[CommentsView]   - \(p.id) (looking for \(postIdString))")
                    }
                }
            }
            
            // If not found, try fetching all posts
            if post == nil {
                print("[CommentsView] 🔄 Post not found by author, fetching all posts...")
                let response: PostsResponse = try await apiService.makeRequest(
                    endpoint: "posts",
                    method: "GET",
                    token: token
                )
                print("[CommentsView] 📊 Found \(response.posts.count) total posts")
                // Find the post we need (case-insensitive comparison)
                post = response.posts.first { $0.id.lowercased() == postIdString.lowercased() }
                if post != nil {
                    print("[CommentsView] ✅ Found post in all posts")
                } else {
                    print("[CommentsView] ❌ Post not found in all posts. Post IDs in response:")
                    response.posts.prefix(10).forEach { p in
                        print("[CommentsView]   - \(p.id) (looking for \(postIdString))")
                    }
                }
            }
            
            await MainActor.run {
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                if let foundPost = post {
                    print("[CommentsView] 💬 Post found! Comments count: \(foundPost.comments?.count ?? 0)")
                    if let postComments = foundPost.comments {
                        print("[CommentsView] 📋 Comments details:")
                        postComments.forEach { comment in
                            let authorName = comment.author.profile?.displayName ?? "Unknown"
                            print("[CommentsView]   - ID: \(comment.id), Author: \(authorName), Content: \(comment.content.prefix(50))")
                        }
                    } else {
                        print("[CommentsView] ⚠️ Post has nil comments array")
                    }
                } else {
                    print("[CommentsView] ❌ Post not found at all!")
                }
                
                let loadedComments = (post?.comments ?? []).compactMap { commentResponse -> Comment? in
                    let createdAt = dateFormatter.date(from: commentResponse.createdAt) ?? Date()
                    // Handle both cases: with profile and without profile
                    let authorName: String
                    if let profile = commentResponse.author.profile {
                        authorName = profile.displayName ?? "Unknown"
                    } else {
                        // If no profile, we'll need to fetch it or use a placeholder
                        // For now, use "Unknown" - in production you might want to fetch author details
                        authorName = "Unknown"
                        print("[CommentsView] ⚠️ Comment author \(commentResponse.author.id) has no profile data")
                    }
                    let comment = Comment(
                        id: UUID(uuidString: commentResponse.id) ?? UUID(),
                        author: authorName,
                        content: commentResponse.content,
                        createdAt: createdAt
                    )
                    print("[CommentsView] ✅ Loaded comment: \(comment.id) by \(comment.author)")
                    return comment
                }
                print("[CommentsView] 📊 Total loaded comments: \(loadedComments.count)")
                self.comments = loadedComments.sorted { $0.createdAt < $1.createdAt } // Oldest first
                print("[CommentsView] ✅ Comments loaded and sorted. Final count: \(self.comments.count)")
                self.isLoading = false
            }
        } catch {
            print("[CommentsView] ❌ ERROR loading comments: \(error)")
            if let urlError = error as? URLError {
                print("[CommentsView]   URL Error: \(urlError.localizedDescription)")
            }
            await MainActor.run {
                self.isLoading = false
                ErrorHandler.shared.showError(error, toast: $toast)
            }
        }
    }
    
    private func postComment() {
        let commentText = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        print("[CommentsView] 📤 Posting comment: '\(commentText.prefix(50))'")
        print("[CommentsView] 📍 Post ID: \(postId.uuidString)")
        
        guard !commentText.isEmpty else {
            print("[CommentsView] ⚠️ Comment is empty, aborting")
            return
        }
        
        guard let token = authManager.getValidatedToken() else {
            print("[CommentsView] ❌ No valid token")
            ErrorHandler.shared.showError(ApiError.invalidResponse, toast: $toast)
            return
        }
        
        newComment = ""
        isPostingComment = true
        
        Task {
            do {
                let apiService = ApiService.shared
                let postIdString = postId.uuidString
                
                struct CommentResponse: Codable {
                    let comment: CommentData
                }
                
                struct CommentData: Codable {
                    let id: String
                    let content: String
                    let author: AuthorResponse
                    let createdAt: String
                }
                
                struct AuthorResponse: Codable {
                    let id: String
                    let profile: ProfileResponse
                }
                
                struct ProfileResponse: Codable {
                    let displayName: String?
                }
                
                let body: [String: Any] = ["content": commentText]
                print("[CommentsView] 📡 Sending POST request to: posts/\(postIdString)/comment")
                print("[CommentsView] 📦 Request body: \(body)")
                
                let response: CommentResponse = try await apiService.makeRequest(
                    endpoint: "posts/\(postIdString)/comment",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                print("[CommentsView] ✅ Comment posted successfully!")
                let authorName = response.comment.author.profile.displayName ?? "Unknown"
                print("[CommentsView] 📋 Response: ID=\(response.comment.id), Author=\(authorName), CreatedAt=\(response.comment.createdAt)")
                
                // Add the new comment optimistically to the UI immediately
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let createdAt = dateFormatter.date(from: response.comment.createdAt) ?? Date()
                
                let newCommentObj = Comment(
                    id: UUID(uuidString: response.comment.id) ?? UUID(),
                    author: response.comment.author.profile.displayName ?? "You",
                    content: response.comment.content,
                    createdAt: createdAt
                )
                
                print("[CommentsView] 💾 Adding comment to local list. Current count: \(comments.count)")
                
                await MainActor.run {
                    self.isPostingComment = false
                    self.newComment = "" // Clear the input
                    // Add the new comment to the list immediately
                    self.comments.append(newCommentObj)
                    self.comments.sort { $0.createdAt < $1.createdAt } // Keep sorted
                    print("[CommentsView] ✅ Comment added to list. New count: \(self.comments.count)")
                }
                
                // Wait a moment for the database to update, then reload all comments from server
                print("[CommentsView] ⏳ Waiting 0.5s before reloading comments...")
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                print("[CommentsView] 🔄 Reloading comments from server...")
                await loadCommentsAsync()
            } catch {
                print("[CommentsView] ❌ ERROR posting comment: \(error)")
                if let urlError = error as? URLError {
                    print("[CommentsView]   URL Error: \(urlError.localizedDescription)")
                    print("[CommentsView]   Code: \(urlError.code.rawValue)")
                }
                await MainActor.run {
                    self.isPostingComment = false
                    self.newComment = commentText // Restore comment text
                    ErrorHandler.shared.showError(error, toast: $toast)
                }
            }
        }
    }
}

struct Comment: Identifiable {
    let id: UUID
    let author: String
    let content: String
    let createdAt: Date
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: CosmicSpacing.m) {
            Circle()
                .fill(CosmicColors.primaryGradient)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("👤")
                        .font(.system(size: 18))
                )
            
            VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                Text(comment.author)
                    .font(CosmicFonts.caption)
                    .foregroundColor(CosmicColors.nebulaPurple)
                
                Text(comment.content)
                    .font(CosmicFonts.body)
                    .foregroundColor(CosmicColors.textPrimary)
                
                Text(comment.createdAt, style: .relative)
                    .font(CosmicFonts.small)
                    .foregroundColor(CosmicColors.textMuted)
            }
            
            Spacer()
        }
        .padding(CosmicSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                .fill(CosmicColors.glassBackground)
                .shadow(color: CosmicColors.nebulaBlue.opacity(0.2), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    CommentsView(
        postId: UUID(),
        postAuthor: "Test User",
        postContent: "This is a test post",
        postAuthorId: nil
    )
    .environmentObject(AuthManager())
}
