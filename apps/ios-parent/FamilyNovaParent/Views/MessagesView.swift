//
//  MessagesView.swift
//  FamilyNovaParent
//

import SwiftUI

struct MessagesView: View {
    var initialFriend: Friend? = nil
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var dataManager = DataManager.shared
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
                // Load from cache immediately
                loadConversationsFromCache()
                
                if let initialFriend = initialFriend {
                    selectedFriend = initialFriend
                } else {
                    // Then load from API
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
        // First, try to load from cache
        loadConversationsFromCache()
        
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
            
            // Cache friends
            let cachedFriends = friendsResponse.friends.map { friend in
                CachedFriend(
                    id: friend.id,
                    displayName: friend.profile.displayName ?? "Unknown",
                    avatar: friend.profile.avatar,
                    isVerified: friend.isVerified
                )
            }
            if let currentUserId = authManager.currentUser?.id {
                DataManager.shared.cacheFriends(cachedFriends, userId: currentUserId)
            }
            
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
            
            print("[MessagesView] API returned \(messagesResponse.messages.count) total messages")
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            // Helper function to parse dates (same as in ChatView)
            func parseMessageDate(_ dateString: String) -> Date? {
                if let date = dateFormatter.date(from: dateString) {
                    return date
                }
                let hasTimezone = dateString.hasSuffix("Z") || 
                                 dateString.contains("+") || 
                                 (dateString.count > 10 && dateString[dateString.index(dateString.endIndex, offsetBy: -6)...].contains(":"))
                if !hasTimezone {
                    let dateWithZ = dateString + "Z"
                    if let date = dateFormatter.date(from: dateWithZ) {
                        return date
                    }
                }
                let dateFormatterNoFraction = ISO8601DateFormatter()
                dateFormatterNoFraction.formatOptions = [.withInternetDateTime]
                if let date = dateFormatterNoFraction.date(from: dateString) {
                    return date
                }
                if !hasTimezone {
                    let dateWithZ = dateString + "Z"
                    if let date = dateFormatterNoFraction.date(from: dateWithZ) {
                        return date
                    }
                }
                return nil
            }
            
            // Process messages before MainActor to avoid type-checking issues
            let currentUserId = authManager.currentUser?.id ?? ""
            let processedConversations = friendsResponse.friends.map { friendResult -> Conversation in
                let friend = Friend(
                    id: UUID(uuidString: friendResult.id) ?? UUID(),
                    displayName: friendResult.profile.displayName ?? "Unknown",
                    avatar: friendResult.profile.avatar,
                    isVerified: friendResult.isVerified
                )
                
                // Find last message with this friend
                let friendMessages = messagesResponse.messages.filter { message in
                    (message.sender.id.lowercased() == friendResult.id.lowercased() && message.receiver.id.lowercased() == currentUserId.lowercased()) ||
                    (message.receiver.id.lowercased() == friendResult.id.lowercased() && message.sender.id.lowercased() == currentUserId.lowercased())
                }
                .filter { $0.status == "approved" }
                .sorted { msg1, msg2 in
                    let date1 = parseMessageDate(msg1.createdAt) ?? Date.distantPast
                    let date2 = parseMessageDate(msg2.createdAt) ?? Date.distantPast
                    return date1 > date2
                }
                
                let lastMessage = friendMessages.first
                let lastMessageText = lastMessage?.content ?? "No messages yet"
                let lastMessageDate = lastMessage != nil ? (parseMessageDate(lastMessage!.createdAt) ?? Date()) : Date()
                
                if friendMessages.isEmpty {
                    print("[MessagesView] No messages found for friend: \(friendResult.profile.displayName ?? "Unknown")")
                } else {
                    print("[MessagesView] Found \(friendMessages.count) messages for friend: \(friendResult.profile.displayName ?? "Unknown")")
                }
                
                return Conversation(
                    friend: friend,
                    lastMessage: lastMessageText,
                    timestamp: lastMessageDate,
                    unreadCount: 0 // TODO: Calculate unread count
                )
            }
            .sorted { $0.timestamp > $1.timestamp }
            
            // Cache all messages
            var dateParseFailures = 0
            let cachedMessages = messagesResponse.messages
                .filter { $0.status == "approved" }
                .compactMap { messageResponse -> CachedMessage? in
                    guard let createdAt = parseMessageDate(messageResponse.createdAt) else {
                        dateParseFailures += 1
                        print("[MessagesView] Failed to parse date: \(messageResponse.createdAt) for message \(messageResponse.id)")
                        return nil
                    }
                    return CachedMessage(
                        id: messageResponse.id,
                        senderId: messageResponse.sender.id,
                        receiverId: messageResponse.receiver.id,
                        content: messageResponse.content,
                        createdAt: createdAt,
                        status: messageResponse.status
                    )
                }
            
            print("[MessagesView] Caching \(cachedMessages.count) messages, \(dateParseFailures) date parse failures")
            
            await MainActor.run {
                // Set processed conversations
                self.conversations = processedConversations
                
                // Cache messages
                if let currentUserId = authManager.currentUser?.id {
                    dataManager.cacheMessages(cachedMessages, userId: currentUserId)
                }
                
                print("[MessagesView] Created \(self.conversations.count) conversations")
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                print("[MessagesView] Error loading conversations: \(error)")
                // If API fails, keep cached conversations
                if conversations.isEmpty {
                    loadConversationsFromCache()
                }
            }
        }
    }
    
    private func loadConversationsFromCache() {
        guard let currentUserId = authManager.currentUser?.id else { return }
        guard let cachedFriends = dataManager.getCachedFriends(userId: currentUserId),
              let cachedMessages = dataManager.getCachedMessages(userId: currentUserId) else { return }
        
        conversations = cachedFriends.map { cachedFriend in
            let friend = Friend(
                id: UUID(uuidString: cachedFriend.id) ?? UUID(),
                displayName: cachedFriend.displayName,
                avatar: cachedFriend.avatar,
                isVerified: cachedFriend.isVerified
            )
            
            // Find last message with this friend
            let friendMessages = cachedMessages.filter { message in
                (message.senderId.lowercased() == cachedFriend.id.lowercased() && message.receiverId.lowercased() == currentUserId.lowercased()) ||
                (message.receiverId.lowercased() == cachedFriend.id.lowercased() && message.senderId.lowercased() == currentUserId.lowercased())
            }
            .filter { $0.status == "approved" }
            .sorted { $0.createdAt > $1.createdAt }
            
            let lastMessage = friendMessages.first
            let lastMessageText = lastMessage?.content ?? "No messages yet"
            let lastMessageDate = lastMessage?.createdAt ?? Date()
            
            return Conversation(
                friend: friend,
                lastMessage: lastMessageText,
                timestamp: lastMessageDate,
                unreadCount: 0
            )
        }
        .sorted { $0.timestamp > $1.timestamp }
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
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var realTimeService = RealTimeService.shared
    @State private var messages: [Message] = []
    @State private var messageText = ""
    @State private var isLoading = false
    @State private var isTyping = false
    @State private var friendIsTyping = false
    @State private var typingTimer: Timer?
    @State private var scrollToBottomId = UUID()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            CosmicBackground()
            
            VStack(spacing: 0) {
                if messages.isEmpty {
                    VStack(spacing: CosmicSpacing.l) {
                        Image(systemName: "message.fill")
                            .cosmicIcon(size: 60, color: CosmicColors.nebulaPurple)
                        Text("No messages yet")
                            .font(CosmicFonts.headline)
                            .foregroundColor(CosmicColors.textPrimary)
                        Text("Start the conversation!")
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: CosmicSpacing.m) {
                                ForEach(messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                                
                                // Typing indicator
                                if friendIsTyping {
                                    HStack {
                                        TypingIndicator()
                                        Spacer()
                                    }
                                    .padding(.horizontal, CosmicSpacing.m)
                                    .id("typing")
                                }
                                
                                // Invisible anchor at bottom for scrolling
                                Color.clear
                                    .frame(height: 1)
                                    .id("bottom")
                            }
                            .padding(CosmicSpacing.m)
                        }
                        .onAppear {
                            // Scroll to bottom on appear
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let lastMessage = messages.last {
                                    withAnimation {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                } else {
                                    withAnimation {
                                        proxy.scrollTo("bottom", anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .onChange(of: messages.count) { _ in
                            // Scroll to bottom when new messages arrive
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let lastMessage = messages.last {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                } else {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo("bottom", anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .onChange(of: friendIsTyping) { typing in
                            if typing {
                                // Scroll to bottom when typing indicator appears
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo("typing", anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .onChange(of: scrollToBottomId) { _ in
                            // Trigger scroll when ID changes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let lastMessage = messages.last {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                } else {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo("bottom", anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Typing indicator above input
                if friendIsTyping {
                    HStack {
                        Text("\(friend.displayName) is typing...")
                            .font(CosmicFonts.small)
                            .foregroundColor(CosmicColors.textMuted)
                            .padding(.horizontal, CosmicSpacing.m)
                            .padding(.vertical, CosmicSpacing.s)
                        Spacer()
                    }
                    .background(CosmicColors.glassBackground.opacity(0.5))
                }
                
                // Message Input
                HStack(spacing: CosmicSpacing.m) {
                    TextField("Type a message...", text: $messageText)
                        .focused($isTextFieldFocused)
                        .textFieldStyle(.plain)
                        .foregroundColor(CosmicColors.textPrimary)
                        .font(CosmicFonts.body)
                        .padding(CosmicSpacing.m)
                        .background(
                            RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                .fill(CosmicColors.glassBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                        .stroke(CosmicColors.nebulaPurple.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .lineLimit(3)
                        .onChange(of: messageText) { newValue in
                            handleTyping(newValue: newValue)
                        }
                    
                    Button(action: sendMessage) {
                        ZStack {
                            Circle()
                                .fill(CosmicColors.primaryGradient)
                                .frame(width: 50, height: 50)
                                .shadow(color: CosmicColors.nebulaPurple.opacity(0.5), radius: 8, x: 0, y: 0)
                            Image(systemName: "arrow.up")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(messageText.isEmpty)
                    .opacity(messageText.isEmpty ? 0.5 : 1.0)
                }
                .padding(CosmicSpacing.m)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(CosmicColors.glassBackground.opacity(0.3))
                        .background(.ultraThinMaterial)
                )
            }
        }
        .onAppear {
            // Always load from cache first to preserve messages when re-entering
            loadMessagesFromCache()
            
            // Then load from API to get latest (will append new ones)
            loadMessages()
            
            // Start real-time polling
            if let userId = authManager.currentUser?.id ?? UserDefaults.standard.string(forKey: "current_user_id"),
               let token = authManager.getValidatedToken() {
                let conversationId = "\(userId)_\(friend.id.uuidString)"
                realTimeService.startPollingMessages(
                    for: conversationId,
                    userId: userId,
                    friendId: friend.id.uuidString,
                    token: token
                )
            }
            
            // Focus text field after a short delay to avoid input lag
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
        .onDisappear {
            // Stop real-time polling
            if let userId = authManager.currentUser?.id ?? UserDefaults.standard.string(forKey: "current_user_id") {
                let conversationId = "\(userId)_\(friend.id.uuidString)"
                realTimeService.stopPollingMessages(for: conversationId)
            }
            
            // Stop typing indicator
            stopTyping()
            typingTimer?.invalidate()
        }
        .onChange(of: realTimeService.newMessages) { newMessagesDict in
            // When new messages arrive, reload from cache to get all messages (including new ones)
            if let userId = authManager.currentUser?.id {
                let conversationId = "\(userId)_\(friend.id.uuidString)"
                if let newMessages = newMessagesDict[conversationId], !newMessages.isEmpty {
                    // Reload from cache which now includes the new messages
                    loadMessagesFromCache()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewMessagesReceived"))) { notification in
            // Also listen for notification-based updates as backup
            if let userId = authManager.currentUser?.id {
                let conversationId = "\(userId)_\(friend.id.uuidString)"
                if let receivedConversationId = notification.userInfo?["conversationId"] as? String,
                   receivedConversationId == conversationId {
                    loadMessagesFromCache()
                }
            }
        }
    }
    
    private func loadMessages() {
        isLoading = true
        Task {
            await loadMessagesAsync()
        }
    }
    
    private func loadMessagesAsync() async {
        // Don't load from cache here - it's already loaded in onAppear
        // This prevents clearing messages when API call happens
        
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
            
            print("[ChatView] API returned \(response.messages.count) messages for friend: \(friend.displayName) (\(friend.id.uuidString))")
            if response.messages.isEmpty {
                print("[ChatView] WARNING: API returned empty messages array")
            } else {
                print("[ChatView] First message sample: id=\(response.messages[0].id), sender=\(response.messages[0].sender.id), createdAt=\(response.messages[0].createdAt)")
            }
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            // Helper function to parse dates with or without timezone
            func parseMessageDate(_ dateString: String) -> Date? {
                // First try with the standard formatter
                if let date = dateFormatter.date(from: dateString) {
                    return date
                }
                
                // If that fails, try adding 'Z' if it's missing (assume UTC)
                let hasTimezone = dateString.hasSuffix("Z") || 
                                 dateString.contains("+") || 
                                 (dateString.count > 10 && dateString[dateString.index(dateString.endIndex, offsetBy: -6)...].contains(":"))
                
                if !hasTimezone {
                    let dateWithZ = dateString + "Z"
                    if let date = dateFormatter.date(from: dateWithZ) {
                        return date
                    }
                }
                
                // Try without fractional seconds
                let dateFormatterNoFraction = ISO8601DateFormatter()
                dateFormatterNoFraction.formatOptions = [.withInternetDateTime]
                if let date = dateFormatterNoFraction.date(from: dateString) {
                    return date
                }
                
                // Try adding Z and without fractional seconds
                if !hasTimezone {
                    let dateWithZ = dateString + "Z"
                    if let date = dateFormatterNoFraction.date(from: dateWithZ) {
                        return date
                    }
                }
                
                return nil
            }
            
            // Try to get user ID from currentUser, or fallback to UserDefaults
            var currentUserId: String
            if let userId = authManager.currentUser?.id {
                currentUserId = userId
            } else if let userId = UserDefaults.standard.string(forKey: "current_user_id") {
                currentUserId = userId
                print("[ChatView] WARNING: Using user ID from UserDefaults: \(userId)")
            } else {
                print("[ChatView] ERROR: No current user ID available!")
                await MainActor.run {
                    isLoading = false
                }
                return
            }
            
            let friendId = friend.id.uuidString.lowercased()
            let currentUserIdLower = currentUserId.lowercased()
            
            print("[ChatView] Filtering messages - Current User ID: \(currentUserIdLower), Friend ID: \(friendId)")
            print("[ChatView] First message details - Sender: \(response.messages.first?.sender.id.lowercased() ?? "none"), Receiver: \(response.messages.first?.receiver.id.lowercased() ?? "none")")
            
            // Cache messages
            var dateParseFailures = 0
            var filteredOutByRelevance = 0
            var filteredOutByStatus = 0
            let cachedMessages = response.messages
                .filter { message in
                    let senderId = message.sender.id.lowercased().trimmingCharacters(in: .whitespaces)
                    let receiverId = message.receiver.id.lowercased().trimmingCharacters(in: .whitespaces)
                    let friendIdTrimmed = friendId.trimmingCharacters(in: .whitespaces)
                    let currentUserIdTrimmed = currentUserIdLower.trimmingCharacters(in: .whitespaces)
                    
                    let isRelevant = (senderId == friendIdTrimmed && receiverId == currentUserIdTrimmed) ||
                                    (receiverId == friendIdTrimmed && senderId == currentUserIdTrimmed)
                    
                    if !isRelevant {
                        filteredOutByRelevance += 1
                        if filteredOutByRelevance <= 3 { // Log first 3 for debugging
                            print("[ChatView] Filtered out by relevance - Sender: '\(senderId)', Receiver: '\(receiverId)', Friend: '\(friendIdTrimmed)', User: '\(currentUserIdTrimmed)'")
                            print("[ChatView] Comparison - Sender==Friend: \(senderId == friendIdTrimmed), Receiver==User: \(receiverId == currentUserIdTrimmed)")
                            print("[ChatView] Comparison - Receiver==Friend: \(receiverId == friendIdTrimmed), Sender==User: \(senderId == currentUserIdTrimmed)")
                        }
                    } else {
                        if filteredOutByRelevance == 0 { // Log first matching message
                            print("[ChatView] ✓ Message matches - Sender: '\(senderId)', Receiver: '\(receiverId)'")
                        }
                    }
                    return isRelevant
                }
                .filter { message in
                    let isApproved = message.status == "approved"
                    if !isApproved {
                        filteredOutByStatus += 1
                        print("[ChatView] Filtered out message with status: \(message.status)")
                    }
                    return isApproved
                }
                .compactMap { messageResponse -> CachedMessage? in
                    guard let createdAt = parseMessageDate(messageResponse.createdAt) else {
                        dateParseFailures += 1
                        print("[ChatView] Failed to parse date: \(messageResponse.createdAt) for message \(messageResponse.id)")
                        return nil
                    }
                    
                    return CachedMessage(
                        id: messageResponse.id,
                        senderId: messageResponse.sender.id,
                        receiverId: messageResponse.receiver.id,
                        content: messageResponse.content,
                        createdAt: createdAt,
                        status: messageResponse.status
                    )
                }
            
            print("[ChatView] Processed messages: \(cachedMessages.count) cached, \(dateParseFailures) date parse failures, \(filteredOutByRelevance) filtered by relevance, \(filteredOutByStatus) filtered by status")
            
            dataManager.cacheMessages(cachedMessages, userId: currentUserId)
            
            await MainActor.run {
                // Convert cached messages to Message objects
                let newMessageObjects = cachedMessages
                    .sorted { $0.createdAt < $1.createdAt }
                    .map { cachedMessage in
                        let isFromMe = cachedMessage.senderId.lowercased() == currentUserId.lowercased()
                        return Message(
                            id: UUID(uuidString: cachedMessage.id) ?? UUID(),
                            content: cachedMessage.content,
                            sender: isFromMe ? "You" : friend.displayName,
                            timestamp: cachedMessage.createdAt
                        )
                    }
                
                // Always merge with existing messages, avoiding duplicates
                // Never replace - only append new ones
                let existingMessageIds = Set(messages.map { $0.id.uuidString })
                let uniqueNewMessages = newMessageObjects.filter { message in
                    !existingMessageIds.contains(message.id.uuidString)
                }
                
                print("[ChatView] Merging messages: \(messages.count) existing, \(uniqueNewMessages.count) new unique messages")
                
                if !uniqueNewMessages.isEmpty {
                    // Append new messages
                    messages.append(contentsOf: uniqueNewMessages)
                    messages.sort { $0.timestamp < $1.timestamp }
                    print("[ChatView] Total messages after merge: \(messages.count)")
                } else if messages.isEmpty {
                    // Only set if we have no messages at all
                    messages = newMessageObjects
                    print("[ChatView] Set initial messages: \(messages.count)")
                } else {
                    print("[ChatView] No new messages to add, keeping existing \(messages.count) messages")
                }
                
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                print("[ChatView] Error loading messages: \(error)")
                // If API fails, keep cached messages
                if messages.isEmpty {
                    loadMessagesFromCache()
                }
            }
        }
    }
    
    private func loadMessagesFromCache() {
        guard let currentUserId = authManager.currentUser?.id ?? UserDefaults.standard.string(forKey: "current_user_id") else {
            print("[ChatView] No user ID available for cache loading")
            return
        }
        
        guard let cachedMessages = dataManager.getCachedMessagesForConversation(with: friend.id.uuidString, currentUserId: currentUserId) else {
            print("[ChatView] No cached messages found for conversation with \(friend.displayName)")
            // If no cached messages, don't return early - let API load them
            return
        }
        
        print("[ChatView] Found \(cachedMessages.count) cached messages")
        
        guard !cachedMessages.isEmpty else {
            print("[ChatView] Cached messages array is empty")
            return
        }
        
        let loadedMessages = cachedMessages
            .sorted { $0.createdAt < $1.createdAt }
            .map { cachedMessage in
                let isFromMe = cachedMessage.senderId.lowercased() == currentUserId.lowercased()
                return Message(
                    id: UUID(uuidString: cachedMessage.id) ?? UUID(),
                    content: cachedMessage.content,
                    sender: isFromMe ? "You" : friend.displayName,
                    timestamp: cachedMessage.createdAt
                )
            }
        
        // If messages are empty, set them from cache
        // Otherwise, only append new messages that aren't already displayed
        if messages.isEmpty {
            messages = loadedMessages
            print("[ChatView] Loaded \(messages.count) messages from cache (initial load)")
        } else {
            // Append only new messages
            let existingIds = Set(messages.map { $0.id.uuidString })
            let newMessages = loadedMessages.filter { !existingIds.contains($0.id.uuidString) }
            
            print("[ChatView] Cache merge: \(messages.count) existing, \(newMessages.count) new from cache")
            
            if !newMessages.isEmpty {
                messages.append(contentsOf: newMessages)
                messages.sort { $0.timestamp < $1.timestamp }
                print("[ChatView] Total messages after cache merge: \(messages.count)")
            } else {
                print("[ChatView] No new messages from cache to add")
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func scrollToBottom(animated: Bool) {
        // Trigger scroll by updating the ID
        scrollToBottomId = UUID()
    }
    
    private func handleTyping(newValue: String) {
        // Debounce typing indicator
        typingTimer?.invalidate()
        
        if !newValue.isEmpty && !isTyping {
            startTyping()
        }
        
        // Reset timer - if user stops typing for 2 seconds, stop the indicator
        typingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            stopTyping()
        }
    }
    
    private func startTyping() {
        guard !isTyping else { return }
        isTyping = true
        
        // TODO: Send typing indicator to backend
        // For now, we'll simulate it locally
        // In production, you'd make an API call here
        print("[ChatView] User started typing")
    }
    
    private func stopTyping() {
        guard isTyping else { return }
        isTyping = false
        
        // TODO: Send stop typing indicator to backend
        print("[ChatView] User stopped typing")
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty, let token = authManager.getValidatedToken() else {
            print("[ChatView] Cannot send message: text empty or no token")
            return
        }
        
        print("[ChatView] Sending message to \(friend.displayName): \(messageText.prefix(50))")
        
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
                
                print("[ChatView] Sending message API call to: messages")
                let response: SendMessageResponse = try await apiService.makeRequest(
                    endpoint: "messages",
                    method: "POST",
                    body: body,
                    token: token
                )
                print("[ChatView] Message sent successfully: id=\(response.message.id), createdAt=\(response.message.createdAt)")
                
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let newMessageDate = dateFormatter.date(from: response.message.createdAt) ?? Date()
                // Use currentUser ID or fallback to UserDefaults
                let currentUserId = authManager.currentUser?.id ?? UserDefaults.standard.string(forKey: "current_user_id") ?? ""
                
                guard !currentUserId.isEmpty else {
                    print("[ChatView] ERROR: Cannot cache message - no user ID available")
                    return
                }
                
                // Cache the new message
                let cachedMessage = CachedMessage(
                    id: response.message.id,
                    senderId: currentUserId,
                    receiverId: friend.id.uuidString,
                    content: messageText,
                    createdAt: newMessageDate,
                    status: "approved"
                )
                dataManager.addCachedMessage(cachedMessage, userId: currentUserId)
                
                await MainActor.run {
                    let newMessage = Message(
                        id: UUID(uuidString: response.message.id) ?? UUID(),
                        content: messageText,
                        sender: "You",
                        timestamp: newMessageDate
                    )
                    messages.append(newMessage)
                    messageText = ""
                    stopTyping()
                    
                    // Scroll to bottom after sending
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom(animated: true)
                    }
                }
            } catch {
                print("[ChatView] Error sending message: \(error)")
            }
        }
    }
    
}

struct Message: Identifiable {
    let id: UUID
    let content: String
    let sender: String
    let timestamp: Date
    
    init(content: String, sender: String, timestamp: Date) {
        self.id = UUID()
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
    }
    
    init(id: UUID = UUID(), content: String, sender: String, timestamp: Date) {
        self.id = id
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
    }
}

struct MessageBubble: View {
    let message: Message
    
    var isFromMe: Bool {
        message.sender == "You"
    }
    
    var body: some View {
        HStack {
            if !isFromMe {
                // Receiver's message on the left
                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                    Text(message.content)
                        .font(CosmicFonts.body)
                        .foregroundColor(CosmicColors.textPrimary)
                    
                    Text(message.timestamp, style: .time)
                        .font(CosmicFonts.small)
                        .foregroundColor(CosmicColors.textMuted)
                }
                .padding(CosmicSpacing.m)
                .background(
                    RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                        .fill(CosmicColors.glassBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                .stroke(CosmicColors.glassBorder, lineWidth: 1)
                        )
                )
                .shadow(color: CosmicColors.nebulaBlue.opacity(0.2), radius: 5, x: 0, y: 2)
                
                Spacer()
            } else {
                // Sender's message on the right
                Spacer()
                
                VStack(alignment: .trailing, spacing: CosmicSpacing.xs) {
                    Text(message.content)
                        .font(CosmicFonts.body)
                        .foregroundColor(.white)
                    
                    Text(message.timestamp, style: .time)
                        .font(CosmicFonts.small)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(CosmicSpacing.m)
                .background(CosmicColors.primaryGradient)
                .cornerRadius(CosmicCornerRadius.medium)
                .shadow(color: CosmicColors.nebulaPurple.opacity(0.4), radius: 8, x: 0, y: 2)
            }
        }
        .padding(.horizontal, CosmicSpacing.m)
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(spacing: CosmicSpacing.xs) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(CosmicColors.textMuted)
                    .frame(width: 8, height: 8)
                    .opacity(animationPhase == index ? 1.0 : 0.3)
                    .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: false), value: animationPhase)
            }
        }
        .padding(CosmicSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                .fill(CosmicColors.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                        .stroke(CosmicColors.glassBorder, lineWidth: 1)
                )
        )
        .onAppear {
            // Animate the typing dots
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: false)) {
                animationPhase = 1
            }
            
            // Cycle through phases
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                withAnimation(.easeInOut(duration: 0.4)) {
                    animationPhase = (animationPhase + 1) % 3
                }
            }
        }
    }
}

#Preview {
    MessagesView()
}

