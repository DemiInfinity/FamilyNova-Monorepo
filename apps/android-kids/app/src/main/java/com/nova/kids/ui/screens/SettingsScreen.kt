package com.nova.kids.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.nova.kids.design.CosmicColors
import com.nova.kids.design.CosmicCornerRadius
import com.nova.kids.design.CosmicSpacing
import com.nova.kids.viewmodels.AuthViewModel

@Composable
fun SettingsScreen(authViewModel: AuthViewModel) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = CosmicColors.GlassBackground
                )
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            CosmicColors.SpaceTop,
                            CosmicColors.SpaceMiddle,
                            CosmicColors.SpaceBottom
                        )
                    )
                )
        ) {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(CosmicSpacing.M),
                verticalArrangement = Arrangement.spacedBy(CosmicSpacing.S)
            ) {
                // Account Section
                item {
                    SettingsSection("Account")
                }
                item {
                    SettingsItem(
                        icon = Icons.Default.Person,
                        title = "Edit Profile",
                        onClick = { /* TODO: Navigate to edit profile */ }
                    )
                }
                item {
                    SettingsItem(
                        icon = Icons.Default.Lock,
                        title = "Privacy",
                        onClick = { /* TODO: Navigate to privacy settings */ }
                    )
                }

                // Notifications Section
                item {
                    Spacer(modifier = Modifier.height(CosmicSpacing.M))
                    SettingsSection("Notifications")
                }
                item {
                    var notificationsEnabled by remember { mutableStateOf(true) }
                    SettingsItem(
                        icon = Icons.Default.Notifications,
                        title = "Push Notifications",
                        trailing = {
                            Switch(
                                checked = notificationsEnabled,
                                onCheckedChange = { notificationsEnabled = it }
                            )
                        }
                    )
                }

                // About Section
                item {
                    Spacer(modifier = Modifier.height(CosmicSpacing.M))
                    SettingsSection("About")
                }
                item {
                    SettingsItem(
                        icon = Icons.Default.Info,
                        title = "About Nova",
                        onClick = { /* TODO: Show about dialog */ }
                    )
                }
                item {
                    SettingsItem(
                        icon = Icons.Default.Help,
                        title = "Help & Support",
                        onClick = { /* TODO: Navigate to help */ }
                    )
                }

                // Logout
                item {
                    Spacer(modifier = Modifier.height(CosmicSpacing.L))
                    Button(
                        onClick = {
                            authViewModel.logout()
                        },
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = CosmicColors.NebulaPurple
                        ),
                        shape = RoundedCornerShape(CosmicCornerRadius.Medium)
                    ) {
                        Text("Logout", fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

@Composable
fun SettingsSection(title: String) {
    Text(
        text = title,
        fontSize = 14.sp,
        fontWeight = FontWeight.Bold,
        color = CosmicColors.TextSecondary,
        modifier = Modifier.padding(horizontal = CosmicSpacing.M, vertical = CosmicSpacing.S)
    )
}

@Composable
fun SettingsItem(
    icon: ImageVector,
    title: String,
    onClick: () -> Unit = {},
    trailing: @Composable (() -> Unit)? = null
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(CosmicCornerRadius.Medium),
        colors = CardDefaults.cardColors(
            containerColor = CosmicColors.GlassBackground
        ),
        onClick = onClick
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(CosmicSpacing.M),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                icon,
                contentDescription = null,
                tint = CosmicColors.NebulaPurple,
                modifier = Modifier.size(24.dp)
            )
            Spacer(modifier = Modifier.width(CosmicSpacing.M))
            Text(
                text = title,
                fontSize = 16.sp,
                color = CosmicColors.TextPrimary,
                modifier = Modifier.weight(1f)
            )
            trailing?.invoke() ?: Icon(
                Icons.Default.ChevronRight,
                contentDescription = null,
                tint = CosmicColors.TextMuted
            )
        }
    }
}

