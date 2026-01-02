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
fun MoreScreen(authViewModel: AuthViewModel) {
    ProfileScreen(authViewModel = authViewModel)
}

