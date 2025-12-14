package com.nova.kids.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.unit.dp
import com.nova.kids.design.CosmicColors
import com.nova.kids.viewmodels.AuthViewModel

@Composable
fun ExploreScreen(authViewModel: AuthViewModel) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        CosmicColors.SpaceTop,
                        CosmicColors.SpaceMiddle,
                        CosmicColors.SpaceBottom
                    )
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "Explore",
            color = CosmicColors.TextPrimary
        )
    }
}

