//
//  AddFriendView.swift
//  FamilyNovaKids
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    var initialTab: Int? = nil // Optional initial tab to show
    @State private var selectedTab: Int = 0 // 0 = Search, 1 = My Code, 2 = Scan QR, 3 = Enter Code
    @State private var searchQuery = ""
    @State private var searchResults: [Friend] = []
    @State private var myFriendCode = ""
    @State private var isLoadingCode = false
    @State private var showQRScanner = false
    @State private var showCodeEntry = false
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
                
                VStack(spacing: 0) {
                    // Tab Selector
                    Picker("", selection: $selectedTab) {
                        Text("🔍 Search").tag(0)
                        Text("📱 My Code").tag(1)
                        Text("📷 Scan QR").tag(2)
                        Text("⌨️ Enter Code").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, AppSpacing.m)
                    .padding(.top, AppSpacing.m)
                    
                    // Content based on selected tab
                    Group {
                        switch selectedTab {
                        case 0:
                            searchTabView
                        case 1:
                            myCodeTabView
                        case 2:
                            scanQRTabView
                        case 3:
                            enterCodeTabView
                        default:
                            searchTabView
                        }
                    }
                }
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(AppFonts.button)
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
            .onAppear {
                // If initialTab was set, use it
                if let tab = initialTab {
                    selectedTab = tab
                }
                if selectedTab == 1 {
                    loadMyFriendCode()
                }
            }
            .onChange(of: selectedTab) { newTab in
                if newTab == 1 {
                    loadMyFriendCode()
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
    
    // MARK: - Search Tab
    private var searchTabView: some View {
        VStack(spacing: AppSpacing.l) {
            Text("🔍")
                .font(.system(size: 60))
            
            Text("Find Your Friends")
                .font(AppFonts.title)
                .foregroundColor(AppColors.primaryPurple)
            
            Text("Search by name to find and add friends!")
                .font(AppFonts.body)
                .foregroundColor(AppColors.darkGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.primaryBlue)
                TextField("Enter friend's name...", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .foregroundColor(AppColors.black)
                    .font(AppFonts.body)
                    .onChange(of: searchQuery) { newValue in
                        if !newValue.isEmpty {
                            performSearch(query: newValue)
                        } else {
                            searchResults = []
                        }
                    }
            }
            .padding(AppSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(Color.white)
                    .shadow(color: AppColors.primaryBlue.opacity(0.2), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal, AppSpacing.m)
            .padding(.top, AppSpacing.xl)
            
            // Search results
            if !searchQuery.isEmpty {
                ScrollView {
                    LazyVStack(spacing: AppSpacing.m) {
                        ForEach(searchResults) { friend in
                            FriendRow(friend: friend, showAddButton: true, onAdd: {
                                addFriend(friendId: friend.id.uuidString)
                            })
                        }
                    }
                    .padding(.horizontal, AppSpacing.m)
                }
            } else {
                Spacer()
            }
        }
        .padding(.top, AppSpacing.xxl)
    }
    
    // MARK: - My Code Tab
    private var myCodeTabView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                Text("📱")
                    .font(.system(size: 80))
                
                Text("My Friend Code")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryPurple)
                
                Text("Share this code with friends so they can add you!")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.darkGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
                
                if isLoadingCode {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if !myFriendCode.isEmpty {
                    // Friend Code Display
                    VStack(spacing: AppSpacing.l) {
                        // Code
                        Text(myFriendCode)
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.primaryBlue)
                            .padding(AppSpacing.xl)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                    .fill(Color.white)
                                    .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                        
                        // QR Code
                        if let qrImage = generateQRCode(from: "FAMILYNOVA:\(myFriendCode)") {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .padding(AppSpacing.l)
                                .background(Color.white)
                                .cornerRadius(AppCornerRadius.large)
                                .shadow(color: AppColors.primaryBlue.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        
                        // Share Button
                        Button(action: shareFriendCode) {
                            HStack(spacing: AppSpacing.s) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Code")
                                    .font(AppFonts.button)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(AppCornerRadius.large)
                        }
                        .padding(.horizontal, AppSpacing.m)
                    }
                    .padding(.horizontal, AppSpacing.m)
                }
            }
            .padding(.top, AppSpacing.xxl)
            .padding(.bottom, AppSpacing.xl)
        }
    }
    
    // MARK: - Scan QR Tab
    private var scanQRTabView: some View {
        VStack(spacing: AppSpacing.xl) {
            Text("📷")
                .font(.system(size: 80))
            
            Text("Scan Friend's QR Code")
                .font(AppFonts.title)
                .foregroundColor(AppColors.primaryPurple)
            
            Text("Point your camera at your friend's QR code to add them!")
                .font(AppFonts.body)
                .foregroundColor(AppColors.darkGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            Button(action: { showQRScanner = true }) {
                HStack(spacing: AppSpacing.s) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 24))
                    Text("Scan QR Code")
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
            .padding(.top, AppSpacing.xl)
            
            Spacer()
        }
        .padding(.top, AppSpacing.xxl)
    }
    
    // MARK: - Enter Code Tab
    private var enterCodeTabView: some View {
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
    
    // MARK: - Helper Functions
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
    
    private func performSearch(query: String) {
        guard let token = authManager.getValidatedToken() else { return }
        
        Task {
            do {
                let apiService = ApiService.shared
                
                struct SearchResponse: Codable {
                    let results: [FriendSearchResult]
                }
                
                struct FriendSearchResult: Codable {
                    let id: String
                    let profile: ProfileResult
                    let isVerified: Bool
                    let isFriend: Bool
                }
                
                struct ProfileResult: Codable {
                    let displayName: String?
                    let avatar: String?
                }
                
                let response: SearchResponse = try await apiService.makeRequest(
                    endpoint: "friends/search?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)",
                    method: "GET",
                    token: token
                )
                
                await MainActor.run {
                    self.searchResults = response.results.map { result in
                        Friend(
                            id: UUID(uuidString: result.id) ?? UUID(),
                            displayName: result.profile.displayName ?? "Unknown",
                            avatar: result.profile.avatar,
                            isVerified: result.isVerified
                        )
                    }
                }
            } catch {
                print("Error searching friends: \(error)")
            }
        }
    }
    
    private func addFriend(friendId: String) {
        guard let token = authManager.getValidatedToken() else {
            errorMessage = "Not authenticated. Please log in again."
            showError = true
            return
        }
        
        isAddingFriend = true
        Task {
            do {
                let apiService = ApiService.shared
                
                struct AddFriendResponse: Codable {
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
                
                let body: [String: Any] = ["friendId": friendId]
                
                let _: AddFriendResponse = try await apiService.makeRequest(
                    endpoint: "friends/request",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                await MainActor.run {
                    self.isAddingFriend = false
                    self.successMessage = "Friend request sent!"
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
    
    private func handleQRCodeScanned(_ code: String) {
        showQRScanner = false
        
        // Extract friend code from QR (format: "FAMILYNOVA:XXXXXXXX" or just "XXXXXXXX")
        let friendCode = code.replacingOccurrences(of: "FAMILYNOVA:", with: "").uppercased()
        
        if friendCode.count == 8 {
            enteredCode = friendCode
            selectedTab = 3 // Switch to enter code tab
            addFriendByCode()
        } else {
            errorMessage = "Invalid QR code format"
            showError = true
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
                "Add me on FamilyNova! My friend code is: \(myFriendCode)\n\nScan this QR code or enter the code in the app!",
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
    AddFriendView()
        .environmentObject(AuthManager())
}

