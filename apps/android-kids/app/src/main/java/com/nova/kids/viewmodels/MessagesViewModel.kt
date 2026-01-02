package com.nova.kids.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nova.kids.api.ApiInterface
import com.nova.kids.models.Conversation
import com.nova.kids.models.Friend
import com.nova.kids.models.Message
import com.nova.kids.services.ApiService
import com.nova.kids.services.DataManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

class MessagesViewModel(private val authViewModel: AuthViewModel) : ViewModel() {
    private val api: ApiInterface = ApiService.retrofit.create(ApiInterface::class.java)
    private val dataManager = DataManager

    private val _conversations = MutableStateFlow<List<Conversation>>(emptyList())
    val conversations: StateFlow<List<Conversation>> = _conversations.asStateFlow()

    private val _messages = MutableStateFlow<List<Message>>(emptyList())
    val messages: StateFlow<List<Message>> = _messages.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _isSending = MutableStateFlow(false)
    val isSending: StateFlow<Boolean> = _isSending.asStateFlow()

    fun loadConversations() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val token = authViewModel.token.value ?: return@launch
                
                // Get friends first
                val friendsResponse = api.getFriends("Bearer $token")
                if (friendsResponse.isSuccessful && friendsResponse.body() != null) {
                    val friends = friendsResponse.body()!!.friends.map { friendData ->
                        Friend(
                            id = java.util.UUID.fromString(friendData.id),
                            displayName = friendData.profile.displayName ?: "Unknown",
                            avatar = friendData.profile.avatar,
                            isVerified = false
                        )
                    }

                    // Get messages for all friends
                    val messagesResponse = api.getMessages("Bearer $token", null)
                    if (messagesResponse.isSuccessful && messagesResponse.body() != null) {
                        val allMessages = messagesResponse.body()!!.messages
                        
                        val conversationsList = friends.map { friend ->
                            val friendMessages = allMessages.filter { 
                                it.senderId == friend.id.toString() || it.receiverId == friend.id.toString() 
                            }
                            val lastMessage = friendMessages.maxByOrNull { parseDate(it.createdAt)?.time ?: 0L }
                            
                            Conversation(
                                friend = friend,
                                lastMessage = lastMessage?.content,
                                timestamp = lastMessage?.let { parseDate(it.createdAt) }
                            )
                        }.sortedByDescending { it.timestamp?.time ?: 0L }
                        
                        _conversations.value = conversationsList
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun loadMessages(friendId: String) {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val token = authViewModel.token.value ?: return@launch
                
                val response = api.getMessages("Bearer $token", friendId)
                if (response.isSuccessful && response.body() != null) {
                    val messagesList = response.body()!!.messages.map { messageData ->
                        Message(
                            id = java.util.UUID.fromString(messageData.id),
                            senderId = messageData.senderId,
                            receiverId = messageData.receiverId,
                            content = messageData.content,
                            timestamp = parseDate(messageData.createdAt) ?: Date()
                        )
                    }
                    
                    _messages.value = messagesList.sortedBy { it.timestamp }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun sendMessage(receiverId: String, content: String) {
        viewModelScope.launch {
            _isSending.value = true
            try {
                val token = authViewModel.token.value ?: return@launch
                
                val response = api.sendMessage(
                    "Bearer $token",
                    com.nova.kids.api.SendMessageRequest(receiverId, content.trim())
                )
                
                if (response.isSuccessful && response.body() != null) {
                    val messageData = response.body()!!.message
                    val newMessage = Message(
                        id = java.util.UUID.fromString(messageData.id),
                        senderId = messageData.senderId,
                        receiverId = messageData.receiverId,
                        content = messageData.content,
                        timestamp = parseDate(messageData.createdAt) ?: Date()
                    )
                    
                    _messages.value = (_messages.value + newMessage).sortedBy { it.timestamp }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                _isSending.value = false
            }
        }
    }

    private fun parseDate(dateString: String): Date? {
        return try {
            val formats = listOf(
                SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US),
                SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US)
            )
            formats.forEach { format ->
                format.timeZone = TimeZone.getTimeZone("UTC")
                try {
                    return format.parse(dateString)
                } catch (e: Exception) {
                    // Try next format
                }
            }
            null
        } catch (e: Exception) {
            null
        }
    }
}

