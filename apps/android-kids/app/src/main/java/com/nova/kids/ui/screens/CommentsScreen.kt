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
import com.nova.kids.viewmodels.AuthViewModel
import com.nova.kids.viewmodels.CommentsViewModel
import java.text.SimpleDateFormat
import java.util.*

data class Comment(
    val id: String,
    val author: String,
    val content: String,
    val createdAt: Date
)

@Composable
fun CommentsScreen(
    post: Post,
    authViewModel: AuthViewModel,
    onDismiss: () -> Unit
) {
    val commentsViewModel = remember { CommentsViewModel(authViewModel, post.id.toString()) }
    val comments by commentsViewModel.comments.collectAsState()
    val isLoading by commentsViewModel.isLoading.collectAsState()
    var newComment by remember { mutableStateOf("") }
    val isPosting by commentsViewModel.isPosting.collectAsState()

    LaunchedEffect(Unit) {
        commentsViewModel.loadComments()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Comments") },
                navigationIcon = {
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.ArrowBack, "Back")
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
                modifier = Modifier.fillMaxSize()
            ) {
                // Post Preview
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(CosmicSpacing.M),
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
                            model = post.authorAvatar,
                            contentDescription = "Avatar",
                            modifier = Modifier
                                .size(40.dp)
                                .clip(CircleShape)
                                .background(CosmicColors.NebulaPurple),
                        )
                        Spacer(modifier = Modifier.width(CosmicSpacing.M))
                        Column {
                            Text(
                                text = post.author,
                                fontWeight = FontWeight.SemiBold,
                                color = CosmicColors.TextPrimary
                            )
                            Text(
                                text = post.content.take(50) + if (post.content.length > 50) "..." else "",
                                fontSize = 12.sp,
                                color = CosmicColors.TextSecondary,
                                maxLines = 2
                            )
                        }
                    }
                }

                // Comments List
                if (isLoading && comments.isEmpty()) {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = CosmicColors.NebulaPurple)
                    }
                } else if (comments.isEmpty()) {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(CosmicSpacing.M)
                        ) {
                            Text("💬", fontSize = 60.sp)
                            Text(
                                "No comments yet",
                                fontWeight = FontWeight.Bold,
                                color = CosmicColors.TextPrimary
                            )
                            Text(
                                "Be the first to comment!",
                                color = CosmicColors.TextSecondary
                            )
                        }
                    }
                } else {
                    LazyColumn(
                        modifier = Modifier.weight(1f),
                        contentPadding = PaddingValues(CosmicSpacing.M),
                        verticalArrangement = Arrangement.spacedBy(CosmicSpacing.M)
                    ) {
                        items(comments) { comment ->
                            CommentRow(comment = comment)
                        }
                    }
                }

                // Comment Input
                Divider()
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(CosmicSpacing.M),
                    horizontalArrangement = Arrangement.spacedBy(CosmicSpacing.S),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedTextField(
                        value = newComment,
                        onValueChange = { newComment = it },
                        modifier = Modifier.weight(1f),
                        placeholder = { Text("Add a comment...") },
                        maxLines = 3,
                        shape = RoundedCornerShape(CosmicCornerRadius.Large),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = CosmicColors.NebulaPurple,
                            unfocusedBorderColor = CosmicColors.TextMuted
                        )
                    )
                    IconButton(
                        onClick = {
                            if (newComment.isNotBlank() && !isPosting) {
                                commentsViewModel.postComment(newComment)
                                newComment = ""
                            }
                        },
                        enabled = newComment.isNotBlank() && !isPosting
                    ) {
                        if (isPosting) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(24.dp),
                                color = CosmicColors.NebulaPurple
                            )
                        } else {
                            Icon(
                                Icons.Default.Send,
                                "Send",
                                tint = if (newComment.isNotBlank()) CosmicColors.NebulaPurple else CosmicColors.TextMuted
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun CommentRow(comment: Comment) {
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
            verticalAlignment = Alignment.Top
        ) {
            Circle()
                .fill(CosmicColors.NebulaPurple)
                .size(32.dp)
            
            Spacer(modifier = Modifier.width(CosmicSpacing.S))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = comment.author,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 14.sp,
                    color = CosmicColors.TextPrimary
                )
                Text(
                    text = comment.content,
                    fontSize = 14.sp,
                    color = CosmicColors.TextSecondary,
                    modifier = Modifier.padding(top = 4.dp)
                )
                Text(
                    text = formatDate(comment.createdAt),
                    fontSize = 12.sp,
                    color = CosmicColors.TextMuted,
                    modifier = Modifier.padding(top = 4.dp)
                )
            }
        }
    }
}

private fun formatDate(date: Date): String {
    val now = Date()
    val diff = now.time - date.time
    val seconds = diff / 1000
    val minutes = seconds / 60
    val hours = minutes / 60
    val days = hours / 24
    
    return when {
        days > 0 -> "${days}d ago"
        hours > 0 -> "${hours}h ago"
        minutes > 0 -> "${minutes}m ago"
        else -> "Just now"
    }
}

