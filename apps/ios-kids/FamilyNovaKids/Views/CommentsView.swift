//
//  CommentsView.swift
//  FamilyNovaKids
//

import SwiftUI

struct CommentsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    let postId: UUID
    let postAuthor: String
    let postContent: String
    
    @State private var comments: [Comment] = []
    @State private var isLoading = false
    @State private var newComment = ""
    @State private var isPostingComment = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.gradientBlue.opacity(0.1), AppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Post Preview
                    VStack(alignment: .leading, spacing: AppSpacing.m) {
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
                                    .frame(width: 40, height: 40)
                                
                                Text("👤")
                                    .font(.system(size: 20))
                            }
                            
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(postAuthor)
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.black)
                                
                                Text(postContent)
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.darkGray)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                        .padding(AppSpacing.m)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                .fill(Color.white.opacity(0.8))
                        )
                    }
                    .padding(AppSpacing.m)
                    
                    // Comments List
                    if isLoading && comments.isEmpty {
                        VStack(spacing: AppSpacing.l) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Loading comments...")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.darkGray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if comments.isEmpty {
                        VStack(spacing: AppSpacing.l) {
                            Text("💬")
                                .font(.system(size: 60))
                            Text("No comments yet")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.primaryPurple)
                            Text("Be the first to comment!")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.darkGray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: AppSpacing.m) {
                                ForEach(comments) { comment in
                                    CommentRow(comment: comment)
                                }
                            }
                            .padding(AppSpacing.m)
                        }
                    }
                    
                    // Comment Input
                    VStack(spacing: 0) {
                        Divider()
                        
                        HStack(spacing: AppSpacing.m) {
                            TextField("Write a comment...", text: $newComment)
                                .textFieldStyle(.plain)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.black)
                                .padding(AppSpacing.m)
                                .background(Color.white)
                                .cornerRadius(AppCornerRadius.large)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                        .stroke(AppColors.mediumGray, lineWidth: 1)
                                )
                            
                            Button(action: postComment) {
                                if isPostingComment {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryBlue))
                                } else {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(
                                            newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                ? AppColors.mediumGray
                                                : AppColors.primaryBlue
                                        )
                                }
                            }
                            .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPostingComment)
                        }
                        .padding(AppSpacing.m)
                        .background(Color.white)
                    }
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(AppFonts.button)
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
            .onAppear {
                loadComments()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loadComments() {
        guard let token = authManager.getValidatedToken() else {
            isLoading = false
            return
        }
        
        isLoading = true
        Task {
            do {
                // Load all posts and find the one we need
                let apiService = ApiService.shared
                let postIdString = postId.uuidString
                
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
                
                // Find the post we need
                let post = response.posts.first { $0.id == postIdString }
                
                await MainActor.run {
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    let loadedComments = (post?.comments ?? []).compactMap { commentResponse in
                        let createdAt = dateFormatter.date(from: commentResponse.createdAt) ?? Date()
                        return Comment(
                            id: UUID(uuidString: commentResponse.id) ?? UUID(),
                            author: commentResponse.author.profile.displayName ?? "Unknown",
                            content: commentResponse.content,
                            createdAt: createdAt
                        )
                    }
                    self.comments = loadedComments.sorted { $0.createdAt < $1.createdAt } // Oldest first
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to load comments: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func postComment() {
        guard !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let token = authManager.getValidatedToken() else {
            errorMessage = "Not authenticated. Please log in again."
            showError = true
            return
        }
        
        let commentText = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        newComment = ""
        isPostingComment = true
        
        Task {
            do {
                let apiService = ApiService.shared
                let postIdString = postId.uuidString
                
                struct CommentResponse: Codable {
                    let comment: CommentData
                }
                
                struct CommentData: Codable {
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
                
                let body: [String: Any] = ["content": commentText]
                
                let response: CommentResponse = try await apiService.makeRequest(
                    endpoint: "posts/\(postIdString)/comment",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let createdAt = dateFormatter.date(from: response.comment.createdAt) ?? Date()
                
                let newComment = Comment(
                    id: UUID(uuidString: response.comment.id) ?? UUID(),
                    author: response.comment.author.profile.displayName ?? "Unknown",
                    content: response.comment.content,
                    createdAt: createdAt
                )
                
                await MainActor.run {
                    self.comments.append(newComment)
                    self.comments.sort { $0.createdAt < $1.createdAt } // Keep oldest first
                    self.isPostingComment = false
                }
            } catch {
                await MainActor.run {
                    self.isPostingComment = false
                    self.newComment = commentText // Restore comment text
                    self.errorMessage = "Failed to post comment: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
}

struct Comment: Identifiable {
    let id: UUID
    let author: String
    let content: String
    let createdAt: Date
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.m) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Text("👤")
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(comment.author)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.primaryBlue)
                
                Text(comment.content)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.black)
                
                Text(comment.createdAt, style: .relative)
                    .font(AppFonts.small)
                    .foregroundColor(AppColors.mediumGray)
            }
            
            Spacer()
        }
        .padding(AppSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct ReactionPickerView: View {
    let onReactionSelected: (String) -> Void
    let onDismiss: () -> Void
    
    let reactions = ["👍", "❤️", "😂", "😮", "😢", "😡"]
    
    var body: some View {
        HStack(spacing: AppSpacing.m) {
            ForEach(reactions, id: \.self) { reaction in
                Button(action: {
                    onReactionSelected(reaction)
                }) {
                    Text(reaction)
                        .font(.system(size: 32))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(AppSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    CommentsView(postId: UUID(), postAuthor: "Test User", postContent: "This is a test post")
        .environmentObject(AuthManager())
}

