package com.nova.parent.ui.navigation

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.nova.parent.design.ParentAppColors
import com.nova.parent.ui.screens.*
import com.nova.parent.viewmodels.AuthViewModel

sealed class Screen(val route: String, val title: String, val icon: androidx.compose.ui.graphics.vector.ImageVector) {
    object Home : Screen("home", "Home", Icons.Default.Home)
    object Explore : Screen("explore", "Explore", Icons.Default.Explore)
    object Create : Screen("create", "Create", Icons.Default.AddCircle)
    object Messages : Screen("messages", "Messages", Icons.Default.Message)
    object More : Screen("more", "More", Icons.Default.MoreVert)
    
    // Detail screens
    data class Dashboard(val childId: String? = null) : Screen("dashboard/${childId ?: "main"}", "Dashboard", Icons.Default.Dashboard)
    data class Monitoring(val childId: String? = null) : Screen("monitoring/${childId ?: "all"}", "Monitoring", Icons.Default.Visibility)
    data class PostApproval(val postId: String? = null) : Screen("postApproval/${postId ?: "all"}", "Post Approval", Icons.Default.CheckCircle)
}

@Composable
fun MainNavigation(authViewModel: AuthViewModel) {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination
    
    Scaffold(
        bottomBar = {
            NavigationBar(
                containerColor = ParentAppColors.White
            ) {
                val screens = listOf(
                    Screen.Home,
                    Screen.Explore,
                    Screen.Create,
                    Screen.Messages,
                    Screen.More
                )
                
                screens.forEach { screen ->
                    NavigationBarItem(
                        icon = { Icon(screen.icon, contentDescription = screen.title) },
                        label = { Text(screen.title) },
                        selected = currentDestination?.hierarchy?.any { it.route == screen.route } == true,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = ParentAppColors.PrimaryTeal,
                            selectedTextColor = ParentAppColors.PrimaryTeal,
                            unselectedIconColor = ParentAppColors.MediumGray,
                            unselectedTextColor = ParentAppColors.MediumGray
                        )
                    )
                }
            }
        }
        ) { paddingValues ->
        var showMonitoring by remember { mutableStateOf(false) }
        var showPostApproval by remember { mutableStateOf(false) }
        var selectedChildId by remember { mutableStateOf<String?>(null) }
        
        NavHost(
            navController = navController,
            startDestination = Screen.Home.route,
            modifier = Modifier.padding(paddingValues)
        ) {
            composable(Screen.Home.route) {
                DashboardScreen(
                    authViewModel = authViewModel,
                    onNavigateToPostApproval = { showPostApproval = true }
                )
            }
            composable(Screen.Explore.route) {
                ExploreScreen(authViewModel)
            }
            composable(Screen.Create.route) {
                CreatePostScreen(authViewModel)
            }
            composable(Screen.Messages.route) {
                MessagesScreen(authViewModel)
            }
            composable(Screen.More.route) {
                MoreScreen(
                    authViewModel = authViewModel,
                    onNavigateToMonitoring = { showMonitoring = true },
                    onNavigateToPostApproval = { showPostApproval = true }
                )
            }
        }
        
        // Full-screen overlays
        if (showMonitoring) {
            MonitoringScreen(
                authViewModel = authViewModel,
                onNavigateBack = { showMonitoring = false }
            )
        }
        
        if (showPostApproval) {
            PostApprovalScreen(
                authViewModel = authViewModel,
                onNavigateBack = { showPostApproval = false }
            )
        }
    }
}

