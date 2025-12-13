//
//  HomeView.swift
//  FamilyNovaKids
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showProfile = false
    @State private var showMessages = false
    @State private var showNotifications = false
    @State private var notificationCount = 0 // TODO: Fetch from backend
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var showCreatePost = false
    @State private var showPhotoPost = false
    @State private var showImageSourcePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fun gradient background
                LinearGradient(
                    colors: [AppColors.gradientBlue.opacity(0.1), AppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isLoading && posts.isEmpty {
                    VStack(spacing: AppSpacing.l) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading posts...")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.darkGray)
                    }
                } else if posts.isEmpty {
                    ScrollView {
                        VStack(spacing: AppSpacing.xl) {
                            // Welcome Card with emoji and fun design
                            WelcomeCard()
                                .padding(.horizontal, AppSpacing.m)
                                .padding(.top, AppSpacing.m)
                            
                            VStack(spacing: AppSpacing.l) {
                                Text("🌟")
                                    .font(.system(size: 80))
                                Text("No posts yet!")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.primaryPurple)
                                Text("Be the first to share something fun!")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.darkGray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, AppSpacing.xl)
                                
                                Button(action: { showCreatePost = true }) {
                                    HStack(spacing: AppSpacing.s) {
                                        Text("✨")
                                            .font(.system(size: 24))
                                        Text("Create Your First Post")
                                            .font(AppFonts.button)
                                            .foregroundColor(.white)
                                    }
                                    .padding(AppSpacing.l)
                                    .background(
                                        LinearGradient(
                                            colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(AppCornerRadius.large)
                                    .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .padding(.top, AppSpacing.m)
                            }
                            .padding(.top, AppSpacing.xxl)
                        }
                        .padding(.bottom, AppSpacing.xxl)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: AppSpacing.l) {
                            // Welcome Card with emoji and fun design
                            WelcomeCard()
                                .padding(.horizontal, AppSpacing.m)
                                .padding(.top, AppSpacing.m)
                            
                            // News Feed Posts
                            LazyVStack(spacing: AppSpacing.l) {
                                ForEach(posts) { post in
                                    PostCard(post: post)
                                        .padding(.horizontal, AppSpacing.m)
                                }
                            }
                            .padding(.top, AppSpacing.m)
                        }
                        .padding(.bottom, AppSpacing.xxl)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Create Post Button
                    Button(action: { showCreatePost = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryBlue)
                    }
                    
                    // Notifications Icon
                    Button(action: { showNotifications = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppColors.primaryBlue)
                            
                            if notificationCount > 0 {
                                Text("\(notificationCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    
                    // Messages Icon
                    Button(action: { showMessages = true }) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryPurple)
                    }
                    
                    // Profile Icon
                    Button(action: { showProfile = true }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }
                
                // Camera button in the middle
                ToolbarItem(placement: .principal) {
                    Button(action: { showImageSourcePicker = true }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showMessages) {
                MessagesView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showCreatePost, onDismiss: {
                // Refresh posts when the create post sheet is dismissed
                loadPosts()
            }) {
                CreatePostView()
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
                // Only show approved posts
                self.posts = response.posts.compactMap { postResponse in
                    guard postResponse.status == "approved" else { return nil }
                    
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    let createdAt = dateFormatter.date(from: postResponse.createdAt) ?? Date()
                    
                    // Check if current user liked this post
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
                
                // If it's an auth error, clear token and logout
                if let apiError = error as? ApiError {
                    switch apiError {
                    case .invalidResponse:
                        // Token is invalid, force logout
                        authManager.logout()
                    case .httpError(let statusCode):
                        if statusCode == 401 {
                            // Unauthorized, force logout
                            authManager.logout()
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
}

struct WelcomeCard: View {
    var body: some View {
        ZStack {
            // Fun gradient background
            LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(AppCornerRadius.extraLarge)
            
            HStack(spacing: AppSpacing.m) {
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    Text("Hey there! 👋")
                        .font(AppFonts.title)
                        .foregroundColor(.white)
                    
                    Text("Ready to connect with friends and learn something new?")
                        .font(AppFonts.body)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Fun emoji decoration
                Text("🌟")
                    .font(.system(size: 60))
            }
            .padding(AppSpacing.xl)
        }
        .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
