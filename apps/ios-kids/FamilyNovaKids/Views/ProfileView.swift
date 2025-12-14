//
//  ProfileView.swift
//  FamilyNovaKids
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var displayName = ""
    @State private var email = ""
    @State private var school: String? = nil
    @State private var grade: String? = nil
    @State private var parentVerified = false
    @State private var schoolVerified = false
    @State private var avatarUrl: String? = nil
    @State private var bannerUrl: String? = nil
    @State private var showEditProfile = false
    @State private var showSchoolCodeEntry = false
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
                                        HStack(spacing: CosmicSpacing.xs) {
                                            Text(displayName.isEmpty ? email : displayName)
                                                .font(CosmicFonts.title)
                                                .foregroundColor(CosmicColors.textPrimary)
                                            
                                            // Verification badges
                                            if parentVerified {
                                                Image(systemName: "checkmark.seal.fill")
                                                    .foregroundColor(CosmicColors.nebulaBlue)
                                                    .font(.system(size: 18))
                                            }
                                            if schoolVerified {
                                                Image(systemName: "building.2.fill")
                                                    .foregroundColor(CosmicColors.nebulaPurple)
                                                    .font(.system(size: 18))
                                            }
                                        }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(CosmicColors.textPrimary)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if !schoolVerified {
                            Button(action: { showSchoolCodeEntry = true }) {
                                Label("Link School", systemImage: "building.2")
                            }
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: handleLogout) {
                            Label("Logout", systemImage: "arrow.right.square")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(CosmicColors.nebulaPurple)
                            .font(.system(size: 20))
                    }
                }
            }
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
            .sheet(isPresented: $showSchoolCodeEntry) {
                SchoolCodeEntryView { code in
                    validateSchoolCode(code: code)
                }
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
                    endpoint: "posts?userId=\(userId)",
                    method: "GET",
                    token: token
                )
                
                await MainActor.run {
                    // All posts returned are already filtered by userId, just ensure they're approved
                    let userPosts = response.posts.filter { postResponse in
                        postResponse.status == "approved"
                    }
                    
                    print("[ProfileView] Total posts from API: \(response.posts.count)")
                    print("[ProfileView] Approved posts: \(userPosts.count)")
                    print("[ProfileView] Current user ID: \(userId)")
                    
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
                    let verification: VerificationData
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
                
                struct VerificationData: Codable {
                    let parentVerified: Bool?
                    let schoolVerified: Bool?
                }
                
                let response: ProfileResponse = try await apiService.makeRequest(
                    endpoint: "kids/profile",
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
                    self.parentVerified = response.user.verification.parentVerified ?? false
                    self.schoolVerified = response.user.verification.schoolVerified ?? false
                    self.avatarUrl = response.user.profile.avatar
                    self.bannerUrl = response.user.profile.banner
                    self.isLoading = false
                    
                    // Update authManager's currentUser
                    if let currentUser = authManager.currentUser {
                        // Update the current user with fetched data
                        authManager.currentUser = User(
                            id: currentUser.id,
                            email: response.user.email,
                            displayName: self.displayName,
                            profile: UserProfile(
                                firstName: response.user.profile.firstName ?? "",
                                lastName: response.user.profile.lastName ?? "",
                                displayName: self.displayName,
                                avatar: response.user.profile.avatar,
                                school: self.school,
                                grade: self.grade
                            ),
                            verification: VerificationStatus(
                                parentVerified: self.parentVerified,
                                schoolVerified: self.schoolVerified
                            )
                        )
                    }
                }
                
                // Load friends count after profile loads
                await loadFriendsCount()
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
    
    private func validateSchoolCode(code: String) {
        // TODO: Implement API call to validate school code
        // POST /api/school-codes/validate
        // Body: { code }
        schoolVerified = true
        showSchoolCodeEntry = false
    }
    
    private func handleLogout() {
        authManager.logout()
    }
}

struct SchoolCodeEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var code = ""
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    let onValidate: (String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                VStack(spacing: CosmicSpacing.xl) {
                    // Header
                    VStack(spacing: CosmicSpacing.m) {
                        Text("🏫")
                            .font(.system(size: 80))
                        Text("Enter School Code")
                            .font(CosmicFonts.title)
                            .foregroundColor(CosmicColors.nebulaPurple)
                        Text("Get your 6-digit code from your school")
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CosmicSpacing.xl)
                    }
                    .padding(.top, CosmicSpacing.xxl)
                    
                    // Code Input
                    VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                        Text("School Code")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.textSecondary)
                        
                        TextField("Enter 6-digit code", text: $code)
                            .textFieldStyle(.plain)
                            .foregroundColor(CosmicColors.textPrimary)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .autocapitalization(.allCharacters)
                            .keyboardType(.asciiCapable)
                            .padding(CosmicSpacing.l)
                            .background(CosmicColors.glassBackground)
                            .cornerRadius(CosmicCornerRadius.large)
                            .overlay(
                                RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                                    .stroke(CosmicColors.nebulaBlue, lineWidth: 2)
                            )
                            .onChange(of: code) { newValue in
                                // Limit to 6 characters and uppercase
                                code = String(newValue.prefix(6)).uppercased()
                            }
                    }
                    .padding(.horizontal, CosmicSpacing.m)
                    
                    // Submit Button
                    Button(action: submitCode) {
                        HStack(spacing: CosmicSpacing.s) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("✅")
                                    .font(.system(size: 24))
                                Text("Verify School")
                                    .font(CosmicFonts.button)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(CosmicColors.nebulaPurple)
                        .cornerRadius(CosmicCornerRadius.large)
                        .shadow(color: CosmicColors.nebulaPurple.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, CosmicSpacing.m)
                    .disabled(code.count != 6 || isSubmitting)
                    .opacity(code.count == 6 ? 1.0 : 0.5)
                    
                    Spacer()
                }
            }
            .navigationTitle("School Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(CosmicFonts.button)
                    .foregroundColor(CosmicColors.nebulaBlue)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    onValidate(code)
                }
            } message: {
                Text("School code verified successfully!")
            }
        }
    }
    
    private func submitCode() {
        guard code.count == 6 else { return }
        
        isSubmitting = true
        Task {
            // TODO: Implement API call to validate school code
            // POST /api/school-codes/validate
            // Body: { code }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            isSubmitting = false
            showSuccess = true
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
