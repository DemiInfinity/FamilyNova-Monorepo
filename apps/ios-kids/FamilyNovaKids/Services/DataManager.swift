//
//  DataManager.swift
//  FamilyNovaKids
//
//  Centralized data management with caching and persistence

import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private init() {}
    
    // MARK: - Cache Key Helpers
    private func postsCacheKey(for userId: String) -> String {
        return "cached_posts_\(userId)"
    }
    
    private func postsTimestampKey(for userId: String) -> String {
        return "cached_posts_timestamp_\(userId)"
    }
    
    private func messagesCacheKey(for userId: String) -> String {
        return "cached_messages_\(userId)"
    }
    
    private func messagesTimestampKey(for userId: String) -> String {
        return "cached_messages_timestamp_\(userId)"
    }
    
    private func friendsCacheKey(for userId: String) -> String {
        return "cached_friends_\(userId)"
    }
    
    private func profileCacheKey(for userId: String) -> String {
        return "cached_user_profile_\(userId)"
    }
    
    private func friendProfilesCacheKey(for userId: String) -> String {
        return "cached_friend_profiles_\(userId)"
    }
    
    // Get current user ID from UserDefaults or return default
    private func getCurrentUserId() -> String {
        // Try to get from UserDefaults (set during login)
        if let userId = UserDefaults.standard.string(forKey: "current_user_id") {
            return userId
        }
        // Fallback to a default key if no user ID is set
        return "default_user"
    }
    
    // Cache expiration time (5 minutes)
    private let cacheExpirationInterval: TimeInterval = 300
    
    // MARK: - Posts Caching
    func cachePosts(_ posts: [CachedPost], userId: String? = nil) {
        let userId = userId ?? getCurrentUserId()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(posts) {
            UserDefaults.standard.set(encoded, forKey: postsCacheKey(for: userId))
            UserDefaults.standard.set(Date(), forKey: postsTimestampKey(for: userId))
        }
    }
    
    func getCachedPosts(userId: String? = nil) -> [CachedPost]? {
        let userId = userId ?? getCurrentUserId()
        guard let data = UserDefaults.standard.data(forKey: postsCacheKey(for: userId)) else { return nil }
        
        // Check if cache is expired
        if let timestamp = UserDefaults.standard.object(forKey: postsTimestampKey(for: userId)) as? Date {
            if Date().timeIntervalSince(timestamp) > cacheExpirationInterval {
                return nil // Cache expired
            }
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode([CachedPost].self, from: data)
    }
    
    // MARK: - Messages Caching
    func cacheMessages(_ messages: [CachedMessage], userId: String? = nil) {
        let userId = userId ?? getCurrentUserId()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(messages) {
            UserDefaults.standard.set(encoded, forKey: messagesCacheKey(for: userId))
            UserDefaults.standard.set(Date(), forKey: messagesTimestampKey(for: userId))
        }
    }
    
    func getCachedMessages(userId: String? = nil) -> [CachedMessage]? {
        let userId = userId ?? getCurrentUserId()
        guard let data = UserDefaults.standard.data(forKey: messagesCacheKey(for: userId)) else { return nil }
        
        // Check if cache is expired
        if let timestamp = UserDefaults.standard.object(forKey: messagesTimestampKey(for: userId)) as? Date {
            if Date().timeIntervalSince(timestamp) > cacheExpirationInterval {
                return nil // Cache expired
            }
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode([CachedMessage].self, from: data)
    }
    
    func getCachedMessagesForConversation(with friendId: String, currentUserId: String? = nil) -> [CachedMessage]? {
        let currentUserId = currentUserId ?? getCurrentUserId()
        guard let allMessages = getCachedMessages(userId: currentUserId) else { return nil }
        return allMessages.filter { message in
            (message.senderId.lowercased() == friendId.lowercased() && message.receiverId.lowercased() == currentUserId.lowercased()) ||
            (message.receiverId.lowercased() == friendId.lowercased() && message.senderId.lowercased() == currentUserId.lowercased())
        }
    }
    
    func addCachedMessage(_ message: CachedMessage, userId: String? = nil) {
        let userId = userId ?? getCurrentUserId()
        var messages = getCachedMessages(userId: userId) ?? []
        messages.append(message)
        cacheMessages(messages, userId: userId)
    }
    
    // MARK: - Friends Caching
    func cacheFriends(_ friends: [CachedFriend], userId: String? = nil) {
        let userId = userId ?? getCurrentUserId()
        if let encoded = try? JSONEncoder().encode(friends) {
            UserDefaults.standard.set(encoded, forKey: friendsCacheKey(for: userId))
        }
    }
    
    func getCachedFriends(userId: String? = nil) -> [CachedFriend]? {
        let userId = userId ?? getCurrentUserId()
        guard let data = UserDefaults.standard.data(forKey: friendsCacheKey(for: userId)) else { return nil }
        return try? JSONDecoder().decode([CachedFriend].self, from: data)
    }
    
    // MARK: - Profile Caching
    func cacheProfile(_ profile: CachedProfile, userId: String? = nil) {
        let userId = userId ?? getCurrentUserId()
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileCacheKey(for: userId))
        }
    }
    
    func getCachedProfile(userId: String? = nil) -> CachedProfile? {
        let userId = userId ?? getCurrentUserId()
        guard let data = UserDefaults.standard.data(forKey: profileCacheKey(for: userId)) else { return nil }
        return try? JSONDecoder().decode(CachedProfile.self, from: data)
    }
    
    // MARK: - Friend Profiles Caching (for individual friend profiles)
    func cacheFriendProfile(_ friendId: String, posts: [CachedPost], userId: String? = nil) {
        let userId = userId ?? getCurrentUserId()
        let key = "\(friendProfilesCacheKey(for: userId))_\(friendId)"
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(posts) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func getCachedFriendProfilePosts(_ friendId: String, userId: String? = nil) -> [CachedPost]? {
        let userId = userId ?? getCurrentUserId()
        let key = "\(friendProfilesCacheKey(for: userId))_\(friendId)"
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode([CachedPost].self, from: data)
    }
    
    // MARK: - Clear Cache
    func clearCache(userId: String? = nil) {
        let userId = userId ?? getCurrentUserId()
        UserDefaults.standard.removeObject(forKey: postsCacheKey(for: userId))
        UserDefaults.standard.removeObject(forKey: postsTimestampKey(for: userId))
        UserDefaults.standard.removeObject(forKey: messagesCacheKey(for: userId))
        UserDefaults.standard.removeObject(forKey: messagesTimestampKey(for: userId))
        UserDefaults.standard.removeObject(forKey: friendsCacheKey(for: userId))
        UserDefaults.standard.removeObject(forKey: profileCacheKey(for: userId))
        // Clear all friend profile caches for this user
        let prefix = friendProfilesCacheKey(for: userId)
        let keys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in keys where key.hasPrefix(prefix) {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

// MARK: - Cache Models
struct CachedPost: Codable, Identifiable {
    let id: String
    let content: String
    let imageUrl: String?
    let authorId: String
    let authorName: String
    let authorAvatar: String?
    let likes: Int
    let comments: Int
    let createdAt: Date
    let status: String
}

struct CachedMessage: Codable, Identifiable, Equatable {
    let id: String
    let senderId: String
    let receiverId: String
    let content: String
    let createdAt: Date
    let status: String
    
    static func == (lhs: CachedMessage, rhs: CachedMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CachedFriend: Codable, Identifiable {
    let id: String
    let displayName: String
    let avatar: String?
    let isVerified: Bool
}

struct CachedProfile: Codable {
    let id: String
    let email: String
    let displayName: String
    let avatar: String?
    let banner: String?
    let postsCount: Int
    let friendsCount: Int
}

