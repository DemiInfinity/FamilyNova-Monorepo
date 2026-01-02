package com.nova.parent

import android.app.Application
import com.nova.parent.services.DataManager

class NovaParentApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        DataManager.init(applicationContext)
    }
}

