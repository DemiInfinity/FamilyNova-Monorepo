//
//  AppDetection.swift
//  FamilyNovaParent
//

import Foundation
import UIKit

class AppDetection {
    static let kidsAppBundleId = "com.familynova.kids"
    static let kidsAppURLScheme = "familynovakids://"
    
    /// Check if the Kids app is installed on the same device
    static func isKidsAppInstalled() -> Bool {
        guard let url = URL(string: kidsAppURLScheme) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    /// Open the Kids app with login credentials
    static func openKidsAppWithLogin(childId: String, email: String, token: String) {
        guard let url = URL(string: "\(kidsAppURLScheme)login?childId=\(childId)&email=\(email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&token=\(token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

