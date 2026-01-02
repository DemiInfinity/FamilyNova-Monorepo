package com.nova.parent.ui.screens

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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.nova.parent.design.ParentAppColors
import com.nova.parent.design.ParentAppCornerRadius
import com.nova.parent.design.ParentAppSpacing
import com.nova.parent.viewmodels.AuthViewModel
import com.nova.parent.viewmodels.CreateChildViewModel
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateChildAccountScreen(
    authViewModel: AuthViewModel,
    onSuccess: () -> Unit = {},
    onDismiss: () -> Unit = {}
) {
    val createChildViewModel: CreateChildViewModel = viewModel()

    var firstName by remember { mutableStateOf("") }
    var lastName by remember { mutableStateOf("") }
    var displayName by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var school by remember { mutableStateOf("") }
    var grade by remember { mutableStateOf("") }

    val isCreating by createChildViewModel.isCreating.collectAsState()
    val isSuccess by createChildViewModel.isSuccess.collectAsState()
    val errorMessage by createChildViewModel.errorMessage.collectAsState()

    LaunchedEffect(isSuccess) {
        if (isSuccess) {
            onSuccess()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Create Child Account") },
                navigationIcon = {
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, "Close")
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
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(ParentAppSpacing.L),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Header
                Icon(
                    Icons.Default.PersonAdd,
                    contentDescription = null,
                    modifier = Modifier.size(48.dp),
                    tint = ParentAppColors.PrimaryTeal
                )

                Text(
                    text = "Create Child Account",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = ParentAppColors.PrimaryNavy,
                    modifier = Modifier.padding(top = ParentAppSpacing.M)
                )

                Text(
                    text = "Create a safe account for your child",
                    fontSize = 14.sp,
                    color = ParentAppColors.DarkGray,
                    modifier = Modifier.padding(top = ParentAppSpacing.S)
                )

                Spacer(modifier = Modifier.height(ParentAppSpacing.XL))

                // Form Fields
                OutlinedTextField(
                    value = firstName,
                    onValueChange = { firstName = it },
                    label = { Text("First Name *") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )

                Spacer(modifier = Modifier.height(ParentAppSpacing.M))

                OutlinedTextField(
                    value = lastName,
                    onValueChange = { lastName = it },
                    label = { Text("Last Name *") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )

                Spacer(modifier = Modifier.height(ParentAppSpacing.M))

                OutlinedTextField(
                    value = displayName,
                    onValueChange = { displayName = it },
                    label = { Text("Display Name (Optional)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )

                Spacer(modifier = Modifier.height(ParentAppSpacing.M))

                OutlinedTextField(
                    value = email,
                    onValueChange = { email = it },
                    label = { Text("Email *") },
                    modifier = Modifier.fillMaxWidth(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                    singleLine = true
                )

                Spacer(modifier = Modifier.height(ParentAppSpacing.M))

                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    label = { Text("Password *") },
                    modifier = Modifier.fillMaxWidth(),
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    singleLine = true
                )

                Spacer(modifier = Modifier.height(ParentAppSpacing.M))

                OutlinedTextField(
                    value = confirmPassword,
                    onValueChange = { confirmPassword = it },
                    label = { Text("Confirm Password *") },
                    modifier = Modifier.fillMaxWidth(),
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    singleLine = true
                )

                Spacer(modifier = Modifier.height(ParentAppSpacing.M))

                OutlinedTextField(
                    value = school,
                    onValueChange = { school = it },
                    label = { Text("School (Optional)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )

                Spacer(modifier = Modifier.height(ParentAppSpacing.M))

                OutlinedTextField(
                    value = grade,
                    onValueChange = { grade = it },
                    label = { Text("Grade (Optional)") },
                    modifier = Modifier.fillMaxWidth(),
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
                            .padding(vertical = ParentAppSpacing.S)
                    )
                }

                Spacer(modifier = Modifier.height(ParentAppSpacing.XL))

                // Create Button
                Button(
                    onClick = {
                        if (password == confirmPassword) {
                            createChildViewModel.createChild(
                                email = email,
                                password = password,
                                firstName = firstName,
                                lastName = lastName,
                                displayName = if (displayName.isBlank()) null else displayName,
                                dateOfBirth = null, // TODO: Add date picker
                                school = if (school.isBlank()) null else school,
                                grade = if (grade.isBlank()) null else grade
                            )
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    enabled = !isCreating && firstName.isNotBlank() && lastName.isNotBlank() &&
                            email.isNotBlank() && password.length >= 6 && password == confirmPassword,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = ParentAppColors.PrimaryTeal
                    ),
                    shape = RoundedCornerShape(ParentAppCornerRadius.Medium)
                ) {
                    if (isCreating) {
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
            }
        }
    }
}
