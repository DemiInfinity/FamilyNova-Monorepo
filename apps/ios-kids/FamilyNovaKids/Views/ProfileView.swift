//
//  ProfileView.swift
//  FamilyNovaKids
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var displayName = "Display Name"
    @State private var email = "email@example.com"
    @State private var school = "School Name"
    @State private var grade = "Grade 5"
    @State private var parentVerified = true
    @State private var schoolVerified = false
    @State private var showEditProfile = false
    @State private var showSchoolCodeEntry = false
    @State private var pendingChanges = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fun gradient background
                LinearGradient(
                    colors: [AppColors.gradientBlue.opacity(0.1), AppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.m) {
                        // Profile Header
                        ProfileHeaderCard(
                            displayName: displayName,
                            email: email
                        )
                        .padding(.horizontal, AppSpacing.m)
                        .padding(.top, AppSpacing.m)
                    
                    // Verification Status
                    VerificationCard(
                        parentVerified: parentVerified,
                        schoolVerified: schoolVerified
                    )
                    .padding(.horizontal, AppSpacing.m)
                    
                    // School Code Entry (if not verified)
                    if !schoolVerified {
                        SchoolCodeEntryCard(showCodeEntry: $showSchoolCodeEntry)
                            .padding(.horizontal, AppSpacing.m)
                    }
                    
                    // Profile Info
                    ProfileInfoCard(
                        school: school,
                        grade: grade
                    )
                    .padding(.horizontal, AppSpacing.m)
                    
                    // Pending Changes Notice
                    if pendingChanges {
                        VStack(spacing: AppSpacing.s) {
                            HStack(spacing: AppSpacing.s) {
                                Text("⏳")
                                    .font(.system(size: 24))
                                Text("Profile changes pending parent approval")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.primaryOrange)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.m)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                .fill(AppColors.primaryOrange.opacity(0.1))
                        )
                        .padding(.horizontal, AppSpacing.m)
                    }
                    
                    // Edit Profile Button
                    Button(action: { showEditProfile = true }) {
                        HStack(spacing: AppSpacing.s) {
                            Text("✏️")
                                .font(.system(size: 24))
                            Text("Edit Profile")
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
                    .padding(.horizontal, AppSpacing.m)
                    .padding(.top, AppSpacing.m)
                    
        // Logout Button
        Button(action: handleLogout) {
            HStack(spacing: AppSpacing.s) {
                Text("👋")
                    .font(.system(size: 24))
                Text("Logout")
                    .font(AppFonts.button)
                    .foregroundColor(AppColors.error)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .stroke(AppColors.error, lineWidth: 3)
            )
            .shadow(color: AppColors.error.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal, AppSpacing.m)
        .padding(.top, AppSpacing.l)
                    }
                    .padding(.bottom, AppSpacing.l)
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(
                    currentDisplayName: displayName,
                    currentSchool: school,
                    currentGrade: grade,
                    onSave: { newDisplayName, newSchool, newGrade in
                        // Request profile change
                        requestProfileChange(
                            displayName: newDisplayName,
                            school: newSchool,
                            grade: newGrade
                        )
                    }
                )
            }
            .sheet(isPresented: $showSchoolCodeEntry) {
                SchoolCodeEntryView { code in
                    validateSchoolCode(code: code)
                }
            }
        }
    }
    
    private func requestProfileChange(displayName: String, school: String, grade: String) {
        // TODO: Implement API call to request profile change
        // POST /api/profile-changes/request
        pendingChanges = true
        showEditProfile = false
    }
    
    private func validateSchoolCode(code: String) {
        // TODO: Implement API call to validate school code
        // POST /api/school-codes/validate
        // Body: { code }
        schoolVerified = true
        showSchoolCodeEntry = false
    }
    
    private func handleLogout() {
        authManager.logout()
    }
}

struct SchoolCodeEntryCard: View {
    @Binding var showCodeEntry: Bool
    
