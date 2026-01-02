package com.nova.kids.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.nova.kids.design.CosmicColors
import com.nova.kids.design.CosmicCornerRadius
import com.nova.kids.design.CosmicSpacing
import com.nova.kids.models.Post
import com.nova.kids.viewmodels.AuthViewModel
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun CosmicPostCard(
    post: Post,
    authViewModel: AuthViewModel,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(CosmicCornerRadius.Large),
        colors = CardDefaults.cardColors(
            containerColor = CosmicColors.GlassBackground
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(CosmicSpacing.M)
        ) {
            // Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Avatar
                AsyncImage(
                    model = post.authorAvatar,
                    contentDescription = "Avatar",
                    modifier = Modifier
                        .size(50.dp)
                        .clip(CircleShape)
                        .background(CosmicColors.NebulaPurple),
                    contentScale = ContentScale.Crop
                )
                
                Spacer(modifier = Modifier.width(CosmicSpacing.M))
                
                Column {
                    Text(
                        text = post.author,
                        color = CosmicColors.TextPrimary,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        text = formatDate(post.createdAt),
                        color = CosmicColors.TextMuted,
                        fontSize = 12.sp
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(CosmicSpacing.M))
            
            // Content
            if (post.content.isNotBlank()) {
                Text(
                    text = post.content,
                    color = CosmicColors.TextSecondary,
                    fontSize = 14.sp,
                    modifier = Modifier.padding(vertical = CosmicSpacing.S)
                )
            }
            
            // Image
            post.imageUrl?.let { imageUrl ->
                AsyncImage(
                    model = imageUrl,
                    contentDescription = "Post image",
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(200.dp)
                        .clip(RoundedCornerShape(CosmicCornerRadius.Medium)),
                    contentScale = ContentScale.Crop
                )
            }
            
            Spacer(modifier = Modifier.height(CosmicSpacing.M))
            
            // Actions
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row {
                    IconButton(onClick = { /* Like */ }) {
                        Icon(
                            imageVector = if (post.isLiked) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                            contentDescription = "Like",
                            tint = if (post.isLiked) CosmicColors.CometPink else CosmicColors.TextMuted
                        )
                    }
                    Text(
                        text = "${post.likes}",
                        color = CosmicColors.TextMuted,
                        modifier = Modifier.align(Alignment.CenterVertically)
                    )
                }
                
                var showComments by remember { mutableStateOf(false) }
                
                Row {
                    IconButton(onClick = { showComments = true }) {
                        Icon(
                            imageVector = Icons.Default.Comment,
                            contentDescription = "Comment",
                            tint = CosmicColors.TextMuted
                        )
                    }
                    Text(
                        text = "${post.comments}",
                        color = CosmicColors.TextMuted,
                        modifier = Modifier.align(Alignment.CenterVertically)
                    )
                }
                
                if (showComments) {
                    // Navigate to comments screen - this would need navigation context
                    // For now, we'll handle this in the parent composable
                }
                
                IconButton(onClick = { /* Share */ }) {
                    Icon(
                        imageVector = Icons.Default.Share,
                        contentDescription = "Share",
                        tint = CosmicColors.TextMuted
                    )
                }
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

