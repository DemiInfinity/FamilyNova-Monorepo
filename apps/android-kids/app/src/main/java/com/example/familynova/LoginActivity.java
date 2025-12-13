package com.example.familynova;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;
import com.example.familynova.api.ApiClient;
import com.example.familynova.api.AuthApi;
import com.example.familynova.utils.Encryption;
import com.google.gson.Gson;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import java.util.HashMap;
import java.util.Map;

public class LoginActivity extends AppCompatActivity {
    
    private TextInputLayout emailLayout;
    private TextInputLayout passwordLayout;
    private TextInputEditText emailInput;
    private TextInputEditText passwordInput;
    private MaterialButton loginButton;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        
        // Check if user is already logged in
        SharedPreferences prefs = getSharedPreferences("FamilyNova", MODE_PRIVATE);
        if (prefs.getString("token", null) != null) {
            startActivity(new Intent(this, MainActivity.class));
            finish();
            return;
        }
        
        initializeViews();
        setupListeners();
    }
    
    private void initializeViews() {
        emailLayout = findViewById(R.id.emailLayout);
        passwordLayout = findViewById(R.id.passwordLayout);
        emailInput = findViewById(R.id.emailInput);
        passwordInput = findViewById(R.id.passwordInput);
        loginButton = findViewById(R.id.loginButton);
    }
    
    private void setupListeners() {
        loginButton.setOnClickListener(v -> {
            String email = emailInput.getText() != null ? emailInput.getText().toString().trim() : "";
            String password = passwordInput.getText() != null ? passwordInput.getText().toString() : "";
            
            if (validateInput(email, password)) {
                performLogin(email, password);
            }
        });
    }
    
    private void performLogin(String email, String password) {
        try {
            // Create request body
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("email", email);
            requestBody.put("password", password);
            
            // Convert to JSON string
            String jsonBody = new Gson().toJson(requestBody);
            
            // Encrypt the JSON string
            String encryptedData = Encryption.encrypt(jsonBody);
            
            // Create encrypted request
            Map<String, Object> encryptedRequest = new HashMap<>();
            encryptedRequest.put("encrypted", encryptedData);
            
            // Make API call
            AuthApi authApi = ApiClient.getClient(this).create(AuthApi.class);
            Call<Map<String, Object>> call = authApi.login(encryptedRequest);
            
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
                                SharedPreferences prefs = getSharedPreferences("FamilyNova", MODE_PRIVATE);
                                prefs.edit().putString("token", token).apply();
                                
                                if (session.containsKey("refresh_token")) {
                                    prefs.edit().putString("refreshToken", (String) session.get("refresh_token")).apply();
                                }
                                
                                // Navigate to main activity
                                startActivity(new Intent(LoginActivity.this, MainActivity.class));
                                finish();
                                return;
                            }
                        }
                    }
                    
                    // Handle error
                    String errorMsg = "Login failed";
                    if (response.body() != null && response.body().containsKey("error")) {
                        errorMsg = (String) response.body().get("error");
                    }
                    Toast.makeText(LoginActivity.this, errorMsg, Toast.LENGTH_SHORT).show();
                }
                
                @Override
                public void onFailure(Call<Map<String, Object>> call, Throwable t) {
                    Toast.makeText(LoginActivity.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {
            Toast.makeText(this, "Encryption error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }
    
    private boolean validateInput(String email, String password) {
        boolean isValid = true;
        
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
        
        return isValid;
    }
}