    var body: some View {
        Button(action: { showCodeEntry = true }) {
            HStack(spacing: AppSpacing.m) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryOrange.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text("🏫")
                        .font(.system(size: 32))
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Link Your School")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.primaryOrange)
                    Text("Enter your school code to verify your account")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.darkGray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.primaryOrange)
            }
            .padding(AppSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(AppColors.primaryOrange.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SchoolCodeEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var code = ""
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    let onValidate: (String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.gradientBlue.opacity(0.1), AppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: AppSpacing.xl) {
                    // Header
                    VStack(spacing: AppSpacing.m) {
                        Text("🏫")
                            .font(.system(size: 80))
                        Text("Enter School Code")
                            .font(AppFonts.title)
                            .foregroundColor(AppColors.primaryPurple)
                        Text("Get your 6-digit code from your school")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.xl)
                    }
                    .padding(.top, AppSpacing.xxl)
                    
                    // Code Input
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        Text("School Code")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.darkGray)
                        
                        TextField("Enter 6-digit code", text: $code)
                            .textFieldStyle(.plain)
                            .foregroundColor(AppColors.black)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .autocapitalization(.allCharacters)
                            .keyboardType(.asciiCapable)
                            .padding(AppSpacing.l)
                            .background(Color.white)
                            .cornerRadius(AppCornerRadius.large)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                    .stroke(AppColors.primaryBlue, lineWidth: 2)
                            )
                            .onChange(of: code) { newValue in
                                // Limit to 6 characters and uppercase
                                code = String(newValue.prefix(6)).uppercased()
                            }
                    }
                    .padding(.horizontal, AppSpacing.m)
                    
                    // Submit Button
                    Button(action: submitCode) {
                        HStack(spacing: AppSpacing.s) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("✅")
                                    .font(.system(size: 24))
                                Text("Verify School")
                                    .font(AppFonts.button)
                                    .foregroundColor(.white)
                            }
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
                    .padding(.horizontal, AppSpacing.m)
                    .disabled(code.count != 6 || isSubmitting)
                    .opacity(code.count == 6 ? 1.0 : 0.5)
                    
                    Spacer()
                }
            }
            .navigationTitle("School Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppFonts.button)
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    onValidate(code)
                }
            } message: {
                Text("School code verified successfully!")
            }
        }
    }
    
    private func submitCode() {
        guard code.count == 6 else { return }
        
        isSubmitting = true
        Task {
            // TODO: Implement API call to validate school code
            // POST /api/school-codes/validate
            // Body: { code }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            isSubmitting = false
            showSuccess = true
        }
    }
}

struct ProfileHeaderCard: View {
    let displayName: String
    let email: String
    
    var body: some View {
        VStack(spacing: AppSpacing.m) {
            // Avatar with fun gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text("👤")
                    .font(.system(size: 60))
            }
            .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text(displayName)
                .font(AppFonts.title)
                .foregroundColor(AppColors.primaryPurple)
            
            Text(email)
                .font(AppFonts.body)
                .foregroundColor(AppColors.darkGray)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.extraLarge)
                .fill(Color.white)
                .shadow(color: AppColors.primaryBlue.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

struct VerificationCard: View {
    let parentVerified: Bool
    let schoolVerified: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            HStack {
                Text("✅")
                    .font(.system(size: 24))
                Text("Verification Status")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.primaryPurple)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                HStack(spacing: AppSpacing.m) {
                    ZStack {
                        Circle()
                            .fill(parentVerified ? AppColors.success.opacity(0.2) : AppColors.error.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Text(parentVerified ? "✓" : "✗")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(parentVerified ? AppColors.success : AppColors.error)
                    }
                    Text("Parent Verified")
                        .font(AppFonts.body)
                        .foregroundColor(parentVerified ? AppColors.success : AppColors.error)
                }
                
                HStack(spacing: AppSpacing.m) {
                    ZStack {
                        Circle()
                            .fill(schoolVerified ? AppColors.success.opacity(0.2) : AppColors.error.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Text(schoolVerified ? "✓" : "✗")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(schoolVerified ? AppColors.success : AppColors.error)
                    }
                    Text("School Verified")
                        .font(AppFonts.body)
                        .foregroundColor(schoolVerified ? AppColors.success : AppColors.error)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct ProfileInfoCard: View {
    let school: String
    let grade: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.l) {
            HStack(spacing: AppSpacing.m) {
                Text("🏫")
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("School")
                        .font(AppFonts.small)
                        .foregroundColor(AppColors.darkGray)
                    Text(school)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.primaryBlue)
                }
            }
            
            HStack(spacing: AppSpacing.m) {
                Text("📚")
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Grade")
                        .font(AppFonts.small)
                        .foregroundColor(AppColors.darkGray)
                    Text(grade)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.primaryPurple)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}

