//
//  PostApprovalView.swift
//  FamilyNovaParent
//

import SwiftUI

struct PostApprovalView: View {
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var pendingPosts: [PendingPost] = []
    @State private var isLoading = false
    @State private var toast: ToastNotificationData? = nil
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                OfflineIndicator()
                
                if isLoading && pendingPosts.isEmpty {
                    LoadingStateView(message: "Loading posts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if pendingPosts.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle",
                        title: "No pending posts",
                        message: "All posts from your children have been reviewed"
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: ParentAppSpacing.l) {
                            ForEach(pendingPosts) { post in
                                PendingPostCard(post: post)
                            }
                        }
                        .padding(ParentAppSpacing.m)
                    }
                }
            }
            .background(ParentAppColors.lightGray)
            .navigationTitle("Post Approval")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadPendingPosts()
            }
            .refreshable {
                await loadPendingPostsAsync()
            }
            .toastNotification($toast)
        }
    }
    
    private func loadPendingPosts() {
        isLoading = true
        Task {
            await loadPendingPostsAsync()
        }
    }
    
    private func loadPendingPostsAsync() async {
        // TODO: Implement API call to fetch pending posts
        // For now, simulate posts
        try? await Task.sleep(nanoseconds: 500_000_000)
        pendingPosts = []
        isLoading = false
    }
}

struct PendingPost: Identifiable {
    let id = UUID()
    let postId: String
    let author: String
    let content: String
    let imageUrl: String?
    let createdAt: Date
}

struct PendingPostCard: View {
    let post: PendingPost
    @State private var isProcessing = false
    @State private var showRejectReason = false
    @State private var rejectReason = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text("From: \(post.author)")
                        .font(ParentAppFonts.headline)
                        .foregroundColor(ParentAppColors.primaryNavy)
                    Text(post.createdAt, style: .relative)
                        .font(ParentAppFonts.small)
                        .foregroundColor(ParentAppColors.darkGray)
                }
                
                Spacer()
                
                Text("Pending Review")
                    .font(ParentAppFonts.caption)
                    .foregroundColor(ParentAppColors.warning)
                    .padding(.horizontal, ParentAppSpacing.m)
                    .padding(.vertical, ParentAppSpacing.xs)
                    .background(ParentAppColors.warning.opacity(0.2))
                    .cornerRadius(ParentAppCornerRadius.small)
            }
            
            Divider()
            
            // Post content
            Text(post.content)
                .font(ParentAppFonts.body)
                .foregroundColor(ParentAppColors.black)
                .padding(.vertical, ParentAppSpacing.xs)
            
            // Post image (if any)
            if let imageUrl = post.imageUrl, !imageUrl.isEmpty {
                RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                    .fill(ParentAppColors.mediumGray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Text("📷 Image")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                    )
            }
            
            // Actions
            HStack(spacing: ParentAppSpacing.m) {
                Button(action: { approvePost() }) {
                    HStack(spacing: ParentAppSpacing.xs) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        Text("Approve")
                            .font(ParentAppFonts.button)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ParentAppSpacing.m)
                    .background(ParentAppColors.success)
                    .cornerRadius(ParentAppCornerRadius.medium)
                }
                .disabled(isProcessing)
                
                Button(action: { showRejectReason = true }) {
                    HStack(spacing: ParentAppSpacing.xs) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Reject")
                            .font(ParentAppFonts.button)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ParentAppSpacing.m)
                    .background(ParentAppColors.error)
                    .cornerRadius(ParentAppCornerRadius.medium)
                }
                .disabled(isProcessing)
            }
        }
        .padding(ParentAppSpacing.l)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.large)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .alert("Reject Post", isPresented: $showRejectReason) {
            TextField("Reason (optional)", text: $rejectReason)
            Button("Cancel", role: .cancel) {
                rejectReason = ""
            }
            Button("Reject") {
                rejectPost()
            }
        } message: {
            Text("Please provide a reason for rejecting this post (optional)")
        }
    }
    
    private func approvePost() {
        isProcessing = true
        // TODO: Implement API call to approve post
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            isProcessing = false
        }
    }
    
    private func rejectPost() {
        isProcessing = true
        // TODO: Implement API call to reject post with reason
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            isProcessing = false
            rejectReason = ""
        }
    }
}

#Preview {
    PostApprovalView()
        .environmentObject(AuthManager())
}

