//
//  LoadingState.swift
//  FamilyNovaParent
//
//  Enhanced loading states with skeleton loaders

import SwiftUI

struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
            .fill(
                LinearGradient(
                    colors: [
                        ParentAppColors.lightGray.opacity(0.3),
                        ParentAppColors.lightGray.opacity(0.6),
                        ParentAppColors.lightGray.opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
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
        VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
            // Header
            HStack(spacing: ParentAppSpacing.m) {
                Circle()
                    .fill(ParentAppColors.lightGray.opacity(0.5))
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
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
            HStack(spacing: ParentAppSpacing.l) {
                SkeletonView()
                    .frame(width: 60, height: 20)
                SkeletonView()
                    .frame(width: 60, height: 20)
                Spacer()
            }
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
            VStack(spacing: ParentAppSpacing.l) {
                ForEach(0..<3) { _ in
                    PostSkeletonCard()
                }
            }
            .padding(ParentAppSpacing.m)
        } else {
            VStack(spacing: ParentAppSpacing.m) {
                ProgressView()
                Text(message)
                    .font(ParentAppFonts.body)
                    .foregroundColor(ParentAppColors.darkGray)
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
        icon: String = "checkmark.circle",
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
        VStack(spacing: ParentAppSpacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(ParentAppColors.success)
            Text(title)
                .font(ParentAppFonts.headline)
                .foregroundColor(ParentAppColors.black)
            Text(message)
                .font(ParentAppFonts.body)
                .foregroundColor(ParentAppColors.darkGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ParentAppSpacing.xl)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(ParentAppFonts.button)
                        .foregroundColor(.white)
                        .padding(.horizontal, ParentAppSpacing.l)
                        .padding(.vertical, ParentAppSpacing.m)
                        .background(ParentAppColors.primaryTeal)
                        .cornerRadius(ParentAppCornerRadius.small)
                }
            }
        }
    }
}

