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
    @State private var schoolVerified = true
    
    var body: some View {
        NavigationView {
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
                    
                    // Profile Info
                    ProfileInfoCard(
                        school: school,
                        grade: grade
                    )
                    .padding(.horizontal, AppSpacing.m)
                    
                    // Logout Button
                    Button(action: handleLogout) {
                        Text("Logout")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.error)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .stroke(AppColors.error, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, AppSpacing.m)
                    .padding(.top, AppSpacing.l)
                }
                .padding(.bottom, AppSpacing.l)
            }
            .background(AppColors.lightGray)
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func handleLogout() {
        authManager.logout()
    }
}

struct ProfileHeaderCard: View {
    let displayName: String
    let email: String
    
    var body: some View {
        VStack(spacing: AppSpacing.m) {
            // Avatar
            Circle()
                .fill(AppColors.mediumGray)
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                )
            
            Text(displayName)
                .font(AppFonts.title)
                .foregroundColor(AppColors.black)
            
            Text(email)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.darkGray)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.l)
        .background(Color.white)
        .cornerRadius(AppCornerRadius.large)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct VerificationCard: View {
    let parentVerified: Bool
    let schoolVerified: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            Text("Verification Status")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.black)
            
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                HStack {
                    Image(systemName: parentVerified ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(parentVerified ? AppColors.success : AppColors.error)
                    Text("Parent Verified")
                        .font(AppFonts.caption)
                        .foregroundColor(parentVerified ? AppColors.success : AppColors.error)
                }
                
                HStack {
                    Image(systemName: schoolVerified ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(schoolVerified ? AppColors.success : AppColors.error)
                    Text("School Verified")
                        .font(AppFonts.caption)
                        .foregroundColor(schoolVerified ? AppColors.success : AppColors.error)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.m)
        .background(Color.white)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ProfileInfoCard: View {
    let school: String
    let grade: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("School")
                    .font(AppFonts.small)
                    .foregroundColor(AppColors.darkGray)
                Text(school)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.black)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Grade")
                    .font(AppFonts.small)
                    .foregroundColor(AppColors.darkGray)
                Text(grade)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.black)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.m)
        .background(Color.white)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}

