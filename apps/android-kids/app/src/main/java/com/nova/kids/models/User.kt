package com.nova.kids.models

data class User(
    val id: String,
    val email: String,
    val displayName: String,
    val profile: UserProfile,
    val verification: VerificationStatus
)

data class UserProfile(
    val firstName: String,
    val lastName: String,
    val displayName: String,
    val avatar: String?,
    val school: String?,
    val grade: String?
)

data class VerificationStatus(
    val parentVerified: Boolean,
    val schoolVerified: Boolean
)

