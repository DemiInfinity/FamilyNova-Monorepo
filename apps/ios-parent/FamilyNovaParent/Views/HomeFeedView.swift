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
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
            // Header
            HStack(spacing: CosmicSpacing.m) {
                // Profile picture with glow
                Circle()
                    .fill(CosmicColors.primaryGradient)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(CosmicColors.nebulaPurple.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: CosmicColors.nebulaPurple.opacity(0.5), radius: 8)
                
                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                    Text(post.author)
                        .font(CosmicFonts.headline)
                        .foregroundColor(CosmicColors.textPrimary)
                    Text(post.createdAt, style: .relative)
                        .font(CosmicFonts.small)
                        .foregroundColor(CosmicColors.textMuted)
                }
                
                Spacer()
            }
            
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
                        Image(systemName: isLiked ? "star.fill" : "star")
                            .cosmicIcon(size: 18, color: isLiked ? CosmicColors.starGold : CosmicColors.textMuted)
                        Text("\(post.likes)")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.textMuted)
                    }
                }
                
                Button(action: {}) {
                    HStack(spacing: CosmicSpacing.s) {
                        Image(systemName: "message")
                            .cosmicIcon(size: 18, color: CosmicColors.textMuted)
                        Text("\(post.comments)")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.textMuted)
                    }
                }
                
                Spacer()
            }
            .padding(.top, CosmicSpacing.s)
        }
        .padding(CosmicSpacing.m)
        .cosmicCard()
        .onAppear {
            isLiked = post.isLiked
        }
    }
    
    private func toggleLike() {
        isLiked.toggle()
        // TODO: Call API to like/unlike
    }
}

#Preview {
    HomeFeedView()
        .environmentObject(AuthManager())
}

