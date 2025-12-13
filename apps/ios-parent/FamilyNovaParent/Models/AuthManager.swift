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
        let apiUrl = "https://family-nova-monorepo.vercel.app/api"
        guard let url = URL(string: "\(apiUrl)/auth/login") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encrypt the request body
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "Failed to serialize request", code: 0)
        }
        
        // Encrypt the JSON string
        let encryptedData = try Encryption.encrypt(jsonString)
        let encryptedBody: [String: Any] = [
            "encrypted": encryptedData
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: encryptedBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid response", code: 0)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            // Handle Supabase session response
            struct LoginResponse: Codable {
                let session: Session?
                let user: UserResponse
            }
            
            struct Session: Codable {
                let access_token: String
                let refresh_token: String
                let expires_in: Int
                let expires_at: Int?
            }
            
            let result = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            DispatchQueue.main.async {
                // Store access token (Supabase session token)
                if let session = result.session {
                    self.token = session.access_token
                    // Store refresh token separately
                    UserDefaults.standard.set(session.refresh_token, forKey: "refreshToken")
                } else {
                    self.token = nil
                }
                self.isAuthenticated = self.token != nil
                if let token = self.token {
                    UserDefaults.standard.set(token, forKey: "authToken")
                }
            }
        } else {
            let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NSError(domain: errorData?.error ?? "Login failed", code: httpResponse.statusCode)
        }
    }
    
    func register(email: String, password: String, firstName: String, lastName: String) async throws {
        let apiUrl = "https://family-nova-monorepo.vercel.app/api"
        guard let url = URL(string: "\(apiUrl)/auth/register") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encrypt the request body
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "userType": "parent",
            "firstName": firstName,
            "lastName": lastName
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "Failed to serialize request", code: 0)
        }
        
        // Encrypt the JSON string
        let encryptedData = try Encryption.encrypt(jsonString)
        let encryptedBody: [String: Any] = [
            "encrypted": encryptedData
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: encryptedBody)
        
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

