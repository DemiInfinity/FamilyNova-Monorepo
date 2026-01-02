package com.nova.parent.services

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.nova.parent.models.Child
import com.nova.parent.models.User
import kotlinx.coroutines.flow.first
import java.util.*

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "novaparent_prefs")

object DataManager {
    @Volatile
    private var context: Context? = null
    private val gson = Gson()
    private val cacheExpirationInterval = 300_000L // 5 minutes
    
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
        return requireContext().dataStore.data.first()[tokenKey]
    }
    
    suspend fun saveUserId(userId: String) {
        requireContext().dataStore.edit { preferences ->
            preferences[userIdKey] = userId
        }
    }
    
    suspend fun getUserId(): String? {
        return requireContext().dataStore.data.first()[userIdKey]
    }
    
    // Children Caching
    private val childrenCacheKey = stringPreferencesKey("cached_children")
    private val childrenTimestampKey = stringPreferencesKey("cached_children_timestamp")
    
    suspend fun cacheChildren(children: List<Child>) {
        val childrenJson = gson.toJson(children)
        val timestamp = System.currentTimeMillis()
        val ctx = requireContext()
        
        ctx.dataStore.edit { preferences ->
            preferences[childrenCacheKey] = childrenJson
            preferences[childrenTimestampKey] = timestamp.toString()
        }
    }
    
    suspend fun getCachedChildren(): List<Child>? {
        val ctx = requireContext()
        val childrenJson = ctx.dataStore.data.first()[childrenCacheKey] ?: return null
        val timestampStr = ctx.dataStore.data.first()[childrenTimestampKey]
        
        if (timestampStr != null) {
            val timestamp = timestampStr.toLongOrNull() ?: return null
            if (System.currentTimeMillis() - timestamp > cacheExpirationInterval) {
                return null // Cache expired
            }
        }
        
        val type: java.lang.reflect.Type = object : TypeToken<List<Child>>() {}.type
        return try {
            gson.fromJson<List<Child>>(childrenJson, type)
        } catch (e: Exception) {
            null
        }
    }
    
    // Profile Caching
    private val profileCacheKey = stringPreferencesKey("cached_profile")
    
    suspend fun cacheProfile(user: User) {
        val profileJson = gson.toJson(user)
        requireContext().dataStore.edit { preferences ->
            preferences[profileCacheKey] = profileJson
        }
    }
    
    suspend fun getCachedProfile(): User? {
        val ctx = requireContext()
        val profileJson = ctx.dataStore.data.first()[profileCacheKey] ?: return null
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

