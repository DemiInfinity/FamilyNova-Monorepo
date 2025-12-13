package com.example.familynovaparent;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;
import com.example.familynovaparent.api.ApiClient;
import com.example.familynovaparent.api.AuthApi;
import com.example.familynovaparent.utils.Encryption;
import com.google.gson.Gson;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import java.util.HashMap;
import java.util.Map;

public class RegisterActivity extends AppCompatActivity {
    
    private TextInputLayout firstNameLayout;
    private TextInputLayout lastNameLayout;
    private TextInputLayout emailLayout;
    private TextInputLayout passwordLayout;
    private TextInputLayout confirmPasswordLayout;
    private TextInputEditText firstNameInput;
    private TextInputEditText lastNameInput;
    private TextInputEditText emailInput;
    private TextInputEditText passwordInput;
    private TextInputEditText confirmPasswordInput;
    private MaterialButton registerButton;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);
        
        initializeViews();
        setupListeners();
    }
    
    private void initializeViews() {
        firstNameLayout = findViewById(R.id.firstNameLayout);
        lastNameLayout = findViewById(R.id.lastNameLayout);
        emailLayout = findViewById(R.id.emailLayout);
        passwordLayout = findViewById(R.id.passwordLayout);
        confirmPasswordLayout = findViewById(R.id.confirmPasswordLayout);
        firstNameInput = findViewById(R.id.firstNameInput);
        lastNameInput = findViewById(R.id.lastNameInput);
        emailInput = findViewById(R.id.emailInput);
        passwordInput = findViewById(R.id.passwordInput);
        confirmPasswordInput = findViewById(R.id.confirmPasswordInput);
        registerButton = findViewById(R.id.registerButton);
    }
    
    private void setupListeners() {
        registerButton.setOnClickListener(v -> {
            String firstName = firstNameInput.getText() != null ? firstNameInput.getText().toString().trim() : "";
            String lastName = lastNameInput.getText() != null ? lastNameInput.getText().toString().trim() : "";
            String email = emailInput.getText() != null ? emailInput.getText().toString().trim() : "";
            String password = passwordInput.getText() != null ? passwordInput.getText().toString() : "";
            String confirmPassword = confirmPasswordInput.getText() != null ? confirmPasswordInput.getText().toString() : "";
            
            if (validateInput(firstName, lastName, email, password, confirmPassword)) {
                performRegistration(firstName, lastName, email, password);
            }
        });
    }
    
    private boolean validateInput(String firstName, String lastName, String email, String password, String confirmPassword) {
        boolean isValid = true;
        
        if (firstName.isEmpty()) {
            firstNameLayout.setError("First name is required");
            isValid = false;
        } else {
            firstNameLayout.setError(null);
        }
        
        if (lastName.isEmpty()) {
            lastNameLayout.setError("Last name is required");
            isValid = false;
        } else {
            lastNameLayout.setError(null);
        }
        
        if (email.isEmpty()) {
            emailLayout.setError("Email is required");
            isValid = false;
        } else if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            emailLayout.setError("Invalid email format");
            isValid = false;
        } else {
            emailLayout.setError(null);
        }
        
        if (password.isEmpty()) {
            passwordLayout.setError("Password is required");
            isValid = false;
        } else if (password.length() < 6) {
            passwordLayout.setError("Password must be at least 6 characters");
            isValid = false;
        } else {
            passwordLayout.setError(null);
        }
        
        if (!password.equals(confirmPassword)) {
            confirmPasswordLayout.setError("Passwords do not match");
            isValid = false;
        } else {
            confirmPasswordLayout.setError(null);
        }
        
        return isValid;
    }
    
    private void performRegistration(String firstName, String lastName, String email, String password) {
        try {
            // Create request body
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("email", email);
            requestBody.put("password", password);
            requestBody.put("userType", "parent");
            requestBody.put("firstName", firstName);
            requestBody.put("lastName", lastName);
            
            // Convert to JSON string
            String jsonBody = new Gson().toJson(requestBody);
            
            // Encrypt the JSON string
            String encryptedData = Encryption.encrypt(jsonBody);
            
            // Create encrypted request
            Map<String, Object> encryptedRequest = new HashMap<>();
            encryptedRequest.put("encrypted", encryptedData);
            
            // Make API call
            AuthApi authApi = ApiClient.getClient(this).create(AuthApi.class);
            Call<Map<String, Object>> call = authApi.register(encryptedRequest);
            
            call.enqueue(new Callback<Map<String, Object>>() {
                @Override
                public void onResponse(Call<Map<String, Object>> call, Response<Map<String, Object>> response) {
                    if (response.isSuccessful() && response.body() != null) {
                        Map<String, Object> body = response.body();
                        
                        // Extract session token
                        if (body.containsKey("session")) {
                            Map<String, Object> session = (Map<String, Object>) body.get("session");
                            if (session != null && session.containsKey("access_token")) {
                                String token = (String) session.get("access_token");
                                
                                // Save token
                                SharedPreferences prefs = getSharedPreferences("FamilyNovaParent", MODE_PRIVATE);
                                prefs.edit().putString("token", token).apply();
                                
                                if (session.containsKey("refresh_token")) {
                                    prefs.edit().putString("refreshToken", (String) session.get("refresh_token")).apply();
                                }
                                
                                // Navigate to main activity
                                startActivity(new Intent(RegisterActivity.this, MainActivity.class));
                                finish();
                                return;
                            }
                        }
                    }
                    
                    // Handle error
                    String errorMsg = "Registration failed";
                    if (response.body() != null && response.body().containsKey("error")) {
                        errorMsg = (String) response.body().get("error");
                    }
                    Toast.makeText(RegisterActivity.this, errorMsg, Toast.LENGTH_SHORT).show();
                }
                
                @Override
                public void onFailure(Call<Map<String, Object>> call, Throwable t) {
                    Toast.makeText(RegisterActivity.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {
            Toast.makeText(this, "Encryption error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }
}

