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
            ZStack {
                // Fun gradient background
                LinearGradient(
                    colors: [AppColors.gradientBlue.opacity(0.1), AppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if messages.isEmpty {
                        VStack(spacing: AppSpacing.l) {
                            Text("💬")
                                .font(.system(size: 80))
                            Text("No messages yet")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.primaryBlue)
                            Text("Start chatting with your friends!")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.xl)
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
                    
                    // Message Input - More colorful
                    HStack(spacing: AppSpacing.m) {
                        TextField("Type a message...", text: $messageText)
                            .textFieldStyle(.plain)
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
            }
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

