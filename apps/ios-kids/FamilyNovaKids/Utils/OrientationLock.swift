//
//  OrientationLock.swift
//  FamilyNovaKids
//
//  Utility to lock app orientation to portrait

import SwiftUI
import UIKit

struct OrientationLockModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Lock to portrait orientation
                AppDelegate.orientationLock = .portrait
            }
    }
}

extension View {
    func lockOrientationToPortrait() -> some View {
        self.modifier(OrientationLockModifier())
    }
}

// AppDelegate to handle orientation
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

