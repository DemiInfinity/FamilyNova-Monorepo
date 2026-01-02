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
import com.nova.kids.models.Message
import com.nova.kids.viewmodels.AuthViewModel
import com.nova.kids.viewmodels.MessagesViewModel
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun MessagesScreen(authViewModel: AuthViewModel) {
    val messagesViewModel = remember { MessagesViewModel(authViewModel) }
    val conversations by messagesViewModel.conversations.collectAsState()
    val isLoading by messagesViewModel.isLoading.collectAsState()
    var selectedFriend by remember { mutableStateOf<Friend?>(null) }

    LaunchedEffect(Unit) {
        messagesViewModel.loadConversations()
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
        if (selectedFriend != null) {
            ChatScreen(
                friend = selectedFriend!!,
                authViewModel = authViewModel,
                onBack = { selectedFriend = null }
            )
        } else {
            if (isLoading && conversations.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = CosmicColors.NebulaPurple)
                }
            } else if (conversations.isEmpty()) {
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
                            "No messages yet",
                            fontWeight = FontWeight.Bold,
                            fontSize = 20.sp,
                            color = CosmicColors.TextPrimary
                        )
                        Text(
                            "Select a friend to start chatting!",
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
                    items(conversations) { conversation ->
                        ConversationRow(
                            conversation = conversation,
                            onClick = { selectedFriend = conversation.friend }
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun ConversationRow(
    conversation: com.nova.kids.models.Conversation,
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
                model = conversation.friend.avatar,
                contentDescription = "Avatar",
                modifier = Modifier
                    .size(56.dp)
                    .clip(CircleShape)
                    .background(CosmicColors.NebulaPurple),
            )
            
            Spacer(modifier = Modifier.width(CosmicSpacing.M))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = conversation.friend.displayName,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 16.sp,
                    color = CosmicColors.TextPrimary
                )
                conversation.lastMessage?.let {
                    Text(
                        text = it,
                        fontSize = 14.sp,
                        color = CosmicColors.TextSecondary,
                        maxLines = 1
                    )
                }
            }
            
            conversation.timestamp?.let {
                Text(
                    text = formatTime(it),
                    fontSize = 12.sp,
                    color = CosmicColors.TextMuted
                )
            }
        }
    }
}

@Composable
fun ChatScreen(
    friend: Friend,
    authViewModel: AuthViewModel,
    onBack: () -> Unit
) {
    val messagesViewModel = remember { MessagesViewModel(authViewModel) }
    val messages by messagesViewModel.messages.collectAsState()
    var messageText by remember { mutableStateOf("") }
    val isSending by messagesViewModel.isSending.collectAsState()

    LaunchedEffect(friend.id.toString()) {
        messagesViewModel.loadMessages(friend.id.toString())
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(friend.displayName) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = CosmicColors.GlassBackground
                )
            )
        }
    ) { paddingValues ->
        Column(
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
                modifier = Modifier.weight(1f),
                contentPadding = PaddingValues(CosmicSpacing.M),
                verticalArrangement = Arrangement.spacedBy(CosmicSpacing.S),
                reverseLayout = true
            ) {
                items(messages.reversed()) { message ->
                    MessageBubble(message = message, isOwnMessage = message.senderId == authViewModel.currentUser.value?.id)
                }
            }

            Divider()
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(CosmicSpacing.M),
                horizontalArrangement = Arrangement.spacedBy(CosmicSpacing.S),
                verticalAlignment = Alignment.CenterVertically
            ) {
                OutlinedTextField(
                    value = messageText,
                    onValueChange = { messageText = it },
                    modifier = Modifier.weight(1f),
                    placeholder = { Text("Type a message...") },
                    maxLines = 3,
                    shape = RoundedCornerShape(CosmicCornerRadius.Large),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = CosmicColors.NebulaPurple,
                        unfocusedBorderColor = CosmicColors.TextMuted
                    )
                )
                IconButton(
                    onClick = {
                        if (messageText.isNotBlank() && !isSending) {
                            messagesViewModel.sendMessage(friend.id.toString(), messageText)
                            messageText = ""
                        }
                    },
                    enabled = messageText.isNotBlank() && !isSending
                ) {
                    if (isSending) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(24.dp),
                            color = CosmicColors.NebulaPurple
                        )
                    } else {
                        Icon(
                            Icons.Default.Send,
                            "Send",
                            tint = CosmicColors.NebulaPurple
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun MessageBubble(
    message: Message,
    isOwnMessage: Boolean
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = if (isOwnMessage) Arrangement.End else Arrangement.Start
    ) {
        Card(
            modifier = Modifier.widthIn(max = 280.dp),
            shape = RoundedCornerShape(CosmicCornerRadius.Medium),
            colors = CardDefaults.cardColors(
                containerColor = if (isOwnMessage) CosmicColors.NebulaPurple else CosmicColors.GlassBackground
            )
        ) {
            Text(
                text = message.content,
                modifier = Modifier.padding(CosmicSpacing.M),
                color = if (isOwnMessage) CosmicColors.TextPrimary else CosmicColors.TextSecondary,
                fontSize = 14.sp
            )
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
        days > 0 -> "${days}d"
        hours > 0 -> "${hours}h"
        minutes > 0 -> "${minutes}m"
        else -> "now"
    }
}
