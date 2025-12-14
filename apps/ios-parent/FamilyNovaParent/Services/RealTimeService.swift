//
//  RealTimeService.swift
//  FamilyNovaParent
//
//  Real-time messaging service with instant delivery

import Foundation
import Combine

class RealTimeService: ObservableObject {
    static let shared = RealTimeService()
    
    @Published var newMessages: [String: [CachedMessage]] = [:] // conversationId: messages
    @Published var friendRequests: [FriendRequest] = []
    @Published var mentions: [Mention] = []
    @Published var childReports: [ChildReport] = []
    
    private var messagePollingTimers: [String: Timer] = [:] // conversationId: timer
    private var friendRequestTimer: Timer?
    private var mentionsTimer: Timer?
    private var childReportsTimer: Timer?
    
    private let pollingInterval: TimeInterval = 2.0 // Poll every 2 seconds for messages (real-time)
    private let friendRequestPollingInterval: TimeInterval = 30.0 // Poll every 30 seconds for friend requests (less frequent)
    
    private init() {}
    
    // MARK: - Message Polling
    func startPollingMessages(for conversationId: String, userId: String, friendId: String, token: String) {
        // Stop existing timer if any
        stopPollingMessages(for: conversationId)
        
        let timer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.checkForNewMessages(conversationId: conversationId, userId: userId, friendId: friendId, token: token)
            }
        }
        
        messagePollingTimers[conversationId] = timer
    }
    
    func stopPollingMessages(for conversationId: String) {
        messagePollingTimers[conversationId]?.invalidate()
        messagePollingTimers.removeValue(forKey: conversationId)
    }
    
    func stopAllMessagePolling() {
        messagePollingTimers.values.forEach { $0.invalidate() }
        messagePollingTimers.removeAll()
    }
    
    private func checkForNewMessages(conversationId: String, userId: String, friendId: String, token: String) async {
        do {
            let apiService = ApiService.shared
            
            struct MessagesResponse: Codable {
                let messages: [MessageResponse]
            }
            
            struct MessageResponse: Codable {
                let id: String
                let sender: SenderResponse
                let receiver: ReceiverResponse
                let content: String
                let createdAt: String
                let status: String
            }
            
            struct SenderResponse: Codable {
                let id: String
            }
            
            struct ReceiverResponse: Codable {
                let id: String
            }
            
            let response: MessagesResponse = try await apiService.makeRequest(
                endpoint: "messages?conversationWith=\(friendId)",
                method: "GET",
                token: token
            )
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let newMessages = response.messages
                .filter { message in
                    (message.sender.id.lowercased() == friendId.lowercased() && message.receiver.id.lowercased() == userId.lowercased()) ||
                    (message.receiver.id.lowercased() == friendId.lowercased() && message.sender.id.lowercased() == userId.lowercased())
                }
                .filter { $0.status == "approved" }
                .map { messageResponse in
                    let createdAt = dateFormatter.date(from: messageResponse.createdAt) ?? Date()
                    return CachedMessage(
                        id: messageResponse.id,
                        senderId: messageResponse.sender.id,
                        receiverId: messageResponse.receiver.id,
                        content: messageResponse.content,
                        createdAt: createdAt,
                        status: messageResponse.status
                    )
                }
            
            // Check for new messages
            let cachedMessages = DataManager.shared.getCachedMessagesForConversation(with: friendId, currentUserId: userId) ?? []
            let cachedMessageIds = Set(cachedMessages.map { $0.id })
            
            let actuallyNewMessages = newMessages.filter { !cachedMessageIds.contains($0.id) }
            
            if !actuallyNewMessages.isEmpty {
                // Only add new messages to cache (append, don't replace)
                // Get all cached messages for this user (not just this conversation)
                let allCachedMessages = DataManager.shared.getCachedMessages(userId: userId) ?? []
                let allCachedMessageIds = Set(allCachedMessages.map { $0.id })
                
                // Filter out any that are already in the global cache
                let trulyNewMessages = actuallyNewMessages.filter { !allCachedMessageIds.contains($0.id) }
                
                if !trulyNewMessages.isEmpty {
                    // Append only the new messages to the cache
                    var updatedMessages = allCachedMessages + trulyNewMessages
                    // Remove duplicates by keeping unique IDs
                    var seenIds = Set<String>()
                    updatedMessages = updatedMessages.filter { message in
                        if seenIds.contains(message.id) {
                            return false
                        }
                        seenIds.insert(message.id)
                        return true
                    }
                    DataManager.shared.cacheMessages(updatedMessages, userId: userId)
                    
                    // Trigger notification for messages from friend (before MainActor.run)
                    let messagesFromFriend = trulyNewMessages.filter { $0.senderId.lowercased() == friendId.lowercased() }
                    var friendName = "Friend"
                    if !messagesFromFriend.isEmpty {
                        // Fetch friend name from cache or API
                        friendName = await getFriendName(friendId: friendId, token: token) ?? "Friend"
                        
                        NotificationManager.shared.scheduleMessageNotification(
                            from: friendName,
                            content: messagesFromFriend.first?.content ?? "New message",
                            friendId: friendId
                        )
                    }
                    
                    // Notify about new messages and trigger view update
                    await MainActor.run {
                        // Create a new dictionary to trigger onChange
                        var updatedDict = self.newMessages
                        updatedDict[conversationId] = trulyNewMessages
                        // Assign new dictionary to trigger @Published change
                        self.newMessages = updatedDict
                        
                        // Also trigger a manual reload by posting a notification
                        NotificationCenter.default.post(
                            name: NSNotification.Name("NewMessagesReceived"),
                            object: nil,
                            userInfo: ["conversationId": conversationId]
                        )
                    }
                }
            }
        } catch {
            print("[RealTimeService] Error checking for new messages: \(error)")
        }
    }
    
    // MARK: - Friend Request Polling
    // Note: This uses polling as a fallback. Ideally, use Supabase real-time subscriptions or push notifications
    func startPollingFriendRequests(userId: String, token: String) {
        friendRequestTimer?.invalidate()
        
        // Poll less frequently (every 30 seconds) since friend requests are less time-sensitive
        // In production, this should be replaced with Supabase real-time subscriptions or push notifications
        friendRequestTimer = Timer.scheduledTimer(withTimeInterval: friendRequestPollingInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.checkForFriendRequests(userId: userId, token: token)
            }
        }
        
        // Also check immediately when starting
        Task {
            await checkForFriendRequests(userId: userId, token: token)
        }
    }
    
    func stopPollingFriendRequests() {
        friendRequestTimer?.invalidate()
        friendRequestTimer = nil
    }
    
    private func checkForFriendRequests(userId: String, token: String) async {
        do {
            let apiService = ApiService.shared
            
            struct FriendRequestsResponse: Codable {
                let requests: [FriendRequestResponse]
            }
            
            struct FriendRequestResponse: Codable {
                let id: String
                let from: UserResponse
                let status: String
                let createdAt: String
            }
            
            struct UserResponse: Codable {
                let id: String
                let profile: ProfileResponse
            }
            
            struct ProfileResponse: Codable {
                let displayName: String?
                let avatar: String?
            }
            
            // Check for pending friend requests
            let response: FriendRequestsResponse = try await apiService.makeRequest(
                endpoint: "friends/requests",
                method: "GET",
                token: token
            )
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let newRequests = response.requests
                .filter { $0.status == "pending" }
                .map { requestResponse in
                    FriendRequest(
                        id: requestResponse.id,
                        fromUserId: requestResponse.from.id,
                        fromUserName: requestResponse.from.profile.displayName ?? "Unknown",
                        fromUserAvatar: requestResponse.from.profile.avatar,
                        createdAt: dateFormatter.date(from: requestResponse.createdAt) ?? Date()
                    )
                }
            
            // Check for new requests
            let existingRequestIds = Set(friendRequests.map { $0.id })
            let actuallyNewRequests = newRequests.filter { !existingRequestIds.contains($0.id) }
            
            if !actuallyNewRequests.isEmpty {
                await MainActor.run {
                    self.friendRequests.append(contentsOf: actuallyNewRequests)
                    
                    // Notify about new friend requests
                    for request in actuallyNewRequests {
                        NotificationManager.shared.scheduleFriendRequestNotification(
                            from: request.fromUserName
                        )
                    }
                }
            }
        } catch {
            // Endpoint might not exist yet, that's okay
            print("[RealTimeService] Error checking for friend requests: \(error)")
        }
    }
    
    // MARK: - Mentions Polling
    func startPollingMentions(userId: String, token: String) {
        mentionsTimer?.invalidate()
        
        mentionsTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval * 3, repeats: true) { [weak self] _ in
            Task {
                await self?.checkForMentions(userId: userId, token: token)
            }
        }
    }
    
    func stopPollingMentions() {
        mentionsTimer?.invalidate()
        mentionsTimer = nil
    }
    
    private func checkForMentions(userId: String, token: String) async {
        // TODO: Implement mentions endpoint
        // For now, we'll check posts/comments for @username mentions
    }
    
    // MARK: - Child Reports Polling
    func startPollingChildReports(userId: String, token: String) {
        childReportsTimer?.invalidate()
        
        childReportsTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval * 5, repeats: true) { [weak self] _ in
            Task {
                await self?.checkForChildReports(userId: userId, token: token)
            }
        }
    }
    
    func stopPollingChildReports() {
        childReportsTimer?.invalidate()
        childReportsTimer = nil
    }
    
    private func checkForChildReports(userId: String, token: String) async {
        // TODO: Implement child reports endpoint
        // This would check for reports from child app (new friends, suspicious activity, etc.)
    }
    
    func stopAllPolling() {
        stopAllMessagePolling()
        stopPollingFriendRequests()
        stopPollingMentions()
        stopPollingChildReports()
    }
    
    // MARK: - Helper Functions
    private func getFriendName(friendId: String, token: String) async -> String? {
        // First try to get from cached friends
        if let cachedFriends = DataManager.shared.getCachedFriends(),
           let friend = cachedFriends.first(where: { $0.id.lowercased() == friendId.lowercased() }) {
            return friend.displayName
        }
        
        // If not in cache, try to fetch from API
        do {
            let apiService = ApiService.shared
            
            struct FriendResponse: Codable {
                let friends: [FriendData]
            }
            
            struct FriendData: Codable {
                let id: String
                let profile: FriendProfile
            }
            
            struct FriendProfile: Codable {
                let displayName: String?
            }
            
            let response: FriendResponse = try await apiService.makeRequest(
                endpoint: "friends",
                method: "GET",
                token: token
            )
            
            if let friend = response.friends.first(where: { $0.id.lowercased() == friendId.lowercased() }) {
                return friend.profile.displayName ?? "Friend"
            }
        } catch {
            print("[RealTimeService] Error fetching friend name: \(error)")
        }
        
        return nil
    }
}

// MARK: - Models
struct FriendRequest: Identifiable {
    let id: String
    let fromUserId: String
    let fromUserName: String
    let fromUserAvatar: String?
    let createdAt: Date
}

struct Mention: Identifiable {
    let id: String
    let postId: String
    let fromUserId: String
    let fromUserName: String
    let content: String
    let createdAt: Date
}

struct ChildReport: Identifiable {
    let id: String
    let childId: String
    let childName: String
    let reportType: String // "new_friend", "suspicious_activity", etc.
    let content: String
    let createdAt: Date
}

