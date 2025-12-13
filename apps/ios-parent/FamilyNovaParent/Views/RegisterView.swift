//
//  RegisterView.swift
//  FamilyNovaParent
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isRegistering = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ParentAppColors.lightGray
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: ParentAppSpacing.l) {
                        // Header
                        VStack(spacing: ParentAppSpacing.m) {
                            Image("Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .shadow(color: ParentAppColors.primaryNavy.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            Text("Create Parent Account")
                                .font(ParentAppFonts.title)
                                .foregroundColor(ParentAppColors.primaryNavy)
                            
                            Text("Sign up to start monitoring and protecting your children's online experience")
                                .font(ParentAppFonts.body)
                                .foregroundColor(ParentAppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, ParentAppSpacing.xl)
                        }
                        .padding(.top, ParentAppSpacing.xxl)
                        
                        // Form Fields
                        VStack(spacing: ParentAppSpacing.m) {
                            // First Name
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("First Name *")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                TextField("First Name", text: $firstName)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(ParentAppColors.black)
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(ParentAppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                            .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                                    )
                            }
                            
                            // Last Name
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("Last Name *")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                TextField("Last Name", text: $lastName)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(ParentAppColors.black)
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(ParentAppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                            .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                                    )
                            }
                            
                            // Email
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("Email *")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                TextField("Email", text: $email)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(ParentAppColors.black)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(ParentAppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                            .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                                    )
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("Password *")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                SecureField("Password (min 6 characters)", text: $password)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(ParentAppColors.black)
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(ParentAppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                            .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                                    )
                            }
                            
                            // Confirm Password
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("Confirm Password *")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                SecureField("Confirm Password", text: $confirmPassword)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(ParentAppColors.black)
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(ParentAppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                            .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        // Register Button
                        Button(action: handleRegister) {
                            HStack(spacing: ParentAppSpacing.s) {
                                if isRegistering {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create Account")
                                        .font(ParentAppFonts.button)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                isFormValid ? ParentAppColors.primaryTeal : ParentAppColors.mediumGray
                            )
                            .cornerRadius(ParentAppCornerRadius.medium)
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        .disabled(!isFormValid || isRegistering)
                        
                        // Info Text
                        VStack(spacing: ParentAppSpacing.xs) {
                            Text("ℹ️")
                                .font(.system(size: 24))
                            Text("After creating your account, you can add your children and start monitoring their online activity.")
                                .font(ParentAppFonts.caption)
                                .foregroundColor(ParentAppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, ParentAppSpacing.xl)
                        }
                        .padding(.top, ParentAppSpacing.s)
                        .padding(.bottom, ParentAppSpacing.xxl)
                    }
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(ParentAppFonts.button)
                    .foregroundColor(ParentAppColors.primaryTeal)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Account created successfully! You can now log in.")
            }
        }
    }
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    private func handleRegister() {
        guard isFormValid else {
            errorMessage = "Please fill in all fields correctly"
            showError = true
            return
        }
        
        isRegistering = true
        Task {
            do {
                try await authManager.register(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName
                )
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isRegistering = false
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthManager())
}

