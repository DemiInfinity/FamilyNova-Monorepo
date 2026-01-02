package com.nova.kids.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nova.kids.api.ApiInterface
import com.nova.kids.services.ApiService
import com.nova.kids.models.Comment
import com.nova.kids.services.DataManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

class CommentsViewModel(
    private val authViewModel: AuthViewModel,
    private val postId: String
) : ViewModel() {
    private val api: ApiInterface = com.nova.kids.services.ApiService.retrofit.create(ApiInterface::class.java)
    private val dataManager = DataManager

    private val _comments = MutableStateFlow<List<Comment>>(emptyList())
    val comments: StateFlow<List<Comment>> = _comments.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _isPosting = MutableStateFlow(false)
    val isPosting: StateFlow<Boolean> = _isPosting.asStateFlow()

    fun loadComments() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val token = authViewModel.token.value ?: return@launch
                
                // Get posts by author to find the post with comments
                val response = api.getPosts("Bearer $token", null)
                
                if (response.isSuccessful && response.body() != null) {
                    val posts = response.body()!!.posts
                    val post = posts.find { it.id == postId }
                    
                    if (post != null) {
                        val commentsList = post.comments?.map { commentData ->
                            Comment(
                                id = commentData.id,
                                author = commentData.author?.profile?.displayName ?: "Unknown",
                                content = commentData.content,
                                createdAt = parseDate(commentData.createdAt) ?: Date()
                            )
                        } ?: emptyList()
                        
                        _comments.value = commentsList.sortedByDescending { it.createdAt }
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun postComment(content: String) {
        viewModelScope.launch {
            _isPosting.value = true
            try {
                val token = authViewModel.token.value ?: return@launch
                
                val response = api.commentOnPost(
                    "Bearer $token",
                    postId,
                    com.nova.kids.api.CommentRequest(content.trim())
                )
                
                if (response.isSuccessful && response.body() != null) {
                    val commentData = response.body()!!.comment
                    val newComment = Comment(
                        id = commentData.id,
                        author = commentData.author?.profile?.displayName ?: "You",
                        content = commentData.content,
                        createdAt = parseDate(commentData.createdAt) ?: Date()
                    )
                    
                    _comments.value = (listOf(newComment) + _comments.value).sortedByDescending { it.createdAt }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                _isPosting.value = false
            }
        }
    }

    private fun parseDate(dateString: String): Date? {
        return try {
            val formats = listOf(
                SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US),
                SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US)
            )
            formats.forEach { format ->
                format.timeZone = TimeZone.getTimeZone("UTC")
                try {
                    return format.parse(dateString)
                } catch (e: Exception) {
                    // Try next format
                }
            }
            null
        } catch (e: Exception) {
            null
        }
    }
}

