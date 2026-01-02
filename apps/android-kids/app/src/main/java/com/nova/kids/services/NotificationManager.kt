package com.nova.kids.services

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.nova.kids.MainActivity
import com.nova.kids.R

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
    
    private val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    
    init {
        createNotificationChannel()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for new messages"
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
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
            .setSmallIcon(R.drawable.ic_notification) // Add notification icon
            .setContentTitle("New message from $senderName")
            .setContentText(content)
            .setStyle(NotificationCompat.BigTextStyle().bigText(content))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()
        
        notificationManager.notify(friendId.hashCode(), notification)
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
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("New friend request")
            .setContentText("$fromUserName wants to be your friend")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()
        
        notificationManager.notify(requestId.hashCode(), notification)
    }
    
    fun cancelNotification(notificationId: Int) {
        notificationManager.cancel(notificationId)
    }
    
    fun cancelAllNotifications() {
        notificationManager.cancelAll()
    }
}

