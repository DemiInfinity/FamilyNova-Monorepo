//
//  MainTabView.swift
//  FamilyNovaParent
//
//  Unified 5-tab cosmic navigation for Nova+

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var toastNotification: ToastNotificationData?
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
        .toastNotification($toastNotification)
        .onAppear {
            // Cosmic theme for tab bar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(CosmicColors.spaceTop)
            appearance.shadowColor = UIColor(CosmicColors.nebulaPurple.opacity(0.3))
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Listen for toast notifications
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ShowToastNotification"),
                object: nil,
                queue: .main
            ) { notification in
                if let userInfo = notification.userInfo,
                   let title = userInfo["title"] as? String,
                   let message = userInfo["message"] as? String,
                   let icon = userInfo["icon"] as? String {
                    
                    let color: Color
                    if let type = userInfo["type"] as? String, type == "message" {
                        color = CosmicColors.nebulaBlue
                    } else {
                        color = CosmicColors.nebulaPurple
                    }
                    
                    toastNotification = ToastNotificationData(
                        title: title,
                        message: message,
                        icon: icon,
                        color: color
                    )
                    
                    // Auto-dismiss after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        toastNotification = nil
                    }
                }
            }
        }
    }
}


#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
