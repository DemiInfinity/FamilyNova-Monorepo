package com.nova.parent.ui.screens

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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.nova.parent.design.ParentAppColors
import com.nova.parent.design.ParentAppCornerRadius
import com.nova.parent.design.ParentAppSpacing
import com.nova.parent.viewmodels.AuthViewModel

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
            .background(ParentAppColors.LightGray)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(ParentAppSpacing.L),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(ParentAppSpacing.XXL))
            
            // Logo/Title
            Text(
                text = "Nova+",
                fontSize = 48.sp,
                fontWeight = FontWeight.Bold,
                color = ParentAppColors.PrimaryNavy
            )
            
            Text(
                text = "Parent Portal",
                fontSize = 24.sp,
                fontWeight = FontWeight.SemiBold,
                color = ParentAppColors.PrimaryNavy,
                modifier = Modifier.padding(top = ParentAppSpacing.M)
            )
            
            Text(
                text = "Monitor and protect your child's online experience",
                fontSize = 14.sp,
                color = ParentAppColors.DarkGray,
                modifier = Modifier.padding(top = ParentAppSpacing.S)
            )
            
            Spacer(modifier = Modifier.height(ParentAppSpacing.XXL))
            
            // Email Input
            OutlinedTextField(
                value = email,
                onValueChange = { email = it },
                label = { Text("Email") },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = ParentAppSpacing.L),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = ParentAppColors.PrimaryTeal,
                    unfocusedBorderColor = ParentAppColors.MediumGray
                ),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                singleLine = true
            )
            
            Spacer(modifier = Modifier.height(ParentAppSpacing.M))
            
            // Password Input
            OutlinedTextField(
                value = password,
                onValueChange = { password = it },
                label = { Text("Password") },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = ParentAppSpacing.L),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = ParentAppColors.PrimaryTeal,
                    unfocusedBorderColor = ParentAppColors.MediumGray
                ),
                visualTransformation = PasswordVisualTransformation(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                singleLine = true
            )
            
            // Error message
            if (errorMessage != null) {
                Text(
                    text = errorMessage ?: "",
                    color = MaterialTheme.colorScheme.error,
                    fontSize = 12.sp,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = ParentAppSpacing.L, vertical = ParentAppSpacing.S)
                )
            }
            
            Spacer(modifier = Modifier.height(ParentAppSpacing.XL))
            
            // Login Button
            Button(
                onClick = {
                    authViewModel.login(email, password)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = ParentAppSpacing.L)
                    .height(56.dp),
                enabled = !isLoading && email.isNotBlank() && password.isNotBlank(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = ParentAppColors.PrimaryTeal
                ),
                shape = RoundedCornerShape(ParentAppCornerRadius.Medium)
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(20.dp),
                        color = Color.White
                    )
                } else {
                    Text(
                        "Login",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(ParentAppSpacing.M))
            
            // Register Link
            TextButton(onClick = onNavigateToRegister) {
                Text(
                    "Create Account",
                    color = ParentAppColors.PrimaryTeal
                )
            }
            
            Spacer(modifier = Modifier.height(ParentAppSpacing.XXL))
        }
    }
}
