//
//  AuthManager.swift
//  FamilyNovaParent
//

import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: ParentUser?
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

struct ParentUser: Codable, Identifiable {
    let id: String
    let email: String
    let profile: ParentProfile
    let children: [Child]
    let parentConnections: [ParentConnection]
}

struct ParentProfile: Codable {
    let firstName: String
    let lastName: String
    let displayName: String
}

struct Child: Codable, Identifiable {
    let id: String
    let profile: ChildProfile
    let verification: VerificationStatus
    let lastLogin: Date?
}

struct ChildProfile: Codable {
    let displayName: String
    let avatar: String?
    let school: String?
    let grade: String?
}

struct ParentConnection: Codable, Identifiable {
    let id: String
    let parent: ParentProfile
    let connectedAt: Date
}

struct VerificationStatus: Codable {
    let parentVerified: Bool
    let schoolVerified: Bool
}

