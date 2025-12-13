//
//  ScanFriendQRView.swift
//  FamilyNovaParent
//

import SwiftUI

struct ScanFriendQRView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var showQRScanner = false
    @State private var isAddingFriend = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var successMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [ParentAppColors.gradientBlue.opacity(0.1), ParentAppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: ParentAppSpacing.xl) {
                    Text("📷")
                        .font(.system(size: 80))
                    
                    Text("Scan Friend's QR Code")
                        .font(ParentAppFonts.title)
                        .foregroundColor(ParentAppColors.primaryPurple)
                    
                    Text("Point your camera at your friend's QR code to add them!")
                        .font(ParentAppFonts.body)
                        .foregroundColor(ParentAppColors.darkGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ParentAppSpacing.xl)
                    
                    Button(action: { showQRScanner = true }) {
                        HStack(spacing: ParentAppSpacing.s) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 24))
                            Text("Scan QR Code")
                                .font(ParentAppFonts.button)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(ParentAppCornerRadius.large)
                        .shadow(color: ParentAppColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, ParentAppSpacing.m)
                    .padding(.top, ParentAppSpacing.xl)
                    
                    Spacer()
                }
                .padding(.top, ParentAppSpacing.xxl)
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(ParentAppFonts.button)
                    .foregroundColor(ParentAppColors.primaryBlue)
                }
            }
            .sheet(isPresented: $showQRScanner) {
                QRCodeScannerView(onCodeScanned: handleQRCodeScanned)
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
                Text(successMessage)
            }
        }
    }
    
    private func handleQRCodeScanned(_ code: String) {
        showQRScanner = false
        
        // Extract friend code from QR (format: "FAMILYNOVA:XXXXXXXX" or just "XXXXXXXX")
        let friendCode = code.replacingOccurrences(of: "FAMILYNOVA:", with: "").uppercased()
        
        if friendCode.count == 8 {
            addFriendByCode(friendCode)
        } else {
            errorMessage = "Invalid QR code format. Please scan a valid friend code."
            showError = true
        }
    }
    
    private func addFriendByCode(_ code: String) {
        guard let token = authManager.getValidatedToken() else {
            errorMessage = "Not authenticated. Please log in again."
            showError = true
            return
        }
        
        isAddingFriend = true
        Task {
            do {
                let apiService = ApiService.shared
                
                struct AddFriendByCodeResponse: Codable {
                    let message: String
                    let friend: FriendResponse
                }
                
                struct FriendResponse: Codable {
                    let id: String
                    let profile: ProfileResponse
                    let isVerified: Bool
                }
                
                struct ProfileResponse: Codable {
                    let displayName: String?
                    let avatar: String?
                }
                
                let body: [String: Any] = ["code": code.uppercased()]
                
                let response: AddFriendByCodeResponse = try await apiService.makeRequest(
                    endpoint: "friends/add-by-code",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                await MainActor.run {
                    self.isAddingFriend = false
                    self.successMessage = "Friend added: \(response.friend.profile.displayName ?? "Friend")!"
                    self.showSuccess = true
                }
            } catch {
                await MainActor.run {
                    self.isAddingFriend = false
                    self.errorMessage = "Failed to add friend: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
}

#Preview {
    ScanFriendQRView()
        .environmentObject(AuthManager())
}

