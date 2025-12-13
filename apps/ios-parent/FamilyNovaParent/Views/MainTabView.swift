//
//  MainTabView.swift
//  FamilyNovaParent
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            MonitoringView()
                .tabItem {
                    Label("Monitoring", systemImage: "eye.fill")
                }
                .tag(1)
            
            PostApprovalView()
                .tabItem {
                    Label("Posts", systemImage: "doc.text.fill")
                }
                .tag(2)
            
            ConnectionsView()
                .tabItem {
                    Label("Connections", systemImage: "person.2.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
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

