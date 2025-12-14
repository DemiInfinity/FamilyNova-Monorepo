//
//  NotificationManager.swift
//  FamilyNovaParent
//
//  Manages local notifications for new messages

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("[NotificationManager] Error requesting authorization: \(error)")
            } else {
                print("[NotificationManager] Notification authorization granted: \(granted)")
            }
        }
    }
    
    func scheduleMessageNotification(from senderName: String, content: String, friendId: String? = nil) {
        // Always schedule system notification (works in background and foreground)
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "New message from \(senderName)"
        notificationContent.body = content
        notificationContent.sound = .default
        notificationContent.badge = NSNumber(value: (UIApplication.shared.applicationIconBadgeNumber + 1))
        notificationContent.categoryIdentifier = "MESSAGE"
        notificationContent.userInfo = [
            "type": "message",
            "sender": senderName,
            "friendId": friendId ?? "",
            "content": content
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "message_\(UUID().uuidString)",
            content: notificationContent,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Error scheduling notification: \(error)")
            } else {
                print("[NotificationManager] Scheduled message notification from \(senderName)")
            }
        }
        
        // Save to notification history
        saveNotification(
            type: .message,
            title: "New message from \(senderName)",
            message: content,
            metadata: ["friendId": friendId ?? "", "sender": senderName]
        )
        
        // Post notification for toast (if app is in foreground)
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowToastNotification"),
            object: nil,
            userInfo: [
                "title": "New message from \(senderName)",
                "message": content,
                "icon": "message.fill",
                "type": "message"
            ]
        )
    }
    
    private func saveNotification(type: NotificationType, title: String, message: String, metadata: [String: String] = [:]) {
        let notification = SavedNotification(
            id: UUID(),
            type: type,
            title: title,
            message: message,
            timestamp: Date(),
            isRead: false,
            metadata: metadata
        )
        
        var notifications = getSavedNotifications()
        notifications.insert(notification, at: 0) // Add to beginning
        
        // Keep only last 100 notifications
        if notifications.count > 100 {
            notifications = Array(notifications.prefix(100))
        }
        
        // Save to UserDefaults
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: "saved_notifications")
        }
    }
    
    func getSavedNotifications() -> [SavedNotification] {
        guard let data = UserDefaults.standard.data(forKey: "saved_notifications") else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let notifications = try? decoder.decode([SavedNotification].self, from: data) else {
            return []
        }
        return notifications
    }
    
    func markNotificationAsRead(_ id: UUID) {
        var notifications = getSavedNotifications()
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
            if let encoded = try? JSONEncoder().encode(notifications) {
                UserDefaults.standard.set(encoded, forKey: "saved_notifications")
            }
        }
    }
    
    func clearAllNotifications() {
        UserDefaults.standard.removeObject(forKey: "saved_notifications")
    }
    
    func scheduleFriendRequestNotification(from userName: String) {
        let content = UNMutableNotificationContent()
        content.title = "New friend request"
        content.body = "\(userName) wants to be your friend"
        content.sound = .default
        content.badge = NSNumber(value: (UIApplication.shared.applicationIconBadgeNumber + 1))
        content.categoryIdentifier = "FRIEND_REQUEST"
        content.userInfo = ["type": "friend_request", "from": userName]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "friend_request_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Error scheduling friend request notification: \(error)")
            }
        }
    }
    
    func scheduleMentionNotification(from userName: String, in postContent: String) {
        let content = UNMutableNotificationContent()
        content.title = "You were mentioned"
        content.body = "\(userName) mentioned you: \(postContent.prefix(50))"
        content.sound = .default
        content.badge = NSNumber(value: (UIApplication.shared.applicationIconBadgeNumber + 1))
        content.categoryIdentifier = "MENTION"
        content.userInfo = ["type": "mention", "from": userName]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "mention_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Error scheduling mention notification: \(error)")
            }
        }
    }
    
    func scheduleChildReportNotification(childName: String, reportType: String, content: String) {
        let title: String
        switch reportType {
        case "new_friend":
            title = "\(childName) added a new friend"
        case "suspicious_activity":
            title = "Activity alert for \(childName)"
        default:
            title = "Report from \(childName)"
        }
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = content
        notificationContent.sound = .default
        notificationContent.badge = NSNumber(value: (UIApplication.shared.applicationIconBadgeNumber + 1))
        notificationContent.categoryIdentifier = "CHILD_REPORT"
        notificationContent.userInfo = ["type": "child_report", "child": childName, "reportType": reportType]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "child_report_\(UUID().uuidString)",
            content: notificationContent,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Error scheduling child report notification: \(error)")
            }
        }
    }
    
    func clearBadge() {
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
            // For iOS 15.0, use the older method
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }
    
    enum NotificationType: String, Codable {
        case message
        case friendRequest
        case mention
        case system
    }
}

struct SavedNotification: Identifiable, Codable {
    let id: UUID
    let type: NotificationManager.NotificationType
    let title: String
    let message: String
    let timestamp: Date
    var isRead: Bool
    let metadata: [String: String]
}

