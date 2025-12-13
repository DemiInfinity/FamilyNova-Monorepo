//
//  MessagesView.swift
//  FamilyNovaParent
//

import SwiftUI

struct MessagesView: View {
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
                loadConversations()
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

