//
//  MessagesView.swift
//  FamilyNovaKids
//

import SwiftUI

struct MessagesView: View {
    @State private var messages: [Message] = []
    @State private var messageText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if messages.isEmpty {
                    VStack(spacing: AppSpacing.m) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.mediumGray)
                        Text("No messages yet")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.darkGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.s) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                            }
                        }
                        .padding(AppSpacing.m)
                    }
                }
                
                // Message Input
                HStack(spacing: AppSpacing.s) {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(AppSpacing.s)
                        .background(Color.white)
                        .cornerRadius(AppCornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.mediumGray, lineWidth: 1)
                        )
                        .lineLimit(3)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.primaryBlue)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(AppSpacing.m)
                .background(Color.white)
            }
            .background(AppColors.lightGray)
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        // TODO: Send message via API
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
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(AppSpacing.m)
            .background(AppColors.primaryBlue)
            .cornerRadius(AppCornerRadius.large)
            
            Spacer()
        }
    }
}

#Preview {
    MessagesView()
}

