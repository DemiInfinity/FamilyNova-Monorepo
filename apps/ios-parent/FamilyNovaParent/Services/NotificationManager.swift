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
    
    func scheduleMessageNotification(from senderName: String, content: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "New message from \(senderName)"
        notificationContent.body = content
        notificationContent.sound = .default
        notificationContent.badge = NSNumber(value: (UIApplication.shared.applicationIconBadgeNumber + 1))
        notificationContent.categoryIdentifier = "MESSAGE"
        notificationContent.userInfo = ["type": "message", "sender": senderName]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "message_\(UUID().uuidString)",
            content: notificationContent,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Error scheduling notification: \(error)")
            }
        }
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
}

