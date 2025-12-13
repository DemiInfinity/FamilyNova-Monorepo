//
//  NotificationsView.swift
//  FamilyNovaParent
//
//  Notifications view with cosmic theme

import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var notifications: [NotificationItem] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                if isLoading {
                    VStack(spacing: CosmicSpacing.l) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(CosmicColors.nebulaPurple)
                        Text("Loading notifications...")
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                    }
                } else if notifications.isEmpty {
                    VStack(spacing: CosmicSpacing.l) {
                        Text("🔔")
                            .font(.system(size: 80))
                        Text("No Notifications")
                            .font(CosmicFonts.headline)
                            .foregroundColor(CosmicColors.textPrimary)
                        Text("You're all caught up!")
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: CosmicSpacing.m) {
                            ForEach(notifications) { notification in
                                NotificationRow(notification: notification)
                            }
                        }
                        .padding(CosmicSpacing.m)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(CosmicFonts.button)
                    .foregroundColor(CosmicColors.nebulaPurple)
                }
            }
            .onAppear {
                loadNotifications()
            }
        }
    }
    
    private func loadNotifications() {
        isLoading = true
        // TODO: Load notifications from API
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            notifications = []
            isLoading = false
        }
    }
}

struct NotificationItem: Identifiable {
    let id: UUID
    let type: NotificationType
    let title: String
    let message: String
    let timestamp: Date
    let isRead: Bool
    
    enum NotificationType {
        case friendRequest
        case postLike
        case comment
        case mention
        case system
    }
}

struct NotificationRow: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(spacing: CosmicSpacing.m) {
            // Icon based on type
            ZStack {
                Circle()
                    .fill(CosmicColors.glassBackground)
                    .frame(width: 50, height: 50)
                
                Image(systemName: iconForType(notification.type))
                    .cosmicIcon(size: 24, color: colorForType(notification.type))
            }
            
            // Content
            VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                Text(notification.title)
                    .font(CosmicFonts.headline)
                    .foregroundColor(CosmicColors.textPrimary)
                
                Text(notification.message)
                    .font(CosmicFonts.caption)
                    .foregroundColor(CosmicColors.textSecondary)
                    .lineLimit(2)
                
                Text(timeAgoString(from: notification.timestamp))
                    .font(CosmicFonts.small)
                    .foregroundColor(CosmicColors.textMuted)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(CosmicColors.nebulaPurple)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(CosmicSpacing.m)
        .cosmicCard()
    }
    
    private func iconForType(_ type: NotificationItem.NotificationType) -> String {
        switch type {
        case .friendRequest: return "person.badge.plus"
        case .postLike: return "heart.fill"
        case .comment: return "bubble.left.fill"
        case .mention: return "at"
        case .system: return "bell.fill"
        }
    }
    
    private func colorForType(_ type: NotificationItem.NotificationType) -> Color {
        switch type {
        case .friendRequest: return CosmicColors.nebulaBlue
        case .postLike: return CosmicColors.cometPink
        case .comment: return CosmicColors.planetTeal
        case .mention: return CosmicColors.starGold
        case .system: return CosmicColors.nebulaPurple
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NotificationsView()
        .environmentObject(AuthManager())
}

