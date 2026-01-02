package com.nova.parent.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.nova.parent.design.ParentAppColors
import com.nova.parent.design.ParentAppCornerRadius
import com.nova.parent.design.ParentAppSpacing
import com.nova.parent.viewmodels.AuthViewModel
import kotlinx.coroutines.delay

@OptIn(ExperimentalMaterial3Api::class)
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
        delay(500)
        onLoadingComplete()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(ParentAppColors.LightGray),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(ParentAppSpacing.XL)
        ) {
            // App Icon/Logo
            Box(
                modifier = Modifier
                    .size(120.dp)
                    .background(
                        ParentAppColors.PrimaryTeal,
                        shape = RoundedCornerShape(ParentAppCornerRadius.Large)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "N+",
                    fontSize = 64.sp,
                    fontWeight = FontWeight.Bold,
                    color = ParentAppColors.White
                )
            }

            // App Name
            Text(
                text = "Nova+",
                fontSize = 42.sp,
                fontWeight = FontWeight.Bold,
                color = ParentAppColors.PrimaryNavy
            )

            // Loading Indicator
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(ParentAppSpacing.M)
            ) {
                CircularProgressIndicator(
                    modifier = Modifier.size(48.dp),
                    color = ParentAppColors.PrimaryTeal
                )

                Text(
                    text = loadingMessage,
                    fontSize = 14.sp,
                    color = ParentAppColors.DarkGray
                )

                // Progress Bar
                LinearProgressIndicator(
                    progress = loadingProgress,
                    modifier = Modifier
                        .fillMaxWidth(0.6f)
                        .height(4.dp),
                    color = ParentAppColors.PrimaryTeal
                )
            }
        }
    }
}

private suspend fun loadInitialData(
    onProgress: (Float, String) -> Unit
) {
    onProgress(0.2f, "Authenticating...")
    delay(300)

    onProgress(0.4f, "Loading profile...")
    delay(300)

    onProgress(0.6f, "Loading children...")
    delay(300)

    onProgress(0.8f, "Loading dashboard...")
    delay(300)

    onProgress(1.0f, "Ready!")
    delay(200)
}
