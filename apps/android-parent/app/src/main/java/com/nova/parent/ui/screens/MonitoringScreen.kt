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
import com.nova.parent.design.ParentAppColors
import com.nova.parent.design.ParentAppCornerRadius
import com.nova.parent.design.ParentAppSpacing
import com.nova.parent.viewmodels.AuthViewModel
import com.nova.parent.viewmodels.MonitoringViewModel
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MonitoringScreen(
    authViewModel: AuthViewModel,
    onNavigateBack: () -> Unit = {}
) {
    val monitoringViewModel: MonitoringViewModel = viewModel { MonitoringViewModel(authViewModel) }
    val messages by monitoringViewModel.messages.collectAsState()
    val isLoading by monitoringViewModel.isLoading.collectAsState()
    val selectedChild by monitoringViewModel.selectedChild.collectAsState()

    LaunchedEffect(Unit) {
        monitoringViewModel.loadMessages()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Message Monitoring") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                },
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
            if (isLoading && messages.isEmpty()) {
                CircularProgressIndicator(
                    modifier = Modifier.align(Alignment.Center),
                    color = ParentAppColors.PrimaryTeal
                )
            } else if (messages.isEmpty()) {
                EmptyStateView(
                    icon = "👁️",
                    title = "No messages to monitor",
                    message = "All messages from your children will appear here"
                )
            } else {
                Column {
                    // Filter by child
                    if (messages.isNotEmpty()) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(ParentAppSpacing.M),
                            horizontalArrangement = Arrangement.spacedBy(ParentAppSpacing.S)
                        ) {
                            FilterChip(
                                selected = selectedChild == null,
                                onClick = { monitoringViewModel.setSelectedChild(null) },
                                label = { Text("All Children") }
                            )
                            // TODO: Add child filter chips
                        }
                    }

                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(ParentAppSpacing.M),
                        verticalArrangement = Arrangement.spacedBy(ParentAppSpacing.M)
                    ) {
                        items(messages) { message ->
                            MessageMonitoringCard(message = message)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun MessageMonitoringCard(message: com.nova.parent.viewmodels.MonitoredMessage) {
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
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "From: ${message.sender}",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = ParentAppColors.PrimaryNavy
                )

                Surface(
                    color = if (message.monitoringLevel == "full") ParentAppColors.PrimaryTeal else ParentAppColors.MediumGray,
                    shape = RoundedCornerShape(ParentAppCornerRadius.Small)
                ) {
                    Text(
                        text = if (message.monitoringLevel == "full") "Full" else "Partial",
                        fontSize = 10.sp,
                        color = ParentAppColors.White,
                        modifier = Modifier.padding(horizontal = ParentAppSpacing.S, vertical = 4.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(ParentAppSpacing.S))

            Text(
                text = message.content,
                fontSize = 14.sp,
                color = ParentAppColors.Black
            )

            Spacer(modifier = Modifier.height(ParentAppSpacing.XS))

            Text(
                text = formatTimestamp(message.timestamp),
                fontSize = 12.sp,
                color = ParentAppColors.DarkGray
            )
        }
    }
}

@Composable
fun EmptyStateView(
    icon: String,
    title: String,
    message: String
) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(ParentAppSpacing.M)
        ) {
            Text(
                text = icon,
                fontSize = 60.sp
            )
            Text(
                text = title,
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = ParentAppColors.Black
            )
            Text(
                text = message,
                fontSize = 14.sp,
                color = ParentAppColors.DarkGray
            )
        }
    }
}

private fun formatTimestamp(timestamp: String): String {
    return try {
        val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
        val outputFormat = SimpleDateFormat("MMM dd, yyyy 'at' HH:mm", Locale.US)
        val date = inputFormat.parse(timestamp)
        date?.let { outputFormat.format(it) } ?: timestamp
    } catch (e: Exception) {
        timestamp
    }
}
