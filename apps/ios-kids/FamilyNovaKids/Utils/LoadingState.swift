//
//  LoadingState.swift
//  FamilyNovaKids
//
//  Enhanced loading states with skeleton loaders

import SwiftUI

struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
            .fill(
                LinearGradient(
                    colors: [
                        CosmicColors.glassBackground.opacity(0.3),
                        CosmicColors.glassBackground.opacity(0.6),
                        CosmicColors.glassBackground.opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                    .stroke(CosmicColors.glassBorder.opacity(0.3), lineWidth: 1)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

struct PostSkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
            // Header
            HStack(spacing: CosmicSpacing.m) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                CosmicColors.glassBackground.opacity(0.3),
                                CosmicColors.glassBackground.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                    SkeletonView()
                        .frame(height: 16)
                    SkeletonView()
                        .frame(width: 100, height: 12)
                }
                
                Spacer()
            }
            
            // Content
            SkeletonView()
                .frame(height: 60)
            
            // Actions
            HStack(spacing: CosmicSpacing.l) {
                SkeletonView()
                    .frame(width: 60, height: 20)
                SkeletonView()
                    .frame(width: 60, height: 20)
                Spacer()
            }
        }
        .padding(CosmicSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                .fill(CosmicColors.glassBackground)
        )
    }
}

struct LoadingStateView: View {
    let message: String
    let showSkeleton: Bool
    
    init(message: String = "Loading...", showSkeleton: Bool = false) {
        self.message = message
        self.showSkeleton = showSkeleton
    }
    
    var body: some View {
        if showSkeleton {
            VStack(spacing: CosmicSpacing.l) {
                ForEach(0..<3) { _ in
                    PostSkeletonCard()
                }
            }
            .padding(CosmicSpacing.m)
        } else {
            VStack(spacing: CosmicSpacing.l) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(CosmicColors.nebulaPurple)
                Text(message)
                    .font(CosmicFonts.body)
                    .foregroundColor(CosmicColors.textSecondary)
            }
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String = "sparkles",
        title: String = "Nothing here",
        message: String = "Check back later!",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: CosmicSpacing.xl) {
            Image(systemName: icon)
                .cosmicIcon(size: 60, color: CosmicColors.nebulaPurple)
            Text(title)
                .font(CosmicFonts.headline)
                .foregroundColor(CosmicColors.textPrimary)
            Text(message)
                .font(CosmicFonts.body)
                .foregroundColor(CosmicColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CosmicSpacing.xl)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(CosmicFonts.button)
                        .foregroundColor(.white)
                        .padding(.horizontal, CosmicSpacing.l)
                        .padding(.vertical, CosmicSpacing.m)
                        .background(
                            RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                .fill(CosmicColors.nebulaPurple)
                        )
                }
            }
        }
    }
}

