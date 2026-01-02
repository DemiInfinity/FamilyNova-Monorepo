package com.nova.kids.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.unit.dp
import com.nova.kids.design.CosmicColors
import com.nova.kids.design.CosmicSpacing
import com.nova.kids.ui.components.CosmicPostCard
import com.nova.kids.viewmodels.AuthViewModel
import com.nova.kids.viewmodels.PostsViewModel

@Composable
fun HomeFeedScreen(
    authViewModel: AuthViewModel,
    onNavigateToComments: (String) -> Unit = {}
) {
    val postsViewModel = remember { PostsViewModel(authViewModel) }
    val posts by postsViewModel.posts.collectAsState()
    val isLoading by postsViewModel.isLoading.collectAsState()
    
    LaunchedEffect(Unit) {
        postsViewModel.loadPosts()
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
            )
    ) {
        if (isLoading && posts.isEmpty()) {
            CircularProgressIndicator(
                modifier = Modifier.align(androidx.compose.ui.Alignment.Center),
                color = CosmicColors.NebulaPurple
            )
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(CosmicSpacing.M),
                verticalArrangement = Arrangement.spacedBy(CosmicSpacing.M)
            ) {
                items(posts) { post ->
                    CosmicPostCard(
                        post = post,
                        authViewModel = authViewModel,
                        onCommentClick = onNavigateToComments
                    )
                }
            }
        }
    }
}

