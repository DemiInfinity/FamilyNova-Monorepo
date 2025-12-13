//
//  MainTabView.swift
//  FamilyNovaKids
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(authManager)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            FriendsView()
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
            
            EducationView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(3)
        }
        .accentColor(AppColors.primaryBlue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}

