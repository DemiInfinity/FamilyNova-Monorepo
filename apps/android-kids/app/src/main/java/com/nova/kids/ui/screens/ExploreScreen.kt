package com.nova.kids.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import com.nova.kids.models.Friend
import com.nova.kids.viewmodels.AuthViewModel
import com.nova.kids.viewmodels.FriendsViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExploreScreen(authViewModel: AuthViewModel) {
    val friendsViewModel = remember { FriendsViewModel(authViewModel) }
    val friends by friendsViewModel.friends.collectAsState()
    val isLoading by friendsViewModel.isLoading.collectAsState()

    LaunchedEffect(Unit) {
        friendsViewModel.loadFriends()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Explore") },
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
            if (isLoading && friends.isEmpty()) {
                CircularProgressIndicator(
                    modifier = Modifier.align(Alignment.Center),
                    color = CosmicColors.NebulaPurple
                )
            } else if (friends.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(CosmicSpacing.M)
                    ) {
                        Text("👥", fontSize = 60.sp)
                        Text(
                            "No friends yet",
                            fontWeight = FontWeight.Bold,
                            color = CosmicColors.TextPrimary
                        )
                        Text(
                            "Add friends to see their posts!",
                            color = CosmicColors.TextSecondary
                        )
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(CosmicSpacing.M),
                    verticalArrangement = Arrangement.spacedBy(CosmicSpacing.S)
                ) {
                    items(friends) { friend ->
                        FriendRow(friend = friend)
                    }
                }
            }
        }
    }
}

@Composable
fun FriendRow(friend: Friend) {
    Card(
        modifier = Modifier.fillMaxWidth(),
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
            AsyncImage(
                model = friend.avatar,
                contentDescription = "Avatar",
                modifier = Modifier
                    .size(56.dp)
                    .clip(CircleShape)
                    .background(CosmicColors.NebulaPurple),
            )
            Spacer(modifier = Modifier.width(CosmicSpacing.M))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = friend.displayName,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 16.sp,
                    color = CosmicColors.TextPrimary
                )
            }
        }
    }
}

