package com.nova.parent.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.nova.parent.design.ParentAppColors
import com.nova.parent.design.ParentAppSpacing
import com.nova.parent.viewmodels.AuthViewModel

@Composable
fun CreatePostScreen(authViewModel: AuthViewModel) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "Create Post",
            color = ParentAppColors.DarkGray
        )
    }
}

