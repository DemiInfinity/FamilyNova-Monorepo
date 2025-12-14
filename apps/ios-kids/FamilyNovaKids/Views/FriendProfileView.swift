//
//  FriendProfileView.swift
//  FamilyNovaKids
//
//  Friend profile view with cosmic theme

import SwiftUI

struct FriendProfileView: View {
    let friend: Friend
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var friendProfile: FriendProfileData?
    @State private var isLoading = false
    @State private var posts: [Post] = []
    @State private var selectedTab = 0
    @State private var showMessage = false
    
    var body: some View {
        ZStack {
            CosmicBackground()
            
            if isLoading {
                VStack(spacing: CosmicSpacing.l) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(CosmicColors.nebulaPurple)
                    Text("Loading profile...")
                        .font(CosmicFonts.body)
                        .foregroundColor(CosmicColors.textSecondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Cover Banner
                        ZStack(alignment: .bottomLeading) {
                            CosmicColors.spaceGradient
                                .frame(height: 200)
                                .clipped()
                            
                            // Profile Picture overlaying the cover
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 120, height: 120)
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                
                                Group {
                                    if let avatarUrl = friend.avatar, !avatarUrl.isEmpty {
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
                                            .overlay(
                                                Text(friend.displayName.prefix(1).uppercased())
                                                    .font(.system(size: 48, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                            }
                            .offset(x: CosmicSpacing.m, y: 60)
                        }
                        
                        // Profile Info
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            HStack {
                                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                                    Text(friend.displayName)
                                        .font(CosmicFonts.title)
                                        .foregroundColor(CosmicColors.textPrimary)
                                    
                                    if friend.isVerified {
                                        HStack(spacing: CosmicSpacing.xs) {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(CosmicColors.planetTeal)
                                            Text("Verified")
                                                .font(CosmicFonts.caption)
                                                .foregroundColor(CosmicColors.planetTeal)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                // Message Button
                                Button(action: {
                                    showMessage = true
                                }) {
                                    HStack(spacing: CosmicSpacing.xs) {
                                        Image(systemName: "message.fill")
                                        Text("Message")
                                            .font(CosmicFonts.button)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, CosmicSpacing.l)
                                    .padding(.vertical, CosmicSpacing.s)
                                    .background(CosmicColors.nebulaPurple)
                                    .cornerRadius(CosmicCornerRadius.medium)
                                }
                            }
                            .padding(.horizontal, CosmicSpacing.m)
                            .padding(.top, 80)
                            
                            // Stats (if available)
                            if let profile = friendProfile {
                                HStack(spacing: CosmicSpacing.l) {
                                    VStack {
                                        Text("\(profile.postsCount)")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                        Text("Posts")
                                            .font(CosmicFonts.caption)
                                            .foregroundColor(CosmicColors.textMuted)
                                    }
                                    
                                    VStack {
                                        Text("\(profile.friendsCount)")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                        Text("Friends")
                                            .font(CosmicFonts.caption)
                                            .foregroundColor(CosmicColors.textMuted)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, CosmicSpacing.m)
                            }
                            
                            // Tabs
                            HStack(spacing: 0) {
                                FriendProfileTabButton(title: "Posts", isSelected: selectedTab == 0) {
                                    selectedTab = 0
                                }
                                
                                FriendProfileTabButton(title: "Photos", isSelected: selectedTab == 1) {
                                    selectedTab = 1
                                }
                            }
                            .padding(.horizontal, CosmicSpacing.m)
                            .padding(.top, CosmicSpacing.l)
                            
                            // Posts/Photos Content
                            if selectedTab == 0 {
                                if posts.isEmpty {
                                    VStack(spacing: CosmicSpacing.m) {
                                        Text("📝")
                                            .font(.system(size: 60))
                                        Text("No posts yet")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(CosmicSpacing.xxl)
                                } else {
                                    LazyVStack(spacing: CosmicSpacing.m) {
                                        ForEach(posts) { post in
                                            CosmicPostCard(post: post)
                                                .environmentObject(authManager)
                                        }
                                    }
                                    .padding(.horizontal, CosmicSpacing.m)
                                    .padding(.top, CosmicSpacing.m)
                                }
                            } else {
                                let photos = posts.filter { $0.imageUrl != nil && !$0.imageUrl!.isEmpty }
                                if photos.isEmpty {
                                    VStack(spacing: CosmicSpacing.m) {
                                        Text("📷")
                                            .font(.system(size: 60))
                                        Text("No photos yet")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(CosmicSpacing.xxl)
                                } else {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: CosmicSpacing.s) {
                                        ForEach(photos) { post in
                                            if let imageUrl = post.imageUrl {
                                                AsyncImage(url: URL(string: imageUrl)) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                } placeholder: {
                                                    Rectangle()
                                                        .fill(CosmicColors.glassBackground)
                                                }
                                                .frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: CosmicCornerRadius.small))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, CosmicSpacing.m)
                                    .padding(.top, CosmicSpacing.m)
                                }
                            }
                        }
                        .padding(.bottom, CosmicSpacing.xl)
                    }
                }
            }
        }
        .navigationTitle(friend.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(CosmicColors.nebulaPurple)
            }
        }
        .onAppear {
            loadFriendProfile()
        }
        .sheet(isPresented: $showMessage) {
            // Navigate to chat with this friend
            NavigationView {
                MessagesView(initialFriend: friend)
                    .environmentObject(authManager)
            }
        }
    }
    
    private func loadFriendProfile() {
        isLoading = true
        Task {
            guard let token = authManager.getValidatedToken() else {
                await MainActor.run {
                    isLoading = false
                }
                return
            }
            
            do {
                let apiService = ApiService.shared
                
                // Load posts and filter by friend
                struct PostsResponse: Codable {
                    let posts: [PostResponse]
                }
                
                struct PostResponse: Codable {
                    let id: String
                    let content: String
                    let imageUrl: String?
                    let author: AuthorResponse
                    let likes: [String]?
                    let comments: [CommentResponse]?
                    let createdAt: String
                    let status: String
                }
                
                struct AuthorResponse: Codable {
                    let id: String
                    let profile: AuthorProfileResponse
                }
                
                struct AuthorProfileResponse: Codable {
                    let displayName: String?
                    let avatar: String?
                }
                
                struct CommentResponse: Codable {
                    let id: String
                    let content: String
                    let author: AuthorResponse
                    let createdAt: String
                }
                
                // Get all posts by this friend using userId query parameter
                let postsResponse: PostsResponse = try await apiService.makeRequest(
                    endpoint: "posts?userId=\(friend.id.uuidString)",
                    method: "GET",
                    token: token
                )
                
                await MainActor.run {
                    // All posts returned are already filtered by userId, just ensure they're approved
                    let friendPosts = postsResponse.posts.filter { postResponse in
                        postResponse.status == "approved"
                    }
                    
                    print("[FriendProfileView] Total posts from API: \(postsResponse.posts.count)")
                    print("[FriendProfileView] Filtered friend posts: \(friendPosts.count)")
                    print("[FriendProfileView] Friend ID: \(friend.id.uuidString)")
                    
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    self.posts = friendPosts.compactMap { postResponse in
                        guard let createdAt = dateFormatter.date(from: postResponse.createdAt) else { return nil }
                        
                        let currentUserId = authManager.currentUser?.id ?? ""
                        let isLiked = postResponse.likes?.contains(currentUserId.lowercased()) ?? false
                        
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
                    
                    // Get friend count from friends list
                    struct FriendsResponse: Codable {
                        let friends: [FriendResult]
                    }
                    
                    struct FriendResult: Codable {
                        let id: String
                    }
                    
                    Task {
                        do {
                            let friendsResponse: FriendsResponse = try await apiService.makeRequest(
                                endpoint: "friends",
                                method: "GET",
                                token: token
                            )
                            
                            await MainActor.run {
                                self.friendProfile = FriendProfileData(
                                    postsCount: friendPosts.count,
                                    friendsCount: friendsResponse.friends.count
                                )
                                self.isLoading = false
                            }
                        } catch {
                            await MainActor.run {
                                self.friendProfile = FriendProfileData(
                                    postsCount: friendPosts.count,
                                    friendsCount: 0
                                )
                                self.isLoading = false
                            }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("[FriendProfileView] Error loading profile: \(error)")
                }
            }
        }
    }
}

struct FriendProfileData {
    let postsCount: Int
    let friendsCount: Int
}

struct FriendProfileTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: CosmicSpacing.xs) {
                Text(title)
                    .font(CosmicFonts.headline)
                    .foregroundColor(isSelected ? CosmicColors.nebulaPurple : CosmicColors.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CosmicSpacing.s)
                
                Rectangle()
                    .fill(isSelected ? CosmicColors.nebulaPurple : Color.clear)
                    .frame(height: 2)
            }
        }
    }
}

#Preview {
    FriendProfileView(friend: Friend(
        id: UUID(),
        displayName: "Test Friend",
        avatar: nil,
        isVerified: true
    ))
    .environmentObject(AuthManager())
}

