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
                let refresh_token: String?
                let expires_in: Int
                let expires_at: Int?
            }
            
            struct UserResponse: Codable {
                let id: String
                let email: String
                let userType: String
            }
            
            let result = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            await MainActor.run {
                // Store access token (Supabase session token)
                if let session = result.session {
                    self.token = session.access_token
                    // Store refresh token separately if available
                    if let refreshToken = session.refresh_token, !refreshToken.isEmpty {
                        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                    } else {
                        UserDefaults.standard.removeObject(forKey: "refreshToken")
                    }
                } else {
                    self.token = nil
                }
                self.isAuthenticated = self.token != nil
                if let token = self.token {
                    UserDefaults.standard.set(token, forKey: "authToken")
                }
                
                // Store user ID for later use
                // Create a minimal User object with the ID from login response
                self.currentUser = User(
                    id: result.user.id,
                    email: result.user.email,
                    displayName: result.user.email, // Will be updated when profile is fetched
                    profile: UserProfile(
                        firstName: "",
                        lastName: "",
                        displayName: result.user.email,
                        avatar: nil,
                        school: nil,
                        grade: nil
                    ),
                    verification: VerificationStatus(parentVerified: false, schoolVerified: false)
                )
            }
        } else {
            struct ErrorResponse: Codable {
                let error: String
            }
            let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NSError(domain: errorData?.error ?? "Login failed", code: httpResponse.statusCode)
        }
    }
    
    func loginWithToken(childId: String, email: String, token: String) async {
        // Store the token and mark as authenticated
        await MainActor.run {
            self.token = token
            self.isAuthenticated = true
            UserDefaults.standard.set(token, forKey: "authToken")
            // TODO: Fetch user profile from API
        }
    }
    
    func loginWithCode(code: String) async throws {
        let apiUrl = "https://family-nova-monorepo.vercel.app/api"
        guard let url = URL(string: "\(apiUrl)/auth/login-code") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["code": code]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid response", code: 0)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            struct LoginCodeResponse: Codable {
                let session: Session?
                let user: UserResponse
            }
            
            struct Session: Codable {
                let access_token: String
                let refresh_token: String?
                let expires_in: Int
                let expires_at: Int?
            }
            
            struct UserResponse: Codable {
                let id: String
                let email: String
                let userType: String
            }
            
            let result = try JSONDecoder().decode(LoginCodeResponse.self, from: data)
            
            await MainActor.run {
                if let session = result.session {
                    self.token = session.access_token
                    if let refreshToken = session.refresh_token, !refreshToken.isEmpty {
                        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                    } else {
                        UserDefaults.standard.removeObject(forKey: "refreshToken")
                    }
                } else {
                    self.token = nil
                }
                self.isAuthenticated = self.token != nil
                if let token = self.token {
                    UserDefaults.standard.set(token, forKey: "authToken")
                }
                
                // Store user ID for later use
                // Create a minimal User object with the ID from login response
                self.currentUser = User(
                    id: result.user.id,
                    email: result.user.email,
                    displayName: result.user.email, // Will be updated when profile is fetched
                    profile: UserProfile(
                        firstName: "",
                        lastName: "",
                        displayName: result.user.email,
                        avatar: nil,
                        school: nil,
                        grade: nil
                    ),
                    verification: VerificationStatus(parentVerified: false, schoolVerified: false)
                )
            }
        } else {
            struct ErrorResponse: Codable {
                let error: String
            }
            let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NSError(domain: errorData?.error ?? "Login failed", code: httpResponse.statusCode)
        }
    }
    
    func logout() {
        self.token = nil
        self.isAuthenticated = false
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
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

