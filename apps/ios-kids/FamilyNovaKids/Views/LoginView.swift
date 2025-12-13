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
    @State private var showQRScanner = false
    @State private var manualCode = ""
    @State private var showManualCodeEntry = false
    
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
                        
                        Text("Welcome to Nova!")
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
                    
                    // QR Code Login Button
                    Button(action: { showQRScanner = true }) {
                        HStack(spacing: AppSpacing.s) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 20))
                            Text("Scan QR Code")
                                .font(AppFonts.button)
                                .foregroundColor(AppColors.primaryPurple)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(AppCornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.primaryPurple, lineWidth: 2)
                        )
                    }
                    .padding(.top, AppSpacing.m)
                    .padding(.horizontal, AppSpacing.l)
                    
                    // Manual Code Entry Button
                    Button(action: { showManualCodeEntry = true }) {
                        Text("Enter Code Manually")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.darkGray)
                    }
                    .padding(.top, AppSpacing.s)
                }
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showQRScanner) {
            QRCodeScannerView(onCodeScanned: handleQRCode)
        }
        .alert("Enter Login Code", isPresented: $showManualCodeEntry) {
            TextField("6-digit code", text: $manualCode)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) {
                manualCode = ""
            }
            Button("Login") {
                if manualCode.count == 6 {
                    handleLoginCode(manualCode)
                } else {
                    errorMessage = "Please enter a 6-digit code"
                    showError = true
                }
            }
        } message: {
            Text("Enter the 6-digit code from the parent app")
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
    
    private func handleQRCode(_ code: String) {
        showQRScanner = false
        handleLoginCode(code)
    }
    
    private func handleLoginCode(_ code: String) {
        guard code.count == 6 else {
            errorMessage = "Invalid code format. Code must be 6 digits."
            showError = true
            return
        }
        
        isLoading = true
        Task {
            do {
                try await authManager.loginWithCode(code: code)
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                    print("Login code error: \(error)")
                }
            }
        }
    }
}


#Preview {
    LoginView()
        .environmentObject(AuthManager())
}

