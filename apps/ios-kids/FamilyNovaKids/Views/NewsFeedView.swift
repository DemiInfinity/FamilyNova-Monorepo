//
//  NewsFeedView.swift
//  FamilyNovaKids
//

import SwiftUI
import UIKit

struct NewsFeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var showCreatePost = false
    @EnvironmentObject var authManager: AuthManager
    
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
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.l) {
                            ForEach(posts) { post in
                                PostCard(post: post)
                            }
                        }
                        .padding(AppSpacing.m)
                    }
                }
            }
            .navigationTitle("News Feed")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreatePost = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryBlue)
                    }
                }
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
                    // We'll need to get the user ID - for now check if we have it in authManager
                    // The user ID should be available from the login response
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

struct Post: Identifiable {
    let id: UUID
    let author: String
    let content: String
    let imageUrl: String?
    let likes: Int
    let comments: Int
    let createdAt: Date
    let isLiked: Bool
}

struct PostCard: View {
    let post: Post
    @State private var isLiked = false
    @State private var likesCount = 0
    
    init(post: Post) {
        self.post = post
        _isLiked = State(initialValue: post.isLiked)
        _likesCount = State(initialValue: post.likes)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            // Author header
            HStack(spacing: AppSpacing.m) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Text("👤")
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(post.author)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.black)
                    
                    Text(post.createdAt, style: .relative)
                        .font(AppFonts.small)
                        .foregroundColor(AppColors.darkGray)
                }
                
                Spacer()
            }
            
            // Post content
            Text(post.content)
                .font(AppFonts.body)
                .foregroundColor(AppColors.black)
                .padding(.vertical, AppSpacing.s)
            
            // Post image (if any)
            if let imageUrl = post.imageUrl, !imageUrl.isEmpty {
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(AppColors.mediumGray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Text("📷 Image")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.darkGray)
                    )
            }
            
            // Actions
            HStack(spacing: AppSpacing.l) {
                Button(action: toggleLike) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? AppColors.primaryPink : AppColors.darkGray)
                        Text("\(likesCount)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.darkGray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {}) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "message")
                            .foregroundColor(AppColors.darkGray)
                        Text("\(post.comments)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.darkGray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, AppSpacing.xs)
        }
        .padding(AppSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    private func toggleLike() {
        isLiked.toggle()
        likesCount += isLiked ? 1 : -1
        // TODO: Implement API call to like/unlike post
    }
}

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var postContent = ""
    @State private var isPosting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.gradientBlue.opacity(0.1), AppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: AppSpacing.xl) {
                    // Header
                    VStack(spacing: AppSpacing.m) {
                        Text("✨")
                            .font(.system(size: 60))
                        Text("Share Your Day!")
                            .font(AppFonts.title)
                            .foregroundColor(AppColors.primaryPurple)
                        Text("Tell your friends what you're up to! Your parent will review it first.")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.xl)
                    }
                    .padding(.top, AppSpacing.xxl)
                    
                    // Post content
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        Text("What's on your mind?")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.darkGray)
                        
                        ZStack(alignment: .topLeading) {
                            // Background
                            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                        .stroke(AppColors.mediumGray, lineWidth: 1)
                                )
                            
                            // Placeholder text
                            if postContent.isEmpty {
                                Text("Share what you're up to...")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.mediumGray)
                                    .padding(.horizontal, AppSpacing.m + 4)
                                    .padding(.vertical, AppSpacing.m + 8)
                                    .allowsHitTesting(false)
                            }
                            
                            // TextEditor with proper text color
                            TextEditor(text: $postContent)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.black)
                                .frame(minHeight: 200)
                                .padding(AppSpacing.m)
                                .background(Color.white)
                                .tint(AppColors.primaryBlue) // Sets cursor color
                        }
                        .frame(minHeight: 200)
                        .onAppear {
                            // Fix TextEditor text color globally for this view
                            UITextView.appearance().backgroundColor = .clear
                            UITextView.appearance().textColor = UIColor(AppColors.black)
                        }
                    }
                    .padding(.horizontal, AppSpacing.m)
                    
                    Spacer()
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppFonts.button)
                    .foregroundColor(AppColors.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createPost) {
                        if isPosting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryBlue))
                        } else {
                            Text("Post")
                                .font(AppFonts.button)
                                .foregroundColor(
                                    postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        ? AppColors.mediumGray
                                        : AppColors.primaryBlue
                                )
                        }
                    }
                    .disabled(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createPost() {
        guard !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Validate token before using it
        guard let token = authManager.getValidatedToken() else {
            errorMessage = "Invalid authentication token. Please log out and log in again."
            showError = true
            return
        }
        
        isPosting = true
        Task {
            do {
                let apiService = ApiService.shared
                
                struct CreatePostResponse: Codable {
                    let post: PostResponse
                    let message: String
                }
                
                struct PostResponse: Codable {
                    let id: String
                    let content: String
                    let imageUrl: String?
                    let status: String
                }
                
                let body: [String: Any] = [
                    "content": postContent.trimmingCharacters(in: .whitespacesAndNewlines)
                ]
                
                let _: CreatePostResponse = try await apiService.makeRequest(
                    endpoint: "posts",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                await MainActor.run {
                    isPosting = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isPosting = false
                    
                    // Check if it's an authentication error
                    if let apiError = error as? ApiError {
                        switch apiError {
                        case .invalidResponse:
                            errorMessage = "Invalid authentication token. Please log out and log in again."
                            // Clear token and force logout
                            authManager.logout()
                        case .httpError(let statusCode):
                            if statusCode == 401 {
                                errorMessage = "Session expired. Please log in again."
                                authManager.logout()
                            } else {
                                errorMessage = "Failed to create post (Error \(statusCode))"
                            }
                        default:
                            errorMessage = "Failed to create post: \(error.localizedDescription)"
                        }
                    } else {
                        errorMessage = "Failed to create post: \(error.localizedDescription)"
                    }
                    
                    showError = true
                }
            }
        }
    }
}

#Preview {
    NewsFeedView()
        .environmentObject(AuthManager())
}

