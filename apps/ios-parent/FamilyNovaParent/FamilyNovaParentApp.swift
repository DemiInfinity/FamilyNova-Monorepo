//
//  FamilyNovaParentApp.swift
//  FamilyNovaParent
//
//  Created for FamilyNova
//

import SwiftUI

@main
struct FamilyNovaParentApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var realTimeService = RealTimeService.shared
    @State private var showSplash = true
    @State private var isLoadingComplete = false
    
    init() {
        // Request notification permissions on app launch
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash && authManager.isAuthenticated && !isLoadingComplete {
                    SplashScreenView(isLoadingComplete: $isLoadingComplete)
                        .environmentObject(authManager)
                        .onChange(of: isLoadingComplete) { newValue in
                            if newValue {
                                // Small delay before hiding splash
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation {
                                        showSplash = false
                                    }
                                }
                            }
                        }
                } else if authManager.isAuthenticated {
                    MainTabView()
                        .environmentObject(authManager)
                        .environmentObject(dataManager)
                        .environmentObject(realTimeService)
                        .onAppear {
                            // Start real-time polling for friend requests, mentions, and child reports
                            if let userId = authManager.currentUser?.id,
                               let token = authManager.token {
                                realTimeService.startPollingFriendRequests(userId: userId, token: token)
                                realTimeService.startPollingMentions(userId: userId, token: token)
                                realTimeService.startPollingChildReports(userId: userId, token: token)
                            }
                        }
                        .onDisappear {
                            realTimeService.stopAllPolling()
                        }
                } else {
                    LoginView()
                        .environmentObject(authManager)
                }
            }
        }
    }
}

