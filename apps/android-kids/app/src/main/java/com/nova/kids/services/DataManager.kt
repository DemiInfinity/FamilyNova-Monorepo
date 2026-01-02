package com.nova.kids.services

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.nova.kids.models.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import java.util.*

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "nova_prefs")

object DataManager {
    @Volatile
    private var context: Context? = null
    private val gson = Gson()
    private val cacheExpirationInterval = 300_000L // 5 minutes in milliseconds
    
    fun init(context: Context) {
        synchronized(this) {
            if (this.context == null) {
                this.context = context.applicationContext
            }
        }
    }
    
    private fun requireContext(): Context {
        return context ?: throw IllegalStateException("DataManager not initialized. Call init() first.")
    }
    
    fun isInitialized(): Boolean {
        return context != null
    }
    
    // Token Management
    private val tokenKey = stringPreferencesKey("auth_token")
    private val userIdKey = stringPreferencesKey("current_user_id")
    
    suspend fun saveToken(token: String) {
        requireContext().dataStore.edit { preferences ->
            preferences[tokenKey] = token
        }
    }
    
    suspend fun getToken(): String? {
        return try {
            requireContext().dataStore.data.first()[tokenKey]
        } catch (e: Exception) {
            null
        }
    }
    
    suspend fun saveUserId(userId: String) {
        requireContext().dataStore.edit { preferences ->
            preferences[userIdKey] = userId
        }
    }
    
    suspend fun getUserId(): String? {
        return try {
            requireContext().dataStore.data.first()[userIdKey]
        } catch (e: Exception) {
            null
        }
    }
    
    // Posts Caching
    private fun postsCacheKey(userId: String) = stringPreferencesKey("cached_posts_$userId")
    private fun postsTimestampKey(userId: String) = stringPreferencesKey("cached_posts_timestamp_$userId")
    
    suspend fun cachePosts(posts: List<Post>, userId: String? = null) {
        val uid = userId ?: getUserId() ?: return
        val postsJson = gson.toJson(posts)
        val timestamp = System.currentTimeMillis()
        val ctx = requireContext()
        
        ctx.dataStore.edit { preferences ->
            preferences[postsCacheKey(uid)] = postsJson
            preferences[stringPreferencesKey("cached_posts_timestamp_$uid")] = timestamp.toString()
        }
    }
    
    suspend fun getCachedPosts(userId: String? = null): List<Post>? {
        val uid = userId ?: getUserId() ?: return null
        val ctx = requireContext()
        
        val postsJson = ctx.dataStore.data.first()[postsCacheKey(uid)] ?: return null
        val timestampStr = ctx.dataStore.data.first()[stringPreferencesKey("cached_posts_timestamp_$uid")]
        
        if (timestampStr != null) {
            val timestamp = timestampStr.toLongOrNull() ?: return null
            if (System.currentTimeMillis() - timestamp > cacheExpirationInterval) {
                return null // Cache expired
            }
        }
        
        val type: java.lang.reflect.Type = object : TypeToken<List<Post>>() {}.type
        return try {
            gson.fromJson<List<Post>>(postsJson, type)
        } catch (e: Exception) {
            null
        }
    }
    
    // Messages Caching
    private fun messagesCacheKey(userId: String) = stringPreferencesKey("cached_messages_$userId")
    
    suspend fun cacheMessages(messages: List<Message>, userId: String? = null) {
        val uid = userId ?: getUserId() ?: return
        val messagesJson = gson.toJson(messages)
        val ctx = requireContext()
        
        ctx.dataStore.edit { preferences ->
            preferences[messagesCacheKey(uid)] = messagesJson
            preferences[stringPreferencesKey("cached_messages_timestamp_$uid")] = System.currentTimeMillis().toString()
        }
    }
    
    suspend fun getCachedMessages(userId: String? = null): List<Message>? {
        val uid = userId ?: getUserId() ?: return null
        val ctx = requireContext()
        
        val messagesJson = ctx.dataStore.data.first()[messagesCacheKey(uid)] ?: return null
        val type: java.lang.reflect.Type = object : TypeToken<List<Message>>() {}.type
        return try {
            gson.fromJson<List<Message>>(messagesJson, type)
        } catch (e: Exception) {
            null
        }
    }
    
    // Friends Caching
    private fun friendsCacheKey(userId: String) = stringPreferencesKey("cached_friends_$userId")
    
    suspend fun cacheFriends(friends: List<Friend>, userId: String? = null) {
        val uid = userId ?: getUserId() ?: return
        val friendsJson = gson.toJson(friends)
        val ctx = requireContext()
        
        ctx.dataStore.edit { preferences ->
            preferences[friendsCacheKey(uid)] = friendsJson
        }
    }
    
    suspend fun getCachedFriends(userId: String? = null): List<Friend>? {
        val uid = userId ?: getUserId() ?: return null
        val ctx = requireContext()
        
        val friendsJson = ctx.dataStore.data.first()[friendsCacheKey(uid)] ?: return null
        val type: java.lang.reflect.Type = object : TypeToken<List<Friend>>() {}.type
        return try {
            gson.fromJson<List<Friend>>(friendsJson, type)
        } catch (e: Exception) {
            null
        }
    }
    
    // Profile Caching
    private fun profileCacheKey(userId: String) = stringPreferencesKey("cached_profile_$userId")
    
    suspend fun cacheProfile(profile: User) {
        val uid = profile.id
        val profileJson = gson.toJson(profile)
        val ctx = requireContext()
        
        ctx.dataStore.edit { preferences ->
            preferences[profileCacheKey(uid)] = profileJson
        }
    }
    
    suspend fun getCachedProfile(userId: String? = null): User? {
        val uid = userId ?: getUserId() ?: return null
        val ctx = requireContext()
        
        val profileJson = ctx.dataStore.data.first()[profileCacheKey(uid)] ?: return null
        return try {
            gson.fromJson(profileJson, User::class.java)
        } catch (e: Exception) {
            null
        }
    }
    
    suspend fun clearAll() {
        requireContext().dataStore.edit { preferences ->
            preferences.clear()
        }
    }
}

