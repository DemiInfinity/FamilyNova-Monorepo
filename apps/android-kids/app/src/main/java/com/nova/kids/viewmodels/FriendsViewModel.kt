package com.nova.kids.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nova.kids.api.ApiInterface
import com.nova.kids.models.Friend
import com.nova.kids.services.ApiService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.*

class FriendsViewModel(private val authViewModel: AuthViewModel) : ViewModel() {
    private val api: ApiInterface = ApiService.retrofit.create(ApiInterface::class.java)

    private val _friends = MutableStateFlow<List<Friend>>(emptyList())
    val friends: StateFlow<List<Friend>> = _friends.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    fun loadFriends() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val token = authViewModel.token.value ?: return@launch
                
                val response = api.getFriends("Bearer $token")
                if (response.isSuccessful && response.body() != null) {
                    val friendsList = response.body()!!.friends.map { friendData ->
                        Friend(
                            id = UUID.fromString(friendData.id),
                            displayName = friendData.profile.displayName ?: "Unknown",
                            avatar = friendData.profile.avatar,
                            isVerified = false
                        )
                    }
                    
                    _friends.value = friendsList
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                _isLoading.value = false
            }
        }
    }
}

