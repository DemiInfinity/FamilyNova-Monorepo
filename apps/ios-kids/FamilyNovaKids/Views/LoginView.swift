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
        ZStack {
            // Fun gradient background
            LinearGradient(
                colors: [AppColors.gradientBlue.opacity(0.2), AppColors.gradientPurple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Logo
                    VStack(spacing: AppSpacing.m) {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("Welcome to FamilyNova!")
                            .font(AppFonts.title)
                            .foregroundColor(AppColors.primaryPurple)
                            .multilineTextAlignment(.center)
                        Text("A safe place to connect with friends and learn!")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.xl)
                    }
                    .padding(.top, AppSpacing.xxl)
                    .padding(.bottom, AppSpacing.xl)
                
                // Email Input
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    Text("Email")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.darkGray)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.plain)
                        .foregroundColor(AppColors.black)
                        .padding(AppSpacing.m)
                        .background(Color.white)
                        .cornerRadius(AppCornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.mediumGray, lineWidth: 1)
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                .padding(.top, AppSpacing.xxl)
                .padding(.horizontal, AppSpacing.l)
                
                // Password Input
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    Text("Password")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.darkGray)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.plain)
                        .foregroundColor(AppColors.black)
                        .padding(AppSpacing.m)
                        .background(Color.white)
                        .cornerRadius(AppCornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.mediumGray, lineWidth: 1)
                        )
                        .autocorrectionDisabled()
                }
                .padding(.top, AppSpacing.m)
                .padding(.horizontal, AppSpacing.l)
                
                    // Login Button - Big and colorful
                    Button(action: handleLogin) {
                        HStack(spacing: AppSpacing.s) {
                            Text("🚀")
                                .font(.system(size: 24))
                            Text("Login")
                                .font(AppFonts.button)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(AppCornerRadius.large)
                        .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, AppSpacing.xl)
                    .padding(.horizontal, AppSpacing.l)
                    .disabled(isLoading)
                }
                .padding(.bottom, AppSpacing.xxl)
            }
        }
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
}


#Preview {
    LoginView()
        .environmentObject(AuthManager())
}

