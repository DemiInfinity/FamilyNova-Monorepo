//
//  MessagesView.swift
//  FamilyNovaParent
//

import SwiftUI

struct MessagesView: View {
    var initialFriend: Friend? = nil
    @EnvironmentObject var authManager: AuthManager
    @State private var conversations: [Conversation] = []
    @State private var selectedFriend: Friend?
    @State private var showFriendPicker = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fun gradient background
                LinearGradient(
                    colors: [ParentAppColors.gradientBlue.opacity(0.1), ParentAppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if let selectedFriend = selectedFriend {
                    ChatView(friend: selectedFriend)
                        .environmentObject(authManager)
                } else {
                    VStack(spacing: ParentAppSpacing.l) {
                        if conversations.isEmpty {
                            VStack(spacing: ParentAppSpacing.l) {
                                Text("💬")
                                    .font(.system(size: 80))
                                Text("No messages yet")
                                    .font(ParentAppFonts.headline)
                                    .foregroundColor(ParentAppColors.primaryBlue)
                                Text("Select a friend to start chatting!")
                                    .font(ParentAppFonts.body)
                                    .foregroundColor(ParentAppColors.darkGray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, ParentAppSpacing.xl)
                                
                                Button(action: { showFriendPicker = true }) {
                                    HStack(spacing: ParentAppSpacing.s) {
                                        Text("👥")
                                            .font(.system(size: 24))
                                        Text("Choose a Friend")
                                            .font(ParentAppFonts.button)
                                            .foregroundColor(.white)
                                    }
                                    .padding(ParentAppSpacing.l)
                                    .background(
                                        LinearGradient(
                                            colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(ParentAppCornerRadius.large)
                                    .shadow(color: ParentAppColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .padding(.top, ParentAppSpacing.m)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: ParentAppSpacing.m) {
                                    ForEach(conversations) { conversation in
                                        ConversationRow(conversation: conversation) {
                                            selectedFriend = conversation.friend
                                        }
                                    }
                                }
                                .padding(ParentAppSpacing.m)
                            }
                        }
                    }
                }
            }
            .navigationTitle(selectedFriend == nil ? "Messages" : selectedFriend?.displayName ?? "Chat")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedFriend == nil {
                        Button(action: { showFriendPicker = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(ParentAppColors.primaryBlue)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if selectedFriend != nil {
                        Button(action: { selectedFriend = nil }) {
                            HStack(spacing: ParentAppSpacing.xs) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(ParentAppFonts.button)
                            .foregroundColor(ParentAppColors.primaryBlue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showFriendPicker) {
                FriendPickerView { friend in
                    selectedFriend = friend
                    showFriendPicker = false
                }
            }
            .onAppear {
                if let initialFriend = initialFriend {
                    selectedFriend = initialFriend
                } else {
                    loadConversations()
                }
            }
        }
    }
    
    private func loadConversations() {
        isLoading = true
        Task {
            await loadConversationsAsync()
        }
    }
    
    private func loadConversationsAsync() async {
        guard let token = authManager.getValidatedToken() else {
            await MainActor.run {
                isLoading = false
            }
            return
        }
        
        do {
            let apiService = ApiService.shared
            
            // Get friends list
            struct FriendsResponse: Codable {
                let friends: [FriendResult]
            }
            
            struct FriendResult: Codable {
                let id: String
                let profile: ProfileResult
                let isVerified: Bool
            }
            
            struct ProfileResult: Codable {
                let displayName: String?
                let avatar: String?
            }
            
            let friendsResponse: FriendsResponse = try await apiService.makeRequest(
                endpoint: "friends",
                method: "GET",
                token: token
            )
            
            // Get messages to find last message for each friend
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
            
            let messagesResponse: MessagesResponse = try await apiService.makeRequest(
                endpoint: "messages",
                method: "GET",
                token: token
            )
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            await MainActor.run {
                // Create conversations from friends and their last messages
                self.conversations = friendsResponse.friends.map { friendResult in
                    let friend = Friend(
                        id: UUID(uuidString: friendResult.id) ?? UUID(),
                        displayName: friendResult.profile.displayName ?? "Unknown",
                        avatar: friendResult.profile.avatar,
                        isVerified: friendResult.isVerified
                    )
                    
                    // Find last message with this friend
                    let friendMessages = messagesResponse.messages.filter { message in
                        (message.sender.id.lowercased() == friendResult.id.lowercased() && message.receiver.id.lowercased() == authManager.currentUser?.id.lowercased()) ||
                        (message.receiver.id.lowercased() == friendResult.id.lowercased() && message.sender.id.lowercased() == authManager.currentUser?.id.lowercased())
                    }
                    .filter { $0.status == "approved" }
                    .sorted { msg1, msg2 in
                        (dateFormatter.date(from: msg1.createdAt) ?? Date.distantPast) >
                        (dateFormatter.date(from: msg2.createdAt) ?? Date.distantPast)
                    }
                    
                    let lastMessage = friendMessages.first
                    let lastMessageText = lastMessage?.content ?? "No messages yet"
                    let lastMessageDate = lastMessage != nil ? (dateFormatter.date(from: lastMessage!.createdAt) ?? Date()) : Date()
                    
                    return Conversation(
                        friend: friend,
                        lastMessage: lastMessageText,
                        timestamp: lastMessageDate,
                        unreadCount: 0 // TODO: Calculate unread count
                    )
                }
                .sorted { $0.timestamp > $1.timestamp }
                
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                print("[MessagesView] Error loading conversations: \(error)")
            }
        }
    }
}

struct Conversation: Identifiable {
    let id = UUID()
    let friend: Friend
    let lastMessage: String
    let timestamp: Date
    let unreadCount: Int
}

struct ConversationRow: View {
    let conversation: Conversation
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ParentAppSpacing.m) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text("👤")
                        .font(.system(size: 30))
                }
                
                // Content
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    HStack {
                        Text(conversation.friend.displayName)
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                        
                        if conversation.friend.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(ParentAppColors.success)
                                .font(.system(size: 14))
                        }
                        
                        Spacer()
                        
                        Text(conversation.timestamp, style: .relative)
                            .font(ParentAppFonts.small)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                    
                    Text(conversation.lastMessage)
                        .font(ParentAppFonts.body)
                        .foregroundColor(ParentAppColors.darkGray)
                        .lineLimit(1)
                    
                    if conversation.unreadCount > 0 {
                        HStack {
                            Spacer()
                            Text("\(conversation.unreadCount)")
                                .font(ParentAppFonts.small)
                                .foregroundColor(.white)
                                .padding(.horizontal, ParentAppSpacing.s)
                                .padding(.vertical, 4)
                                .background(ParentAppColors.primaryBlue)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(ParentAppSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FriendPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var friends: [Friend] = []
    @State private var isLoading = false
    let onSelect: (Friend) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [ParentAppColors.gradientBlue.opacity(0.1), ParentAppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else if friends.isEmpty {
                    VStack(spacing: ParentAppSpacing.l) {
                        Text("👥")
                            .font(.system(size: 60))
                        Text("No friends yet")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.primaryBlue)
                        Text("Add friends to start messaging!")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, ParentAppSpacing.xl)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: ParentAppSpacing.m) {
                            ForEach(friends) { friend in
                                FriendRow(friend: friend, showAddButton: false)
                                    .onTapGesture {
                                        onSelect(friend)
                                    }
                            }
                        }
                        .padding(ParentAppSpacing.m)
                    }
                }
            }
            .navigationTitle("Select Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(ParentAppFonts.button)
                    .foregroundColor(ParentAppColors.primaryBlue)
                }
            }
            .onAppear {
                loadFriends()
            }
        }
    }
    
    private func loadFriends() {
        isLoading = true
        Task {
            await loadFriendsAsync()
        }
    }
    
    private func loadFriendsAsync() async {
        guard let token = authManager.getValidatedToken() else {
            await MainActor.run {
                isLoading = false
            }
            return
        }
        
        do {
            let apiService = ApiService.shared
            
            struct FriendsResponse: Codable {
                let friends: [FriendResult]
            }
            
            struct FriendResult: Codable {
                let id: String
                let profile: ProfileResult
                let isVerified: Bool
            }
            
            struct ProfileResult: Codable {
                let displayName: String?
                let avatar: String?
            }
            
            let response: FriendsResponse = try await apiService.makeRequest(
                endpoint: "friends",
                method: "GET",
                token: token
            )
            
            await MainActor.run {
                self.friends = response.friends.map { friend in
                    Friend(
                        id: UUID(uuidString: friend.id) ?? UUID(),
                        displayName: friend.profile.displayName ?? "Unknown",
                        avatar: friend.profile.avatar,
                        isVerified: friend.isVerified
                    )
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                print("[FriendPickerView] Error loading friends: \(error)")
            }
        }
    }
}

struct ChatView: View {
    let friend: Friend
    @EnvironmentObject var authManager: AuthManager
    @State private var messages: [Message] = []
    @State private var messageText = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            if messages.isEmpty {
                VStack(spacing: ParentAppSpacing.l) {
                    Text("💬")
                        .font(.system(size: 60))
                    Text("No messages yet")
                        .font(ParentAppFonts.headline)
                        .foregroundColor(ParentAppColors.primaryBlue)
                    Text("Start the conversation!")
                        .font(ParentAppFonts.body)
                        .foregroundColor(ParentAppColors.darkGray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: ParentAppSpacing.m) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(ParentAppSpacing.m)
                }
            }
            
            // Message Input
            HStack(spacing: ParentAppSpacing.m) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(.plain)
                    .foregroundColor(ParentAppColors.black)
                    .font(ParentAppFonts.body)
                    .padding(ParentAppSpacing.l)
                    .background(
                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                            .fill(Color.white)
                            .shadow(color: ParentAppColors.primaryBlue.opacity(0.2), radius: 5, x: 0, y: 2)
                    )
                    .lineLimit(3)
                
                Button(action: sendMessage) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(messageText.isEmpty)
                .opacity(messageText.isEmpty ? 0.5 : 1.0)
            }
            .padding(ParentAppSpacing.m)
            .background(Color.white)
        }
        .onAppear {
            loadMessages()
        }
    }
    
