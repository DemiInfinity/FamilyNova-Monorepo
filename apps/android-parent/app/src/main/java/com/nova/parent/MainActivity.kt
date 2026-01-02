package com.nova.parent

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.nova.parent.services.DataManager
import com.nova.parent.ui.navigation.MainNavigation
import com.nova.parent.ui.screens.LoginScreen
import com.nova.parent.ui.screens.RegistrationScreen
import com.nova.parent.ui.screens.SplashScreen
import com.nova.parent.ui.theme.NovaParentTheme
import com.nova.parent.viewmodels.AuthViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        try {
            DataManager.init(applicationContext)
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error initializing DataManager: ${e.message}", e)
        }
        
        setContent {
            NovaParentTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    val authViewModel: AuthViewModel = viewModel()
                    val isAuthenticated by authViewModel.isAuthenticated.collectAsState()
                    var showSplash by remember { mutableStateOf(true) }
                    var showRegistration by remember { mutableStateOf(false) }
                    var isLoadingComplete by remember { mutableStateOf(false) }
                    
                    when {
                        showSplash && isAuthenticated && !isLoadingComplete -> {
                            SplashScreen(
                                authViewModel = authViewModel,
                                onLoadingComplete = {
                                    isLoadingComplete = true
                                    showSplash = false
                                }
                            )
                        }
                        isAuthenticated -> {
                            MainNavigation(authViewModel)
                        }
                        showRegistration -> {
                            RegistrationScreen(
                                authViewModel = authViewModel,
                                onRegistrationSuccess = {
                                    showRegistration = false
                                },
                                onNavigateToLogin = {
                                    showRegistration = false
                                }
                            )
                        }
                        else -> {
                            LoginScreen(
                                authViewModel = authViewModel,
                                onLoginSuccess = { },
                                onNavigateToRegister = { showRegistration = true }
                            )
                        }
                    }
                }
            }
        }
    }
}

