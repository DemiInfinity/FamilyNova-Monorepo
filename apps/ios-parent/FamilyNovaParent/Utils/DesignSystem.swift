//
//  DesignSystem.swift
//  FamilyNovaParent
//

import SwiftUI

struct ParentAppColors {
    // Primary Colors (Parent App - Professional & Trustworthy)
    static let primaryNavy = Color(hex: "2C3E50")
    static let primaryTeal = Color(hex: "16A085")
    static let primaryIndigo = Color(hex: "5B6C7D")
    static let accentGold = Color(hex: "F39C12")
    
    // Neutral Colors
    static let white = Color.white
    static let lightGray = Color(hex: "F5F5F5")
    static let mediumGray = Color(hex: "CCCCCC")
    static let darkGray = Color(hex: "666666")
    static let black = Color.black
    
    // Status Colors
    static let success = Color(hex: "27AE60")
    static let warning = Color(hex: "F39C12")
    static let error = Color(hex: "E74C3C")
    static let info = Color(hex: "3498DB")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ParentAppFonts {
    static let title = Font.system(size: 28, weight: .bold)
    static let headline = Font.system(size: 20, weight: .semibold)
    static let body = Font.system(size: 16, weight: .regular)
    static let caption = Font.system(size: 14, weight: .regular)
    static let small = Font.system(size: 12, weight: .regular)
}

struct ParentAppSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

struct ParentAppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let round: CGFloat = 50
}

