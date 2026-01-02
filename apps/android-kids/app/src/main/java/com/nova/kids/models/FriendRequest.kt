package com.nova.kids.models

import java.util.Date
import java.util.UUID

data class FriendRequest(
    val id: UUID,
    val fromUserId: String,
    val toUserId: String,
    val status: String,
    val createdAt: Date
)

