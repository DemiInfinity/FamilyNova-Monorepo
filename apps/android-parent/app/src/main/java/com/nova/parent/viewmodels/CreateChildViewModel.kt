package com.nova.parent.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nova.parent.api.ApiInterface
import com.nova.parent.services.ApiService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

class CreateChildViewModel(private val authViewModel: AuthViewModel) : ViewModel() {
    private val api = ApiService.retrofit.create(ApiInterface::class.java)
    
    private val _isCreating = MutableStateFlow(false)
    val isCreating: StateFlow<Boolean> = _isCreating.asStateFlow()
    
    private val _isSuccess = MutableStateFlow(false)
    val isSuccess: StateFlow<Boolean> = _isSuccess.asStateFlow()
    
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()
    
    fun createChild(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        displayName: String?,
        dateOfBirth: Date?,
        school: String?,
        grade: String?
    ) {
        viewModelScope.launch {
            _isCreating.value = true
            _errorMessage.value = null
            _isSuccess.value = false
            
            val token = authViewModel.getValidatedToken() ?: run {
                _errorMessage.value = "Not authenticated"
                _isCreating.value = false
                return@launch
            }
            
            try {
                val dateOfBirthStr = dateOfBirth?.let {
                    val formatter = SimpleDateFormat("yyyy-MM-dd", Locale.US)
                    formatter.format(it)
                }
                
                val request = com.nova.parent.api.CreateChildRequest(
                    email = email,
                    password = password,
                    firstName = firstName,
                    lastName = lastName,
                    displayName = displayName,
                    dateOfBirth = dateOfBirthStr,
                    school = school,
                    grade = grade
                )
                
                val response = api.createChild("Bearer $token", request)
                if (response.isSuccessful && response.body() != null) {
                    _isSuccess.value = true
                } else {
                    _errorMessage.value = "Failed to create child: ${response.message()}"
                }
            } catch (e: Exception) {
                _errorMessage.value = "Error: ${e.message}"
            } finally {
                _isCreating.value = false
            }
        }
    }
}

