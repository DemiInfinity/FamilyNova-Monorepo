//
//  ApiService.swift
//  FamilyNovaKids
//

import Foundation

class ApiService {
    static let shared = ApiService()
    
    private let baseURL = "https://family-nova-monorepo.vercel.app/api"
    
    private init() {}
    
    func getBaseURL() -> String {
        // You can also read from UserDefaults if you want to make it configurable
        if let savedURL = UserDefaults.standard.string(forKey: "api_base_url"), !savedURL.isEmpty {
            return savedURL
        }
        return baseURL
    }
    
    func makeRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        token: String? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(getBaseURL())/\(endpoint)") else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            // Trim any whitespace/newlines from token
            var cleanToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Remove any quotes that might have been added
            cleanToken = cleanToken.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            
            // Validate JWT format (should have 3 parts separated by dots)
            let parts = cleanToken.split(separator: ".")
            if parts.count != 3 {
                print("⚠️ Invalid JWT format - token has \(parts.count) parts (expected 3)")
                print("Token length: \(cleanToken.count)")
                print("Token preview (first 50): \(cleanToken.prefix(50))")
                print("Token preview (last 50): \(cleanToken.suffix(50))")
                print("Token contains newlines: \(cleanToken.contains("\n"))")
                print("Token contains spaces: \(cleanToken.contains(" "))")
                
                // Clear corrupted token
                UserDefaults.standard.removeObject(forKey: "authToken")
                
                throw ApiError.invalidResponse
            }
            
            request.setValue("Bearer \(cleanToken)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ApiError.httpError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

enum ApiError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
}

