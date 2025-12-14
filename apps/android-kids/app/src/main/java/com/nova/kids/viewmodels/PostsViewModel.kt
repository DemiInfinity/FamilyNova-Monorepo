package com.nova.kids.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nova.kids.api.ApiInterface
import com.nova.kids.models.Post
import com.nova.kids.services.ApiService
import com.nova.kids.services.DataManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

class PostsViewModel(private val authViewModel: AuthViewModel) : ViewModel() {
    private val api = ApiService.retrofit.create(ApiInterface::class.java)
    
    private val _posts = MutableStateFlow<List<Post>>(emptyList())
    val posts: StateFlow<List<Post>> = _posts.asStateFlow()
    
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()
    
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
    
    fun loadPosts(userId: String? = null) {
        viewModelScope.launch {
            _isLoading.value = true
            
            // Try to load from cache first
            val cachedPosts = DataManager.getCachedPosts(userId)
            if (cachedPosts != null && cachedPosts.isNotEmpty()) {
                _posts.value = cachedPosts
            }
            
            val token = authViewModel.getValidatedToken() ?: return@launch
            val authHeader = "Bearer $token"
            
            try {
                val response = api.getPosts(authHeader, userId)
                if (response.isSuccessful && response.body() != null) {
                    val postsData = response.body()!!.posts
                    val currentUserId = authViewModel.currentUser.value?.id
                    
                    val posts = postsData.mapNotNull { postData ->
                        try {
                            val createdAt = dateFormat.parse(postData.createdAt) ?: Date()
                            val isLiked = postData.likes?.contains(currentUserId ?: "") ?: false
                            
                            Post(
                                id = UUID.fromString(postData.id),
                                author = postData.author.profile.displayName ?: "Unknown",
                                authorId = postData.author.id,
                                authorAvatar = postData.author.profile.avatar,
                                content = postData.content,
                                imageUrl = postData.imageUrl,
                                likes = postData.likes?.size ?: 0,
                                comments = postData.comments?.size ?: 0,
                                createdAt = createdAt,
                                isLiked = isLiked
                            )
                        } catch (e: Exception) {
                            null
                        }
                    }
                    
                    _posts.value = posts
                    DataManager.cachePosts(posts, userId)
                }
            } catch (e: Exception) {
                // Error handling
            } finally {
                _isLoading.value = false
            }
        }
    }
}

