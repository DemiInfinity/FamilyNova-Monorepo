package com.nova.parent.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage
import com.nova.parent.design.ParentAppColors
import com.nova.parent.design.ParentAppCornerRadius
import com.nova.parent.design.ParentAppSpacing
import com.nova.parent.models.Child
import com.nova.parent.viewmodels.AuthViewModel
import com.nova.parent.viewmodels.DashboardViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    authViewModel: AuthViewModel,
    onNavigateToCreateChild: () -> Unit = {},
    onNavigateToChildDetails: (String) -> Unit = {},
    onNavigateToPostApproval: () -> Unit = {},
    onNavigateToProfileChanges: () -> Unit = {}
) {
    var showCreateChild by remember { mutableStateOf(false) }
    val dashboardViewModel: DashboardViewModel = viewModel { DashboardViewModel(authViewModel) }
    val children by dashboardViewModel.children.collectAsState()
    val isLoading by dashboardViewModel.isLoading.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Dashboard") },
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
            if (isLoading && children.isEmpty()) {
                CircularProgressIndicator(
                    modifier = Modifier.align(Alignment.Center),
                    color = ParentAppColors.PrimaryTeal
                )
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(ParentAppSpacing.M),
                    verticalArrangement = Arrangement.spacedBy(ParentAppSpacing.M)
                ) {
                    // Welcome Card
                    item {
                        WelcomeCard()
                    }

                    // My Children Section
                    item {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "My Children",
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Bold,
                                color = ParentAppColors.Black
                            )
                            Button(
                                onClick = { showCreateChild = true },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = ParentAppColors.PrimaryTeal
                                )
                            ) {
                                Icon(Icons.Default.Add, contentDescription = null)
                                Spacer(modifier = Modifier.width(ParentAppSpacing.XS))
                                Text("Add Child")
                            }
                        }
                    }

                    if (children.isEmpty()) {
                        item {
                            EmptyChildrenCard(onCreateChild = { showCreateChild = true })
                        }
                    } else {
                        items(children) { child ->
                            ChildCard(
                                child = child,
                                onClick = { onNavigateToChildDetails(child.id) }
                            )
                        }
                    }

                    // Pending Profile Changes
                    item {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "Profile Changes",
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Bold,
                                color = ParentAppColors.Black
                            )
                            TextButton(onClick = onNavigateToProfileChanges) {
                                Text("View All")
                            }
                        }
                    }

                    item {
                        ProfileChangesCard()
                    }

                    // Pending Posts
                    item {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "Pending Posts",
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Bold,
                                color = ParentAppColors.Black
                            )
                            TextButton(onClick = onNavigateToPostApproval) {
                                Text("View All")
                            }
                        }
                    }

                    item {
                        PendingPostsCard()
                    }
                }
            }
        }

        // Create Child Dialog
        if (showCreateChild) {
            CreateChildAccountScreen(
                authViewModel = authViewModel,
                onSuccess = {
                    showCreateChild = false
                    dashboardViewModel.loadChildren()
                },
                onDismiss = { showCreateChild = false }
            )
        }
    }
}

@Composable
fun WelcomeCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(ParentAppCornerRadius.Medium),
        colors = CardDefaults.cardColors(
            containerColor = ParentAppColors.White
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(ParentAppSpacing.L)
        ) {
            Text(
                text = "Welcome back! 👋",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = ParentAppColors.PrimaryNavy
            )
            Text(
                text = "Monitor and protect your children\'s online experience",
                fontSize = 14.sp,
                color = ParentAppColors.DarkGray,
                modifier = Modifier.padding(top = ParentAppSpacing.S)
            )
        }
    }
}

@Composable
fun ChildCard(
    child: Child,
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
            AsyncImage(
                model = child.profile.avatar,
                contentDescription = "Avatar",
                modifier = Modifier
                    .size(60.dp)
                    .background(ParentAppColors.PrimaryTeal, RoundedCornerShape(ParentAppCornerRadius.Round))
            )

            Spacer(modifier = Modifier.width(ParentAppSpacing.M))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = child.profile.displayName ?: child.email,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = ParentAppColors.Black
                )
                Text(
                    text = child.email,
                    fontSize = 14.sp,
                    color = ParentAppColors.DarkGray
                )
            }

            Icon(
                Icons.Default.ChevronRight,
                contentDescription = null,
                tint = ParentAppColors.MediumGray
            )
        }
    }
}

@Composable
fun EmptyChildrenCard(onCreateChild: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(ParentAppCornerRadius.Medium),
        colors = CardDefaults.cardColors(
            containerColor = ParentAppColors.White
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(ParentAppSpacing.XL),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "👶",
                fontSize = 48.sp
            )
            Text(
                text = "No children yet",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = ParentAppColors.Black,
                modifier = Modifier.padding(top = ParentAppSpacing.M)
            )
            Text(
                text = "Add your first child to get started",
                fontSize = 14.sp,
                color = ParentAppColors.DarkGray,
                modifier = Modifier.padding(top = ParentAppSpacing.S)
            )
            Button(
                onClick = onCreateChild,
                modifier = Modifier.padding(top = ParentAppSpacing.M),
                colors = ButtonDefaults.buttonColors(
                    containerColor = ParentAppColors.PrimaryTeal
                )
            ) {
                Text("Add Child")
            }
        }
    }
}

@Composable
fun ProfileChangesCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(ParentAppCornerRadius.Medium),
        colors = CardDefaults.cardColors(
            containerColor = ParentAppColors.White
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(ParentAppSpacing.M)
        ) {
            Text(
                text = "No pending profile changes",
                fontSize = 14.sp,
                color = ParentAppColors.DarkGray
            )
        }
    }
}

@Composable
fun PendingPostsCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(ParentAppCornerRadius.Medium),
        colors = CardDefaults.cardColors(
            containerColor = ParentAppColors.White
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(ParentAppSpacing.M)
        ) {
            Text(
                text = "No pending posts",
                fontSize = 14.sp,
                color = ParentAppColors.DarkGray
            )
        }
    }
}
