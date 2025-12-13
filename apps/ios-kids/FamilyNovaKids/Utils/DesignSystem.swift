//
//  DesignSystem.swift
//  FamilyNovaKids
//

import SwiftUI

struct AppColors {
    // Primary Colors (Kids App - Fun & Friendly - More Vibrant!)
    static let primaryBlue = Color(hex: "00A8FF")      // Bright blue
    static let primaryGreen = Color(hex: "00D4AA")     // Bright green
    static let primaryOrange = Color(hex: "FF6B9D")    // Pink-orange
    static let primaryPurple = Color(hex: "A855F7")     // Bright purple
    static let primaryYellow = Color(hex: "FFD93D")     // Sunny yellow
    static let primaryPink = Color(hex: "FF6B9D")        // Fun pink
    
    // Gradient Colors for Fun Backgrounds
    static let gradientStart = Color(hex: "667EEA")
    static let gradientEnd = Color(hex: "764BA2")
    static let gradientBlue = Color(hex: "4FACFE")
    static let gradientPurple = Color(hex: "00F2FE")
    
    // Neutral Colors
    static let white = Color.white
    static let lightGray = Color(hex: "F8F9FA")
    static let mediumGray = Color(hex: "DEE2E6")
    static let darkGray = Color(hex: "495057")
    static let black = Color(hex: "212529")
    
    // Status Colors (More Vibrant)
    static let success = Color(hex: "00D4AA")
    static let warning = Color(hex: "FFD93D")
    static let error = Color(hex: "FF6B9D")
    static let info = Color(hex: "00A8FF")
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

struct AppFonts {
    // Bigger, bolder fonts for kids
    static let title = Font.system(size: 32, weight: .bold, design: .rounded)
    static let headline = Font.system(size: 24, weight: .bold, design: .rounded)
    static let body = Font.system(size: 18, weight: .medium, design: .rounded)
    static let caption = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let small = Font.system(size: 14, weight: .medium, design: .rounded)
    static let button = Font.system(size: 18, weight: .bold, design: .rounded)
}

struct AppSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

struct AppCornerRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 20
    static let large: CGFloat = 24
    static let round: CGFloat = 50
    static let extraLarge: CGFloat = 30
}

