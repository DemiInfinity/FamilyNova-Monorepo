//
//  EnterFriendCodeView.swift
//  FamilyNovaKids
//

import SwiftUI

struct EnterFriendCodeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var enteredCode = ""
    @State private var isAddingFriend = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var successMessage = ""
    
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
                    Text("⌨️")
                        .font(.system(size: 80))
                    
                    Text("Enter Friend Code")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryPurple)
                    
                    Text("Type in your friend's 8-character code")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.darkGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                    
                    // Code Input
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        Text("Friend Code")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.darkGray)
                        
                        TextField("Enter 8-character code", text: $enteredCode)
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
                            .onChange(of: enteredCode) { newValue in
                                // Limit to 8 characters and uppercase
                                enteredCode = String(newValue.prefix(8)).uppercased()
                            }
                    }
                    .padding(.horizontal, AppSpacing.m)
                    .padding(.top, AppSpacing.xl)
                    
                    // Add Friend Button
                    Button(action: addFriendByCode) {
                        HStack(spacing: AppSpacing.s) {
                            if isAddingFriend {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("✅")
                                    .font(.system(size: 24))
                                Text("Add Friend")
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
                    .disabled(enteredCode.count != 8 || isAddingFriend)
                    .opacity(enteredCode.count == 8 ? 1.0 : 0.5)
                    
                    Spacer()
                }
                .padding(.top, AppSpacing.xxl)
            }
            .navigationTitle("Enter Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
                    dismiss()
                }
            } message: {
                Text(successMessage)
            }
        }
    }
    
    private func addFriendByCode() {
        guard enteredCode.count == 8 else { return }
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
                
                let body: [String: Any] = ["code": enteredCode.uppercased()]
                
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
                    self.enteredCode = ""
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
    EnterFriendCodeView()
        .environmentObject(AuthManager())
}

