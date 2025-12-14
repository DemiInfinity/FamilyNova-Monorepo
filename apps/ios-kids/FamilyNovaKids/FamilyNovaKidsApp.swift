//
//  FamilyNovaKidsApp.swift
//  FamilyNovaKids
//
//  Created for FamilyNova
//

import SwiftUI

@main
struct FamilyNovaKidsApp: App {
    @StateObject private var authManager = AuthManager()
    @State private var showSplash = true
    @State private var isLoadingComplete = false
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Request notification permissions on app launch
        // Note: NotificationManager may need to be created for kids app
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash && authManager.isAuthenticated && !isLoadingComplete {
                    SplashScreenView(isLoadingComplete: $isLoadingComplete)
                        .environmentObject(authManager)
                        .lockOrientationToPortrait()
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
                        .lockOrientationToPortrait()
                } else {
                    LoginView()
                        .environmentObject(authManager)
                        .lockOrientationToPortrait()
                }
            }
            .onOpenURL { url in
                handleURL(url)
            }
        }
    }
    
    private func handleURL(_ url: URL) {
        guard url.scheme == "familynovakids" || url.scheme == "familynova-kids" else {
            return
        }
        
        if url.host == "login" {
            // Parse URL parameters: familynovakids://login?childId=xxx&email=xxx&token=xxx
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queryItems = components?.queryItems ?? []
            
            var childId: String?
            var email: String?
            var token: String?
            
            for item in queryItems {
                switch item.name {
                case "childId":
                    childId = item.value
                case "email":
                    email = item.value?.removingPercentEncoding
                case "token":
                    token = item.value?.removingPercentEncoding
                default:
                    break
                }
            }
            
            if let childId = childId, let email = email, let token = token {
                Task {
                    await authManager.loginWithToken(childId: childId, email: email, token: token)
                }
            }
        }
    }
}

