//
//  HomeFeedView.swift
//  FamilyNovaKids
//
//  Cosmic-themed home feed

import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var showCreatePost = false
    @State private var toast: ToastNotificationData? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                VStack(spacing: 0) {
                    // Offline indicator
                    OfflineIndicator()
                    
                    if isLoading && posts.isEmpty {
                        LoadingStateView(message: "Loading posts...", showSkeleton: true)
                            .padding(CosmicSpacing.m)
                    } else if posts.isEmpty {
                        EmptyStateView(
                            icon: "sparkles",
                            title: "No posts yet!",
                            message: "Be the first to share something!",
                            actionTitle: "Create Post",
                            action: { showCreatePost = true }
                        )
                    } else {
                    ScrollView {
                        LazyVStack(spacing: CosmicSpacing.l) {
                            ForEach(posts) { post in
                                CosmicPostCard(post: post)
                                    .environmentObject(authManager)
                                    .padding(.horizontal, CosmicSpacing.m)
                            }
                        }
                        .padding(.vertical, CosmicSpacing.m)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toastNotification($toast)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreatePost = true }) {
                        Image(systemName: "plus.circle.fill")
                            .cosmicIcon(size: 24, color: CosmicColors.nebulaPurple)
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                UnifiedCreatePostView(onPostCreated: {
                    loadPosts()
                })
                .environmentObject(authManager)
            }
            .onAppear {
                loadPosts()
            }
            .refreshable {
                await loadPostsAsync()
            }
        }
    }
    
    private func loadPosts() {
        isLoading = true
        Task {
            await loadPostsAsync()
        }
    }
    
    private func loadPostsAsync() async {
        guard let token = authManager.getValidatedToken() else {
            await MainActor.run {
                isLoading = false
            }
            return
        }
        
        do {
            let apiService = ApiService.shared
            
            struct PostsResponse: Codable {
                let posts: [PostResponse]
            }
            
            struct PostResponse: Codable {
                let id: String
                let content: String
                let imageUrl: String?
                let status: String
                let author: AuthorResponse
                let likes: [String]?
                let comments: [CommentResponse]?
                let createdAt: String
            }
            
            struct AuthorResponse: Codable {
                let id: String
                let profile: ProfileResponse
            }
            
            struct ProfileResponse: Codable {
                let displayName: String?
                let avatar: String?
            }
            
            struct CommentResponse: Codable {
                let id: String
                let content: String
            }
            
            let response: PostsResponse = try await apiService.makeRequest(
                endpoint: "posts",
                method: "GET",
                token: token
            )
            
            await MainActor.run {
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                self.posts = response.posts.compactMap { postResponse in
                    let createdAt = dateFormatter.date(from: postResponse.createdAt) ?? Date()
                    
                    var isLiked = false
                    if let currentUserId = authManager.currentUser?.id {
                        isLiked = postResponse.likes?.contains(currentUserId) ?? false
                    }
                    
                    return Post(
                        id: UUID(uuidString: postResponse.id) ?? UUID(),
                        author: postResponse.author.profile.displayName ?? "Unknown",
                        authorId: postResponse.author.id,
                        authorAvatar: postResponse.author.profile.avatar,
                        content: postResponse.content,
                        imageUrl: postResponse.imageUrl,
                        likes: postResponse.likes?.count ?? 0,
                        comments: postResponse.comments?.count ?? 0,
                        createdAt: createdAt,
                        isLiked: isLiked
                    )
                }
                self.isLoading = false
            }
        } catch {
            print("Error loading posts: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

// Cosmic Post Card Component
struct CosmicPostCard: View {
    let post: Post
    @EnvironmentObject var authManager: AuthManager
    @State private var isLiked = false
    @State private var likesCount = 0
    @State private var commentsCount = 0
    @State private var showComments = false
    @State private var showShareSheet = false
    @State private var shareMessage = ""
    @State private var isSharing = false
    @State private var isLiking = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
            // Header - Clickable to navigate to profile
            NavigationLink(destination: destinationView) {
                HStack(spacing: CosmicSpacing.m) {
                    // Profile picture with glow
                    Group {
                        if let avatarUrl = post.authorAvatar, !avatarUrl.isEmpty {
                            AsyncImage(url: URL(string: avatarUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(CosmicColors.primaryGradient)
                            }
                        } else {
                            Circle()
                                .fill(CosmicColors.primaryGradient)
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(CosmicColors.nebulaPurple.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: CosmicColors.nebulaPurple.opacity(0.5), radius: 8)
                    
                    VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                        Text(post.author)
                            .font(CosmicFonts.headline)
                            .foregroundColor(CosmicColors.textPrimary)
                        // Display relative time, with fallback to absolute time if relative fails
                        if post.createdAt.timeIntervalSince1970 > 0 {
                            Text(post.createdAt, style: .relative)
                                .font(CosmicFonts.small)
                                .foregroundColor(CosmicColors.textMuted)
                        } else {
                            Text("Just now")
                                .font(CosmicFonts.small)
                                .foregroundColor(CosmicColors.textMuted)
                        }
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Content
            if !post.content.isEmpty {
                Text(post.content)
                    .font(CosmicFonts.body)
                    .foregroundColor(CosmicColors.textSecondary)
                    .padding(.vertical, CosmicSpacing.s)
            }
            
            // Image if present
            if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                        .frame(height: 200)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .cornerRadius(CosmicCornerRadius.medium)
            }
            
            // Interactions
            HStack(spacing: CosmicSpacing.l) {
                Button(action: { toggleLike() }) {
                    HStack(spacing: CosmicSpacing.s) {
                        if isLiking {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .cosmicIcon(size: 18, color: isLiked ? CosmicColors.cometPink : CosmicColors.textMuted)
                        }
                        Text("\(likesCount)")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.textMuted)
                    }
                }
                .disabled(isLiking)
                
                Button(action: { showComments = true }) {
                    HStack(spacing: CosmicSpacing.s) {
                        Image(systemName: "message")
                            .cosmicIcon(size: 18, color: CosmicColors.textMuted)
                        Text("\(commentsCount)")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.textMuted)
                    }
                }
                
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .cosmicIcon(size: 18, color: CosmicColors.textMuted)
                }
                
                Spacer()
            }
            .padding(.top, CosmicSpacing.s)
        }
        .padding(CosmicSpacing.m)
        .cosmicCard()
        .onAppear {
            isLiked = post.isLiked
            likesCount = post.likes
            commentsCount = post.comments
        }
        .sheet(isPresented: $showComments) {
            CommentsView(
                postId: post.id,
                postAuthor: post.author,
                postContent: post.content,
                postAuthorId: post.authorId
            )
            .environmentObject(authManager)
        }
        .sheet(isPresented: $showShareSheet) {
            SharePostView(
                post: post,
                onShare: { message in
                    sharePost(message: message)
                }
            )
            .environmentObject(authManager)
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if let currentUserId = authManager.currentUser?.id,
           post.authorId.lowercased() == currentUserId.lowercased() {
            ProfileView()
                .environmentObject(authManager)
        } else {
            FriendProfileView(friend: Friend(
                id: UUID(uuidString: post.authorId) ?? UUID(),
                displayName: post.author,
                avatar: post.authorAvatar,
                isVerified: false
            ))
            .environmentObject(authManager)
        }
    }
    
    private func toggleLike() {
        guard let token = authManager.getValidatedToken() else { return }
        
        let previousLiked = isLiked
        let previousCount = likesCount
        
        // Optimistic update
        isLiked.toggle()
        likesCount += isLiked ? 1 : -1
        isLiking = true
        
        Task {
            do {
                let apiService = ApiService.shared
                let postIdString = post.id.uuidString
                
                struct LikeResponse: Codable {
                    let message: String
                    let liked: Bool
                    let likesCount: Int
                }
                
                let response: LikeResponse = try await apiService.makeRequest(
                    endpoint: "posts/\(postIdString)/like",
                    method: "POST",
                    token: token
                )
                
                await MainActor.run {
                    self.isLiked = response.liked
                    self.likesCount = response.likesCount
                    self.isLiking = false
                }
            } catch {
                await MainActor.run {
                    self.isLiked = previousLiked
                    self.likesCount = previousCount
                    self.isLiking = false
                }
                print("[CosmicPostCard] Error liking post: \(error)")
            }
        }
    }
    
    private func refreshCommentsCount() {
        guard let token = authManager.getValidatedToken() else { return }
        
        Task {
            do {
                let apiService = ApiService.shared
                let postIdString = post.id.uuidString
                
                struct PostsResponse: Codable {
                    let posts: [PostResponse]
                }
                
                struct PostResponse: Codable {
                    let id: String
                    let comments: [CommentResponse]?
                }
                
                struct CommentResponse: Codable {
                    let id: String
                }
                
                let response: PostsResponse = try await apiService.makeRequest(
                    endpoint: "posts?userId=\(post.authorId)",
                    method: "GET",
                    token: token
                )
                
                if let foundPost = response.posts.first(where: { $0.id == postIdString }) {
                    await MainActor.run {
                        self.commentsCount = foundPost.comments?.count ?? 0
                    }
                }
            } catch {
                print("[CosmicPostCard] Error refreshing comments count: \(error)")
            }
        }
    }
    
    private func sharePost(message: String) {
        guard let token = authManager.getValidatedToken() else { return }
        
        isSharing = true
        Task {
            do {
                let apiService = ApiService.shared
                let postIdString = post.id.uuidString
                
                struct ShareResponse: Codable {
                    let message: String
                    let postId: String
                }
                
                let body: [String: Any] = [
                    "postId": postIdString,
                    "message": message
                ]
                
                let _: ShareResponse = try await apiService.makeRequest(
                    endpoint: "posts/share",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                await MainActor.run {
                    self.isSharing = false
                    self.showShareSheet = false
                }
            } catch {
                await MainActor.run {
                    self.isSharing = false
                }
                print("[CosmicPostCard] Error sharing post: \(error)")
            }
        }
    }
}

struct SharePostView: View {
    let post: Post
    let onShare: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var shareMessage = ""
    @State private var isSharing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                VStack(spacing: CosmicSpacing.l) {
                    // Post Preview
                    VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                        HStack(spacing: CosmicSpacing.m) {
                            Group {
                                if let avatarUrl = post.authorAvatar, !avatarUrl.isEmpty {
                                    AsyncImage(url: URL(string: avatarUrl)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Circle()
                                            .fill(CosmicColors.primaryGradient)
                                    }
                                } else {
                                    Circle()
                                        .fill(CosmicColors.primaryGradient)
                                }
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                                Text(post.author)
                                    .font(CosmicFonts.headline)
                                    .foregroundColor(CosmicColors.textPrimary)
                                Text(post.content)
                                    .font(CosmicFonts.body)
                                    .foregroundColor(CosmicColors.textSecondary)
                                    .lineLimit(3)
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
                    
                    // Message Input
                    VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                        Text("Add a message (optional)")
                            .font(CosmicFonts.headline)
                            .foregroundColor(CosmicColors.textPrimary)
                        
                        TextEditor(text: $shareMessage)
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textPrimary)
                            .frame(minHeight: 100)
                            .padding(CosmicSpacing.m)
                            .background(
                                RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                    .fill(CosmicColors.glassBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                            .stroke(CosmicColors.nebulaBlue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(CosmicSpacing.m)
                    
                    Spacer()
                    
                    // Share Button
                    Button(action: {
                        onShare(shareMessage)
                    }) {
                        HStack {
                            if isSharing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrowshape.turn.up.right.fill")
                                Text("Share Post")
                            }
                        }
                        .font(CosmicFonts.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(CosmicSpacing.m)
                        .background(
                            LinearGradient(
                                colors: [CosmicColors.nebulaPurple, CosmicColors.nebulaBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(CosmicCornerRadius.large)
                        .shadow(color: CosmicColors.nebulaPurple.opacity(0.5), radius: 8)
                    }
                    .disabled(isSharing)
                    .padding(CosmicSpacing.m)
                }
            }
            .navigationTitle("Share Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(CosmicColors.nebulaPurple)
                }
            }
        }
    }
}

#Preview {
    HomeFeedView()
        .environmentObject(AuthManager())
}

