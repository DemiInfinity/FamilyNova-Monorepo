//
//  MainTabView.swift
//  FamilyNovaParent
//
//  Unified 5-tab cosmic navigation for Nova+

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home - Feed
            HomeFeedView()
                .environmentObject(authManager)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Explore - Discover
            ExploreView()
                .environmentObject(authManager)
                .tabItem {
                    Label("Explore", systemImage: "sparkles")
                }
                .tag(1)
            
            // Create - New Post
            CreatePostView()
                .environmentObject(authManager)
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            // Messages
            MessagesView()
                .environmentObject(authManager)
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .tag(3)
            
            // More - Profile & Parent Tools
            MoreView()
                .environmentObject(authManager)
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
        .accentColor(CosmicColors.nebulaPurple)
        .onAppear {
            // Cosmic theme for tab bar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(CosmicColors.spaceTop)
            appearance.shadowColor = UIColor(CosmicColors.nebulaPurple.opacity(0.3))
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}


#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
