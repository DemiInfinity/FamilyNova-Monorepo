//
//  PostDetailView.swift
//  FamilyNovaKids
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                // Post image
                if let imageUrl = post.imageUrl, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .fill(AppColors.mediumGray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(ProgressView())
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
                }
                
                // Post content
                PostCard(post: post)
                    .environmentObject(authManager)
            }
            .padding(AppSpacing.m)
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
    }
}

