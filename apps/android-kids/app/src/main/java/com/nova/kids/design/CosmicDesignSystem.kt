package com.nova.kids.design

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Unified cosmic design system for Nova and Nova+
 */

// MARK: - Cosmic Colors
object CosmicColors {
    // Deep Space Gradient Colors
    val SpaceTop = Color(0xFF0A0E27)      // Deep navy
    val SpaceMiddle = Color(0xFF1a1d3d)   // Dark purple-blue
    val SpaceBottom = Color(0xFF2D1B69)    // Deep purple
    
    // Primary Cosmic Colors
    val NebulaPurple = Color(0xFF8B5CF6)  // Bright purple
    val NebulaBlue = Color(0xFF3B82F6)    // Bright blue
    val StarGold = Color(0xFFFBBF24)      // Gold star
    val CometPink = Color(0xFFEC4899)     // Pink comet
    val PlanetTeal = Color(0xFF14B8A6)    // Teal planet
    
    // Frosted Glass Colors
    val GlassBackground = Color.White.copy(alpha = 0.1f)
    val GlassBorder = Color.White.copy(alpha = 0.1f)
    
    // Text Colors
    val TextPrimary = Color(0xFFF8FAFC)    // Off-white
    val TextSecondary = Color(0xFFE2E8F0)  // Light gray
    val TextMuted = Color(0xFF94A3B8)      // Muted gray
    
    // Status Colors
    val Success = Color(0xFF10B981)         // Green nebula
    val Warning = Color(0xFFF59E0B)         // Orange star
    val Error = Color(0xFFEF4444)          // Red supernova
    val Info = Color(0xFF3B82F6)           // Blue nebula
}

// MARK: - Cosmic Spacing
object CosmicSpacing {
    val XS = 4.dp
    val S = 8.dp
    val M = 16.dp
    val L = 24.dp
    val XL = 32.dp
    val XXL = 48.dp
}

// MARK: - Cosmic Corner Radius
object CosmicCornerRadius {
    val Small = 12.dp
    val Medium = 16.dp
    val Large = 20.dp
    val ExtraLarge = 24.dp
    val Round = 50.dp
}

// MARK: - Cosmic Typography
object CosmicTypography {
    val Title = androidx.compose.ui.text.TextStyle(
        fontSize = 28.sp,
        fontWeight = FontWeight.Bold
    )
    
    val Headline = androidx.compose.ui.text.TextStyle(
        fontSize = 20.sp,
        fontWeight = FontWeight.SemiBold
    )
    
    val Body = androidx.compose.ui.text.TextStyle(
        fontSize = 16.sp,
        fontWeight = FontWeight.Normal
    )
    
    val Caption = androidx.compose.ui.text.TextStyle(
        fontSize = 14.sp,
        fontWeight = FontWeight.Normal
    )
    
    val Small = androidx.compose.ui.text.TextStyle(
        fontSize = 12.sp,
        fontWeight = FontWeight.Light
    )
    
    val Button = androidx.compose.ui.text.TextStyle(
        fontSize = 16.sp,
        fontWeight = FontWeight.SemiBold
    )
}

