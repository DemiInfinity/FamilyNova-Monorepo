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
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var isCreating = false
    @State private var toast: ToastNotificationData? = nil
    
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
            .toastNotification($toast)
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
            ErrorHandler.shared.showError(NSError(domain: "ValidationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Please fill in all required fields correctly"]), toast: $toast)
            return
        }
        
        guard let token = authManager.token else {
            ErrorHandler.shared.showError(ApiError.invalidResponse, toast: $toast)
            return
        }
        
        isCreating = true
        Task {
            do {
                let apiService = ApiService.shared
                
                // Prepare request body
                var body: [String: Any] = [
                    "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
                    "password": password,
                    "firstName": firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                    "lastName": lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                ]
                
                if !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    body["displayName"] = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                // Format date of birth as ISO8601 string
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
                body["dateOfBirth"] = formatter.string(from: dateOfBirth)
                
                if !school.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    body["school"] = school.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                if !grade.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    body["grade"] = grade.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                // Make API call
                struct CreateChildResponse: Codable {
                    let message: String
                    let child: ChildResponse
                }
                
                struct ChildResponse: Codable {
                    let id: String
                    let email: String
                    let profile: ChildProfile
                    let verification: VerificationStatus
                }
                
                let _: CreateChildResponse = try await apiService.makeRequest(
                    endpoint: "parents/children/create",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                await MainActor.run {
                    isCreating = false
                    ErrorHandler.shared.showSuccess("Child account created successfully! Your child can now log in with their email and password.", toast: $toast)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                    ErrorHandler.shared.showError(error, toast: $toast)
                }
            }
        }
    }
}

#Preview {
    CreateChildAccountView()
        .environmentObject(AuthManager())
}

