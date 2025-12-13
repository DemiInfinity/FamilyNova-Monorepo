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
            // Trim any whitespace/newlines from saved token
            var cleanToken = savedToken.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Remove any quotes that might have been added
            cleanToken = cleanToken.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            
            // Validate JWT format (should have 3 parts separated by dots)
            let parts = cleanToken.split(separator: ".")
            if parts.count == 3 {
                self.token = cleanToken
                self.isAuthenticated = !cleanToken.isEmpty
            } else {
                // Token is corrupted, clear it
                print("⚠️ Corrupted token found in storage - clearing it")
                UserDefaults.standard.removeObject(forKey: "authToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                self.token = nil
                self.isAuthenticated = false
            }
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
                    // Trim token to remove any whitespace/newlines
                    var accessToken = session.access_token.trimmingCharacters(in: .whitespacesAndNewlines)
                    accessToken = accessToken.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                    
                    // Validate token format before storing
                    let parts = accessToken.split(separator: ".")
                    if parts.count == 3 {
                        self.token = accessToken
                        UserDefaults.standard.set(accessToken, forKey: "authToken")
                        
                        // Store refresh token separately if available
                        if let refreshToken = session.refresh_token, !refreshToken.isEmpty {
                            var cleanRefreshToken = refreshToken.trimmingCharacters(in: .whitespacesAndNewlines)
                            cleanRefreshToken = cleanRefreshToken.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                            UserDefaults.standard.set(cleanRefreshToken, forKey: "refreshToken")
                        } else {
                            UserDefaults.standard.removeObject(forKey: "refreshToken")
                        }
                    } else {
                        print("⚠️ Invalid token format received from login - not storing")
                        self.token = nil
                    }
                } else {
                    self.token = nil
                }
                self.isAuthenticated = self.token != nil
                
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
            // Trim any whitespace/newlines from token
            let cleanToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
            self.token = cleanToken
            self.isAuthenticated = !cleanToken.isEmpty
            UserDefaults.standard.set(cleanToken, forKey: "authToken")
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
                    // Trim token to remove any whitespace/newlines
                    var accessToken = session.access_token.trimmingCharacters(in: .whitespacesAndNewlines)
                    accessToken = accessToken.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                    
                    // Validate token format before storing
                    let parts = accessToken.split(separator: ".")
                    if parts.count == 3 {
                        self.token = accessToken
                        UserDefaults.standard.set(accessToken, forKey: "authToken")
                        
                        if let refreshToken = session.refresh_token, !refreshToken.isEmpty {
                            var cleanRefreshToken = refreshToken.trimmingCharacters(in: .whitespacesAndNewlines)
                            cleanRefreshToken = cleanRefreshToken.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                            UserDefaults.standard.set(cleanRefreshToken, forKey: "refreshToken")
                        } else {
                            UserDefaults.standard.removeObject(forKey: "refreshToken")
                        }
                    } else {
                        print("⚠️ Invalid token format received from login-code - not storing")
                        self.token = nil
                    }
                } else {
                    self.token = nil
                }
                self.isAuthenticated = self.token != nil
                
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
    
    /// Validates that the current token is a valid JWT format
    func validateToken() -> Bool {
        guard let token = self.token else { return false }
        
        var cleanToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanToken = cleanToken.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
        
        let parts = cleanToken.split(separator: ".")
        if parts.count != 3 {
            // Token is invalid, clear it
            print("⚠️ Token validation failed - clearing corrupted token")
            logout()
            return false
        }
        
        return true
    }
    
    /// Gets a validated token, or returns nil if invalid
    func getValidatedToken() -> String? {
        guard validateToken() else { return nil }
        guard var token = self.token else { return nil }
        
        token = token.trimmingCharacters(in: .whitespacesAndNewlines)
        token = token.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
        return token
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

