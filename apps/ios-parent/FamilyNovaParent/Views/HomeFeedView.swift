//
//  HomeFeedView.swift
//  FamilyNovaKids
//
//  Cosmic-themed home feed

import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var showCreatePost = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                if isLoading && posts.isEmpty {
                    VStack(spacing: CosmicSpacing.l) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(CosmicColors.nebulaPurple)
                        Text("Loading posts...")
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                    }
                } else if posts.isEmpty {
                    VStack(spacing: CosmicSpacing.xl) {
                        Image(systemName: "sparkles")
                            .cosmicIcon(size: 60, color: CosmicColors.nebulaPurple)
                        Text("No posts yet!")
                            .font(CosmicFonts.headline)
                            .foregroundColor(CosmicColors.textPrimary)
                        Text("Be the first to share something!")
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CosmicSpacing.xl)
                    }
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
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.large)
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
                // Always refresh from API when view appears
                loadPosts()
            }
            .refreshable {
                await loadPostsAsync()
            }
        }
    }
    
    private func loadPosts() {
        // First, try to load from cache for instant display
        loadPostsFromCache()
        
        // Always fetch fresh data from API
        isLoading = true
        Task {
            await loadPostsAsync()
        }
    }
    
    private func loadPostsFromCache() {
        guard let userId = authManager.currentUser?.id else { return }
        guard let cachedPosts = DataManager.shared.getCachedPosts(userId: userId) else { return }
        
        // Map cached posts to Post objects, ensuring dates are valid
        posts = cachedPosts.compactMap { cachedPost in
            // Ensure the date is valid (not a zero date or invalid)
            guard cachedPost.createdAt.timeIntervalSince1970 > 0 else {
                print("[HomeFeed] Invalid date for post \(cachedPost.id): \(cachedPost.createdAt)")
                return nil
            }
            
            return Post(
                id: UUID(uuidString: cachedPost.id) ?? UUID(),
                authorId: cachedPost.authorId,
                author: cachedPost.authorName,
                authorAvatar: cachedPost.authorAvatar,
                content: cachedPost.content,
                imageUrl: cachedPost.imageUrl,
                likes: cachedPost.likes,
                comments: cachedPost.comments,
                createdAt: cachedPost.createdAt,
                isLiked: false // Will be updated when we load from API
            )
        }
        .sorted { $0.createdAt > $1.createdAt }
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
            
            print("[HomeFeed] API returned \(response.posts.count) posts")
            if response.posts.isEmpty {
                print("[HomeFeed] WARNING: API returned empty posts array")
            } else {
                print("[HomeFeed] First post sample: id=\(response.posts[0].id), author=\(response.posts[0].author.profile.displayName ?? "Unknown"), createdAt=\(response.posts[0].createdAt)")
            }
            
            await MainActor.run {
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                // Helper function to parse dates with or without timezone
                func parseDate(_ dateString: String) -> Date? {
                    // First try with the standard formatter
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    
                    // If that fails, try adding 'Z' if it's missing (assume UTC)
                    // Check if it has timezone info (Z, +, or - at the end)
                    let hasTimezone = dateString.hasSuffix("Z") || 
                                     dateString.contains("+") || 
                                     (dateString.count > 10 && dateString[dateString.index(dateString.endIndex, offsetBy: -6)...].contains(":"))
                    
                    if !hasTimezone {
                        let dateWithZ = dateString + "Z"
                        if let date = dateFormatter.date(from: dateWithZ) {
                            return date
                        }
                    }
                    
                    // Try without fractional seconds
                    let dateFormatterNoFraction = ISO8601DateFormatter()
                    dateFormatterNoFraction.formatOptions = [.withInternetDateTime]
                    if let date = dateFormatterNoFraction.date(from: dateString) {
                        return date
                    }
                    
                    // Try adding Z and without fractional seconds
                    if !hasTimezone {
                        let dateWithZ = dateString + "Z"
                        if let date = dateFormatterNoFraction.date(from: dateWithZ) {
                            return date
                        }
                    }
                    
                    return nil
                }
                
                var dateParseFailures = 0
                let loadedPosts = response.posts.compactMap { postResponse -> Post? in
                    guard let createdAt = parseDate(postResponse.createdAt) else {
                        dateParseFailures += 1
                        print("[HomeFeed] Failed to parse date: \(postResponse.createdAt) for post \(postResponse.id)")
                        return nil
                    }
                    
                    var isLiked = false
                    if let currentUserId = authManager.currentUser?.id {
                        // Handle both array and optional array for likes
                        if let likesArray = postResponse.likes {
                            isLiked = likesArray.contains(currentUserId.lowercased())
                        }
                    }
                    
                    return Post(
                        id: UUID(uuidString: postResponse.id) ?? UUID(),
                        authorId: postResponse.author.id,
                        author: postResponse.author.profile.displayName ?? "Unknown",
                        authorAvatar: postResponse.author.profile.avatar,
                        content: postResponse.content,
                        imageUrl: postResponse.imageUrl,
                        likes: postResponse.likes?.count ?? 0,
                        comments: postResponse.comments?.count ?? 0,
                        createdAt: createdAt,
                        isLiked: isLiked
                    )
                }
                
                if dateParseFailures > 0 {
                    print("[HomeFeed] WARNING: Failed to parse dates for \(dateParseFailures) posts")
                }
                
                // Sort posts by creation date (newest first)
                self.posts = loadedPosts.sorted { $0.createdAt > $1.createdAt }
                
                print("[HomeFeed] Loaded \(self.posts.count) posts after parsing")
                
                // Cache posts
                let cachedPosts = response.posts.compactMap { postResponse -> CachedPost? in
                    guard let createdAt = dateFormatter.date(from: postResponse.createdAt) else { return nil }
                    
                    return CachedPost(
                        id: postResponse.id,
                        content: postResponse.content,
                        imageUrl: postResponse.imageUrl,
                        authorId: postResponse.author.id,
                        authorName: postResponse.author.profile.displayName ?? "Unknown",
                        authorAvatar: postResponse.author.profile.avatar,
                        likes: postResponse.likes?.count ?? 0,
                        comments: postResponse.comments?.count ?? 0,
                        createdAt: createdAt,
                        status: postResponse.status
                    )
                }
                    if let userId = authManager.currentUser?.id {
                        DataManager.shared.cachePosts(cachedPosts, userId: userId)
                    }
                
                self.isLoading = false
            }
        } catch {
            print("[HomeFeed] Error loading posts: \(error)")
            await MainActor.run {
                self.isLoading = false
                // If we have cached posts, keep showing them
                if self.posts.isEmpty {
                    loadPostsFromCache()
                }
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
        // Navigate to friend profile if it's not the current user, otherwise to own profile
        if let currentUserId = authManager.currentUser?.id,
           post.authorId.lowercased() == currentUserId.lowercased() {
            ProfileView()
                .environmentObject(authManager)
        } else {
            // Navigate to friend profile
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
        guard !isLiking else { return }
        isLiking = true
        
        Task {
            guard let token = authManager.getValidatedToken() else {
                await MainActor.run {
                    isLiking = false
                }
                return
            }
            
            do {
                let apiService = ApiService.shared
                let postIdString = post.id.uuidString
                
                struct LikeResponse: Codable {
                    let liked: Bool
                    let likesCount: Int
                }
                
                let response: LikeResponse = try await apiService.makeRequest(
                    endpoint: "posts/\(postIdString)/like",
                    method: "POST",
                    token: token
                )
                
                await MainActor.run {
                    isLiked = response.liked
                    likesCount = response.likesCount
                    isLiking = false
                }
            } catch {
                print("[CosmicPostCard] Error liking post: \(error)")
                await MainActor.run {
                    isLiking = false
                }
            }
        }
    }
    
    private func sharePost(message: String) {
        guard !isSharing else { return }
        isSharing = true
        
        Task {
            guard let token = authManager.getValidatedToken() else {
                await MainActor.run {
                    isSharing = false
                    showShareSheet = false
                }
                return
            }
            
            do {
                let apiService = ApiService.shared
                
                // Create a new post with the shared content
                var content = message.trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty {
                    content += "\n\n"
                }
                content += "Shared from \(post.author):\n\(post.content)"
                
                struct PostResponse: Codable {
                    let post: PostData
                    let message: String
                }
                
                struct PostData: Codable {
                    let id: String
                    let content: String
                    let imageUrl: String?
                    let status: String
                }
                
                let body: [String: Any] = [
                    "content": content,
                    "imageUrl": post.imageUrl ?? NSNull()
                ]
                
                let _: PostResponse = try await apiService.makeRequest(
                    endpoint: "posts",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                await MainActor.run {
                    isSharing = false
                    showShareSheet = false
                    shareMessage = ""
                }
            } catch {
                print("[CosmicPostCard] Error sharing post: \(error)")
                await MainActor.run {
                    isSharing = false
                }
            }
        }
    }
}

// Share Post View
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

