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
    
    func register(email: String, password: String, firstName: String, lastName: String) async throws {
        let apiUrl = "http://infinityiotserver.local:3000/api"
        guard let url = URL(string: "\(apiUrl)/auth/register") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "userType": "parent",
            "firstName": firstName,
            "lastName": lastName
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid response", code: 0)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            let result = try JSONDecoder().decode(RegisterResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.token = result.token
                self.isAuthenticated = true
                UserDefaults.standard.set(result.token, forKey: "authToken")
            }
        } else {
            let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NSError(domain: errorData?.error ?? "Registration failed", code: httpResponse.statusCode)
        }
    }
    
    func logout() {
        self.token = nil
        self.isAuthenticated = false
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
}

struct RegisterResponse: Codable {
    let token: String
    let user: UserResponse
}

struct UserResponse: Codable {
    let id: String
    let email: String
    let userType: String
}

struct ErrorResponse: Codable {
    let error: String
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

