package com.nova.kids.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.nova.kids.design.CosmicColors
import com.nova.kids.design.CosmicCornerRadius
import com.nova.kids.design.CosmicSpacing
import com.nova.kids.viewmodels.AuthViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
@Suppress("UNUSED_PARAMETER")
fun MoreScreen(
    authViewModel: AuthViewModel,
    onNavigateToProfile: () -> Unit = {},
    onNavigateToFriends: () -> Unit = {},
    onNavigateToNotifications: () -> Unit = {},
    onNavigateToSettings: () -> Unit = {}
) {
    // These parameters are for future navigation implementation
    var showProfile by remember { mutableStateOf(false) }
    var showSettings by remember { mutableStateOf(false) }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("More") },
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
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .fillMaxWidth()
                    .padding(CosmicSpacing.M),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(CosmicSpacing.XL)
                ) {
                    // Profile Section
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(CosmicCornerRadius.Large),
                        colors = CardDefaults.cardColors(
                            containerColor = CosmicColors.GlassBackground
                        )
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(CosmicSpacing.L),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(CosmicSpacing.M)
                        ) {
                            // Profile Picture
                            AsyncImage(
                                model = authViewModel.currentUser.value?.profile?.avatar,
                                contentDescription = "Avatar",
                                modifier = Modifier
                                    .size(100.dp)
                                    .clip(CircleShape)
                                    .background(CosmicColors.NebulaPurple)
                            )
                            
                            // Username
                            Text(
                                text = authViewModel.currentUser.value?.profile?.displayName ?: "User",
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Bold,
                                color = CosmicColors.TextPrimary
                            )
                            
                            // Quick Stats
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(CosmicSpacing.XL)
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(
                                        text = "0",
                                        fontSize = 18.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = CosmicColors.NebulaPurple
                                    )
                                    Text(
                                        text = "Friends",
                                        fontSize = 12.sp,
                                        color = CosmicColors.TextMuted
                                    )
                                }
                                
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(
                                        text = "0",
                                        fontSize = 18.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = CosmicColors.NebulaPurple
                                    )
                                    Text(
                                        text = "Posts",
                                        fontSize = 12.sp,
                                        color = CosmicColors.TextMuted
                                    )
                                }
                            }
                        }
                    }
                    
                    // Menu Options
                    Column(
                        verticalArrangement = Arrangement.spacedBy(CosmicSpacing.S)
                    ) {
                        MenuRow(
                            icon = Icons.Default.Person,
                            title = "My Profile",
                            onClick = { showProfile = true }
                        )
                        MenuRow(
                            icon = Icons.Default.People,
                            title = "Friends",
                            onClick = onNavigateToFriends
                        )
                        MenuRow(
                            icon = Icons.Default.Notifications,
                            title = "Notifications",
                            onClick = onNavigateToNotifications
                        )
                        MenuRow(
                            icon = Icons.Default.Settings,
                            title = "Settings",
                            onClick = { showSettings = true }
                        )
                    }
                    
                    // Educational Section
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(CosmicCornerRadius.Medium),
                        colors = CardDefaults.cardColors(
                            containerColor = CosmicColors.GlassBackground
                        )
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(CosmicSpacing.M),
                            verticalArrangement = Arrangement.spacedBy(CosmicSpacing.S)
                        ) {
                            Text(
                                text = "Digital Safety Tips",
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = CosmicColors.TextPrimary
                            )
                            Text(
                                text = "Learn how to stay safe online and be a good digital citizen.",
                                fontSize = 14.sp,
                                color = CosmicColors.TextSecondary
                            )
                        }
                    }
                    
                    // Log Out
                    Button(
                        onClick = { authViewModel.logout() },
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = CosmicColors.NebulaPurple
                        ),
                        shape = RoundedCornerShape(CosmicCornerRadius.Medium)
                    ) {
                        Text(
                            "Log Out",
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }

@Composable
fun MenuRow(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    title: String,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(CosmicCornerRadius.Medium),
        colors = CardDefaults.cardColors(
            containerColor = CosmicColors.GlassBackground
        )
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
            Icon(
                Icons.Default.ChevronRight,
                contentDescription = null,
                tint = CosmicColors.TextMuted
            )
        }
    }
}

