//
//  ExploreView.swift
//  FamilyNovaKids
//
//  Cosmic-themed explore/discover screen

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                ScrollView {
                    VStack(spacing: CosmicSpacing.xl) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .cosmicIcon(color: CosmicColors.textMuted)
                            TextField("Search...", text: $searchText)
                                .font(CosmicFonts.body)
                                .foregroundColor(CosmicColors.textPrimary)
                        }
                        .padding(CosmicSpacing.m)
                        .cosmicCard()
                        .padding(.horizontal, CosmicSpacing.m)
                        .padding(.top, CosmicSpacing.m)
                        
                        // Trending Topics
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            Text("Trending Topics")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: CosmicSpacing.m) {
                                    ForEach(["Gaming", "Art", "Music", "Sports", "Science"], id: \.self) { topic in
                                        Text(topic)
                                            .font(CosmicFonts.caption)
                                            .foregroundColor(CosmicColors.textPrimary)
                                            .padding(.horizontal, CosmicSpacing.m)
                                            .padding(.vertical, CosmicSpacing.s)
                                            .background(
                                                Capsule()
                                                    .fill(CosmicColors.glassBackground)
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(CosmicColors.glassBorder, lineWidth: 1)
                                                    )
                                            )
                                    }
                                }
                                .padding(.horizontal, CosmicSpacing.m)
                            }
                        }
                        
                        // Friend Suggestions
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            Text("Friend Suggestions")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            // Placeholder for friend suggestions
                            Text("Discover new friends in your school community")
                                .font(CosmicFonts.body)
                                .foregroundColor(CosmicColors.textSecondary)
                                .padding(CosmicSpacing.m)
                                .cosmicCard()
                                .padding(.horizontal, CosmicSpacing.m)
                        }
                    }
                    .padding(.bottom, CosmicSpacing.xxl)
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ExploreView()
        .environmentObject(AuthManager())
}

