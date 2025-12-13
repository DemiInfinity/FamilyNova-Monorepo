//
//  CosmicDesignSystem.swift
//  FamilyNovaKids
//
//  Unified cosmic design system for Nova and Nova+

import SwiftUI

// MARK: - Cosmic Colors
struct CosmicColors {
    // Deep Space Gradient Colors
    static let spaceTop = Color(hex: "0A0E27")      // Deep navy
    static let spaceMiddle = Color(hex: "1a1d3d")   // Dark purple-blue
    static let spaceBottom = Color(hex: "2D1B69")    // Deep purple
    
    // Primary Cosmic Colors
    static let nebulaPurple = Color(hex: "8B5CF6")  // Bright purple
    static let nebulaBlue = Color(hex: "3B82F6")    // Bright blue
    static let starGold = Color(hex: "FBBF24")      // Gold star
    static let cometPink = Color(hex: "EC4899")     // Pink comet
    static let planetTeal = Color(hex: "14B8A6")    // Teal planet
    
    // Gradient Combinations
    static let primaryGradient = LinearGradient(
        colors: [nebulaPurple, nebulaBlue],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let spaceGradient = LinearGradient(
        colors: [spaceTop, spaceMiddle, spaceBottom],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Frosted Glass Colors
    static let glassBackground = Color.white.opacity(0.1)
    static let glassBorder = Color.white.opacity(0.1)
    
    // Text Colors
    static let textPrimary = Color(hex: "F8FAFC")    // Off-white
    static let textSecondary = Color(hex: "E2E8F0")  // Light gray
    static let textMuted = Color(hex: "94A3B8")      // Muted gray
    
    // Status Colors (with cosmic theme)
    static let success = Color(hex: "10B981")         // Green nebula
    static let warning = Color(hex: "F59E0B")         // Orange star
    static let error = Color(hex: "EF4444")          // Red supernova
    static let info = Color(hex: "3B82F6")           // Blue nebula
    
    // Reaction Colors
    static let reactionHappy = Color(hex: "FBBF24")  // Gold
    static let reactionLove = Color(hex: "EC4899")    // Pink
    static let reactionWow = Color(hex: "8B5CF6")    // Purple
    static let reactionSad = Color(hex: "3B82F6")    // Blue
    static let reactionAngry = Color(hex: "EF4444")  // Red
}

// MARK: - Cosmic Fonts
struct CosmicFonts {
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headline = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 14, weight: .regular, design: .rounded)
    static let small = Font.system(size: 12, weight: .light, design: .rounded)
    static let button = Font.system(size: 16, weight: .semibold, design: .rounded)
    
    // Text with shadow for readability on cosmic background
    static func textWithShadow(_ text: String, color: Color = CosmicColors.textPrimary) -> some View {
        Text(text)
            .foregroundColor(color)
            .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Cosmic Spacing
struct CosmicSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Cosmic Corner Radius
struct CosmicCornerRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 20
    static let extraLarge: CGFloat = 24
    static let round: CGFloat = 50
}

// MARK: - Cosmic Card Style
struct CosmicCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                    .fill(CosmicColors.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                            .stroke(CosmicColors.glassBorder, lineWidth: 1)
                    )
            )
            .shadow(color: CosmicColors.nebulaPurple.opacity(0.3), radius: 15, x: 0, y: 0)
    }
}

extension View {
    func cosmicCard() -> some View {
        modifier(CosmicCard())
    }
}

// MARK: - Cosmic Button Style
struct CosmicButtonStyle: ButtonStyle {
    var isPrimary: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, CosmicSpacing.l)
            .padding(.vertical, CosmicSpacing.m)
            .background(
                Group {
                    if isPrimary {
                        CosmicColors.primaryGradient
                    } else {
                        RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                            .fill(CosmicColors.glassBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                    .stroke(CosmicColors.glassBorder, lineWidth: 1)
                            )
                    }
                }
            )
            .foregroundColor(isPrimary ? .white : CosmicColors.textPrimary)
            .cornerRadius(CosmicCornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(
                color: isPrimary ? CosmicColors.nebulaPurple.opacity(0.4) : Color.clear,
                radius: configuration.isPressed ? 5 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Cosmic Background
struct CosmicBackground: View {
    var body: some View {
        ZStack {
            // Deep space gradient
            CosmicColors.spaceGradient
                .ignoresSafeArea()
            
            // Subtle animated star field (static for now, can be animated later)
            StarField()
        }
    }
}

// MARK: - Star Field View
struct StarField: View {
    @State private var stars: [Star] = []
    
    struct Star {
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
    }
    
    init() {
        // Generate random stars
        var generatedStars: [Star] = []
        for _ in 0..<50 {
            generatedStars.append(Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.3...0.8)
            ))
        }
        _stars = State(initialValue: generatedStars)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<stars.count, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: stars[index].size, height: stars[index].size)
                    .opacity(stars[index].opacity)
                    .position(
                        x: stars[index].x * geometry.size.width,
                        y: stars[index].y * geometry.size.height
                    )
            }
        }
    }
}

// MARK: - Cosmic Icon Style
extension Image {
    func cosmicIcon(size: CGFloat = 24, color: Color = CosmicColors.nebulaPurple) -> some View {
        self
            .font(.system(size: size, weight: .medium))
            .foregroundColor(color)
            .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 0)
    }
}

// Note: Color.init(hex:) is already defined in DesignSystem.swift

