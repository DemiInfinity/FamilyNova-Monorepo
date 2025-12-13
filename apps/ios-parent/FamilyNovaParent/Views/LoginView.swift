//
//  LoginView.swift
//  FamilyNovaParent
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Logo/Icon Area - Using FamilyNova logo (shield represents protection/monitoring)
                Image(systemName: "person.2.badge.shield.checkmark.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(ParentAppColors.primaryNavy)
                    .padding(.top, ParentAppSpacing.xxl)
                    // TODO: Replace with custom FamilyNova logo asset when available
                
                // Title
                Text("Parent Portal")
                    .font(ParentAppFonts.title)
                    .foregroundColor(ParentAppColors.primaryNavy)
                    .padding(.top, ParentAppSpacing.l)
                
                // Subtitle
                Text("Monitor and protect your child's online experience")
                    .font(ParentAppFonts.body)
                    .foregroundColor(ParentAppColors.darkGray)
                    .multilineTextAlignment(.center)
                    .padding(.top, ParentAppSpacing.s)
                    .padding(.horizontal, ParentAppSpacing.l)
                
                // Email Input
                VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                    Text("Email")
                        .font(ParentAppFonts.caption)
                        .foregroundColor(ParentAppColors.darkGray)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding(.top, ParentAppSpacing.xxl)
                .padding(.horizontal, ParentAppSpacing.l)
                
                // Password Input
                VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                    Text("Password")
                        .font(ParentAppFonts.caption)
                        .foregroundColor(ParentAppColors.darkGray)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedTextFieldStyle())
                }
                .padding(.top, ParentAppSpacing.m)
                .padding(.horizontal, ParentAppSpacing.l)
                
                // Login Button
                Button(action: handleLogin) {
                    Text("Login")
                        .font(ParentAppFonts.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(ParentAppColors.primaryTeal)
                        .cornerRadius(ParentAppCornerRadius.medium)
                }
                .padding(.top, ParentAppSpacing.xl)
                .padding(.horizontal, ParentAppSpacing.l)
                .disabled(isLoading)
                
                // Register Button
                Button(action: handleRegister) {
                    Text("Create Account")
                        .font(ParentAppFonts.headline)
                        .foregroundColor(ParentAppColors.primaryTeal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                .stroke(ParentAppColors.primaryTeal, lineWidth: 2)
                        )
                }
                .padding(.top, ParentAppSpacing.m)
                .padding(.horizontal, ParentAppSpacing.l)
                .disabled(isLoading)
            }
            .padding(.bottom, ParentAppSpacing.xxl)
        }
        .background(ParentAppColors.lightGray)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email"
            showError = true
            return
        }
        
        isLoading = true
        Task {
            do {
                try await authManager.login(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
    
    private func handleRegister() {
        // TODO: Navigate to registration
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(ParentAppSpacing.m)
            .background(Color.white)
            .cornerRadius(ParentAppCornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                    .stroke(ParentAppColors.mediumGray, lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}

