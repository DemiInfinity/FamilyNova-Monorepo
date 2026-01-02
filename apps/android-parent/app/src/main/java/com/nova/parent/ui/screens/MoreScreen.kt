package com.nova.parent.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.nova.parent.design.ParentAppColors
import com.nova.parent.design.ParentAppCornerRadius
import com.nova.parent.design.ParentAppSpacing
import com.nova.parent.viewmodels.AuthViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MoreScreen(
    authViewModel: AuthViewModel,
    onNavigateToProfile: () -> Unit = {},
    onNavigateToMonitoring: () -> Unit = {},
    onNavigateToPostApproval: () -> Unit = {},
    onNavigateToSettings: () -> Unit = {}
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("More") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = ParentAppColors.White
                )
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .background(ParentAppColors.LightGray)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(ParentAppSpacing.M),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(ParentAppSpacing.XL)
            ) {
                // Profile Section
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(ParentAppCornerRadius.Large),
                    colors = CardDefaults.cardColors(
                        containerColor = ParentAppColors.White
                    )
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(ParentAppSpacing.L),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(ParentAppSpacing.M)
                    ) {
                        AsyncImage(
                            model = authViewModel.currentUser.value?.profile?.avatar,
                            contentDescription = "Avatar",
                            modifier = Modifier
                                .size(100.dp)
                                .background(ParentAppColors.PrimaryTeal, RoundedCornerShape(ParentAppCornerRadius.Round))
                        )

                        Text(
                            text = authViewModel.currentUser.value?.displayName ?: "User",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            color = ParentAppColors.Black
                        )
                    }
                }

                // Menu Options
                Column(
                    verticalArrangement = Arrangement.spacedBy(ParentAppSpacing.S)
                ) {
                    MenuRow(
                        icon = Icons.Default.Person,
                        title = "My Profile",
                        onClick = onNavigateToProfile
                    )
                    MenuRow(
                        icon = Icons.Default.Visibility,
                        title = "Monitoring",
                        onClick = onNavigateToMonitoring
                    )
                    MenuRow(
                        icon = Icons.Default.CheckCircle,
                        title = "Post Approval",
                        onClick = onNavigateToPostApproval
                    )
                    MenuRow(
                        icon = Icons.Default.Settings,
                        title = "Settings",
                        onClick = onNavigateToSettings
                    )
                }

                // Log Out
                Button(
                    onClick = { authViewModel.logout() },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = ParentAppColors.Error
                    ),
                    shape = RoundedCornerShape(ParentAppCornerRadius.Medium)
                ) {
                    Text(
                        "Log Out",
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

@Composable
fun MenuRow(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    title: String,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(ParentAppCornerRadius.Medium),
        colors = CardDefaults.cardColors(
            containerColor = ParentAppColors.White
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(ParentAppSpacing.M),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                icon,
                contentDescription = null,
                tint = ParentAppColors.PrimaryTeal,
                modifier = Modifier.size(24.dp)
            )
            Spacer(modifier = Modifier.width(ParentAppSpacing.M))
            Text(
                text = title,
                fontSize = 16.sp,
                color = ParentAppColors.Black,
                modifier = Modifier.weight(1f)
            )
            Icon(
                Icons.Default.ChevronRight,
                contentDescription = null,
                tint = ParentAppColors.MediumGray
            )
        }
    }
}
