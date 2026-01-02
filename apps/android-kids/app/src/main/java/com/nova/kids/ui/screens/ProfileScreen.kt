package com.nova.kids.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import com.nova.kids.models.Post
import com.nova.kids.ui.components.CosmicPostCard
import com.nova.kids.viewmodels.AuthViewModel
import com.nova.kids.viewmodels.ProfileViewModel

@Composable
fun ProfileScreen(
    authViewModel: AuthViewModel,
    userId: String? = null
) {
    val profileViewModel = remember { ProfileViewModel(authViewModel, userId) }
    val profile by profileViewModel.profile.collectAsState()
    val posts by profileViewModel.posts.collectAsState()
    val isLoading by profileViewModel.isLoading.collectAsState()
    var selectedTab by remember { mutableStateOf(0) } // 0 = Posts, 1 = Photos

    LaunchedEffect(Unit) {
        profileViewModel.loadProfile()
        profileViewModel.loadPosts()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(profile?.displayName ?: "Profile") },
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
            if (isLoading && profile == null) {
                CircularProgressIndicator(
                    modifier = Modifier.align(Alignment.Center),
                    color = CosmicColors.NebulaPurple
                )
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize()
                ) {
                    // Cover Banner
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(200.dp)
                                .background(CosmicColors.NebulaPurple)
                        ) {
                            profile?.bannerUrl?.let { bannerUrl ->
                                AsyncImage(
                                    model = bannerUrl,
                                    contentDescription = "Banner",
                                    modifier = Modifier.fillMaxSize()
                                )
                            }
                            
                            // Profile Picture
                            AsyncImage(
                                model = profile?.avatarUrl,
                                contentDescription = "Avatar",
                                modifier = Modifier
                                    .size(120.dp)
                                    .clip(CircleShape)
                                    .align(Alignment.BottomStart)
                                    .offset(x = CosmicSpacing.M.dp, y = 60.dp)
                                    .background(CosmicColors.GlassBackground)
                            )
                        }
                        Spacer(modifier = Modifier.height(70.dp))
                    }

                    // Profile Info
                    item {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = CosmicSpacing.M)
                        ) {
                            Text(
                                text = profile?.displayName ?: "Unknown",
                                fontSize = 24.sp,
                                fontWeight = FontWeight.Bold,
                                color = CosmicColors.TextPrimary
                            )
                            Text(
                                text = profile?.email ?: "",
                                fontSize = 14.sp,
                                color = CosmicColors.TextSecondary
                            )
                        }
                        Spacer(modifier = Modifier.height(CosmicSpacing.M))
                    }

                    // Stats
                    item {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = CosmicSpacing.M),
                            horizontalArrangement = Arrangement.SpaceEvenly
                        ) {
                            StatItem("Posts", posts.size.toString())
                            StatItem("Friends", profile?.friendsCount?.toString() ?: "0")
                        }
                        Spacer(modifier = Modifier.height(CosmicSpacing.M))
                    }

                    // Tabs
                    item {
                        Row(
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            TabButton(
                                text = "Posts",
                                selected = selectedTab == 0,
                                onClick = { selectedTab = 0 },
                                modifier = Modifier.weight(1f)
                            )
                            TabButton(
                                text = "Photos",
                                selected = selectedTab == 1,
                                onClick = { selectedTab = 1 },
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }

                    // Content
                    if (selectedTab == 0) {
                        items(posts) { post ->
                            CosmicPostCard(
                                post = post,
                                authViewModel = authViewModel,
                                modifier = Modifier.padding(CosmicSpacing.M)
                            )
                        }
                    } else {
                        item {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(200.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    "Photos coming soon",
                                    color = CosmicColors.TextSecondary
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun StatItem(label: String, value: String) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = value,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = CosmicColors.NebulaPurple
        )
        Text(
            text = label,
            fontSize = 12.sp,
            color = CosmicColors.TextSecondary
        )
    }
}

@Composable
fun TabButton(
    text: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    TextButton(
        onClick = onClick,
        modifier = modifier,
        colors = ButtonDefaults.textButtonColors(
            contentColor = if (selected) CosmicColors.NebulaPurple else CosmicColors.TextMuted
        )
    ) {
        Text(
            text = text,
            fontWeight = if (selected) FontWeight.Bold else FontWeight.Normal
        )
    }
}

