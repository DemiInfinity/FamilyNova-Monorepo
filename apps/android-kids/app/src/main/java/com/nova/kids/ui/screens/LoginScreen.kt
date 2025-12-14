package com.nova.kids.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
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
    val isLoading by authViewModel.isLoading.collectAsState()
    val errorMessage by authViewModel.errorMessage.collectAsState()
    
    val isAuthenticated by authViewModel.isAuthenticated.collectAsState()
    
    LaunchedEffect(isAuthenticated) {
        if (isAuthenticated) {
            onLoginSuccess()
        }
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

