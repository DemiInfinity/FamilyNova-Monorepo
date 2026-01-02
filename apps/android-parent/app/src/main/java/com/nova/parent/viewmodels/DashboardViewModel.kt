package com.nova.parent.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nova.parent.api.ApiInterface
import com.nova.parent.models.Child
import com.nova.parent.models.ChildProfile
import com.nova.parent.models.VerificationStatus
import com.nova.parent.services.ApiService
import com.nova.parent.services.DataManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class DashboardViewModel(private val authViewModel: AuthViewModel) : ViewModel() {
    private val api = ApiService.retrofit.create(ApiInterface::class.java)
    private val dataManager = DataManager
    
    private val _children = MutableStateFlow<List<Child>>(emptyList())
    val children: StateFlow<List<Child>> = _children.asStateFlow()
    
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()
    
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()
    
    init {
        loadChildren()
    }
    
    fun loadChildren() {
        viewModelScope.launch {
            _isLoading.value = true
            _errorMessage.value = null
            
            // Try to load from cache first
            val cachedChildren = dataManager.getCachedChildren()
            if (cachedChildren != null) {
                _children.value = cachedChildren
            }
            
            val token = authViewModel.getValidatedToken() ?: run {
                _isLoading.value = false
                return@launch
            }
            
            try {
                val response = api.getDashboard("Bearer $token")
                if (response.isSuccessful && response.body() != null) {
                    val dashboardData = response.body()!!.parent
                    val childrenList = dashboardData.children.map { childData ->
                        Child(
                            id = childData.id,
                            email = childData.email,
                            profile = ChildProfile(
                                firstName = childData.profile.firstName,
                                lastName = childData.profile.lastName,
                                displayName = childData.profile.displayName,
                                avatar = childData.profile.avatar,
                                school = childData.profile.school,
                                grade = childData.profile.grade
                            ),
                            verification = VerificationStatus(
                                parentVerified = childData.verification.parentVerified,
                                schoolVerified = childData.verification.schoolVerified
                            ),
                            lastLogin = childData.lastLogin
                        )
                    }
                    _children.value = childrenList
                    dataManager.cacheChildren(childrenList)
                } else {
                    _errorMessage.value = "Failed to load children: ${response.message()}"
                }
            } catch (e: Exception) {
                _errorMessage.value = "Error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }
}

