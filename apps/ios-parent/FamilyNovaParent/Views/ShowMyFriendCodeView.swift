//
//  ShowMyFriendCodeView.swift
//  FamilyNovaParent
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

struct ShowMyFriendCodeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var myFriendCode = ""
    @State private var isLoadingCode = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [ParentAppColors.gradientBlue.opacity(0.1), ParentAppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: ParentAppSpacing.xl) {
                        Text("📱")
                            .font(.system(size: 80))
                        
                        Text("My Friend Code")
                            .font(ParentAppFonts.title)
                            .foregroundColor(ParentAppColors.primaryPurple)
                        
                        Text("Share this code with friends so they can add you!")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, ParentAppSpacing.xl)
                        
                        if isLoadingCode {
                            ProgressView()
                                .scaleEffect(1.5)
                        } else if !myFriendCode.isEmpty {
                            // Friend Code Display
                            VStack(spacing: ParentAppSpacing.l) {
                                // Code
                                Text(myFriendCode)
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(ParentAppColors.primaryBlue)
                                    .padding(ParentAppSpacing.xl)
                                    .background(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                                            .fill(Color.white)
                                            .shadow(color: ParentAppColors.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                                    )
                                
                                // QR Code
                                if let qrImage = generateQRCode(from: "FAMILYNOVA:\(myFriendCode)") {
                                    Image(uiImage: qrImage)
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250, height: 250)
                                        .padding(ParentAppSpacing.l)
                                        .background(Color.white)
                                        .cornerRadius(ParentAppCornerRadius.large)
                                        .shadow(color: ParentAppColors.primaryBlue.opacity(0.2), radius: 10, x: 0, y: 5)
                                }
                                
                                // Share Button
                                Button(action: shareFriendCode) {
                                    HStack(spacing: ParentAppSpacing.s) {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share Code")
                                            .font(ParentAppFonts.button)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        LinearGradient(
                                            colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(ParentAppCornerRadius.large)
                                }
                                .padding(.horizontal, ParentAppSpacing.m)
                            }
                            .padding(.horizontal, ParentAppSpacing.m)
                        }
                    }
                    .padding(.top, ParentAppSpacing.xxl)
                    .padding(.bottom, ParentAppSpacing.xl)
                }
            }
            .navigationTitle("My Friend Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(ParentAppFonts.button)
                    .foregroundColor(ParentAppColors.primaryBlue)
                }
            }
            .onAppear {
                loadMyFriendCode()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loadMyFriendCode() {
        guard let token = authManager.getValidatedToken() else {
            errorMessage = "Not authenticated. Please log in again."
            showError = true
            return
        }
        
        isLoadingCode = true
        Task {
            do {
                let apiService = ApiService.shared
                
                struct FriendCodeResponse: Codable {
                    let code: String
                    let expiresAt: String?
                    let createdAt: String?
                }
                
                let response: FriendCodeResponse = try await apiService.makeRequest(
                    endpoint: "friends/my-code",
                    method: "GET",
                    token: token
                )
                
                await MainActor.run {
                    self.myFriendCode = response.code
                    self.isLoadingCode = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingCode = false
                    self.errorMessage = "Failed to load friend code: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func shareFriendCode() {
        let activityVC = UIActivityViewController(
            activityItems: [
                "Add me on Nova! My friend code is: \(myFriendCode)\n\nScan this QR code or enter the code in the app!",
                generateQRCode(from: "FAMILYNOVA:\(myFriendCode)") as Any
            ],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

#Preview {
    ShowMyFriendCodeView()
        .environmentObject(AuthManager())
}

