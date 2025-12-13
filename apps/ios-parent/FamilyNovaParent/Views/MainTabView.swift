//
//  MainTabView.swift
//  FamilyNovaParent
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .environmentObject(authManager)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            FriendsView()
                .environmentObject(authManager)
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
                .tag(1)
            
            MessagesView()
                .environmentObject(authManager)
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .tag(2)
            
            ProfileView()
                .environmentObject(authManager)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
            
            MoreView()
                .environmentObject(authManager)
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
        .accentColor(ParentAppColors.primaryTeal)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}

