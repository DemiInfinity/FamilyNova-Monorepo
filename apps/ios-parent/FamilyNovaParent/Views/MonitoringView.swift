//
//  MonitoringView.swift
//  FamilyNovaParent
//

import SwiftUI

struct MonitoringView: View {
    @State private var messages: [MonitoredMessage] = []
    @State private var isLoading = false
    @State private var selectedChild: String? = nil
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter by child
                if !messages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: ParentAppSpacing.s) {
                            Button(action: { selectedChild = nil }) {
                                Text("All Children")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(selectedChild == nil ? .white : ParentAppColors.primaryNavy)
                                    .padding(.horizontal, ParentAppSpacing.m)
                                    .padding(.vertical, ParentAppSpacing.s)
                                    .background(selectedChild == nil ? ParentAppColors.primaryNavy : Color.white)
                                    .cornerRadius(ParentAppCornerRadius.small)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.small)
                                            .stroke(ParentAppColors.primaryNavy, lineWidth: selectedChild == nil ? 0 : 1)
                                    )
                            }
                            
                            // TODO: Add child filter buttons
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        .padding(.vertical, ParentAppSpacing.s)
                    }
                    .background(Color.white)
                }
                
                if isLoading {
                    VStack(spacing: ParentAppSpacing.m) {
                        ProgressView()
                        Text("Loading messages...")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if messages.isEmpty {
                    VStack(spacing: ParentAppSpacing.m) {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 48))
                            .foregroundColor(ParentAppColors.mediumGray)
                        Text("No messages to monitor")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                        Text("All messages from your children will appear here")
                            .font(ParentAppFonts.caption)
                            .foregroundColor(ParentAppColors.mediumGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, ParentAppSpacing.xl)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: ParentAppSpacing.m) {
                            ForEach(filteredMessages) { message in
                                MessageMonitoringCard(message: message)
                            }
                        }
                        .padding(ParentAppSpacing.m)
                    }
                }
            }
            .background(ParentAppColors.lightGray)
            .navigationTitle("Message Monitoring")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadMessages()
            }
            .refreshable {
                await loadMessagesAsync()
            }
        }
    }
    
    private var filteredMessages: [MonitoredMessage] {
        if let selectedChild = selectedChild {
            return messages.filter { $0.sender == selectedChild || $0.receiver == selectedChild }
        }
        return messages
    }
    
    private func loadMessages() {
        isLoading = true
        Task {
            await loadMessagesAsync()
        }
    }
    
    private func loadMessagesAsync() async {
        // TODO: Implement API call to fetch messages from children
        // For now, simulate messages
        try? await Task.sleep(nanoseconds: 500_000_000)
        messages = []
        isLoading = false
    }
}

struct MonitoredMessage: Identifiable {
    let id = UUID()
    let content: String
    let sender: String
    let receiver: String
    let timestamp: Date
    let isModerated: Bool
}

struct MessageMonitoringCard: View {
    let message: MonitoredMessage
    @State private var isModerating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
            HStack {
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    HStack(spacing: ParentAppSpacing.xs) {
                        Text("From:")
                            .font(ParentAppFonts.caption)
                            .foregroundColor(ParentAppColors.darkGray)
                        Text(message.sender)
                            .font(ParentAppFonts.caption)
                            .foregroundColor(ParentAppColors.primaryNavy)
                            .fontWeight(.semibold)
                    }
                    HStack(spacing: ParentAppSpacing.xs) {
                        Text("To:")
                            .font(ParentAppFonts.caption)
                            .foregroundColor(ParentAppColors.darkGray)
                        Text(message.receiver)
                            .font(ParentAppFonts.caption)
                            .foregroundColor(ParentAppColors.primaryNavy)
                            .fontWeight(.semibold)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: ParentAppSpacing.xs) {
                    Text(message.timestamp, style: .time)
                        .font(ParentAppFonts.small)
                        .foregroundColor(ParentAppColors.darkGray)
                    
                    if message.isModerated {
                        HStack(spacing: ParentAppSpacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ParentAppColors.success)
                                .font(.system(size: 12))
                            Text("Reviewed")
                                .font(ParentAppFonts.small)
                                .foregroundColor(ParentAppColors.success)
                        }
                    }
                }
            }
            
            Divider()
            
            Text(message.content)
                .font(ParentAppFonts.body)
                .foregroundColor(ParentAppColors.black)
                .padding(.vertical, ParentAppSpacing.xs)
            
            if !message.isModerated {
                HStack(spacing: ParentAppSpacing.s) {
                    Button(action: { moderateMessage(action: "approve") }) {
                        HStack(spacing: ParentAppSpacing.xs) {
                            if isModerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text("Approve")
                                .font(ParentAppFonts.small)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        .padding(.vertical, ParentAppSpacing.s)
                        .background(ParentAppColors.success)
                        .cornerRadius(ParentAppCornerRadius.small)
                    }
                    .disabled(isModerating)
                    
                    Button(action: { moderateMessage(action: "flag") }) {
                        HStack(spacing: ParentAppSpacing.xs) {
                            Image(systemName: "flag.fill")
                            Text("Flag")
                                .font(ParentAppFonts.small)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        .padding(.vertical, ParentAppSpacing.s)
                        .background(ParentAppColors.warning)
                        .cornerRadius(ParentAppCornerRadius.small)
                    }
                    .disabled(isModerating)
                    
                    Spacer()
                }
            }
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func moderateMessage(action: String) {
        isModerating = true
        // TODO: Implement API call to moderate message
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            isModerating = false
        }
    }
}

#Preview {
    MonitoringView()
}

