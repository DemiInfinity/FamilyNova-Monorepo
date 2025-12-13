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
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
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

