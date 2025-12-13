//
//  CreateChildAccountView.swift
//  FamilyNovaParent
//

import SwiftUI

struct CreateChildAccountView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var dateOfBirth = Date()
    @State private var school = ""
    @State private var grade = ""
    @State private var isCreating = false
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
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(ParentAppColors.primaryTeal)
                            Text("Create Child Account")
                                .font(ParentAppFonts.title)
                                .foregroundColor(ParentAppColors.primaryNavy)
                            Text("Create a safe account for your child")
                                .font(ParentAppFonts.body)
                                .foregroundColor(ParentAppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, ParentAppSpacing.xl)
                        }
                        .padding(.top, ParentAppSpacing.xl)
                        
                        // Form
                        VStack(spacing: ParentAppSpacing.m) {
                            // Name Fields
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
                            
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("Display Name")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                TextField("Display Name (optional)", text: $displayName)
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
                            
                            // Optional Fields
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("Date of Birth")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(ParentAppCornerRadius.medium)
                            }
                            
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("School")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                TextField("School Name (optional)", text: $school)
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
                            
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("Grade")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                TextField("Grade (optional)", text: $grade)
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
                        
                        // Create Button
                        Button(action: createChildAccount) {
                            HStack(spacing: ParentAppSpacing.s) {
                                if isCreating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "person.badge.plus")
                                    Text("Create Account")
                                        .font(ParentAppFonts.button)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                isFormValid ? ParentAppColors.primaryTeal : ParentAppColors.mediumGray
                            )
                            .cornerRadius(ParentAppCornerRadius.large)
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        .disabled(!isFormValid || isCreating)
                        
                        // Info Text
                        VStack(spacing: ParentAppSpacing.xs) {
                            Text("ℹ️")
                                .font(.system(size: 24))
                            Text("The account will be automatically verified by you as the parent.")
                                .font(ParentAppFonts.caption)
                                .foregroundColor(ParentAppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, ParentAppSpacing.xl)
                        }
                        .padding(.top, ParentAppSpacing.s)
                        .padding(.bottom, ParentAppSpacing.xl)
                    }
                }
            }
            .navigationTitle("Create Child Account")
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
                Text("Child account created successfully! Your child can now log in with their email and password.")
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
    
    private func createChildAccount() {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields correctly"
            showError = true
            return
        }
        
        isCreating = true
        Task {
            // TODO: Implement API call to create child account
            // POST /api/parents/children/create
            // Body: { email, password, firstName, lastName, displayName, dateOfBirth, school, grade }
            
            // Simulate API call
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            isCreating = false
            showSuccess = true
        }
    }
}

#Preview {
    CreateChildAccountView()
        .environmentObject(AuthManager())
}

