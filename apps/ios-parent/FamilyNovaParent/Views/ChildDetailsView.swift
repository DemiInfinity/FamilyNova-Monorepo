//
//  ChildDetailsView.swift
//  FamilyNovaParent
//

import SwiftUI
import Foundation

struct ChildDetailsView: View {
    let child: Child
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var childDetails: ChildDetails?
    @State private var isLoading = false
    @State private var toast: ToastNotificationData? = nil
    @State private var showQRCode = false
    @State private var loginCode: String?
    @State private var isGeneratingCode = false
    
    var body: some View {
        ZStack {
            CosmicBackground()
            
            VStack(spacing: 0) {
                OfflineIndicator()
                
                if isLoading {
                    LoadingStateView(message: "Loading child details...")
                } else if let details = childDetails {
                    ScrollView {
                        VStack(spacing: CosmicSpacing.l) {
                        // Profile Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            Text("Profile Information")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            ProfileInfoCard(details: details)
                                .padding(.horizontal, CosmicSpacing.m)
                        }
                        .padding(.top, CosmicSpacing.m)
                        
                        // Login Information Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            Text("Login Information")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            LoginInfoCard(email: details.email)
                                .padding(.horizontal, CosmicSpacing.m)
                        }
                        
                        // Verification Status
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            Text("Verification Status")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            VerificationCard(verification: details.verification)
                                .padding(.horizontal, CosmicSpacing.m)
                        }
                        
                        // Activity Information
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            Text("Activity")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            ChildActivityCard(lastLogin: details.lastLogin)
                                .padding(.horizontal, CosmicSpacing.m)
                        }
                        
                        // Quick Login Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            Text("Quick Login")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            QuickLoginCard(
                                childId: details.id,
                                email: details.email,
                                onDirectLogin: handleDirectLogin,
                                onQRCodeLogin: handleQRCodeLogin,
                                isGeneratingCode: isGeneratingCode
                            )
                            .padding(.horizontal, CosmicSpacing.m)
                        }
                    }
                    .padding(.bottom, CosmicSpacing.xl)
                }
            } else {
                // Show basic info from child object if details not loaded
                ScrollView {
                    ProfileInfoCard(details: ChildDetails(
                        id: child.id,
                        email: "Loading...",
                        profile: child.profile,
                        verification: child.verification,
                        lastLogin: child.lastLogin
                    ))
                    .padding(.horizontal, CosmicSpacing.m)
                    .padding(.top, CosmicSpacing.m)
                }
            }
            }
        }
        .navigationTitle(child.profile.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(CosmicColors.nebulaPurple)
            }
        }
        .onAppear {
            Task {
                await loadChildDetails()
            }
        }
        .toastNotification($toast)
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
            ErrorHandler.shared.showError(ApiError.invalidResponse, toast: $toast)
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
                ErrorHandler.shared.showError(error, toast: $toast)
            }
        }
    }
    
    private func handleDirectLogin() {
        guard let details = childDetails, let token = authManager.token else {
            ErrorHandler.shared.showError(NSError(domain: "LoginError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to log in. Please try again."]), toast: $toast)
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
            ErrorHandler.shared.showError(NSError(domain: "LoginError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to generate login code. Please try again."]), toast: $toast)
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
                ErrorHandler.shared.showError(error, toast: $toast)
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
        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
            HStack {
                // Avatar
                Group {
                    if let avatarUrl = details.profile.avatar, !avatarUrl.isEmpty {
                        AsyncImage(url: URL(string: avatarUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(CosmicColors.primaryGradient)
                        }
                    } else {
                        Circle()
                            .fill(CosmicColors.primaryGradient)
                            .overlay(
                                Text(details.profile.displayName.prefix(1).uppercased())
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(CosmicColors.nebulaPurple.opacity(0.3), lineWidth: 2)
                )
                
                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                    Text(details.profile.displayName)
                        .font(CosmicFonts.title)
                        .foregroundColor(CosmicColors.textPrimary)
                    
                    if let school = details.profile.school {
                        Text(school)
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                    }
                }
                
                Spacer()
            }
            
            Divider()
                .background(CosmicColors.glassBorder.opacity(0.3))
            
            VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                if let school = details.profile.school {
                    ChildInfoRow(label: "School", value: school)
                }
                
                if let grade = details.profile.grade {
                    ChildInfoRow(label: "Grade", value: grade)
                }
            }
        }
        .padding(CosmicSpacing.m)
        .cosmicCard()
    }
}

struct LoginInfoCard: View {
    let email: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
            ChildInfoRow(label: "Email", value: email)
            
            Text("Password")
                .font(CosmicFonts.caption)
                .foregroundColor(CosmicColors.textMuted)
            
            HStack {
                Text("••••••••")
                    .font(CosmicFonts.body)
                    .foregroundColor(CosmicColors.textPrimary)
                
                Spacer()
                
                Text("Set by parent")
                    .font(CosmicFonts.small)
                    .foregroundColor(CosmicColors.textMuted)
                    .italic()
            }
            .padding(CosmicSpacing.s)
            .background(CosmicColors.glassBackground.opacity(0.3))
            .cornerRadius(CosmicCornerRadius.small)
        }
        .padding(CosmicSpacing.m)
        .cosmicCard()
    }
}

