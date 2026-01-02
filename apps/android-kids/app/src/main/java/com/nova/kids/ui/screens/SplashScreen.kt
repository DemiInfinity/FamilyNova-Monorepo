package com.nova.kids.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.nova.kids.design.CosmicColors
import com.nova.kids.design.CosmicCornerRadius
import com.nova.kids.design.CosmicSpacing
import com.nova.kids.viewmodels.AuthViewModel
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(
    authViewModel: AuthViewModel,
    onLoadingComplete: () -> Unit
) {
    var loadingProgress by remember { mutableStateOf(0f) }
    var loadingMessage by remember { mutableStateOf("Initializing...") }
    var isLoadingComplete by remember { mutableStateOf(false) }
    
    LaunchedEffect(Unit) {
        loadInitialData { progress, message ->
            loadingProgress = progress
            loadingMessage = message
        }
        isLoadingComplete = true
        delay(500) // Small delay before hiding splash
        onLoadingComplete()
    }
    
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
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(CosmicSpacing.XL)
        ) {
            // App Icon/Logo
            Box(
                modifier = Modifier
                    .size(120.dp)
                    .background(
                        Brush.linearGradient(
                            colors = listOf(
                                CosmicColors.NebulaPurple,
                                CosmicColors.NebulaBlue
                            )
                        ),
                        shape = RoundedCornerShape(CosmicCornerRadius.Large)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "N",
                    fontSize = 64.sp,
                    fontWeight = FontWeight.Bold,
                    color = CosmicColors.TextPrimary
                )
            }
            
            // App Name
            Text(
                text = "Nova",
                fontSize = 42.sp,
                fontWeight = FontWeight.Bold,
                color = CosmicColors.TextPrimary
            )
            
            // Loading Indicator
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(CosmicSpacing.M)
            ) {
                CircularProgressIndicator(
                    modifier = Modifier.size(48.dp),
                    color = CosmicColors.NebulaPurple
                )
                
                Text(
                    text = loadingMessage,
                    fontSize = 14.sp,
                    color = CosmicColors.TextSecondary
                )
                
                // Progress Bar
                LinearProgressIndicator(
                    progress = { loadingProgress },
                    modifier = Modifier
                        .fillMaxWidth(0.6f)
                        .height(4.dp),
                    color = CosmicColors.NebulaPurple,
                    trackColor = CosmicColors.GlassBackground
                )
            }
        }
    }
}

private suspend fun loadInitialData(
    onProgress: (Float, String) -> Unit
) {
    // Step 1: Validate token and load user
    onProgress(0.2f, "Authenticating...")
    delay(300)
    
    // Step 2: Load user profile
    onProgress(0.4f, "Loading profile...")
    delay(300)
    
    // Step 3: Load friends
    onProgress(0.6f, "Loading friends...")
    delay(300)
    
    // Step 4: Load posts
    onProgress(0.8f, "Loading posts...")
    delay(300)
    
    // Step 5: Complete
    onProgress(1.0f, "Ready!")
    delay(200)
}

