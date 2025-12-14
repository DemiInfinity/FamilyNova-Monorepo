//
//  MessagesView.swift
//  FamilyNovaKids
//

import SwiftUI

struct MessagesView: View {
    let initialFriend: Friend?
    @State private var conversations: [Conversation] = []
    @State private var selectedFriend: Friend?
    @State private var showFriendPicker = false
    @State private var isLoading = false
    
    init(initialFriend: Friend? = nil) {
        self.initialFriend = initialFriend
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fun gradient background
                LinearGradient(
                    colors: [AppColors.gradientBlue.opacity(0.1), AppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if let selectedFriend = selectedFriend {
                    ChatView(friend: selectedFriend)
                } else if let initialFriend = initialFriend {
                    ChatView(friend: initialFriend)
                } else {
                    VStack(spacing: AppSpacing.l) {
                        if conversations.isEmpty {
                            VStack(spacing: AppSpacing.l) {
                                Text("💬")
                                    .font(.system(size: 80))
                                Text("No messages yet")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.primaryBlue)
                                Text("Select a friend to start chatting!")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.darkGray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, AppSpacing.xl)
                                
                                Button(action: { showFriendPicker = true }) {
                                    HStack(spacing: AppSpacing.s) {
                                        Text("👥")
                                            .font(.system(size: 24))
                                        Text("Choose a Friend")
                                            .font(AppFonts.button)
                                            .foregroundColor(.white)
                                    }
                                    .padding(AppSpacing.l)
                                    .background(
                                        LinearGradient(
                                            colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(AppCornerRadius.large)
                                    .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .padding(.top, AppSpacing.m)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: AppSpacing.m) {
                                    ForEach(conversations) { conversation in
                                        ConversationRow(conversation: conversation) {
                                            selectedFriend = conversation.friend
                                        }
                                    }
                                }
                                .padding(AppSpacing.m)
                            }
                        }
                    }
                }
            }
            .navigationTitle((selectedFriend ?? initialFriend) == nil ? "Messages" : (selectedFriend ?? initialFriend)?.displayName ?? "Chat")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if (selectedFriend ?? initialFriend) == nil {
                        Button(action: { showFriendPicker = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primaryBlue)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if (selectedFriend ?? initialFriend) != nil {
                        Button(action: { selectedFriend = nil }) {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(AppFonts.button)
                            .foregroundColor(AppColors.primaryBlue)
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
                }
                if (selectedFriend ?? initialFriend) == nil {
                    loadConversations()
                }
            }
        }
    }
    
    private func loadConversations() {
        isLoading = true
        // TODO: Implement API call to fetch conversations
        isLoading = false
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
            HStack(spacing: AppSpacing.m) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text("👤")
                        .font(.system(size: 30))
                }
                
                // Content
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text(conversation.friend.displayName)
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.black)
                        
                        if conversation.friend.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(AppColors.success)
                                .font(.system(size: 14))
                        }
                        
                        Spacer()
                        
                        Text(conversation.timestamp, style: .relative)
                            .font(AppFonts.small)
                            .foregroundColor(AppColors.darkGray)
                    }
                    
                    Text(conversation.lastMessage)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.darkGray)
                        .lineLimit(1)
                    
                    if conversation.unreadCount > 0 {
                        HStack {
                            Spacer()
                            Text("\(conversation.unreadCount)")
                                .font(AppFonts.small)
                                .foregroundColor(.white)
                                .padding(.horizontal, AppSpacing.s)
                                .padding(.vertical, 4)
                                .background(AppColors.primaryBlue)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(AppSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FriendPickerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var friends: [Friend] = []
    @State private var isLoading = false
    let onSelect: (Friend) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.gradientBlue.opacity(0.1), AppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else if friends.isEmpty {
                    VStack(spacing: AppSpacing.l) {
                        Text("👥")
                            .font(.system(size: 60))
                        Text("No friends yet")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.primaryBlue)
                        Text("Add friends to start messaging!")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.xl)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.m) {
                            ForEach(friends) { friend in
                                FriendRow(friend: friend, showAddButton: false)
                                    .onTapGesture {
                                        onSelect(friend)
                                    }
                            }
                        }
                        .padding(AppSpacing.m)
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
                    .font(AppFonts.button)
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
            .onAppear {
                loadFriends()
            }
        }
    }
    
    private func loadFriends() {
        isLoading = true
        // TODO: Implement API call to fetch friends
        // For now, simulate friends
        friends = [
            Friend(displayName: "Alex", avatar: nil, isVerified: true),
            Friend(displayName: "Sam", avatar: nil, isVerified: false)
        ]
        isLoading = false
    }
}

struct ChatView: View {
    let friend: Friend
    @State private var messages: [Message] = []
    @State private var messageText = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            if messages.isEmpty {
                VStack(spacing: AppSpacing.l) {
                    Text("💬")
                        .font(.system(size: 60))
                    Text("No messages yet")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.primaryBlue)
                    Text("Start the conversation!")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.darkGray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: AppSpacing.m) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(AppSpacing.m)
                }
            }
            
            // Message Input
            HStack(spacing: AppSpacing.m) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(.plain)
                    .foregroundColor(AppColors.black)
                    .font(AppFonts.body)
                    .padding(AppSpacing.l)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.large)
                            .fill(Color.white)
                            .shadow(color: AppColors.primaryBlue.opacity(0.2), radius: 5, x: 0, y: 2)
                    )
                    .lineLimit(3)
                
                Button(action: sendMessage) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
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
            .padding(AppSpacing.m)
            .background(Color.white)
        }
        .onAppear {
            loadMessages()
        }
    }
    
    private func loadMessages() {
        isLoading = true
        // TODO: Implement API call to fetch messages with this friend
        isLoading = false
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        // TODO: Send message via API
        let newMessage = Message(
            content: messageText,
            sender: "You",
            timestamp: Date()
        )
        messages.append(newMessage)
        messageText = ""
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
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(message.content)
                    .font(AppFonts.body)
                    .foregroundColor(.white)
                
                Text(message.timestamp, style: .time)
                    .font(AppFonts.small)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(AppSpacing.l)
            .background(
                LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppCornerRadius.large)
            .shadow(color: AppColors.primaryBlue.opacity(0.2), radius: 5, x: 0, y: 2)
            
            Spacer()
        }
    }
}

#Preview {
    MessagesView()
}

