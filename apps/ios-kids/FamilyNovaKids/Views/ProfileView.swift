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
                    
                    // Profile Info
                    ProfileInfoCard(
                        school: school,
                        grade: grade
                    )
                    .padding(.horizontal, AppSpacing.m)
                    
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

