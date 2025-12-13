//
//  LoginView.swift
//  FamilyNovaKids
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
                // Logo/Icon Area - Using FamilyNova logo (person.2.fill represents friends/community)
                Image(systemName: "person.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(AppColors.primaryBlue)
                    .padding(.top, AppSpacing.xxl)
                    // TODO: Replace with custom FamilyNova logo asset when available
                
                // Title
                Text("Welcome to FamilyNova!")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryBlue)
                    .padding(.top, AppSpacing.l)
                
                // Subtitle
                Text("A safe place to connect with friends")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.darkGray)
                    .padding(.top, AppSpacing.s)
                
                // Email Input
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    Text("Email")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.darkGray)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding(.top, AppSpacing.xxl)
                .padding(.horizontal, AppSpacing.l)
                
                // Password Input
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    Text("Password")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.darkGray)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedTextFieldStyle())
                }
                .padding(.top, AppSpacing.m)
                .padding(.horizontal, AppSpacing.l)
                
                // Login Button
                Button(action: handleLogin) {
                    Text("Login")
                        .font(AppFonts.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.primaryBlue)
                        .cornerRadius(AppCornerRadius.medium)
                }
                .padding(.top, AppSpacing.xl)
                .padding(.horizontal, AppSpacing.l)
                .disabled(isLoading)
                
                // Register Button
                Button(action: handleRegister) {
                    Text("Create Account")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.primaryBlue, lineWidth: 2)
                        )
                }
                .padding(.top, AppSpacing.m)
                .padding(.horizontal, AppSpacing.l)
                .disabled(isLoading)
            }
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(AppColors.lightGray)
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
            .padding(AppSpacing.m)
            .background(Color.white)
            .cornerRadius(AppCornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(AppColors.mediumGray, lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}

