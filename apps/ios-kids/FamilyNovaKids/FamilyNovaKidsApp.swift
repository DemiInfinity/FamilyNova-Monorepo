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
        }
    }
}

