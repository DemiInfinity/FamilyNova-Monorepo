package com.nova.kids.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.draw.clip
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.nova.kids.design.CosmicColors
import com.nova.kids.design.CosmicCornerRadius
import com.nova.kids.design.CosmicSpacing
import com.nova.kids.viewmodels.AuthViewModel
import com.nova.kids.viewmodels.CreatePostViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreatePostScreen(authViewModel: AuthViewModel) {
    val createPostViewModel = remember { CreatePostViewModel(authViewModel) }
    var content by remember { mutableStateOf("") }
    var imageUrl by remember { mutableStateOf<String?>(null) }
    val isPosting by createPostViewModel.isPosting.collectAsState()
    val isSuccess by createPostViewModel.isSuccess.collectAsState()

    LaunchedEffect(isSuccess) {
        if (isSuccess) {
            content = ""
            imageUrl = null
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Create Post") },
                actions = {
                    TextButton(
                        onClick = {
                            if (content.isNotBlank() && !isPosting) {
                                createPostViewModel.createPost(content, imageUrl)
                            }
                        },
                        enabled = content.isNotBlank() && !isPosting
                    ) {
                        if (isPosting) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(16.dp),
                                color = CosmicColors.NebulaPurple
                            )
                        } else {
                            Text("Post", color = CosmicColors.NebulaPurple)
                        }
                    }
                },
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
                    .padding(CosmicSpacing.M),
                verticalArrangement = Arrangement.spacedBy(CosmicSpacing.M)
            ) {
                    // User info
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(CosmicSpacing.S)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(40.dp)
                                .clip(CircleShape)
                                .background(CosmicColors.NebulaPurple)
                        )
                        Text(
                            text = authViewModel.currentUser.value?.email ?: "You",
                            fontWeight = FontWeight.SemiBold,
                            color = CosmicColors.TextPrimary
                        )
                    }

                // Content input
                OutlinedTextField(
                    value = content,
                    onValueChange = { content = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                    placeholder = { Text("What's on your mind?") },
                    maxLines = 10,
                    shape = RoundedCornerShape(CosmicCornerRadius.Medium),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CosmicColors.NebulaPurple,
                        unfocusedBorderColor = CosmicColors.TextMuted
                    )
                )

                // Image preview
                imageUrl?.let { url ->
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(CosmicCornerRadius.Medium)
                    ) {
                        Box {
                            AsyncImage(
                                model = url,
                                contentDescription = "Post image",
                                modifier = Modifier.fillMaxWidth()
                            )
                            IconButton(
                                onClick = { imageUrl = null },
                                modifier = Modifier.align(Alignment.TopEnd)
                            ) {
                                Icon(Icons.Default.Close, "Remove", tint = CosmicColors.TextPrimary)
                            }
                        }
                    }
                }

                // Image picker button (placeholder - would need actual image picker)
                OutlinedButton(
                    onClick = { /* TODO: Open image picker */ },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(Icons.Default.Image, "Add Image")
                    Spacer(modifier = Modifier.width(CosmicSpacing.S))
                    Text("Add Image")
                }
            }
        }
    }
}
