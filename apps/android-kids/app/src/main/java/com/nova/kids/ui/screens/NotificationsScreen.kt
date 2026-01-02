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
import com.nova.kids.design.CosmicColors
import com.nova.kids.design.CosmicCornerRadius
import com.nova.kids.design.CosmicSpacing
import com.nova.kids.viewmodels.AuthViewModel
import java.text.SimpleDateFormat
import java.util.*

data class Notification(
    val id: String,
    val type: NotificationType,
    val title: String,
    val message: String,
    val timestamp: Date,
    val isRead: Boolean,
    val metadata: Map<String, String> = emptyMap()
)

enum class NotificationType {
    MESSAGE, FRIEND_REQUEST, POST_LIKE, POST_COMMENT, FRIEND_ACCEPTED
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
@Suppress("UNUSED_PARAMETER")
fun NotificationsScreen(authViewModel: AuthViewModel) { // Reserved for loading notifications from API
    // TODO: Load from ViewModel or DataManager
    val notifications = remember { mutableStateListOf<Notification>() }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Notifications") },
                actions = {
                    if (notifications.isNotEmpty()) {
                        TextButton(onClick = { /* TODO: Mark all as read */ }) {
                            Text("Mark all read", color = CosmicColors.NebulaPurple)
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
            if (notifications.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(CosmicSpacing.M)
                    ) {
                        Text("🔔", fontSize = 60.sp)
                        Text(
                            "No notifications",
                            fontWeight = FontWeight.Bold,
                            color = CosmicColors.TextPrimary
                        )
                        Text(
                            "You're all caught up!",
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
                    items(notifications) { notification ->
                        NotificationCard(notification = notification)
                    }
                }
            }
        }
    }
}

@Composable
fun NotificationCard(notification: Notification) {
    val icon = when (notification.type) {
        NotificationType.MESSAGE -> Icons.Default.Message
        NotificationType.FRIEND_REQUEST -> Icons.Default.PersonAdd
        NotificationType.POST_LIKE -> Icons.Default.Favorite
        NotificationType.POST_COMMENT -> Icons.Default.Comment
        NotificationType.FRIEND_ACCEPTED -> Icons.Default.CheckCircle
    }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(CosmicCornerRadius.Medium),
        colors = CardDefaults.cardColors(
            containerColor = if (notification.isRead) 
                CosmicColors.GlassBackground 
            else 
                CosmicColors.GlassBackground.copy(alpha = 0.7f)
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(CosmicSpacing.M),
            verticalAlignment = Alignment.Top
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(CosmicColors.NebulaPurple),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    icon,
                    contentDescription = null,
                    tint = CosmicColors.TextPrimary,
                    modifier = Modifier.size(24.dp)
                )
            }
            Spacer(modifier = Modifier.width(CosmicSpacing.M))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = notification.title,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 14.sp,
                    color = CosmicColors.TextPrimary
                )
                Text(
                    text = notification.message,
                    fontSize = 12.sp,
                    color = CosmicColors.TextSecondary,
                    modifier = Modifier.padding(top = 4.dp)
                )
                Text(
                    text = formatTime(notification.timestamp),
                    fontSize = 10.sp,
                    color = CosmicColors.TextMuted,
                    modifier = Modifier.padding(top = 4.dp)
                )
            }
            if (!notification.isRead) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(CosmicColors.NebulaPurple)
                )
            }
        }
    }
}

private fun formatTime(date: Date): String {
    val now = Date()
    val diff = now.time - date.time
    val minutes = diff / 60000
    val hours = minutes / 60
    val days = hours / 24

    return when {
        days > 0 -> "${days}d ago"
        hours > 0 -> "${hours}h ago"
        minutes > 0 -> "${minutes}m ago"
        else -> "Just now"
    }
}

