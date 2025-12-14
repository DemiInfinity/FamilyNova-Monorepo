//
//  MyPostsView.swift
//  FamilyNovaParent
//
//  View showing user's own posts with cosmic theme

import SwiftUI

struct MyPostsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var selectedTab = 0 // 0 = All Posts, 1 = Photos
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                VStack(spacing: 0) {
                    // Tab Selector
                    HStack(spacing: 0) {
                        MyPostsTabButton(title: "All Posts", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        MyPostsTabButton(title: "Photos", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                    }
                    .padding(.horizontal, CosmicSpacing.m)
                    .padding(.top, CosmicSpacing.m)
                    
                    // Content
                    if isLoading && posts.isEmpty {
                        VStack(spacing: CosmicSpacing.l) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(CosmicColors.nebulaPurple)
                            Text("Loading your posts...")
                                .font(CosmicFonts.body)
                                .foregroundColor(CosmicColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if posts.isEmpty {
                        VStack(spacing: CosmicSpacing.l) {
                            Text("📝")
                                .font(.system(size: 80))
                            Text("No Posts Yet")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                            Text("Start sharing your thoughts!")
                                .font(CosmicFonts.body)
                                .foregroundColor(CosmicColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        if selectedTab == 0 {
                            // All Posts
                            ScrollView {
                                LazyVStack(spacing: CosmicSpacing.m) {
                                    ForEach(posts) { post in
                                        CosmicPostCard(post: post)
                                            .environmentObject(authManager)
                                    }
                                }
                                .padding(CosmicSpacing.m)
                            }
                        } else {
                            // Photos Only
                            ScrollView {
                                let postsWithImages = posts.filter { $0.imageUrl != nil && !$0.imageUrl!.isEmpty }
                                
                                if postsWithImages.isEmpty {
                                    VStack(spacing: CosmicSpacing.l) {
                                        Text("📷")
                                            .font(.system(size: 60))
                                        Text("No photos yet")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                        Text("Photos from your posts will appear here")
                                            .font(CosmicFonts.body)
                                            .foregroundColor(CosmicColors.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(CosmicSpacing.xxl)
                                } else {
                                    LazyVGrid(columns: [
                                        GridItem(.flexible(), spacing: CosmicSpacing.s),
                                        GridItem(.flexible(), spacing: CosmicSpacing.s),
                                        GridItem(.flexible(), spacing: CosmicSpacing.s)
                                    ], spacing: CosmicSpacing.s) {
                                        ForEach(postsWithImages) { post in
                                            if let imageUrl = post.imageUrl, !imageUrl.isEmpty {
                                                NavigationLink(destination: PostDetailView(post: post)) {
                                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                    } placeholder: {
                                                        RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                                            .fill(CosmicColors.glassBackground)
                                                            .overlay(
                                                                ProgressView()
                                                                    .tint(CosmicColors.nebulaPurple)
                                                            )
                                                    }
                                                    .frame(width: 110, height: 110)
                                                    .clipShape(RoundedRectangle(cornerRadius: CosmicCornerRadius.medium))
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, CosmicSpacing.m)
                                    .padding(.top, CosmicSpacing.m)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Posts")
            .navigationBarTitleDisplayMode(.large)
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
                loadMyPosts()
            }
        }
    }
    
    private func loadMyPosts() {
        isLoading = true
        Task {
            await loadMyPostsAsync()
        }
    }
    
    private func loadMyPostsAsync() async {
        guard let token = authManager.getValidatedToken(),
              let currentUserId = authManager.currentUser?.id else {
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
                // Filter to only show current user's posts
                let filteredPosts = response.posts.compactMap { (postResponse: PostResponse) -> Post? in
                    guard postResponse.author.id.lowercased() == currentUserId.lowercased() else { return nil }
                    
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    let createdAt = dateFormatter.date(from: postResponse.createdAt) ?? Date()
                    
                    var isLiked = false
                    if let userId = authManager.currentUser?.id {
                        isLiked = postResponse.likes?.contains(userId.lowercased()) ?? false
                    }
                    
                    return Post(
                        id: UUID(uuidString: postResponse.id) ?? UUID(),
                        authorId: postResponse.author.id,
                        author: postResponse.author.profile.displayName ?? "You",
                        authorAvatar: postResponse.author.profile.avatar,
                        content: postResponse.content,
                        imageUrl: postResponse.imageUrl,
                        likes: postResponse.likes?.count ?? 0,
                        comments: postResponse.comments?.count ?? 0,
                        createdAt: createdAt,
                        isLiked: isLiked
                    )
                }
                self.posts = filteredPosts.sorted { $0.createdAt > $1.createdAt }
                self.isLoading = false
            }
        } catch {
            print("Error loading my posts: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

struct MyPostsTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CosmicFonts.body)
                .foregroundColor(isSelected ? CosmicColors.textPrimary : CosmicColors.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, CosmicSpacing.m)
                .background(
                    RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                        .fill(isSelected ? CosmicColors.glassBackground : Color.clear)
                )
        }
    }
}

#Preview {
    MyPostsView()
        .environmentObject(AuthManager())
}

