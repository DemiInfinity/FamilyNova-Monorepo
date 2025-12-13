//
//  NewsFeedView.swift
//  FamilyNovaKids
//

import SwiftUI

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
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
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
        // TODO: Implement API call to fetch posts
        // For now, simulate posts
        try? await Task.sleep(nanoseconds: 500_000_000)
        posts = []
        isLoading = false
    }
}

struct Post: Identifiable {
    let id = UUID()
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
                        
                        TextEditor(text: $postContent)
                            .foregroundColor(AppColors.black)
                            .font(AppFonts.body)
                            .frame(minHeight: 200)
                            .padding(AppSpacing.m)
                            .background(Color.white)
                            .cornerRadius(AppCornerRadius.large)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                    .stroke(AppColors.mediumGray, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, AppSpacing.m)
                    
                    // Post button
                    Button(action: createPost) {
                        HStack(spacing: AppSpacing.s) {
                            if isPosting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("🚀")
                                    .font(.system(size: 24))
                                Text("Post")
                                    .font(AppFonts.button)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
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
                    .padding(.horizontal, AppSpacing.m)
                    .disabled(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
                    .opacity(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                    
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
        
        isPosting = true
        Task {
            // TODO: Implement API call to create post
            // For now, simulate success
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isPosting = false
            dismiss()
        }
    }
}

#Preview {
    NewsFeedView()
        .environmentObject(AuthManager())
}

