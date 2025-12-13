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
    
    private let pollingInterval: TimeInterval = 2.0 // Poll every 2 seconds for real-time feel
    
    private init() {}
    
    // MARK: - Message Polling
    func startPollingMessages(for conversationId: String, userId: String, friendId: String, token: String) {
        // Stop existing timer if any
        stopPollingMessages(for: conversationId)
        
        let timer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.checkForNewMessages(conversationId: conversationId, userId: userId, friendId: friendId, token: token)
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
            let cachedMessages = DataManager.shared.getCachedMessagesForConversation(with: friendId) ?? []
            let cachedMessageIds = Set(cachedMessages.map { $0.id })
            
            let actuallyNewMessages = newMessages.filter { !cachedMessageIds.contains($0.id) }
            
            if !actuallyNewMessages.isEmpty {
                // Update cache
                var allMessages = cachedMessages + actuallyNewMessages
                allMessages = Array(Set(allMessages.map { $0.id })).compactMap { id in
                    allMessages.first { $0.id == id }
                }
                DataManager.shared.cacheMessages(allMessages)
                
                // Notify about new messages
                await MainActor.run {
                    self.newMessages[conversationId] = actuallyNewMessages
                    
                    // Trigger notification for messages from friend
                    let messagesFromFriend = actuallyNewMessages.filter { $0.senderId.lowercased() == friendId.lowercased() }
                    if !messagesFromFriend.isEmpty {
                        NotificationManager.shared.scheduleMessageNotification(
                            from: "Friend",
                            content: messagesFromFriend.first?.content ?? "New message"
                        )
                    }
                }
            }
        } catch {
            print("[RealTimeService] Error checking for new messages: \(error)")
        }
    }
    
    // MARK: - Friend Request Polling
    func startPollingFriendRequests(userId: String, token: String) {
        friendRequestTimer?.invalidate()
        
        friendRequestTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval * 2, repeats: true) { [weak self] _ in
            Task {
                await self?.checkForFriendRequests(userId: userId, token: token)
            }
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

