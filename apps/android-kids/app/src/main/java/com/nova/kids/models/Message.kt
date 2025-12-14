package com.nova.kids.models

import java.util.Date
import java.util.UUID

data class Message(
    val id: UUID,
    val senderId: String,
    val receiverId: String,
    val content: String,
    val timestamp: Date
)

data class Conversation(
    val friend: Friend,
    val lastMessage: String?,
    val timestamp: Date?
)

