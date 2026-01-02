package com.nova.parent.ui.screens

import androidx.compose.foundation.background
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
import com.nova.parent.models.Post
import com.nova.parent.viewmodels.AuthViewModel
import com.nova.parent.viewmodels.PostApprovalViewModel
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun PostApprovalScreen(
    authViewModel: AuthViewModel,
    onNavigateBack: () -> Unit = {}
) {
    val postApprovalViewModel: PostApprovalViewModel = viewModel { PostApprovalViewModel(authViewModel) }
    val pendingPosts by postApprovalViewModel.pendingPosts.collectAsState()
    val isLoading by postApprovalViewModel.isLoading.collectAsState()
    
    LaunchedEffect(Unit) {
        postApprovalViewModel.loadPendingPosts()
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Post Approval") },
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
            if (isLoading && pendingPosts.isEmpty()) {
                CircularProgressIndicator(
                    modifier = Modifier.align(Alignment.Center),
                    color = ParentAppColors.PrimaryTeal
                )
            } else if (pendingPosts.isEmpty()) {
                EmptyStateView(
                    icon = "✅",
                    title = "No pending posts",
                    message = "All posts from your children have been reviewed"
                )
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(ParentAppSpacing.M),
                    verticalArrangement = Arrangement.spacedBy(ParentAppSpacing.L)
                ) {
                    items(pendingPosts) { post ->
                        PendingPostCard(
                            post = post,
                            onApprove = { postApprovalViewModel.approvePost(post.id) },
                            onReject = { reason -> postApprovalViewModel.rejectPost(post.id, reason) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun PendingPostCard(
    post: Post,
    onApprove: () -> Unit,
    onReject: (String?) -> Unit
) {
    var showRejectDialog by remember { mutableStateOf(false) }
    var rejectReason by remember { mutableStateOf("") }
    var isProcessing by remember { mutableStateOf(false) }
    
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
                .padding(ParentAppSpacing.L)
        ) {
            // Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "From: ${post.author.profile.displayName ?: "Unknown"}",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = ParentAppColors.PrimaryNavy
                    )
                    Text(
                        text = formatTimestamp(post.createdAt),
                        fontSize = 12.sp,
                        color = ParentAppColors.DarkGray
                    )
                }
                
                Surface(
                    color = ParentAppColors.Warning.copy(alpha = 0.2f),
                    shape = RoundedCornerShape(ParentAppCornerRadius.Small)
                ) {
                    Text(
                        text = "Pending Review",
                        fontSize = 12.sp,
                        color = ParentAppColors.Warning,
                        modifier = Modifier.padding(horizontal = ParentAppSpacing.S, vertical = 4.dp)
                    )
                }
            }
            
            Divider(modifier = Modifier.padding(vertical = ParentAppSpacing.M))
            
            // Post content
            Text(
                text = post.content,
                fontSize = 14.sp,
                color = ParentAppColors.Black,
                modifier = Modifier.padding(bottom = ParentAppSpacing.S)
            )
            
            // Post image (if any)
            post.imageUrl?.let { imageUrl ->
                AsyncImage(
                    model = imageUrl,
                    contentDescription = "Post image",
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(200.dp)
                )
            }
            
            Spacer(modifier = Modifier.height(ParentAppSpacing.M))
            
            // Actions
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(ParentAppSpacing.M)
            ) {
                Button(
                    onClick = {
                        isProcessing = true
                        onApprove()
                    },
                    modifier = Modifier.weight(1f),
                    enabled = !isProcessing,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = ParentAppColors.Success
                    )
                ) {
                    if (isProcessing) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(16.dp),
                            color = ParentAppColors.White
                        )
                    } else {
                        Icon(Icons.Default.CheckCircle, contentDescription = null)
                        Spacer(modifier = Modifier.width(ParentAppSpacing.XS))
                        Text("Approve")
                    }
                }
                
                Button(
                    onClick = { showRejectDialog = true },
                    modifier = Modifier.weight(1f),
                    enabled = !isProcessing,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = ParentAppColors.Error
                    )
                ) {
                    Icon(Icons.Default.Cancel, contentDescription = null)
                    Spacer(modifier = Modifier.width(ParentAppSpacing.XS))
                    Text("Reject")
                }
            }
        }
    }
    
    if (showRejectDialog) {
        AlertDialog(
            onDismissRequest = { showRejectDialog = false },
            title = { Text("Reject Post") },
            text = {
                Column {
                    Text("Please provide a reason for rejecting this post (optional)")
                    Spacer(modifier = Modifier.height(ParentAppSpacing.M))
                    OutlinedTextField(
                        value = rejectReason,
                        onValueChange = { rejectReason = it },
                        label = { Text("Reason") },
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        onReject(if (rejectReason.isBlank()) null else rejectReason)
                        showRejectDialog = false
                        rejectReason = ""
                    }
                ) {
                    Text("Reject")
                }
            },
            dismissButton = {
                TextButton(onClick = { showRejectDialog = false }) {
                    Text("Cancel")
                }
            }
        )
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

