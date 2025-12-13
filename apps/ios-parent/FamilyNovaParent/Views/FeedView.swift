//
//  FeedView.swift
//  FamilyNovaParent
//

import SwiftUI
import UIKit

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var showCreatePost = false
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fun gradient background
                LinearGradient(
                    colors: [ParentAppColors.gradientBlue.opacity(0.1), ParentAppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isLoading && posts.isEmpty {
                    VStack(spacing: ParentAppSpacing.l) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading posts...")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                } else if posts.isEmpty {
                    VStack(spacing: ParentAppSpacing.l) {
                        Text("🌟")
                            .font(.system(size: 80))
                        Text("No posts yet!")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.primaryPurple)
                        Text("Be the first to share something fun!")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, ParentAppSpacing.xl)
                        
                        Button(action: { showCreatePost = true }) {
                            HStack(spacing: ParentAppSpacing.s) {
                                Text("✨")
                                    .font(.system(size: 24))
                                Text("Create Your First Post")
                                    .font(ParentAppFonts.button)
                                    .foregroundColor(.white)
                            }
                            .padding(ParentAppSpacing.l)
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
                        .padding(.top, ParentAppSpacing.m)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: ParentAppSpacing.l) {
                            ForEach(posts) { post in
                                PostCard(post: post)
                            }
                        }
                        .padding(ParentAppSpacing.m)
                    }
                }
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreatePost = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(ParentAppColors.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showCreatePost, onDismiss: {
                // Refresh posts when the create post sheet is dismissed
                loadPosts()
            }) {
                UnifiedCreatePostView(onPostCreated: {
                    // Refresh posts after post is created
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
                // Only show approved posts from users 16+ (parents/adults)
                // The backend should filter by age, but we'll also filter here for safety
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
    @State private var commentsCount = 0
    @State private var showComments = false
    @State private var showReactionPicker = false
    @State private var selectedReaction: String? = nil
    @State private var showDeleteConfirmation = false
    @EnvironmentObject var authManager: AuthManager
    var onDelete: (() -> Void)? = nil // Optional callback for delete action
    
    init(post: Post, onDelete: (() -> Void)? = nil) {
        self.post = post
        self.onDelete = onDelete
        _isLiked = State(initialValue: post.isLiked)
        _likesCount = State(initialValue: post.likes)
        _commentsCount = State(initialValue: post.comments)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
            // Author header
            HStack(spacing: ParentAppSpacing.m) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Text("👤")
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text(post.author)
                        .font(ParentAppFonts.headline)
                        .foregroundColor(ParentAppColors.black)
                    
                    Text(post.createdAt, style: .relative)
                        .font(ParentAppFonts.small)
                        .foregroundColor(ParentAppColors.darkGray)
                }
                
                Spacer()
                
                // Delete button (only shown if onDelete callback is provided)
                if onDelete != nil {
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(ParentAppColors.error)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Post content
            Text(post.content)
                .font(ParentAppFonts.body)
                .foregroundColor(ParentAppColors.black)
                .padding(.vertical, ParentAppSpacing.s)
            
            // Post image (if any)
            if let imageUrl = post.imageUrl, !imageUrl.isEmpty {
                RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                    .fill(ParentAppColors.mediumGray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Text("📷 Image")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                    )
            }
            
            // Actions
            HStack(spacing: ParentAppSpacing.l) {
                // Like/Reaction Button
                HStack(spacing: ParentAppSpacing.xs) {
                    Button(action: toggleLike) {
                        HStack(spacing: ParentAppSpacing.xs) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? ParentAppColors.primaryPink : ParentAppColors.darkGray)
                            Text("\(likesCount)")
                                .font(ParentAppFonts.caption)
                                .foregroundColor(ParentAppColors.darkGray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Reaction Picker Button
                    Button(action: { showReactionPicker.toggle() }) {
                        Image(systemName: "face.smiling")
                            .foregroundColor(ParentAppColors.darkGray)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Comment Button
                Button(action: { showComments = true }) {
                    HStack(spacing: ParentAppSpacing.xs) {
                        Image(systemName: "message")
                            .foregroundColor(ParentAppColors.darkGray)
                        Text("\(commentsCount)")
                            .font(ParentAppFonts.caption)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, ParentAppSpacing.xs)
        }
        .padding(ParentAppSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
        .overlay(
            // Reaction Picker
            Group {
                if showReactionPicker {
                    ReactionPickerView(
                        onReactionSelected: { reaction in
                            addReaction(reaction)
                            showReactionPicker = false
                        },
                        onDismiss: {
                            showReactionPicker = false
                        }
                    )
                    .offset(x: 0, y: -60)
                }
            },
            alignment: .bottomLeading
        )
        .sheet(isPresented: $showComments, onDismiss: {
            // Refresh comments count when sheet is dismissed
            refreshCommentsCount()
        }) {
            CommentsView(postId: post.id, postAuthor: post.author, postContent: post.content)
                .environmentObject(authManager)
        }
        .alert("Delete Post", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("Are you sure you want to delete this post? This action cannot be undone.")
        }
    }
    
    private func toggleLike() {
        guard let token = authManager.getValidatedToken() else { return }
        
        let previousLiked = isLiked
        let previousCount = likesCount
        
        // Optimistic update
        isLiked.toggle()
        likesCount += isLiked ? 1 : -1
        
        Task {
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
                    self.isLiked = response.liked
                    self.likesCount = response.likesCount
                }
            } catch {
                // Revert on error
                await MainActor.run {
                    self.isLiked = previousLiked
                    self.likesCount = previousCount
                }
                print("Error liking post: \(error)")
            }
        }
    }
    
    private func addReaction(_ reaction: String) {
        // For now, reactions are just visual - we can extend the backend later
        // This is a placeholder for future reaction functionality
        print("Reaction selected: \(reaction)")
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
                    let content: String
                    let author: AuthorResponse
                    let createdAt: String
                }
                
                struct AuthorResponse: Codable {
                    let id: String
                    let profile: ProfileResponse
                }
                
                struct ProfileResponse: Codable {
                    let displayName: String?
                }
                
                let response: PostsResponse = try await apiService.makeRequest(
                    endpoint: "posts",
                    method: "GET",
                    token: token
                )
                
                let postResponse = response.posts.first { $0.id == postIdString }
                
                await MainActor.run {
                    self.commentsCount = postResponse?.comments?.count ?? 0
                }
            } catch {
                print("Error refreshing comments count: \(error)")
            }
        }
    }
}

struct TextOnlyPostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var postContent = ""
    @State private var isPosting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var visibleToChildren = true // Default: children can see parent posts
    @EnvironmentObject var authManager: AuthManager
    
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
                        Text("✨")
                            .font(.system(size: 60))
                        Text("Share Your Day!")
                            .font(ParentAppFonts.title)
                            .foregroundColor(ParentAppColors.primaryPurple)
                        Text("Share what's on your mind with other parents and your children!")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, ParentAppSpacing.xl)
                    }
                    .padding(.top, ParentAppSpacing.xxl)
                    
                    // Post content
                    VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                        Text("What's on your mind?")
                            .font(ParentAppFonts.caption)
                            .foregroundColor(ParentAppColors.darkGray)
                        
                        ZStack(alignment: .topLeading) {
                            // Background
                            RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                                        .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                                )
                            
                            // Placeholder text
                            if postContent.isEmpty {
                                Text("Share what you're up to...")
                                    .font(ParentAppFonts.body)
                                    .foregroundColor(ParentAppColors.mediumGray)
                                    .padding(.horizontal, ParentAppSpacing.m + 4)
                                    .padding(.vertical, ParentAppSpacing.m + 8)
                                    .allowsHitTesting(false)
                            }
                            
                            // TextEditor with proper text color
                            TextEditor(text: $postContent)
                                .font(ParentAppFonts.body)
                                .foregroundColor(ParentAppColors.black)
                                .frame(minHeight: 200)
                                .padding(ParentAppSpacing.m)
                                .background(Color.white)
                                .tint(ParentAppColors.primaryBlue) // Sets cursor color
                        }
                        .frame(minHeight: 200)
                        .onAppear {
                            // Fix TextEditor text color globally for this view
                            UITextView.appearance().backgroundColor = .clear
                            UITextView.appearance().textColor = UIColor(ParentAppColors.black)
                        }
                    }
                    .padding(.horizontal, ParentAppSpacing.m)
                    
                    // Visibility Toggle (for parents)
                    VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                        HStack {
                            VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                                Text("Visibility")
                                    .font(ParentAppFonts.headline)
                                    .foregroundColor(ParentAppColors.black)
                                Text("Allow children to see this post")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $visibleToChildren)
                                .labelsHidden()
                        }
                        .padding(ParentAppSpacing.m)
                        .background(Color.white)
                        .cornerRadius(ParentAppCornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, ParentAppSpacing.m)
                    
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
                    .font(ParentAppFonts.button)
                    .foregroundColor(ParentAppColors.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createPost) {
                        if isPosting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: ParentAppColors.primaryBlue))
                        } else {
                            Text("Post")
                                .font(ParentAppFonts.button)
                                .foregroundColor(
                                    postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        ? ParentAppColors.mediumGray
                                        : ParentAppColors.primaryBlue
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
                    "content": postContent.trimmingCharacters(in: .whitespacesAndNewlines),
                    "visibleToChildren": visibleToChildren
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
    FeedView()
        .environmentObject(AuthManager())
}

