//
//  ProfileView.swift
//  FamilyNovaParent
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var displayName = ""
    @State private var email = ""
    @State private var school: String? = nil
    @State private var grade: String? = nil
    @State private var avatarUrl: String? = nil
    @State private var bannerUrl: String? = nil
    @State private var showEditProfile = false
    @State private var pendingChanges = false
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var posts: [Post] = []
    @State private var postsCount = 0
    @State private var friendsCount = 0
    @State private var isLoadingPosts = false
    @State private var selectedTab = 0 // 0 = Posts, 1 = Photos (future)
    
    var body: some View {
        NavigationView {
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Cover Banner
                            ZStack(alignment: .bottomLeading) {
                                Group {
                                    if let bannerUrl = bannerUrl, !bannerUrl.isEmpty {
                                        AsyncImage(url: URL(string: bannerUrl)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            CosmicColors.spaceGradient
                                        }
                                    } else {
                                        CosmicColors.spaceGradient
                                    }
                                }
                                .frame(height: 200)
                                .clipped()
                                
                                // Profile Picture overlaying the cover
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 120, height: 120)
                                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                    
                                    Group {
                                        if let avatarUrl = avatarUrl, !avatarUrl.isEmpty {
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
                                                    Text((displayName.isEmpty ? email : displayName).prefix(1).uppercased())
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
                                        Text(displayName.isEmpty ? email : displayName)
                                            .font(CosmicFonts.title)
                                            .foregroundColor(CosmicColors.textPrimary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Edit Profile Button
                                    Button(action: {
                                        showEditProfile = true
                                    }) {
                                        HStack(spacing: CosmicSpacing.xs) {
                                            Image(systemName: "pencil")
                                            Text("Edit Profile")
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
                                
                                // Stats
                                HStack(spacing: CosmicSpacing.l) {
                                    VStack {
                                        Text("\(postsCount)")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                        Text("Posts")
                                            .font(CosmicFonts.caption)
                                            .foregroundColor(CosmicColors.textMuted)
                                    }
                                    
                                    VStack {
                                        Text("\(friendsCount)")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                        Text("Friends")
                                            .font(CosmicFonts.caption)
                                            .foregroundColor(CosmicColors.textMuted)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, CosmicSpacing.m)
                                
                                // Tabs
                                HStack(spacing: 0) {
                                    TabButton(title: "Posts", isSelected: selectedTab == 0) {
                                        selectedTab = 0
                                    }
                                    
                                    TabButton(title: "Photos", isSelected: selectedTab == 1) {
                                        selectedTab = 1
                                    }
                                }
                                .padding(.horizontal, CosmicSpacing.m)
                                .padding(.top, CosmicSpacing.l)
                                
                                // Content based on selected tab
                                if selectedTab == 0 {
                                    // Posts Feed
                                    if isLoadingPosts && posts.isEmpty {
                                        VStack(spacing: CosmicSpacing.l) {
                                            ProgressView()
                                            Text("Loading posts...")
                                                .font(CosmicFonts.body)
                                                .foregroundColor(CosmicColors.textSecondary)
                                        }
                                        .padding(CosmicSpacing.xxl)
                                    } else if posts.isEmpty {
                                        VStack(spacing: CosmicSpacing.l) {
                                            Text("📝")
                                                .font(.system(size: 60))
                                            Text("No posts yet")
                                                .font(CosmicFonts.headline)
                                                .foregroundColor(CosmicColors.nebulaPurple)
                                            Text("Share your first post!")
                                                .font(CosmicFonts.body)
                                                .foregroundColor(CosmicColors.textSecondary)
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
            .navigationTitle(displayName.isEmpty ? email : displayName)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(
                    currentDisplayName: displayName,
                    currentSchool: school ?? "",
                    currentGrade: grade ?? "",
                    currentAvatarUrl: avatarUrl,
                    currentBannerUrl: bannerUrl,
                    onSave: { newDisplayName, newSchool, newGrade in
                        // Request profile change
                        requestProfileChange(
                            displayName: newDisplayName,
                            school: newSchool,
                            grade: newGrade
                        )
                    },
                    onImageUploaded: {
                        // Reload profile to get updated images
                        loadProfile()
                    }
                )
                .environmentObject(authManager)
            }
            .onAppear {
                loadProfile()
                // Load user's posts when profile appears
                loadUserPosts()
            }
            .onChange(of: selectedTab) { newTab in
                // Reload posts when switching to Photos tab to show latest photos
                if newTab == 1 {
                    loadUserPosts()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loadUserPosts() {
        guard let token = authManager.getValidatedToken(),
              let userId = authManager.currentUser?.id else {
            return
        }
        
        isLoadingPosts = true
        Task {
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
                    // Filter to only show user's own posts (posts created by this user)
                    // Compare author.id with userId to ensure we only show posts created by the current user
                    let userPosts = response.posts.filter { postResponse in
                        // Ensure we're comparing strings correctly and only showing approved posts
                        postResponse.author.id == userId && postResponse.status == "approved"
                    }
                    
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    self.posts = userPosts.compactMap { postResponse in
                        let createdAt = dateFormatter.date(from: postResponse.createdAt) ?? Date()
                        
                        var isLiked = false
                        if let currentUserId = authManager.currentUser?.id {
                            isLiked = postResponse.likes?.contains(currentUserId) ?? false
                        }
                        
                        return Post(
                            id: UUID(uuidString: postResponse.id) ?? UUID(),
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
                    // Sort posts by creation date (newest first)
                    self.posts.sort { $0.createdAt > $1.createdAt }
                    self.postsCount = self.posts.count
                    self.isLoadingPosts = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingPosts = false
                    print("Error loading user posts: \(error)")
                }
            }
        }
    }
    
    private func loadFriendsCount() async {
        guard let token = authManager.getValidatedToken() else { return }
        
        do {
            let apiService = ApiService.shared
            
            struct FriendsResponse: Codable {
                let friends: [FriendResponse]
            }
            
            struct FriendResponse: Codable {
                let id: String
            }
            
            let response: FriendsResponse = try await apiService.makeRequest(
                endpoint: "friends",
                method: "GET",
                token: token
            )
            
            await MainActor.run {
                self.friendsCount = response.friends.count
            }
        } catch {
            print("Error loading friends count: \(error)")
        }
    }
    
    private func deletePost(postId: UUID) {
        guard let token = authManager.getValidatedToken() else {
            errorMessage = "Not authenticated. Please log in again."
            showError = true
            return
        }
        
        Task {
            do {
                let apiService = ApiService.shared
                let postIdString = postId.uuidString
                
                struct DeleteResponse: Codable {
                    let message: String
                    let postId: String
                }
                
                let _: DeleteResponse = try await apiService.makeRequest(
                    endpoint: "posts/\(postIdString)",
                    method: "DELETE",
                    token: token
                )
                
                // Remove the post from the local array and update count
                await MainActor.run {
                    self.posts.removeAll { $0.id == postId }
                    self.postsCount = self.posts.count
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to delete post: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func loadProfile() {
        guard let token = authManager.getValidatedToken() else {
            errorMessage = "Not authenticated. Please log in again."
            showError = true
            isLoading = false
            return
        }
        
        isLoading = true
        Task {
            do {
                let apiService = ApiService.shared
                
                struct ProfileResponse: Codable {
                    let user: UserProfileResponse
                }
                
                struct UserProfileResponse: Codable {
                    let id: String
                    let email: String
                    let profile: ProfileData
                    let friends: [FriendResponse]?
                    let friendsCount: Int?
                    let children: [ChildResponse]?
                    let childrenCount: Int?
                    let postsCount: Int?
                }
                
                struct ProfileData: Codable {
                    let firstName: String?
                    let lastName: String?
                    let displayName: String?
                    let school: String?
                    let grade: String?
                    let avatar: String?
                    let banner: String?
                }
                
                struct FriendResponse: Codable {
                    let id: String
                    let profile: FriendProfileData
                }
                
                struct FriendProfileData: Codable {
                    let displayName: String?
                    let avatar: String?
                }
                
                struct ChildResponse: Codable {
                    let id: String
                    let profile: ChildProfileData
                    let verification: VerificationData?
                }
                
                struct VerificationData: Codable {
                    let parentVerified: Bool?
                    let schoolVerified: Bool?
                }
                
                struct ChildProfileData: Codable {
                    let displayName: String?
                    let avatar: String?
                    let school: String?
                    let grade: String?
                }
                
                let response: ProfileResponse = try await apiService.makeRequest(
                    endpoint: "parents/profile",
                    method: "GET",
                    token: token
                )
                
                await MainActor.run {
                    self.email = response.user.email
                    let fullName = "\(response.user.profile.firstName ?? "") \(response.user.profile.lastName ?? "")".trimmingCharacters(in: .whitespaces)
                    self.displayName = response.user.profile.displayName ?? 
                                      (fullName.isEmpty ? response.user.email : fullName)
                    self.school = response.user.profile.school
                    self.grade = response.user.profile.grade
                    self.avatarUrl = response.user.profile.avatar
                    self.bannerUrl = response.user.profile.banner
                    
                    // Update counts from response
                    self.friendsCount = response.user.friendsCount ?? response.user.friends?.count ?? 0
                    self.postsCount = response.user.postsCount ?? 0
                    
                    self.isLoading = false
                    
                    // Update authManager's currentUser
                    if let currentUser = authManager.currentUser {
                        // Convert children from response to Child structs
                        let children = (response.user.children ?? []).map { childResponse in
                            let verificationData = childResponse.verification
                            let verification = VerificationStatus(
                                parentVerified: verificationData?.parentVerified ?? false,
                                schoolVerified: verificationData?.schoolVerified ?? false
                            )
                            return Child(
                                id: childResponse.id,
                                profile: ChildProfile(
                                    displayName: childResponse.profile.displayName ?? "Unknown",
                                    avatar: childResponse.profile.avatar,
                                    school: childResponse.profile.school,
                                    grade: childResponse.profile.grade
                                ),
                                verification: verification,
                                lastLogin: nil
                            )
                        }
                        
                        // Update the current user with fetched data
                        authManager.currentUser = ParentUser(
                            id: currentUser.id,
                            email: response.user.email,
                            profile: ParentProfile(
                                firstName: response.user.profile.firstName ?? "",
                                lastName: response.user.profile.lastName ?? "",
                                displayName: self.displayName,
                                avatar: self.avatarUrl
                            ),
                            children: children,
                            parentConnections: currentUser.parentConnections
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func requestProfileChange(displayName: String, school: String, grade: String) {
        // TODO: Implement API call to request profile change
        // POST /api/profile-changes/request
        pendingChanges = true
        showEditProfile = false
    }
    
    private func handleLogout() {
        authManager.logout()
    }
}

struct ProfileHeaderCard: View {
    let displayName: String
    let email: String
    
    var body: some View {
        VStack(spacing: CosmicSpacing.m) {
            // Avatar with fun gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [CosmicColors.nebulaBlue, CosmicColors.nebulaPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text("👤")
                    .font(.system(size: 60))
            }
            .shadow(color: CosmicColors.nebulaBlue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text(displayName)
                .font(CosmicFonts.title)
                .foregroundColor(CosmicColors.nebulaPurple)
            
            Text(email)
                .font(CosmicFonts.body)
                .foregroundColor(CosmicColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(CosmicSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: CosmicCornerRadius.extraLarge)
                .fill(Color.white)
                .shadow(color: CosmicColors.nebulaBlue.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

struct ProfileSchoolInfoCard: View {
    let school: String
    let grade: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.l) {
            HStack(spacing: CosmicSpacing.m) {
                Text("🏫")
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                    Text("School")
                        .font(CosmicFonts.small)
                        .foregroundColor(CosmicColors.textSecondary)
                    Text(school)
                        .font(CosmicFonts.headline)
                        .foregroundColor(CosmicColors.nebulaBlue)
                }
            }
            
            HStack(spacing: CosmicSpacing.m) {
                Text("📚")
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                    Text("Grade")
                        .font(CosmicFonts.small)
                        .foregroundColor(CosmicColors.textSecondary)
                    Text(grade)
                        .font(CosmicFonts.headline)
                        .foregroundColor(CosmicColors.nebulaPurple)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CosmicSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}

