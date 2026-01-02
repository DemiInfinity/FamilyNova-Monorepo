package com.nova.kids.services

import android.app.NotificationChannel
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.nova.kids.MainActivity

class NotificationManager private constructor(private val context: Context) {
    companion object {
        private const val TAG = "NotificationManager"
        private const val CHANNEL_ID = "familynova_messages"
        private const val CHANNEL_NAME = "Messages"
        
        @Volatile
        private var INSTANCE: NotificationManager? = null
        
        fun getInstance(context: Context): NotificationManager {
            return INSTANCE ?: synchronized(this) {
                val instance = NotificationManager(context.applicationContext)
                INSTANCE = instance
                instance
            }
        }
    }
    
    private val systemNotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
    
    init {
        createNotificationChannel()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                android.app.NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for new messages"
                enableVibration(true)
            }
            systemNotificationManager.createNotificationChannel(channel)
        }
    }
    
    fun showMessageNotification(senderName: String, content: String, friendId: String) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("open_messages", true)
            putExtra("friend_id", friendId)
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Using system icon
            .setContentTitle("New message from $senderName")
            .setContentText(content)
            .setStyle(NotificationCompat.BigTextStyle().bigText(content))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()
        
        systemNotificationManager.notify(friendId.hashCode(), notification)
    }
    
    fun showFriendRequestNotification(fromUserName: String, requestId: String) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("open_friends", true)
            putExtra("request_id", requestId)
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Using system icon
            .setContentTitle("New friend request")
            .setContentText("$fromUserName wants to be your friend")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()
        
        systemNotificationManager.notify(requestId.hashCode(), notification)
    }
    
    fun cancelNotification(notificationId: Int) {
        systemNotificationManager.cancel(notificationId)
    }
    
    fun cancelAllNotifications() {
        systemNotificationManager.cancelAll()
    }
}

