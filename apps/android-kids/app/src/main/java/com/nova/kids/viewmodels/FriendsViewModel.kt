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
    
    private val _searchResults = MutableStateFlow<List<Friend>>(emptyList())
    val searchResults: StateFlow<List<Friend>> = _searchResults.asStateFlow()
    
    private val _isSearching = MutableStateFlow(false)
    val isSearching: StateFlow<Boolean> = _isSearching.asStateFlow()

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
    
    fun searchFriends(query: String) {
        viewModelScope.launch {
            _isSearching.value = true
            try {
                // TODO: Implement actual search API call using authViewModel.token
                // For now, filter local friends
                val results = _friends.value.filter { friend ->
                    friend.displayName.contains(query, ignoreCase = true)
                }
                _searchResults.value = results
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                _isSearching.value = false
            }
        }
    }
    
    fun addFriendByCode(code: String, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            try {
                val token = authViewModel.token.value ?: return@launch
                
                val request = com.nova.kids.api.AddFriendByCodeRequest(code = code.uppercase())
                val response = api.addFriendByCode("Bearer $token", request)
                if (response.isSuccessful && response.body() != null) {
                    // Reload friends list
                    loadFriends()
                    onResult(true)
                } else {
                    onResult(false)
                }
            } catch (e: Exception) {
                e.printStackTrace()
                onResult(false)
            }
        }
    }
    
    fun getMyFriendCode(onResult: (String?) -> Unit) {
        viewModelScope.launch {
            try {
                val token = authViewModel.token.value ?: return@launch
                
                val response = api.getMyFriendCode("Bearer $token")
                if (response.isSuccessful && response.body() != null) {
                    onResult(response.body()!!.code)
                } else {
                    onResult(null)
                }
            } catch (e: Exception) {
                e.printStackTrace()
                onResult(null)
            }
        }
    }
}

