//
//  DataManager.swift
//  FamilyNovaParent
//
//  Centralized data management with caching and persistence

import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private init() {}
    
    // MARK: - Cache Keys
    private let postsCacheKey = "cached_posts"
    private let postsTimestampKey = "cached_posts_timestamp"
    private let messagesCacheKey = "cached_messages"
    private let messagesTimestampKey = "cached_messages_timestamp"
    private let friendsCacheKey = "cached_friends"
    private let profileCacheKey = "cached_user_profile"
    
    // Cache expiration time (5 minutes)
    private let cacheExpirationInterval: TimeInterval = 300
    
    // MARK: - Posts Caching
    func cachePosts(_ posts: [CachedPost]) {
        if let encoded = try? JSONEncoder().encode(posts) {
            UserDefaults.standard.set(encoded, forKey: postsCacheKey)
            UserDefaults.standard.set(Date(), forKey: postsTimestampKey)
        }
    }
    
    func getCachedPosts() -> [CachedPost]? {
        guard let data = UserDefaults.standard.data(forKey: postsCacheKey) else { return nil }
        
        // Check if cache is expired
        if let timestamp = UserDefaults.standard.object(forKey: postsTimestampKey) as? Date {
            if Date().timeIntervalSince(timestamp) > cacheExpirationInterval {
                return nil // Cache expired
            }
        }
        
        return try? JSONDecoder().decode([CachedPost].self, from: data)
    }
    
    // MARK: - Messages Caching
    func cacheMessages(_ messages: [CachedMessage]) {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: messagesCacheKey)
            UserDefaults.standard.set(Date(), forKey: messagesTimestampKey)
        }
    }
    
    func getCachedMessages() -> [CachedMessage]? {
        guard let data = UserDefaults.standard.data(forKey: messagesCacheKey) else { return nil }
        
        // Check if cache is expired
        if let timestamp = UserDefaults.standard.object(forKey: messagesTimestampKey) as? Date {
            if Date().timeIntervalSince(timestamp) > cacheExpirationInterval {
                return nil // Cache expired
            }
        }
        
        return try? JSONDecoder().decode([CachedMessage].self, from: data)
    }
    
    func getCachedMessagesForConversation(with userId: String) -> [CachedMessage]? {
        guard let allMessages = getCachedMessages() else { return nil }
        return allMessages.filter { message in
            message.senderId.lowercased() == userId.lowercased() ||
            message.receiverId.lowercased() == userId.lowercased()
        }
    }
    
    func addCachedMessage(_ message: CachedMessage) {
        var messages = getCachedMessages() ?? []
        messages.append(message)
        cacheMessages(messages)
    }
    
    // MARK: - Friends Caching
    func cacheFriends(_ friends: [CachedFriend]) {
        if let encoded = try? JSONEncoder().encode(friends) {
            UserDefaults.standard.set(encoded, forKey: friendsCacheKey)
        }
    }
    
    func getCachedFriends() -> [CachedFriend]? {
        guard let data = UserDefaults.standard.data(forKey: friendsCacheKey) else { return nil }
        return try? JSONDecoder().decode([CachedFriend].self, from: data)
    }
    
    // MARK: - Profile Caching
    func cacheProfile(_ profile: CachedProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileCacheKey)
        }
    }
    
    func getCachedProfile() -> CachedProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileCacheKey) else { return nil }
        return try? JSONDecoder().decode(CachedProfile.self, from: data)
    }
    
    // MARK: - Clear Cache
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: postsCacheKey)
        UserDefaults.standard.removeObject(forKey: postsTimestampKey)
        UserDefaults.standard.removeObject(forKey: messagesCacheKey)
        UserDefaults.standard.removeObject(forKey: messagesTimestampKey)
        UserDefaults.standard.removeObject(forKey: friendsCacheKey)
        UserDefaults.standard.removeObject(forKey: profileCacheKey)
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

