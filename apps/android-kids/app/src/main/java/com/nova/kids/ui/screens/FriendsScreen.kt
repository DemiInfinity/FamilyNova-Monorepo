package com.nova.kids.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import com.nova.kids.models.Friend
import com.nova.kids.viewmodels.AuthViewModel
import com.nova.kids.viewmodels.FriendsViewModel

@Composable
fun FriendsScreen(
    authViewModel: AuthViewModel,
    onFriendClick: (Friend) -> Unit = {}
) {
    val friendsViewModel = remember { FriendsViewModel(authViewModel) }
    val friends by friendsViewModel.friends.collectAsState()
    val isLoading by friendsViewModel.isLoading.collectAsState()
    var searchText by remember { mutableStateOf("") }

    LaunchedEffect(Unit) {
        friendsViewModel.loadFriends()
    }

    val filteredFriends = friends.filter { friend ->
        searchText.isEmpty() || friend.displayName.contains(searchText, ignoreCase = true)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Friends") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = CosmicColors.GlassBackground
                )
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { /* TODO: Open add friend screen */ },
                containerColor = CosmicColors.NebulaPurple
            ) {
                Icon(Icons.Default.PersonAdd, "Add Friend")
            }
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
                modifier = Modifier.fillMaxSize()
            ) {
                // Search bar
                OutlinedTextField(
                    value = searchText,
                    onValueChange = { searchText = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(CosmicSpacing.M),
                    placeholder = { Text("Search friends...") },
                    leadingIcon = { Icon(Icons.Default.Search, "Search") },
                    trailingIcon = {
                        if (searchText.isNotEmpty()) {
                            IconButton(onClick = { searchText = "" }) {
                                Icon(Icons.Default.Clear, "Clear")
                            }
                        }
                    },
                    shape = RoundedCornerShape(CosmicCornerRadius.Large),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CosmicColors.NebulaPurple,
                        unfocusedBorderColor = CosmicColors.TextMuted
                    )
                )

                // Friends list
                if (isLoading && friends.isEmpty()) {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = CosmicColors.NebulaPurple)
                    }
                } else if (filteredFriends.isEmpty()) {
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
                                if (searchText.isNotEmpty()) "No friends found" else "No friends yet",
                                fontWeight = FontWeight.Bold,
                                color = CosmicColors.TextPrimary
                            )
                            Text(
                                if (searchText.isNotEmpty()) "Try a different search" else "Add friends to get started!",
                                color = CosmicColors.TextSecondary
                            )
                        }
                    }
                } else {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(horizontal = CosmicSpacing.M),
                        verticalArrangement = Arrangement.spacedBy(CosmicSpacing.S)
                    ) {
                        items(filteredFriends) { friend ->
                            FriendCard(
                                friend = friend,
                                onClick = { onFriendClick(friend) }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun FriendCard(
    friend: Friend,
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
                if (friend.isVerified) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(CosmicSpacing.XS)
                    ) {
                        Icon(
                            Icons.Default.Verified,
                            "Verified",
                            modifier = Modifier.size(16.dp),
                            tint = CosmicColors.NebulaPurple
                        )
                        Text(
                            "Verified",
                            fontSize = 12.sp,
                            color = CosmicColors.TextSecondary
                        )
                    }
                }
            }
            IconButton(onClick = { /* TODO: Open friend options */ }) {
                Icon(Icons.Default.MoreVert, "More")
            }
        }
    }
}

