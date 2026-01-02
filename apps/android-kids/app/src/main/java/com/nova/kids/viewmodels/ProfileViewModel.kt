package com.nova.kids.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nova.kids.api.ApiInterface
import com.nova.kids.models.Post
import com.nova.kids.services.ApiService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

data class ProfileData(
    val id: String,
    val email: String,
    val displayName: String,
    val avatarUrl: String?,
    val bannerUrl: String?,
    val friendsCount: Int
)

class ProfileViewModel(
    private val authViewModel: AuthViewModel,
    private val userId: String? = null
) : ViewModel() {
    private val api: ApiInterface = ApiService.retrofit.create(ApiInterface::class.java)

    private val _profile = MutableStateFlow<ProfileData?>(null)
    val profile: StateFlow<ProfileData?> = _profile.asStateFlow()

    private val _posts = MutableStateFlow<List<Post>>(emptyList())
    val posts: StateFlow<List<Post>> = _posts.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    fun loadProfile() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val token = authViewModel.token.value ?: return@launch
                val targetUserId = userId ?: authViewModel.currentUser.value?.id ?: return@launch
                
                val response = api.getProfile("Bearer $token")
                if (response.isSuccessful && response.body() != null) {
                    val profileData = response.body()!!.user
                    _profile.value = ProfileData(
                        id = profileData.id,
                        email = profileData.email,
                        displayName = profileData.profile.displayName ?: profileData.email,
                        avatarUrl = profileData.profile.avatar,
                        bannerUrl = profileData.profile.banner,
                        friendsCount = 0 // TODO: Get from friends endpoint
                    )
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun loadPosts() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val token = authViewModel.token.value ?: return@launch
                val targetUserId = userId ?: authViewModel.currentUser.value?.id ?: return@launch
                
                val response = api.getPosts("Bearer $token", targetUserId)
                if (response.isSuccessful && response.body() != null) {
                    val postsData = response.body()!!.posts
                    val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
                    
                    val postsList = postsData.mapNotNull { postData ->
                        try {
                            Post(
                                id = UUID.fromString(postData.id),
                                author = postData.author.profile.displayName ?: "Unknown",
                                authorId = postData.author.id,
                                authorAvatar = postData.author.profile.avatar,
                                content = postData.content,
                                imageUrl = postData.imageUrl,
                                likes = postData.likes?.size ?: 0,
                                comments = postData.comments?.size ?: 0,
                                createdAt = dateFormat.parse(postData.createdAt) ?: Date(),
                                isLiked = false
                            )
                        } catch (e: Exception) {
                            null
                        }
                    }
                    
                    _posts.value = postsList
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                _isLoading.value = false
            }
        }
    }
}

