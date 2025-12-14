package com.nova.kids.models

import java.util.UUID

data class Friend(
    val id: UUID,
    val displayName: String,
    val avatar: String?,
    val isVerified: Boolean
)

