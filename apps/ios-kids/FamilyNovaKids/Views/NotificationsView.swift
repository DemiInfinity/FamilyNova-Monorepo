//
//  NotificationsView.swift
//  FamilyNovaKids
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var notifications: [NotificationItem] = []
    @State private var isLoading = false
    
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
                    VStack(spacing: AppSpacing.l) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading notifications...")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.darkGray)
                    }
                } else if notifications.isEmpty {
                    VStack(spacing: AppSpacing.l) {
                        Text("🔔")
                            .font(.system(size: 80))
                        Text("No Notifications")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.primaryPurple)
                        Text("You're all caught up!")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.darkGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.m) {
                            ForEach(notifications) { notification in
                                NotificationRow(notification: notification)
                            }
                        }
                        .padding(AppSpacing.m)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(AppFonts.button)
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
            .onAppear {
                loadNotifications()
            }
        }
    }
    
    private func loadNotifications() {
        // TODO: Implement API call to fetch notifications
        isLoading = false
        notifications = []
    }
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    let timestamp: Date
    let isRead: Bool
}

enum NotificationType {
    case friendRequest
    case message
    case postApproved
    case postRejected
    case profileChangeApproved
    case profileChangeRejected
    case homework
}

struct NotificationRow: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(spacing: AppSpacing.m) {
            // Icon based on type
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20))
            }
            
            // Content
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(notification.title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.black)
                
                Text(notification.message)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.darkGray)
                    .lineLimit(2)
                
                Text(notification.timestamp, style: .relative)
                    .font(AppFonts.small)
                    .foregroundColor(AppColors.mediumGray)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(AppColors.primaryBlue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(AppSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private var iconName: String {
        switch notification.type {
        case .friendRequest:
            return "person.badge.plus"
        case .message:
            return "message.fill"
        case .postApproved:
            return "checkmark.circle.fill"
        case .postRejected:
            return "xmark.circle.fill"
        case .profileChangeApproved:
            return "checkmark.seal.fill"
        case .profileChangeRejected:
            return "xmark.seal.fill"
        case .homework:
            return "book.fill"
        }
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .friendRequest:
            return AppColors.primaryGreen
        case .message:
            return AppColors.primaryPurple
        case .postApproved, .profileChangeApproved:
            return AppColors.success
        case .postRejected, .profileChangeRejected:
            return AppColors.error
        case .homework:
            return AppColors.primaryBlue
        }
    }
}

#Preview {
    NotificationsView()
        .environmentObject(AuthManager())
}

