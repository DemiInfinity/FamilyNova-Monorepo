package com.nova.parent.models

data class User(
    val id: String,
    val email: String,
    val displayName: String,
    val profile: UserProfile,
    val userType: String // "parent" or "kid"
)

data class UserProfile(
    val firstName: String?,
    val lastName: String?,
    val displayName: String?,
    val avatar: String?,
    val banner: String?,
    val school: String?,
    val grade: String?
)

data class Child(
    val id: String,
    val email: String,
    val profile: ChildProfile,
    val verification: VerificationStatus,
    val lastLogin: String?
)

data class ChildProfile(
    val firstName: String?,
    val lastName: String?,
    val displayName: String?,
    val avatar: String?,
    val school: String?,
    val grade: String?
)

data class VerificationStatus(
    val parentVerified: Boolean?,
    val schoolVerified: Boolean?
)

data class Post(
    val id: String,
    val content: String,
    val imageUrl: String?,
    val status: String, // "pending", "approved", "rejected"
    val author: Author,
    val likes: List<String>?,
    val comments: List<Comment>?,
    val createdAt: String
)

data class Author(
    val id: String,
    val profile: AuthorProfile
)

data class AuthorProfile(
    val displayName: String?,
    val avatar: String?
)

data class Comment(
    val id: String,
    val content: String,
    val author: Author,
    val createdAt: String
)

data class Message(
    val id: String,
    val senderId: String,
    val receiverId: String,
    val content: String,
    val createdAt: String
)