    private func loadMessages() {
        isLoading = true
        Task {
            await loadMessagesAsync()
        }
    }
    
    private func loadMessagesAsync() async {
        guard let token = authManager.getValidatedToken() else {
            await MainActor.run {
                isLoading = false
            }
            return
        }
        
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
                endpoint: "messages?conversationWith=\(friend.id.uuidString)",
                method: "GET",
                token: token
            )
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let currentUserId = authManager.currentUser?.id ?? ""
            let friendId = friend.id.uuidString.lowercased()
            
            await MainActor.run {
                self.messages = response.messages
                    .filter { message in
                        (message.sender.id.lowercased() == friendId && message.receiver.id.lowercased() == currentUserId.lowercased()) ||
                        (message.receiver.id.lowercased() == friendId && message.sender.id.lowercased() == currentUserId.lowercased())
                    }
                    .filter { $0.status == "approved" }
                    .sorted { msg1, msg2 in
                        (dateFormatter.date(from: msg1.createdAt) ?? Date.distantPast) <
                        (dateFormatter.date(from: msg2.createdAt) ?? Date.distantPast)
                    }
                    .map { messageResponse in
                        let isFromMe = messageResponse.sender.id.lowercased() == currentUserId.lowercased()
                        return Message(
                            content: messageResponse.content,
                            sender: isFromMe ? "You" : friend.displayName,
                            timestamp: dateFormatter.date(from: messageResponse.createdAt) ?? Date()
                        )
                    }
                
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                print("[ChatView] Error loading messages: \(error)")
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty, let token = authManager.getValidatedToken() else { return }
        
        Task {
            do {
                let apiService = ApiService.shared
                
                struct SendMessageResponse: Codable {
                    let message: MessageResponse
                }
                
                struct MessageResponse: Codable {
                    let id: String
                    let content: String
                    let createdAt: String
                }
                
                let body: [String: Any] = [
                    "receiverId": friend.id.uuidString,
                    "content": messageText
                ]
                
                let response: SendMessageResponse = try await apiService.makeRequest(
                    endpoint: "messages",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                await MainActor.run {
                    let newMessage = Message(
                        content: messageText,
                        sender: "You",
                        timestamp: dateFormatter.date(from: response.message.createdAt) ?? Date()
                    )
                    messages.append(newMessage)
                    messageText = ""
                }
            } catch {
                print("[ChatView] Error sending message: \(error)")
            }
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let sender: String
    let timestamp: Date
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                Text(message.content)
                    .font(ParentAppFonts.body)
                    .foregroundColor(.white)
                
                Text(message.timestamp, style: .time)
                    .font(ParentAppFonts.small)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(ParentAppSpacing.l)
            .background(
                LinearGradient(
                    colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(ParentAppCornerRadius.large)
            .shadow(color: ParentAppColors.primaryBlue.opacity(0.2), radius: 5, x: 0, y: 2)
            
            Spacer()
        }
    }
}

#Preview {
    MessagesView()
}

