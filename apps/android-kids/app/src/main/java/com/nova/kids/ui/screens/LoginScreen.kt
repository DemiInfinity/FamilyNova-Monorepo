package com.nova.kids.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.BorderStroke
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.QrCode
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.nova.kids.design.CosmicColors
import com.nova.kids.design.CosmicCornerRadius
import com.nova.kids.design.CosmicSpacing
import com.nova.kids.viewmodels.AuthViewModel

@Composable
fun LoginScreen(
    authViewModel: AuthViewModel,
    onLoginSuccess: () -> Unit,
    onNavigateToRegister: () -> Unit
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var showQRScanner by remember { mutableStateOf(false) }
    var showManualCodeEntry by remember { mutableStateOf(false) }
    var manualCode by remember { mutableStateOf("") }
    val isLoading by authViewModel.isLoading.collectAsState()
    val errorMessage by authViewModel.errorMessage.collectAsState()
    
    val isAuthenticated by authViewModel.isAuthenticated.collectAsState()
    
    LaunchedEffect(isAuthenticated) {
        if (isAuthenticated) {
            onLoginSuccess()
        }
    }
    
    if (showQRScanner) {
        QRCodeScannerScreen(
            onCodeScanned = { code ->
                if (code.length == 6) {
                    authViewModel.loginWithCode(code)
                }
            },
            onDismiss = { showQRScanner = false }
        )
        return
    }
    
    if (showManualCodeEntry) {
        AlertDialog(
            onDismissRequest = { showManualCodeEntry = false },
            title = { Text("Enter Login Code") },
            text = {
                OutlinedTextField(
                    value = manualCode,
                    onValueChange = { 
                        // Limit to 6 digits
                        manualCode = it.filter { it.isDigit() }.take(6)
                    },
                    label = { Text("6-digit code") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    placeholder = { Text("000000") }
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        if (manualCode.length == 6) {
                            authViewModel.loginWithCode(manualCode)
                            showManualCodeEntry = false
                            manualCode = ""
                        }
                    },
                    enabled = manualCode.length == 6
                ) {
                    Text("Login")
                }
            },
            dismissButton = {
                TextButton(onClick = { 
                    showManualCodeEntry = false
                    manualCode = ""
                }) {
                    Text("Cancel")
                }
            }
        )
    }
    
    Box(
        modifier = Modifier
            .fillMaxSize()
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
                .padding(CosmicSpacing.L),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Spacer(modifier = Modifier.height(CosmicSpacing.XXL))
            
            // Logo/Title
            Text(
                text = "Nova",
                fontSize = 48.sp,
                fontWeight = FontWeight.Bold,
                color = CosmicColors.NebulaPurple
            )
            
            Text(
                text = "A safe place to connect with friends!",
                fontSize = 16.sp,
                color = CosmicColors.TextSecondary,
                modifier = Modifier.padding(top = CosmicSpacing.M)
            )
            
            Spacer(modifier = Modifier.height(CosmicSpacing.XXL))
            
            // Email Input
            OutlinedTextField(
                value = email,
                onValueChange = { email = it },
                label = { Text("Email", color = CosmicColors.TextSecondary) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = CosmicSpacing.L),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = CosmicColors.TextPrimary,
                    unfocusedTextColor = CosmicColors.TextPrimary,
                    focusedBorderColor = CosmicColors.NebulaPurple,
                    unfocusedBorderColor = CosmicColors.TextMuted,
                    focusedLabelColor = CosmicColors.TextSecondary,
                    unfocusedLabelColor = CosmicColors.TextMuted
                ),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                singleLine = true
            )
            
            Spacer(modifier = Modifier.height(CosmicSpacing.M))
            
            // Password Input
            OutlinedTextField(
                value = password,
                onValueChange = { password = it },
                label = { Text("Password", color = CosmicColors.TextSecondary) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = CosmicSpacing.L),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = CosmicColors.TextPrimary,
                    unfocusedTextColor = CosmicColors.TextPrimary,
                    focusedBorderColor = CosmicColors.NebulaPurple,
                    unfocusedBorderColor = CosmicColors.TextMuted,
                    focusedLabelColor = CosmicColors.TextSecondary,
                    unfocusedLabelColor = CosmicColors.TextMuted
                ),
                visualTransformation = PasswordVisualTransformation(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                singleLine = true
            )
            
            // Error Message
            errorMessage?.let { error ->
                Text(
                    text = error,
                    color = CosmicColors.Error,
                    modifier = Modifier.padding(top = CosmicSpacing.M)
                )
            }
            
            Spacer(modifier = Modifier.height(CosmicSpacing.XL))
            
            // Login Button
            Button(
                onClick = { authViewModel.login(email, password) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = CosmicSpacing.L)
                    .height(56.dp),
                enabled = !isLoading && email.isNotBlank() && password.isNotBlank(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = CosmicColors.NebulaPurple
                ),
                shape = RoundedCornerShape(CosmicCornerRadius.Large)
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(24.dp),
                        color = CosmicColors.TextPrimary
                    )
                } else {
                    Text(
                        text = "Login",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(CosmicSpacing.M))
            
            // QR Code Login Button
            OutlinedButton(
                onClick = { showQRScanner = true },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = CosmicSpacing.L)
                    .height(50.dp),
                colors = ButtonDefaults.outlinedButtonColors(
                    contentColor = CosmicColors.NebulaPurple
                ),
                border = BorderStroke(2.dp, CosmicColors.NebulaPurple),
                shape = RoundedCornerShape(CosmicCornerRadius.Medium)
            ) {
                Icon(
                    imageVector = Icons.Default.QrCode,
                    contentDescription = "QR Code",
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(CosmicSpacing.S))
                Text("Scan QR Code", fontSize = 14.sp)
            }
            
            Spacer(modifier = Modifier.height(CosmicSpacing.S))
            
            // Manual Code Entry Button
            TextButton(onClick = { showManualCodeEntry = true }) {
                Text(
                    text = "Enter Code Manually",
                    color = CosmicColors.TextSecondary,
                    fontSize = 12.sp
                )
            }
            
            Spacer(modifier = Modifier.height(CosmicSpacing.M))
            
            // Register Link
            TextButton(onClick = onNavigateToRegister) {
                Text(
                    text = "Don't have an account? Register",
                    color = CosmicColors.NebulaBlue
                )
            }
        }
    }
}

