package com.nova.kids.services

import android.util.Log
import com.nova.kids.api.ApiInterface
import com.nova.kids.models.Message
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.text.SimpleDateFormat
import java.util.*

class RealTimeService private constructor() {
    companion object {
        private const val TAG = "RealTimeService"
        private const val MESSAGE_POLLING_INTERVAL = 2000L // 2 seconds
        private const val FRIEND_REQUEST_POLLING_INTERVAL = 30000L // 30 seconds
        
        @Volatile
        private var INSTANCE: RealTimeService? = null
        
        fun getInstance(): RealTimeService {
            return INSTANCE ?: synchronized(this) {
                val instance = RealTimeService()
                INSTANCE = instance
                instance
            }
        }
    }
    
    private val api: ApiInterface = ApiService.retrofit.create(ApiInterface::class.java)
    private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    
    private val _newMessages = MutableStateFlow<Map<String, List<Message>>>(emptyMap())
    val newMessages: StateFlow<Map<String, List<Message>>> = _newMessages.asStateFlow()
    
    private val _friendRequests = MutableStateFlow<List<com.nova.kids.models.FriendRequest>>(emptyList())
    val friendRequests: StateFlow<List<com.nova.kids.models.FriendRequest>> = _friendRequests.asStateFlow()
    
    private val messagePollingJobs = mutableMapOf<String, Job>()
    private var friendRequestPollingJob: Job? = null
    
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
    
    // Start polling messages for a conversation
    fun startPollingMessages(conversationId: String, userId: String, friendId: String, token: String) {
        stopPollingMessages(conversationId)
        
        val job = coroutineScope.launch {
            while (isActive) {
                try {
                    checkForNewMessages(conversationId, userId, friendId, token)
                } catch (e: Exception) {
                    Log.e(TAG, "Error polling messages: ${e.message}")
                }
                delay(MESSAGE_POLLING_INTERVAL)
            }
        }
        
        messagePollingJobs[conversationId] = job
    }
    
    fun stopPollingMessages(conversationId: String) {
        messagePollingJobs[conversationId]?.cancel()
        messagePollingJobs.remove(conversationId)
    }
    
    fun stopAllMessagePolling() {
        messagePollingJobs.values.forEach { it.cancel() }
        messagePollingJobs.clear()
    }
    
    private suspend fun checkForNewMessages(conversationId: String, userId: String, friendId: String, token: String) {
        try {
            val authHeader = "Bearer $token"
            val response = api.getMessages(authHeader, friendId)
            
            if (response.isSuccessful && response.body() != null) {
                val messagesData = response.body()!!.messages
                val currentUserId = userId
                
                val messages = messagesData
                    .filter { message ->
                        (message.senderId.lowercase() == friendId.lowercase() && message.receiverId.lowercase() == currentUserId.lowercase()) ||
                        (message.receiverId.lowercase() == friendId.lowercase() && message.senderId.lowercase() == currentUserId.lowercase())
                    }
                    .mapNotNull { messageData ->
                        try {
                            val createdAt = dateFormat.parse(messageData.createdAt) ?: Date()
                            Message(
                                id = UUID.fromString(messageData.id),
                                senderId = UUID.fromString(messageData.senderId),
                                receiverId = UUID.fromString(messageData.receiverId),
                                content = messageData.content,
                                createdAt = createdAt
                            )
                        } catch (e: Exception) {
                            Log.e(TAG, "Error parsing message: ${e.message}")
                            null
                        }
                    }
                
                // Check for new messages
                val cachedMessages = DataManager.getCachedMessages(userId) ?: emptyList()
                val cachedMessageIds = cachedMessages.map { it.id.toString() }.toSet()
                
                val newMessagesList = messages.filter { !cachedMessageIds.contains(it.id.toString()) }
                
                if (newMessagesList.isNotEmpty()) {
                    // Update cache
                    val updatedMessages = cachedMessages + newMessagesList
                    DataManager.cacheMessages(updatedMessages, userId)
                    
                    // Update state
                    _newMessages.value = _newMessages.value + (conversationId to newMessagesList)
                    
                    // Trigger notifications for messages from friend
                    val messagesFromFriend = newMessagesList.filter { 
                        it.senderId.toString().lowercase() == friendId.lowercase() 
                    }
                    
                    if (messagesFromFriend.isNotEmpty()) {
                        // Note: NotificationManager needs context - should be called from Activity/Fragment
                        // NotificationManager.getInstance(context).showMessageNotification(...)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking for new messages: ${e.message}")
        }
    }
    
    // Start polling friend requests
    fun startPollingFriendRequests(userId: String, token: String) {
        stopPollingFriendRequests()
        
        friendRequestPollingJob = coroutineScope.launch {
            while (isActive) {
                try {
                    checkForFriendRequests(userId, token)
                } catch (e: Exception) {
                    Log.e(TAG, "Error polling friend requests: ${e.message}")
                }
                delay(FRIEND_REQUEST_POLLING_INTERVAL)
            }
        }
    }
    
    fun stopPollingFriendRequests() {
        friendRequestPollingJob?.cancel()
        friendRequestPollingJob = null
    }
    
    private suspend fun checkForFriendRequests(userId: String, token: String) {
        try {
            val authHeader = "Bearer $token"
            // Assuming there's a friend requests endpoint
            // val response = api.getFriendRequests(authHeader)
            // Process friend requests...
        } catch (e: Exception) {
            Log.e(TAG, "Error checking for friend requests: ${e.message}")
        }
    }
    
    fun stopAll() {
        stopAllMessagePolling()
        stopPollingFriendRequests()
        coroutineScope.cancel()
    }
}

// Friend Request model (if not exists)
data class FriendRequest(
    val id: String,
    val fromUserId: String,
    val toUserId: String,
    val status: String,
    val createdAt: Date
)

