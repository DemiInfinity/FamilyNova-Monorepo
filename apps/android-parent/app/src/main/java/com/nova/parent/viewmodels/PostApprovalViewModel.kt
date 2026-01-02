package com.nova.parent.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nova.parent.api.ApiInterface
import com.nova.parent.models.Post
import com.nova.parent.models.Author
import com.nova.parent.models.AuthorProfile
import com.nova.parent.services.ApiService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class PostApprovalViewModel(private val authViewModel: AuthViewModel) : ViewModel() {
    private val api = ApiService.retrofit.create(ApiInterface::class.java)
    
    private val _pendingPosts = MutableStateFlow<List<Post>>(emptyList())
    val pendingPosts: StateFlow<List<Post>> = _pendingPosts.asStateFlow()
    
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()
    
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()
    
    fun loadPendingPosts() {
        viewModelScope.launch {
            _isLoading.value = true
            _errorMessage.value = null
            
            val token = authViewModel.getValidatedToken() ?: run {
                _isLoading.value = false
                return@launch
            }
            
            try {
                val response = api.getPendingPosts("Bearer $token")
                if (response.isSuccessful && response.body() != null) {
                    val postsData = response.body()!!.posts
                    _pendingPosts.value = postsData.map { postData ->
                        Post(
                            id = postData.id,
                            content = postData.content,
                            imageUrl = postData.imageUrl,
                            status = postData.status,
                            author = Author(
                                id = postData.author.id,
                                profile = AuthorProfile(
                                    displayName = postData.author.profile.displayName,
                                    avatar = postData.author.profile.avatar
                                )
                            ),
                            likes = postData.likes,
                            comments = postData.comments?.map { commentData ->
                                com.nova.parent.models.Comment(
                                    id = commentData.id,
                                    content = commentData.content,
                                    author = Author(
                                        id = commentData.author.id,
                                        profile = AuthorProfile(
                                            displayName = commentData.author.profile.displayName,
                                            avatar = commentData.author.profile.avatar
                                        )
                                    ),
                                    createdAt = commentData.createdAt
                                )
                            },
                            createdAt = postData.createdAt
                        )
                    }
                } else {
                    _errorMessage.value = "Failed to load posts: ${response.message()}"
                }
            } catch (e: Exception) {
                _errorMessage.value = "Error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun approvePost(postId: String) {
        viewModelScope.launch {
            val token = authViewModel.getValidatedToken() ?: return@launch
            
            try {
                val response = api.approvePost("Bearer $token", postId)
                if (response.isSuccessful) {
                    // Reload posts
                    loadPendingPosts()
                }
            } catch (e: Exception) {
                _errorMessage.value = "Error approving post: ${e.message}"
            }
        }
    }
    
    fun rejectPost(postId: String, reason: String? = null) {
        viewModelScope.launch {
            val token = authViewModel.getValidatedToken() ?: return@launch
            
            try {
                val response = api.rejectPost("Bearer $token", postId, com.nova.parent.api.RejectPostRequest(reason))
                if (response.isSuccessful) {
                    // Reload posts
                    loadPendingPosts()
                }
            } catch (e: Exception) {
                _errorMessage.value = "Error rejecting post: ${e.message}"
            }
        }
    }
}

