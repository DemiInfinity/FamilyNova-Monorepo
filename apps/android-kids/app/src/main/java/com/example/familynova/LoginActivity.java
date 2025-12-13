package com.example.familynova;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

public class LoginActivity extends AppCompatActivity {
    
    private TextInputLayout emailLayout;
    private TextInputLayout passwordLayout;
    private TextInputEditText emailInput;
    private TextInputEditText passwordInput;
    private MaterialButton loginButton;
    private MaterialButton registerButton;
    
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
        registerButton = findViewById(R.id.registerButton);
    }
    
    private void setupListeners() {
        loginButton.setOnClickListener(v -> {
            String email = emailInput.getText() != null ? emailInput.getText().toString().trim() : "";
            String password = passwordInput.getText() != null ? passwordInput.getText().toString() : "";
            
            if (validateInput(email, password)) {
                // TODO: Implement API call for login
                // For now, just navigate to main activity
                Toast.makeText(this, "Login functionality coming soon!", Toast.LENGTH_SHORT).show();
                startActivity(new Intent(this, MainActivity.class));
                finish();
            }
        });
        
        registerButton.setOnClickListener(v -> {
            // TODO: Navigate to registration screen
            Toast.makeText(this, "Registration coming soon!", Toast.LENGTH_SHORT).show();
        });
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