struct VerificationCard: View {
    let verification: VerificationStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
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
        .padding(CosmicSpacing.m)
        .cosmicCard()
    }
}

struct VerificationRow: View {
    let title: String
    let isVerified: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: CosmicSpacing.m) {
            Image(systemName: icon)
                .cosmicIcon(size: 20, color: isVerified ? CosmicColors.planetTeal : CosmicColors.textMuted)
            
            Text(title)
                .font(CosmicFonts.body)
                .foregroundColor(CosmicColors.textPrimary)
            
            Spacer()
            
            if isVerified {
                HStack(spacing: CosmicSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(CosmicColors.planetTeal)
                    Text("Verified")
                        .font(CosmicFonts.small)
                        .foregroundColor(CosmicColors.planetTeal)
                }
            } else {
                Text("Pending")
                    .font(CosmicFonts.small)
                    .foregroundColor(CosmicColors.starGold)
            }
        }
    }
}

struct ChildActivityCard: View {
    let lastLogin: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
            if let lastLogin = lastLogin {
                ChildInfoRow(label: "Last Login", value: formatDate(lastLogin))
            } else {
                ChildInfoRow(label: "Last Login", value: "Never")
            }
        }
        .padding(CosmicSpacing.m)
        .cosmicCard()
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
                .font(CosmicFonts.caption)
                .foregroundColor(CosmicColors.textMuted)
            
            Spacer()
            
            Text(value)
                .font(CosmicFonts.body)
                .foregroundColor(CosmicColors.textPrimary)
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
        VStack(spacing: CosmicSpacing.m) {
            if isKidsAppInstalled {
                Button(action: onDirectLogin) {
                    HStack(spacing: CosmicSpacing.s) {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Log into Nova App")
                            .font(CosmicFonts.button)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(CosmicColors.nebulaPurple)
                    .cornerRadius(CosmicCornerRadius.medium)
                }
            }
            
            Button(action: onQRCodeLogin) {
                HStack(spacing: CosmicSpacing.s) {
                    if isGeneratingCode {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "qrcode")
                    }
                    Text(isKidsAppInstalled ? "Show QR Code" : "Generate QR Code")
                        .font(CosmicFonts.button)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isGeneratingCode ? CosmicColors.textMuted : CosmicColors.nebulaBlue)
                .cornerRadius(CosmicCornerRadius.medium)
            }
            .disabled(isGeneratingCode)
        }
        .padding(CosmicSpacing.m)
        .cosmicCard()
    }
}

struct QRCodeLoginView: View {
    let loginCode: String
    let childName: String
    @Environment(\.dismiss) private var dismiss
    @State private var showCopiedMessage = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                VStack(spacing: CosmicSpacing.l) {
                    VStack(spacing: CosmicSpacing.m) {
                        Text("Scan to Log In")
                            .font(CosmicFonts.title)
                            .foregroundColor(CosmicColors.textPrimary)
                        
                        Text("Have \(childName) scan this QR code with the Nova app")
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CosmicSpacing.m)
                    }
                    .padding(.top, CosmicSpacing.xl)
                    
                    QRCodeView(qrCodeString: "FAMILYNOVA:\(loginCode)")
                        .padding()
                        .cosmicCard()
                    
                    VStack(spacing: CosmicSpacing.s) {
                        Text("Or enter this code manually:")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.textMuted)
                        
                        HStack(spacing: CosmicSpacing.s) {
                            Text(loginCode)
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundColor(CosmicColors.nebulaPurple)
                                .padding()
                                .background(CosmicColors.glassBackground.opacity(0.5))
                                .cornerRadius(CosmicCornerRadius.medium)
                            
                            Button(action: {
                                UIPasteboard.general.string = loginCode
                                withAnimation {
                                    showCopiedMessage = true
                                }
                                // Hide the message after 2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showCopiedMessage = false
                                    }
                                }
                            }) {
                                Image(systemName: showCopiedMessage ? "checkmark.circle.fill" : "doc.on.doc")
                                    .cosmicIcon(size: 24, color: showCopiedMessage ? CosmicColors.planetTeal : CosmicColors.nebulaPurple)
                                    .frame(width: 50, height: 50)
                                    .background(CosmicColors.glassBackground.opacity(0.5))
                                    .cornerRadius(CosmicCornerRadius.medium)
                            }
                        }
                        
                        if showCopiedMessage {
                            Text("Copied!")
                                .font(CosmicFonts.caption)
                                .foregroundColor(CosmicColors.planetTeal)
                                .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, CosmicSpacing.m)
                    
                    Spacer()
                }
            }
            .navigationTitle("QR Code Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(CosmicColors.nebulaPurple)
                }
            }
        }
    }
}
