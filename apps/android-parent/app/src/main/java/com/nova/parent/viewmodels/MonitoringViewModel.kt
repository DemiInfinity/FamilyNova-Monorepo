package com.nova.parent.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nova.parent.api.ApiInterface
import com.nova.parent.services.ApiService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class MonitoredMessage(
    val id: String,
    val content: String,
    val sender: String,
    val receiver: String,
    val timestamp: String,
    val isModerated: Boolean,
    val monitoringLevel: String
)

class MonitoringViewModel(private val authViewModel: AuthViewModel) : ViewModel() {
    private val api = ApiService.retrofit.create(ApiInterface::class.java)
    
    private val _messages = MutableStateFlow<List<MonitoredMessage>>(emptyList())
    val messages: StateFlow<List<MonitoredMessage>> = _messages.asStateFlow()
    
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()
    
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()
    
    private val _selectedChild = MutableStateFlow<String?>(null)
    val selectedChild: StateFlow<String?> = _selectedChild.asStateFlow()
    
    fun loadMessages(childId: String? = null) {
        viewModelScope.launch {
            _isLoading.value = true
            _errorMessage.value = null
            _selectedChild.value = childId
            
            val token = authViewModel.getValidatedToken() ?: run {
                _isLoading.value = false
                return@launch
            }
            
            try {
                val response = api.getMonitoredMessages("Bearer $token", childId)
                if (response.isSuccessful && response.body() != null) {
                    val messagesData = response.body()!!.messages
                    _messages.value = messagesData.map { msg ->
                        MonitoredMessage(
                            id = msg.id,
                            content = msg.content,
                            sender = msg.sender,
                            receiver = msg.receiver,
                            timestamp = msg.createdAt,
                            isModerated = false, // TODO: Get from API
                            monitoringLevel = "full" // TODO: Get from API
                        )
                    }
                } else {
                    _errorMessage.value = "Failed to load messages: ${response.message()}"
                }
            } catch (e: Exception) {
                _errorMessage.value = "Error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun setSelectedChild(childId: String?) {
        _selectedChild.value = childId
        loadMessages(childId)
    }
}

