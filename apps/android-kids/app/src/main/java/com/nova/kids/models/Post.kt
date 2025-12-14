package com.nova.kids.models

import java.util.Date
import java.util.UUID

data class Post(
    val id: UUID,
    val author: String,
    val authorId: String,
    val authorAvatar: String?,
    val content: String,
    val imageUrl: String?,
    val likes: Int,
    val comments: Int,
    val createdAt: Date,
    val isLiked: Boolean
) {
    companion object {
        fun fromApiData(
            id: String,
            author: String,
            authorId: String,
            authorAvatar: String?,
            content: String,
            imageUrl: String?,
            likes: Int,
            comments: Int,
            createdAt: Date,
            isLiked: Boolean
        ): Post {
            return Post(
                id = try { UUID.fromString(id) } catch (e: Exception) { UUID.randomUUID() },
                author = author,
                authorId = authorId,
                authorAvatar = authorAvatar,
                content = content,
                imageUrl = imageUrl,
                likes = likes,
                comments = comments,
                createdAt = createdAt,
                isLiked = isLiked
            )
        }
    }
}

