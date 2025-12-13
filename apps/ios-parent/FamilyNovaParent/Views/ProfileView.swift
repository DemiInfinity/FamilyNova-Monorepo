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
    @State private var parentVerified = false
    @State private var schoolVerified = false
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
                Color.white.ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: ParentAppSpacing.l) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading profile...")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Cover Image/Banner (like Facebook/Twitter)
                            ZStack(alignment: .bottomLeading) {
                                // Cover Banner
                                LinearGradient(
                                    colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(height: 200)
                                .overlay(
                                    // Pattern overlay for visual interest
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 100))
                                        .foregroundColor(.white.opacity(0.1))
                                        .offset(x: 50, y: 50)
                                )
                                
                                // Profile Picture overlaying the cover
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 120, height: 120)
                                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                    
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 110, height: 110)
                                    
                                    Text("👤")
                                        .font(.system(size: 55))
                                }
                                .offset(x: 20, y: 60)
                            }
                            
                            // User Info Section
                            VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
                                // Name and Handle
                                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                                    HStack(spacing: ParentAppSpacing.xs) {
                                        Text(displayName.isEmpty ? email : displayName)
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(ParentAppColors.black)
                                        
                                        // Verification badges
                                        if parentVerified {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(ParentAppColors.primaryBlue)
                                                .font(.system(size: 18))
                                        }
                                        if schoolVerified {
                                            Image(systemName: "building.2.fill")
                                                .foregroundColor(ParentAppColors.primaryPurple)
                                                .font(.system(size: 18))
                                        }
                                    }
                                    
                                    Text("@\(email.components(separatedBy: "@").first ?? "user")")
                                        .font(ParentAppFonts.body)
                                        .foregroundColor(ParentAppColors.darkGray)
                                    
                                    // Bio/Info
                                    if let school = school, !school.isEmpty {
                                        HStack(spacing: ParentAppSpacing.xs) {
                                            Image(systemName: "building.2")
                                                .foregroundColor(ParentAppColors.mediumGray)
                                                .font(.system(size: 14))
                                            Text(school)
                                                .font(ParentAppFonts.caption)
                                                .foregroundColor(ParentAppColors.darkGray)
                                        }
                                        .padding(.top, ParentAppSpacing.xs)
                                    }
                                    
                                    if let grade = grade, !grade.isEmpty {
                                        HStack(spacing: ParentAppSpacing.xs) {
                                            Image(systemName: "book")
                                                .foregroundColor(ParentAppColors.mediumGray)
                                                .font(.system(size: 14))
                                            Text(grade)
                                                .font(ParentAppFonts.caption)
                                                .foregroundColor(ParentAppColors.darkGray)
                                        }
                                    }
                                }
                                .padding(.leading, 20)
                                .padding(.top, 70)
                                
                                // Stats Bar (like Twitter/Bluesky)
                                HStack(spacing: ParentAppSpacing.xl) {
                                    StatItem(count: postsCount, label: "Posts")
                                    StatItem(count: friendsCount, label: "Friends")
                                    StatItem(count: 0, label: "Following") // Future feature
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, ParentAppSpacing.m)
                                .padding(.bottom, ParentAppSpacing.s)
                                
                                Divider()
                                    .padding(.horizontal, 20)
                                
                                // Tabs (Posts, Photos, etc.)
                                HStack(spacing: 0) {
                                    TabButton(title: "Posts", isSelected: selectedTab == 0) {
                                        selectedTab = 0
                                    }
                                    TabButton(title: "Photos", isSelected: selectedTab == 1) {
                                        selectedTab = 1
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, ParentAppSpacing.s)
                                
                                // Content based on selected tab
                                if selectedTab == 0 {
                                    // Posts Feed
                                    if isLoadingPosts && posts.isEmpty {
                                        VStack(spacing: ParentAppSpacing.l) {
                                            ProgressView()
                                            Text("Loading posts...")
                                                .font(ParentAppFonts.body)
                                                .foregroundColor(ParentAppColors.darkGray)
                                        }
                                        .padding(ParentAppSpacing.xxl)
                                    } else if posts.isEmpty {
                                        VStack(spacing: ParentAppSpacing.l) {
                                            Text("📝")
                                                .font(.system(size: 60))
                                            Text("No posts yet")
                                                .font(ParentAppFonts.headline)
                                                .foregroundColor(ParentAppColors.primaryPurple)
                                            Text("Share your first post!")
                                                .font(ParentAppFonts.body)
                                                .foregroundColor(ParentAppColors.darkGray)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(ParentAppSpacing.xxl)
                                    } else {
                                        LazyVStack(spacing: ParentAppSpacing.m) {
                                            ForEach(posts) { post in
                                                PostCard(post: post, onDelete: {
                                                    deletePost(postId: post.id)
                                                })
                                                    .environmentObject(authManager)
                                                    .padding(.horizontal, ParentAppSpacing.m)
                                            }
                                        }
                                        .padding(.top, ParentAppSpacing.m)
                                    }
                                } else {
                                    // Photos tab - show posts with images
                                    if isLoadingPosts && posts.isEmpty {
                                        VStack(spacing: ParentAppSpacing.l) {
                                            ProgressView()
                                            Text("Loading photos...")
                                                .font(ParentAppFonts.body)
                                                .foregroundColor(ParentAppColors.darkGray)
                                        }
                                        .padding(ParentAppSpacing.xxl)
                                    } else {
                                        let postsWithImages = posts.filter { $0.imageUrl != nil && !$0.imageUrl!.isEmpty }
                                        
                                        if postsWithImages.isEmpty {
                                            VStack(spacing: ParentAppSpacing.l) {
                                                Text("📷")
                                                    .font(.system(size: 60))
                                                Text("No photos yet")
                                                    .font(ParentAppFonts.headline)
                                                    .foregroundColor(ParentAppColors.primaryPurple)
                                                Text("Photos from your posts will appear here")
                                                    .font(ParentAppFonts.body)
                                                    .foregroundColor(ParentAppColors.darkGray)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(ParentAppSpacing.xxl)
                                        } else {
                                            // Grid layout for photos
                                            LazyVGrid(columns: [
                                                GridItem(.flexible(), spacing: ParentAppSpacing.s),
                                                GridItem(.flexible(), spacing: ParentAppSpacing.s),
                                                GridItem(.flexible(), spacing: ParentAppSpacing.s)
                                            ], spacing: ParentAppSpacing.s) {
                                                ForEach(postsWithImages) { post in
                                                    if let imageUrl = post.imageUrl, !imageUrl.isEmpty {
                                                        NavigationLink(destination: PostDetailView(post: post)) {
                                                            AsyncImage(url: URL(string: imageUrl)) { image in
                                                                image
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                            } placeholder: {
                                                                RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                                                    .fill(ParentAppColors.mediumGray.opacity(0.3))
                                                                    .overlay(
                                                                        ProgressView()
                                                                    )
                                                            }
                                                            .frame(width: 110, height: 110)
                                                            .clipShape(RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium))
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, ParentAppSpacing.m)
                                            .padding(.top, ParentAppSpacing.m)
                                        }
                                    }
                                }
                            }
                            .background(Color.white)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(ParentAppColors.black)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showEditProfile = true }) {
                            Label("Edit Profile", systemImage: "pencil")
                        }
                        
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
                            .foregroundColor(ParentAppColors.primaryBlue)
                            .font(.system(size: 20))
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(
                    currentDisplayName: displayName,
                    currentSchool: school ?? "",
                    currentGrade: grade ?? "",
                    onSave: { newDisplayName, newSchool, newGrade in
                        // Request profile change
                        requestProfileChange(
                            displayName: newDisplayName,
                            school: newSchool,
                            grade: newGrade
                        )
                    }
                )
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
                    self.isLoading = false
                    
                    // Update authManager's currentUser
                    if let currentUser = authManager.currentUser {
                        // Update the current user with fetched data
                        authManager.currentUser = ParentUser(
                            id: currentUser.id,
                            email: response.user.email,
                            profile: ParentProfile(
                                firstName: response.user.profile.firstName ?? "",
                                lastName: response.user.profile.lastName ?? "",
                                displayName: self.displayName
                            ),
                            children: currentUser.children,
                            parentConnections: currentUser.parentConnections
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

struct SchoolCodeEntryCard: View {
    @Binding var showCodeEntry: Bool
    
    var body: some View {
        Button(action: { showCodeEntry = true }) {
            HStack(spacing: ParentAppSpacing.m) {
                ZStack {
                    Circle()
                        .fill(ParentAppColors.primaryOrange.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text("🏫")
                        .font(.system(size: 32))
                }
                
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text("Link Your School")
                        .font(ParentAppFonts.headline)
                        .foregroundColor(ParentAppColors.primaryOrange)
                    Text("Enter your school code to verify your account")
                        .font(ParentAppFonts.caption)
                        .foregroundColor(ParentAppColors.darkGray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(ParentAppColors.primaryOrange)
            }
            .padding(ParentAppSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                    .fill(ParentAppColors.primaryOrange.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
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
                LinearGradient(
                    colors: [ParentAppColors.gradientBlue.opacity(0.1), ParentAppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: ParentAppSpacing.xl) {
                    // Header
                    VStack(spacing: ParentAppSpacing.m) {
                        Text("🏫")
                            .font(.system(size: 80))
                        Text("Enter School Code")
                            .font(ParentAppFonts.title)
                            .foregroundColor(ParentAppColors.primaryPurple)
                        Text("Get your 6-digit code from your school")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, ParentAppSpacing.xl)
                    }
                    .padding(.top, ParentAppSpacing.xxl)
                    
                    // Code Input
                    VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                        Text("School Code")
                            .font(ParentAppFonts.caption)
                            .foregroundColor(ParentAppColors.darkGray)
                        
                        TextField("Enter 6-digit code", text: $code)
                            .textFieldStyle(.plain)
                            .foregroundColor(ParentAppColors.black)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .autocapitalization(.allCharacters)
                            .keyboardType(.asciiCapable)
                            .padding(ParentAppSpacing.l)
                            .background(Color.white)
                            .cornerRadius(ParentAppCornerRadius.large)
                            .overlay(
                                RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                                    .stroke(ParentAppColors.primaryBlue, lineWidth: 2)
                            )
                            .onChange(of: code) { newValue in
                                // Limit to 6 characters and uppercase
                                code = String(newValue.prefix(6)).uppercased()
                            }
                    }
                    .padding(.horizontal, ParentAppSpacing.m)
                    
                    // Submit Button
                    Button(action: submitCode) {
                        HStack(spacing: ParentAppSpacing.s) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("✅")
                                    .font(.system(size: 24))
                                Text("Verify School")
                                    .font(ParentAppFonts.button)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(ParentAppCornerRadius.large)
                        .shadow(color: ParentAppColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, ParentAppSpacing.m)
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
                    .font(ParentAppFonts.button)
                    .foregroundColor(ParentAppColors.primaryBlue)
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

struct ProfileHeaderCard: View {
    let displayName: String
    let email: String
    
    var body: some View {
        VStack(spacing: ParentAppSpacing.m) {
            // Avatar with fun gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text("👤")
                    .font(.system(size: 60))
            }
            .shadow(color: ParentAppColors.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text(displayName)
                .font(ParentAppFonts.title)
                .foregroundColor(ParentAppColors.primaryPurple)
            
            Text(email)
                .font(ParentAppFonts.body)
                .foregroundColor(ParentAppColors.darkGray)
        }
        .frame(maxWidth: .infinity)
        .padding(ParentAppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: ParentAppCornerRadius.extraLarge)
                .fill(Color.white)
                .shadow(color: ParentAppColors.primaryBlue.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

struct ProfileVerificationCard: View {
    let parentVerified: Bool
    let schoolVerified: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
            HStack {
                Text("✅")
                    .font(.system(size: 24))
                Text("Verification Status")
                    .font(ParentAppFonts.headline)
                    .foregroundColor(ParentAppColors.primaryPurple)
            }
            
            VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
                HStack(spacing: ParentAppSpacing.m) {
                    ZStack {
                        Circle()
                            .fill(parentVerified ? ParentAppColors.success.opacity(0.2) : ParentAppColors.error.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Text(parentVerified ? "✓" : "✗")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(parentVerified ? ParentAppColors.success : ParentAppColors.error)
                    }
                    Text("Parent Verified")
                        .font(ParentAppFonts.body)
                        .foregroundColor(parentVerified ? ParentAppColors.success : ParentAppColors.error)
                }
                
                HStack(spacing: ParentAppSpacing.m) {
                    ZStack {
                        Circle()
                            .fill(schoolVerified ? ParentAppColors.success.opacity(0.2) : ParentAppColors.error.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Text(schoolVerified ? "✓" : "✗")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(schoolVerified ? ParentAppColors.success : ParentAppColors.error)
                    }
                    Text("School Verified")
                        .font(ParentAppFonts.body)
                        .foregroundColor(schoolVerified ? ParentAppColors.success : ParentAppColors.error)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ParentAppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct ProfileSchoolInfoCard: View {
    let school: String
    let grade: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.l) {
            HStack(spacing: ParentAppSpacing.m) {
                Text("🏫")
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text("School")
                        .font(ParentAppFonts.small)
                        .foregroundColor(ParentAppColors.darkGray)
                    Text(school)
                        .font(ParentAppFonts.headline)
                        .foregroundColor(ParentAppColors.primaryBlue)
                }
            }
            
            HStack(spacing: ParentAppSpacing.m) {
                Text("📚")
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text("Grade")
                        .font(ParentAppFonts.small)
                        .foregroundColor(ParentAppColors.darkGray)
                    Text(grade)
                        .font(ParentAppFonts.headline)
                        .foregroundColor(ParentAppColors.primaryPurple)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ParentAppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}

