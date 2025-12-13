//
//  MainTabView.swift
//  FamilyNovaKids
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
                .tag(1)
            
            NewsFeedView()
                .tabItem {
                    Label("Feed", systemImage: "house.2.fill")
                }
                .tag(2)
            
            EducationView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(3)
            
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .tag(4)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(5)
        }
        .accentColor(AppColors.primaryBlue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}

