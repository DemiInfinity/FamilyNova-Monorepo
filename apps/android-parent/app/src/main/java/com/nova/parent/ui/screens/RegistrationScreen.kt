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
fun RegistrationScreen(
    authViewModel: AuthViewModel,
    onRegistrationSuccess: () -> Unit,
    onNavigateToLogin: () -> Unit
) {
    var firstName by remember { mutableStateOf("") }
    var lastName by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
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
            
            Text(
                text = "Create Parent Account",
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = ParentAppColors.PrimaryNavy
            )
            
            Text(
                text = "Sign up to start monitoring and protecting your children's online experience",
                fontSize = 14.sp,
                color = ParentAppColors.DarkGray,
                modifier = Modifier.padding(top = ParentAppSpacing.S)
            )
            
            Spacer(modifier = Modifier.height(ParentAppSpacing.XXL))
            
            // First Name
            OutlinedTextField(
                value = firstName,
                onValueChange = { firstName = it },
                label = { Text("First Name *") },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = ParentAppSpacing.L),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = ParentAppColors.PrimaryTeal,
                    unfocusedBorderColor = ParentAppColors.MediumGray
                ),
                singleLine = true
            )
            
            Spacer(modifier = Modifier.height(ParentAppSpacing.M))
            
            // Last Name
            OutlinedTextField(
                value = lastName,
                onValueChange = { lastName = it },
                label = { Text("Last Name *") },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = ParentAppSpacing.L),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = ParentAppColors.PrimaryTeal,
                    unfocusedBorderColor = ParentAppColors.MediumGray
                ),
                singleLine = true
            )
            
            Spacer(modifier = Modifier.height(ParentAppSpacing.M))
            
            // Email
            OutlinedTextField(
                value = email,
                onValueChange = { email = it },
                label = { Text("Email *") },
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
            
            // Password
            OutlinedTextField(
                value = password,
                onValueChange = { password = it },
                label = { Text("Password *") },
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
            
            // Register Button
            Button(
                onClick = {
                    authViewModel.register(email, password, firstName, lastName)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = ParentAppSpacing.L)
                    .height(56.dp),
                enabled = !isLoading && firstName.isNotBlank() && lastName.isNotBlank() && 
                         email.isNotBlank() && password.length >= 6,
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
                        "Create Account",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(ParentAppSpacing.M))
            
            // Login Link
            TextButton(onClick = onNavigateToLogin) {
                Text(
                    "Already have an account? Log in",
                    color = ParentAppColors.PrimaryTeal
                )
            }
            
            Spacer(modifier = Modifier.height(ParentAppSpacing.XXL))
        }
    }
}

