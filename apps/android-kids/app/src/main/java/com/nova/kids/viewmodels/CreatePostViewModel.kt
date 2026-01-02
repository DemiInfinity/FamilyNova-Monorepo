package com.nova.kids.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nova.kids.api.ApiInterface
import com.nova.kids.services.ApiService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class CreatePostViewModel(private val authViewModel: AuthViewModel) : ViewModel() {
    private val api: ApiInterface = ApiService.retrofit.create(ApiInterface::class.java)

    private val _isPosting = MutableStateFlow(false)
    val isPosting: StateFlow<Boolean> = _isPosting.asStateFlow()

    private val _isSuccess = MutableStateFlow(false)
    val isSuccess: StateFlow<Boolean> = _isSuccess.asStateFlow()

    fun createPost(content: String, imageUrl: String?) {
        viewModelScope.launch {
            _isPosting.value = true
            _isSuccess.value = false
            try {
                val token = authViewModel.token.value ?: return@launch
                
                val response = api.createPost(
                    "Bearer $token",
                    com.nova.kids.api.CreatePostRequest(content.trim(), imageUrl)
                )
                
                if (response.isSuccessful) {
                    _isSuccess.value = true
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                _isPosting.value = false
            }
        }
    }
}

