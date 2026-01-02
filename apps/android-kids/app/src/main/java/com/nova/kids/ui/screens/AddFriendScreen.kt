package com.nova.kids.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.nova.kids.design.CosmicColors
import com.nova.kids.design.CosmicCornerRadius
import com.nova.kids.design.CosmicSpacing
import com.nova.kids.viewmodels.AuthViewModel
import com.nova.kids.viewmodels.FriendsViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddFriendScreen(
    authViewModel: AuthViewModel,
    onDismiss: () -> Unit
) {
    var selectedTab by remember { mutableStateOf(0) } // 0 = Search, 1 = My Code, 2 = Enter Code
    val friendsViewModel = remember { FriendsViewModel(authViewModel) } // authViewModel is used here
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Add Friend") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = CosmicColors.GlassBackground
                ),
                navigationIcon = {
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, "Close")
                    }
                }
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            CosmicColors.SpaceTop,
                            CosmicColors.SpaceMiddle,
                            CosmicColors.SpaceBottom
                        )
                    )
                )
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
            ) {
                // Tab Selector
                var tabTitles = listOf("🔍 Search", "📱 My Code", "⌨️ Enter Code")
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(CosmicSpacing.M),
                    horizontalArrangement = Arrangement.spacedBy(CosmicSpacing.S)
                ) {
                    tabTitles.forEachIndexed { index, title ->
                        FilterChip(
                            selected = selectedTab == index,
                            onClick = { selectedTab = index },
                            label = { Text(title, fontSize = 12.sp) },
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
                
                // Content based on selected tab
                when (selectedTab) {
                    0 -> SearchFriendTab(friendsViewModel)
                    1 -> MyFriendCodeTab(authViewModel)
                    2 -> EnterFriendCodeTab(authViewModel, friendsViewModel, onDismiss)
                }
            }
        }
    }
}

@Composable
fun SearchFriendTab(friendsViewModel: FriendsViewModel) {
    var searchQuery by remember { mutableStateOf("") }
    val searchResults by friendsViewModel.searchResults.collectAsState()
    val isSearching by friendsViewModel.isSearching.collectAsState()
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(CosmicSpacing.M),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(CosmicSpacing.L)
    ) {
        OutlinedTextField(
            value = searchQuery,
            onValueChange = { 
                searchQuery = it
                if (it.isNotEmpty()) {
                    friendsViewModel.searchFriends(it)
                }
            },
            modifier = Modifier.fillMaxWidth(),
            placeholder = { Text("Search for friends...") },
            leadingIcon = { Icon(Icons.Default.Search, "Search") },
            shape = RoundedCornerShape(CosmicCornerRadius.Large)
        )
        
        if (isSearching) {
            CircularProgressIndicator(color = CosmicColors.NebulaPurple)
        } else if (searchResults.isEmpty() && searchQuery.isNotEmpty()) {
            Text(
                "No friends found",
                color = CosmicColors.TextSecondary,
                textAlign = TextAlign.Center
            )
        } else {
            // Show search results
            // TODO: Implement friend result cards
        }
    }
}

@Composable
fun MyFriendCodeTab(authViewModel: AuthViewModel) {
    var friendCode by remember { mutableStateOf<String?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    val friendsViewModel = remember { FriendsViewModel(authViewModel) }
    
    LaunchedEffect(Unit) {
        isLoading = true
        friendsViewModel.getMyFriendCode { code ->
            friendCode = code
            isLoading = false
        }
    }
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(CosmicSpacing.XL),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(CosmicSpacing.XL)
    ) {
        Text("📱", fontSize = 80.sp)
        Text(
            "My Friend Code",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = CosmicColors.NebulaPurple
        )
        Text(
            "Share this code with friends so they can add you!",
            color = CosmicColors.TextSecondary,
            textAlign = TextAlign.Center
        )
        
        if (isLoading) {
            CircularProgressIndicator(color = CosmicColors.NebulaPurple)
        } else {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = CosmicColors.GlassBackground
                )
            ) {
                Text(
                    text = friendCode ?: "Loading...",
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace,
                    textAlign = TextAlign.Center,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(CosmicSpacing.L)
                )
            }
            
            Button(
                onClick = { /* TODO: Share code */ },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = CosmicColors.NebulaPurple
                )
            ) {
                Icon(Icons.Default.Share, "Share")
                Spacer(modifier = Modifier.width(CosmicSpacing.S))
                Text("Share Code")
            }
        }
    }
}

@Composable
fun EnterFriendCodeTab(
    authViewModel: AuthViewModel,
    friendsViewModel: FriendsViewModel,
    onDismiss: () -> Unit
) {
    var enteredCode by remember { mutableStateOf("") }
    var isAdding by remember { mutableStateOf(false) }
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(CosmicSpacing.XL),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(CosmicSpacing.XL)
    ) {
        Text("⌨️", fontSize = 80.sp)
        Text(
            "Enter Friend Code",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = CosmicColors.NebulaPurple
        )
        Text(
            "Type in your friend's 8-character code",
            color = CosmicColors.TextSecondary,
            textAlign = TextAlign.Center
        )
        
        OutlinedTextField(
            value = enteredCode,
            onValueChange = { 
                // Limit to 8 characters and uppercase
                enteredCode = it.take(8).uppercase()
            },
            modifier = Modifier.fillMaxWidth(),
            placeholder = { Text("Enter 8-character code") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text),
            textStyle = androidx.compose.ui.text.TextStyle(
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold,
                fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace,
                textAlign = TextAlign.Center
            ),
            shape = RoundedCornerShape(CosmicCornerRadius.Large),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = CosmicColors.NebulaPurple,
                unfocusedBorderColor = CosmicColors.TextMuted
            )
        )
        
        Button(
            onClick = {
                if (enteredCode.length == 8) {
                    isAdding = true
                    friendsViewModel.addFriendByCode(enteredCode) { success ->
                        isAdding = false
                        if (success) {
                            onDismiss()
                        }
                    }
                }
            },
            modifier = Modifier.fillMaxWidth(),
            enabled = enteredCode.length == 8 && !isAdding,
            colors = ButtonDefaults.buttonColors(
                containerColor = CosmicColors.NebulaPurple
            )
        ) {
            if (isAdding) {
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    color = CosmicColors.TextPrimary
                )
            } else {
                Text("✅ Add Friend", fontWeight = FontWeight.Bold)
            }
        }
    }
}

