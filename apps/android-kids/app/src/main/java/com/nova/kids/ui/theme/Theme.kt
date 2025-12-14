package com.nova.kids.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat
import com.nova.kids.design.CosmicColors

private val DarkColorScheme = darkColorScheme(
    primary = CosmicColors.NebulaPurple,
    secondary = CosmicColors.NebulaBlue,
    tertiary = CosmicColors.CometPink,
    background = CosmicColors.SpaceTop,
    surface = CosmicColors.SpaceMiddle,
    error = CosmicColors.Error,
    onPrimary = CosmicColors.TextPrimary,
    onSecondary = CosmicColors.TextPrimary,
    onTertiary = CosmicColors.TextPrimary,
    onBackground = CosmicColors.TextPrimary,
    onSurface = CosmicColors.TextPrimary,
    onError = CosmicColors.TextPrimary
)

@Composable
fun NovaTheme(
    darkTheme: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = DarkColorScheme
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.background.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}

