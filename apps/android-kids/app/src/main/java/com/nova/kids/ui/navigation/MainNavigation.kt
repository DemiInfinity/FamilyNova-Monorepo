package com.nova.kids.ui.navigation

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.nova.kids.ui.screens.*
import com.nova.kids.viewmodels.AuthViewModel

sealed class Screen(val route: String, val title: String, val icon: androidx.compose.ui.graphics.vector.ImageVector) {
    object Home : Screen("home", "Home", Icons.Default.Home)
    object Explore : Screen("explore", "Explore", Icons.Default.Explore)
    object Create : Screen("create", "Create", Icons.Default.AddCircle)
    object Messages : Screen("messages", "Messages", Icons.Default.Message)
    object More : Screen("more", "More", Icons.Default.MoreVert)
}

@Composable
fun MainNavigation(authViewModel: AuthViewModel) {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination
    
    Scaffold(
        bottomBar = {
            NavigationBar(
                containerColor = com.nova.kids.design.CosmicColors.SpaceTop
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
                            selectedIconColor = com.nova.kids.design.CosmicColors.NebulaPurple,
                            selectedTextColor = com.nova.kids.design.CosmicColors.NebulaPurple,
                            unselectedIconColor = com.nova.kids.design.CosmicColors.TextMuted,
                            unselectedTextColor = com.nova.kids.design.CosmicColors.TextMuted
                        )
                    )
                }
            }
        }
    ) { paddingValues ->
        NavHost(
            navController = navController,
            startDestination = Screen.Home.route,
            modifier = Modifier.padding(paddingValues)
        ) {
            composable(Screen.Home.route) {
                HomeFeedScreen(authViewModel)
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
                MoreScreen(authViewModel)
            }
        }
    }
}

