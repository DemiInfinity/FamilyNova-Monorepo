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
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.nova.kids.design.CosmicColors
import com.nova.kids.design.CosmicCornerRadius
import com.nova.kids.design.CosmicSpacing
import com.nova.kids.viewmodels.AuthViewModel

@Composable
fun RegistrationScreen(
    authViewModel: AuthViewModel,
    onRegistrationSuccess: () -> Unit,
    onNavigateToLogin: () -> Unit
) {
    var firstName by remember { mutableStateOf("") }
    var lastName by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var displayName by remember { mutableStateOf("") }
    val isLoading by authViewModel.isLoading.collectAsState()
    val errorMessage by authViewModel.errorMessage.collectAsState()
    
    val isAuthenticated by authViewModel.isAuthenticated.collectAsState()
    
    LaunchedEffect(isAuthenticated) {
        if (isAuthenticated) {
            onRegistrationSuccess()
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
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(CosmicSpacing.XXL))
            
            // Logo/Title
            Text(
                text = "Join Nova",
                fontSize = 36.sp,
                fontWeight = FontWeight.Bold,
                color = CosmicColors.NebulaPurple
            )
            
            Text(
                text = "Create your account to get started!",
                fontSize = 16.sp,
                color = CosmicColors.TextSecondary,
                modifier = Modifier.padding(top = CosmicSpacing.S)
            )
            
            Spacer(modifier = Modifier.height(CosmicSpacing.XXL))
            
            // Form Fields
            OutlinedTextField(
                value = firstName,
                onValueChange = { firstName = it },
                label = { Text("First Name", color = CosmicColors.TextSecondary) },
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
                singleLine = true
            )
            
            Spacer(modifier = Modifier.height(CosmicSpacing.M))
            
            OutlinedTextField(
                value = lastName,
                onValueChange = { lastName = it },
                label = { Text("Last Name", color = CosmicColors.TextSecondary) },
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
                singleLine = true
            )
            
            Spacer(modifier = Modifier.height(CosmicSpacing.M))
            
            OutlinedTextField(
                value = displayName,
                onValueChange = { displayName = it },
                label = { Text("Display Name (Optional)", color = CosmicColors.TextSecondary) },
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
                singleLine = true
            )
            
            Spacer(modifier = Modifier.height(CosmicSpacing.M))
            
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
            
            Spacer(modifier = Modifier.height(CosmicSpacing.M))
            
            OutlinedTextField(
                value = confirmPassword,
                onValueChange = { confirmPassword = it },
                label = { Text("Confirm Password", color = CosmicColors.TextSecondary) },
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
            
            // Error message
            if (errorMessage.isNotEmpty()) {
                Text(
                    text = errorMessage,
                    color = MaterialTheme.colorScheme.error,
                    fontSize = 12.sp,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = CosmicSpacing.L, vertical = CosmicSpacing.S)
                )
            }
            
            Spacer(modifier = Modifier.height(CosmicSpacing.XL))
            
            // Register Button
            Button(
                onClick = {
                    if (password == confirmPassword) {
                        authViewModel.register(
                            email = email,
                            password = password,
                            firstName = firstName,
                            lastName = lastName,
                            displayName = if (displayName.isBlank()) "$firstName $lastName" else displayName
                        )
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = CosmicSpacing.L)
                    .height(56.dp),
                enabled = !isLoading && firstName.isNotBlank() && lastName.isNotBlank() && 
                         email.isNotBlank() && password.length >= 6 && password == confirmPassword,
                colors = ButtonDefaults.buttonColors(
                    containerColor = CosmicColors.NebulaPurple
                ),
                shape = RoundedCornerShape(CosmicCornerRadius.Medium)
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(20.dp),
                        color = CosmicColors.TextPrimary
                    )
                } else {
                    Text(
                        "Create Account",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(CosmicSpacing.M))
            
            // Login Link
            TextButton(onClick = onNavigateToLogin) {
                Text(
                    "Already have an account? Log in",
                    color = CosmicColors.NebulaPurple
                )
            }
            
            Spacer(modifier = Modifier.height(CosmicSpacing.XXL))
        }
    }
}

