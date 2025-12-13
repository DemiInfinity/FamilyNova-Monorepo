//
//  ChildDetailsView.swift
//  FamilyNovaParent
//

import SwiftUI

struct ChildDetailsView: View {
    let child: Child
    @EnvironmentObject var authManager: AuthManager
    @State private var childDetails: ChildDetails?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showQRCode = false
    @State private var loginCode: String?
    @State private var isGeneratingCode = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: ParentAppSpacing.l) {
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let details = childDetails {
                    // Profile Section
                    VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
                        Text("Profile Information")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                            .padding(.horizontal, ParentAppSpacing.m)
                        
                        ProfileInfoCard(details: details)
                            .padding(.horizontal, ParentAppSpacing.m)
                    }
                    .padding(.top, ParentAppSpacing.m)
                    
                    // Login Information Section
                    VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
                        Text("Login Information")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                            .padding(.horizontal, ParentAppSpacing.m)
                        
                        LoginInfoCard(email: details.email)
                            .padding(.horizontal, ParentAppSpacing.m)
                    }
                    
                    // Verification Status
                    VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
                        Text("Verification Status")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                            .padding(.horizontal, ParentAppSpacing.m)
                        
                        VerificationCard(verification: details.verification)
                            .padding(.horizontal, ParentAppSpacing.m)
                    }
                    
                    // Activity Information
                    VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
                        Text("Activity")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                            .padding(.horizontal, ParentAppSpacing.m)
                        
                        ChildActivityCard(lastLogin: details.lastLogin)
                            .padding(.horizontal, ParentAppSpacing.m)
                    }
                    
                    // Quick Login Section
                    VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
                        Text("Quick Login")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                            .padding(.horizontal, ParentAppSpacing.m)
                        
                        QuickLoginCard(
                            childId: details.id,
                            email: details.email,
                            onDirectLogin: handleDirectLogin,
                            onQRCodeLogin: handleQRCodeLogin,
                            isGeneratingCode: isGeneratingCode
                        )
                        .padding(.horizontal, ParentAppSpacing.m)
                    }
                } else {
                    // Show basic info from child object if details not loaded
                    ProfileInfoCard(details: ChildDetails(
                        id: child.id,
                        email: "Loading...",
                        profile: child.profile,
                        verification: child.verification,
                        lastLogin: child.lastLogin
                    ))
                    .padding(.horizontal, ParentAppSpacing.m)
                    .padding(.top, ParentAppSpacing.m)
                }
            }
            .padding(.bottom, ParentAppSpacing.l)
        }
        .background(ParentAppColors.lightGray)
        .navigationTitle(child.profile.displayName)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                await loadChildDetails()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showQRCode) {
            if let code = loginCode, let details = childDetails {
                QRCodeLoginView(
                    loginCode: code,
                    childName: details.profile.displayName
                )
            }
        }
    }
    
    private func loadChildDetails() async {
        guard let token = authManager.token else {
            errorMessage = "Not authenticated"
            showError = true
            return
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let apiService = ApiService.shared
            
            struct ChildDetailsResponse: Codable {
                let child: ChildDetailsData
            }
            
            struct ChildDetailsData: Codable {
                let id: String
                let email: String?
                let profile: ChildProfile
                let verification: VerificationStatus
                let lastLogin: String?
            }
            
            let response: ChildDetailsResponse = try await apiService.makeRequest(
                endpoint: "parents/children/\(child.id)",
                method: "GET",
                token: token
            )
            
            await MainActor.run {
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                self.childDetails = ChildDetails(
                    id: response.child.id,
                    email: response.child.email ?? "Not available",
                    profile: response.child.profile,
                    verification: response.child.verification,
                    lastLogin: response.child.lastLogin != nil ? dateFormatter.date(from: response.child.lastLogin!) : nil
                )
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load child details: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }
    
    private func handleDirectLogin() {
        guard let details = childDetails, let token = authManager.token else {
            errorMessage = "Unable to log in. Please try again."
            showError = true
            return
        }
        
        AppDetection.openKidsAppWithLogin(
            childId: details.id,
            email: details.email,
            token: token
        )
    }
    
    private func handleQRCodeLogin() {
        guard let details = childDetails, let token = authManager.token else {
            errorMessage = "Unable to generate login code. Please try again."
            showError = true
            return
        }
        
        isGeneratingCode = true
        Task {
            await generateLoginCode(childId: details.id, token: token)
        }
    }
    
    private func generateLoginCode(childId: String, token: String) async {
        do {
            let apiService = ApiService.shared
            
            struct LoginCodeRequest: Codable {
                let childId: String
            }
            
            struct LoginCodeResponse: Codable {
                let code: String
                let expiresAt: String
            }
            
            let requestBody: [String: Any] = ["childId": childId]
            let response: LoginCodeResponse = try await apiService.makeRequest(
                endpoint: "parents/children/\(childId)/login-code",
                method: "POST",
                body: requestBody,
                token: token
            )
            
            await MainActor.run {
                self.loginCode = response.code
                self.isGeneratingCode = false
                self.showQRCode = true
            }
        } catch {
            await MainActor.run {
                self.isGeneratingCode = false
                self.errorMessage = "Failed to generate login code: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }
}

struct ChildDetails {
    let id: String
    let email: String
    let profile: ChildProfile
    let verification: VerificationStatus
    let lastLogin: Date?
}

struct ProfileInfoCard: View {
    let details: ChildDetails
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
            HStack {
                // Avatar
                Circle()
                    .fill(ParentAppColors.primaryTeal)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(details.profile.displayName.prefix(1).uppercased())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text(details.profile.displayName)
                        .font(ParentAppFonts.title)
                        .foregroundColor(ParentAppColors.black)
                    
                    if let school = details.profile.school {
                        Text(school)
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                }
                
                Spacer()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                if let school = details.profile.school {
                    ChildInfoRow(label: "School", value: school)
                }
                
                if let grade = details.profile.grade {
                    ChildInfoRow(label: "Grade", value: grade)
                }
            }
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct LoginInfoCard: View {
    let email: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
            ChildInfoRow(label: "Email", value: email)
            
            Text("Password")
                .font(ParentAppFonts.caption)
                .foregroundColor(ParentAppColors.darkGray)
            
            HStack {
                Text("••••••••")
                    .font(ParentAppFonts.body)
                    .foregroundColor(ParentAppColors.black)
                
                Spacer()
                
                Text("Set by parent")
                    .font(ParentAppFonts.small)
                    .foregroundColor(ParentAppColors.mediumGray)
                    .italic()
            }
            .padding(ParentAppSpacing.s)
            .background(ParentAppColors.lightGray)
            .cornerRadius(ParentAppCornerRadius.small)
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct VerificationCard: View {
    let verification: VerificationStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
            VerificationRow(
                title: "Parent Verification",
                isVerified: verification.parentVerified,
                icon: "person.fill.checkmark"
            )
            
            VerificationRow(
                title: "School Verification",
                isVerified: verification.schoolVerified,
                icon: "building.2.fill.checkmark"
            )
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct VerificationRow: View {
    let title: String
    let isVerified: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: ParentAppSpacing.m) {
            Image(systemName: icon)
                .foregroundColor(isVerified ? ParentAppColors.success : ParentAppColors.mediumGray)
                .font(.system(size: 20))
            
            Text(title)
                .font(ParentAppFonts.body)
                .foregroundColor(ParentAppColors.black)
            
            Spacer()
            
            if isVerified {
                HStack(spacing: ParentAppSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ParentAppColors.success)
                    Text("Verified")
                        .font(ParentAppFonts.small)
                        .foregroundColor(ParentAppColors.success)
                }
            } else {
                Text("Pending")
                    .font(ParentAppFonts.small)
                    .foregroundColor(ParentAppColors.warning)
            }
        }
    }
}

struct ChildActivityCard: View {
    let lastLogin: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
            if let lastLogin = lastLogin {
                ChildInfoRow(label: "Last Login", value: formatDate(lastLogin))
            } else {
                ChildInfoRow(label: "Last Login", value: "Never")
            }
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ChildInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(ParentAppFonts.caption)
                .foregroundColor(ParentAppColors.darkGray)
            
            Spacer()
            
            Text(value)
                .font(ParentAppFonts.body)
                .foregroundColor(ParentAppColors.black)
        }
    }
}

struct QuickLoginCard: View {
    let childId: String
    let email: String
    let onDirectLogin: () -> Void
    let onQRCodeLogin: () -> Void
    let isGeneratingCode: Bool
    
    private var isKidsAppInstalled: Bool {
        AppDetection.isKidsAppInstalled()
    }
    
    var body: some View {
        VStack(spacing: ParentAppSpacing.m) {
            if isKidsAppInstalled {
                Button(action: onDirectLogin) {
                    HStack(spacing: ParentAppSpacing.s) {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Log into Kid App")
                            .font(ParentAppFonts.button)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(ParentAppColors.primaryTeal)
                    .cornerRadius(ParentAppCornerRadius.medium)
                }
            }
            
            Button(action: onQRCodeLogin) {
                HStack(spacing: ParentAppSpacing.s) {
                    if isGeneratingCode {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "qrcode")
                    }
                    Text(isKidsAppInstalled ? "Show QR Code" : "Generate QR Code")
                        .font(ParentAppFonts.button)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isGeneratingCode ? ParentAppColors.mediumGray : ParentAppColors.primaryNavy)
                .cornerRadius(ParentAppCornerRadius.medium)
            }
            .disabled(isGeneratingCode)
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct QRCodeLoginView: View {
    let loginCode: String
    let childName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: ParentAppSpacing.l) {
                VStack(spacing: ParentAppSpacing.m) {
                    Text("Scan to Log In")
                        .font(ParentAppFonts.title)
                        .foregroundColor(ParentAppColors.primaryNavy)
                    
                    Text("Have \(childName) scan this QR code with the FamilyNova Kids app")
                        .font(ParentAppFonts.body)
                        .foregroundColor(ParentAppColors.darkGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ParentAppSpacing.m)
                }
                .padding(.top, ParentAppSpacing.xl)
                
                QRCodeView(qrCodeString: "FAMILYNOVA:\(loginCode)")
                    .padding()
                
                VStack(spacing: ParentAppSpacing.s) {
                    Text("Or enter this code manually:")
                        .font(ParentAppFonts.caption)
                        .foregroundColor(ParentAppColors.darkGray)
                    
                    Text(loginCode)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(ParentAppColors.primaryTeal)
                        .padding()
                        .background(ParentAppColors.lightGray)
                        .cornerRadius(ParentAppCornerRadius.medium)
                }
                .padding(.horizontal, ParentAppSpacing.m)
                
                Spacer()
            }
            .background(ParentAppColors.lightGray)
            .navigationTitle("QR Code Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ChildDetailsView(child: Child(
            id: "123",
            profile: ChildProfile(
                displayName: "John Doe",
                avatar: nil,
                school: "Elementary School",
                grade: "5th Grade"
            ),
            verification: VerificationStatus(
                parentVerified: true,
                schoolVerified: false
            ),
            lastLogin: Date()
        ))
        .environmentObject(AuthManager())
    }
}

