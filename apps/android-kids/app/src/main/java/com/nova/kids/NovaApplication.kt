package com.nova.kids

import android.app.Application
import com.nova.kids.services.DataManager

class NovaApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize DataManager early in application lifecycle
        DataManager.init(applicationContext)
    }
}

