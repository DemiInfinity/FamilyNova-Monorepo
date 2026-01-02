package com.nova.parent.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nova.parent.api.ApiInterface
import com.nova.parent.models.User
import com.nova.parent.models.UserProfile
import com.nova.parent.services.ApiService
import com.nova.parent.services.DataManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class AuthViewModel : ViewModel() {
    private val api = ApiService.retrofit.create(ApiInterface::class.java)
    private val dataManager = DataManager
    
    private val _isAuthenticated = MutableStateFlow(false)
    val isAuthenticated: StateFlow<Boolean> = _isAuthenticated.asStateFlow()
    
    private val _currentUser = MutableStateFlow<User?>(null)
    val currentUser: StateFlow<User?> = _currentUser.asStateFlow()
    
    private val _token = MutableStateFlow<String?>(null)
    val token: StateFlow<String?> = _token.asStateFlow()
    
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()
    
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()
    
    init {
        viewModelScope.launch {
            try {
                var attempts = 0
                while (!dataManager.isInitialized() && attempts < 10) {
                    kotlinx.coroutines.delay(50)
                    attempts++
                }
                
                if (dataManager.isInitialized()) {
                    val savedToken = dataManager.getToken()
                    if (savedToken != null && savedToken.isNotBlank()) {
                        _token.value = savedToken
                        _isAuthenticated.value = true
                        loadUserProfile()
                    }
                }
            } catch (e: Exception) {
                android.util.Log.e("AuthViewModel", "Error loading saved token: ${e.message}", e)
            }
        }
    }
    
    fun login(email: String, password: String) {
        viewModelScope.launch {
            _isLoading.value = true
            _errorMessage.value = null
            
            try {
                val response = api.login(com.nova.parent.api.LoginRequest(email, password))
                if (response.isSuccessful && response.body() != null) {
                    val loginResponse = response.body()!!
                    val accessToken = loginResponse.session?.access_token ?: ""
                    
                    _token.value = accessToken
                    _isAuthenticated.value = true
                    dataManager.saveToken(accessToken)
                    dataManager.saveUserId(loginResponse.user.id)
                    
                    loadUserProfile()
                } else {
                    _errorMessage.value = "Login failed: ${response.message()}"
                }
            } catch (e: Exception) {
                _errorMessage.value = "Error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun register(email: String, password: String, firstName: String, lastName: String) {
        viewModelScope.launch {
            _isLoading.value = true
            _errorMessage.value = null
            
            try {
                val response = api.register(
                    com.nova.parent.api.RegisterRequest(email, password, firstName, lastName, "parent")
                )
                if (response.isSuccessful && response.body() != null) {
                    val registerResponse = response.body()!!
                    val accessToken = registerResponse.session?.access_token ?: ""
                    
                    _token.value = accessToken
                    _isAuthenticated.value = true
                    dataManager.saveToken(accessToken)
                    dataManager.saveUserId(registerResponse.user.id)
                    
                    loadUserProfile()
                } else {
                    _errorMessage.value = "Registration failed: ${response.message()}"
                }
            } catch (e: Exception) {
                _errorMessage.value = "Error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    private fun loadUserProfile() {
        viewModelScope.launch {
            val token = _token.value ?: return@launch
            
            try {
                val response = api.getCurrentUser("Bearer $token")
                if (response.isSuccessful && response.body() != null) {
                    val profileData = response.body()!!.user
                    val user = User(
                        id = profileData.id,
                        email = profileData.email,
                        displayName = profileData.profile.displayName ?: profileData.email,
                        profile = UserProfile(
                            firstName = profileData.profile.firstName,
                            lastName = profileData.profile.lastName,
                            displayName = profileData.profile.displayName,
                            avatar = profileData.profile.avatar,
                            banner = profileData.profile.banner,
                            school = profileData.profile.school,
                            grade = profileData.profile.grade
                        ),
                        userType = profileData.userType
                    )
                    _currentUser.value = user
                    dataManager.cacheProfile(user)
                }
            } catch (e: Exception) {
                _errorMessage.value = "Error loading profile: ${e.message}"
            }
        }
    }
    
    fun logout() {
        _token.value = null
        _isAuthenticated.value = false
        _currentUser.value = null
        viewModelScope.launch {
            dataManager.clearAll()
        }
    }
    
    fun getValidatedToken(): String? {
        return _token.value?.trim()
    }
}

