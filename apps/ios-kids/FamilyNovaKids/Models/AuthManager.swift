//
//  AuthManager.swift
//  FamilyNovaKids
//

import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var token: String?
    
    init() {
        // Check for saved token
        if let savedToken = UserDefaults.standard.string(forKey: "authToken") {
            self.token = savedToken
            self.isAuthenticated = true
            // TODO: Validate token and load user
        }
    }
    
    func login(email: String, password: String) async throws {
        // TODO: Implement API call
        // For now, simulate login
        DispatchQueue.main.async {
            self.token = "mock_token"
            self.isAuthenticated = true
            UserDefaults.standard.set("mock_token", forKey: "authToken")
        }
    }
    
    func logout() {
        self.token = nil
        self.isAuthenticated = false
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
}

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let displayName: String
    let profile: UserProfile
    let verification: VerificationStatus
}

struct UserProfile: Codable {
    let firstName: String
    let lastName: String
    let displayName: String
    let avatar: String?
    let school: String?
    let grade: String?
}

struct VerificationStatus: Codable {
    let parentVerified: Bool
    let schoolVerified: Bool
}

