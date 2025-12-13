//
//  MonitoringView.swift
//  FamilyNovaParent
//

import SwiftUI

struct MonitoringView: View {
    @State private var messages: [MonitoredMessage] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if messages.isEmpty {
                    VStack(spacing: ParentAppSpacing.m) {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 48))
                            .foregroundColor(ParentAppColors.mediumGray)
                        Text("No messages to monitor")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: ParentAppSpacing.m) {
                            ForEach(messages) { message in
                                MessageMonitoringCard(message: message)
                            }
                        }
                        .padding(ParentAppSpacing.m)
                    }
                }
            }
            .background(ParentAppColors.lightGray)
            .navigationTitle("Monitoring")
            .navigationBarTitleDisplayMode(.large)
        }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
            HStack {
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text("From: \(message.sender)")
                        .font(ParentAppFonts.caption)
                        .foregroundColor(ParentAppColors.darkGray)
                    Text("To: \(message.receiver)")
                        .font(ParentAppFonts.caption)
                        .foregroundColor(ParentAppColors.darkGray)
                }
                
                Spacer()
                
                Text(message.timestamp, style: .time)
                    .font(ParentAppFonts.small)
                    .foregroundColor(ParentAppColors.darkGray)
            }
            
            Text(message.content)
                .font(ParentAppFonts.body)
                .foregroundColor(ParentAppColors.black)
            
            HStack(spacing: ParentAppSpacing.s) {
                Button(action: {}) {
                    Text("Approve")
                        .font(ParentAppFonts.small)
                        .foregroundColor(.white)
                        .padding(.horizontal, ParentAppSpacing.m)
                        .padding(.vertical, ParentAppSpacing.s)
                        .background(ParentAppColors.success)
                        .cornerRadius(ParentAppCornerRadius.small)
                }
                
                Button(action: {}) {
                    Text("Flag")
                        .font(ParentAppFonts.small)
                        .foregroundColor(.white)
                        .padding(.horizontal, ParentAppSpacing.m)
                        .padding(.vertical, ParentAppSpacing.s)
                        .background(ParentAppColors.warning)
                        .cornerRadius(ParentAppCornerRadius.small)
                }
            }
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    MonitoringView()
}

