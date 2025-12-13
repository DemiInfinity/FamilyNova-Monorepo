//
//  ApiService.swift
//  FamilyNovaParent
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
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
        // Set date decoding strategy to handle ISO8601 date strings (with or without fractional seconds)
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            print("[ApiService] Decoding date string: \(dateString)")
            
            // Try with fractional seconds first (e.g., "2025-12-13T20:01:07.376Z")
            let formatterWithFractional = ISO8601DateFormatter()
            formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatterWithFractional.date(from: dateString) {
                print("[ApiService] Successfully decoded date with fractional seconds: \(date)")
                return date
            }
            
            // Fallback to standard ISO8601 without fractional seconds
            let formatterStandard = ISO8601DateFormatter()
            formatterStandard.formatOptions = [.withInternetDateTime]
            if let date = formatterStandard.date(from: dateString) {
                print("[ApiService] Successfully decoded date without fractional seconds: \(date)")
                return date
            }
            
            // If all else fails, throw an error
            print("[ApiService] Failed to decode date string: \(dateString)")
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        return try decoder.decode(T.self, from: data)
    }
}

enum ApiError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
}

