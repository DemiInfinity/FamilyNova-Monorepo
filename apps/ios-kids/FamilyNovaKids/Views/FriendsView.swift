//
//  FriendsView.swift
//  FamilyNovaKids
//

import SwiftUI

struct FriendsView: View {
    @State private var searchText = ""
    @State private var friends: [Friend] = []
    @State private var searchResults: [Friend] = []
    @State private var isSearching = false
    @State private var showAddFriend = false
    @State private var showScanQR = false
    @State private var showEnterCode = false
    @State private var showMyCode = false
    @State private var errorMessage = ""
    @State private var showError = false
    @EnvironmentObject var authManager: AuthManager
    
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
                
                VStack(spacing: 0) {
                    // Fun Search Bar
                    HStack(spacing: AppSpacing.m) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryBlue)
                        
                        TextField("Search for friends...", text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundColor(AppColors.black)
                            .font(AppFonts.body)
                            .onChange(of: searchText) { newValue in
                                if !newValue.isEmpty {
                                    isSearching = true
                                    performSearch(query: newValue)
                                } else {
                                    isSearching = false
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
                    .padding(.top, AppSpacing.m)
                    
                    // Add Friend Buttons
                    VStack(spacing: AppSpacing.m) {
                        // Main Add Friend Button
                        Button(action: {
                            showAddFriend = true
                        }) {
                            HStack(spacing: AppSpacing.s) {
                                Text("➕")
                                    .font(.system(size: 24))
                                Text("Add New Friend")
                                    .font(AppFonts.button)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.primaryGreen, AppColors.primaryBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(AppCornerRadius.large)
                            .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        // Quick Add Options
                        HStack(spacing: AppSpacing.m) {
                            Button(action: {
                                showScanQR = true
                            }) {
                                HStack(spacing: AppSpacing.xs) {
                                    Image(systemName: "qrcode.viewfinder")
                                        .font(.system(size: 18))
                                    Text("Scan QR")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.primaryBlue)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.s)
                                .background(Color.white)
                                .cornerRadius(AppCornerRadius.medium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                        .stroke(AppColors.primaryBlue, lineWidth: 2)
                                )
                            }
                            
                            Button(action: {
                                showEnterCode = true
                            }) {
                                HStack(spacing: AppSpacing.xs) {
                                    Image(systemName: "keyboard")
                                        .font(.system(size: 18))
                                    Text("Enter Code")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.primaryPurple)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.s)
                                .background(Color.white)
                                .cornerRadius(AppCornerRadius.medium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                        .stroke(AppColors.primaryPurple, lineWidth: 2)
                                )
                            }
                        }
                        
                        // Show My Code Button
                        Button(action: {
                            showMyCode = true
                        }) {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 18))
                                Text("Show My Code")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.primaryGreen)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.s)
                            .background(Color.white)
                            .cornerRadius(AppCornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .stroke(AppColors.primaryGreen, lineWidth: 2)
                            )
                        }
                        .padding(.top, AppSpacing.xs)
                    }
                    .padding(.horizontal, AppSpacing.m)
                    .padding(.top, AppSpacing.m)
                    
                    // Friends List or Search Results
                    VStack(alignment: .leading, spacing: AppSpacing.m) {
                        if isSearching {
                            Text("🔍 Search Results")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.primaryPurple)
                                .padding(.horizontal, AppSpacing.m)
                                .padding(.top, AppSpacing.l)
                            
                            if searchResults.isEmpty && !searchText.isEmpty {
                                VStack(spacing: AppSpacing.m) {
                                    Text("😕")
                                        .font(.system(size: 60))
                                    Text("No friends found")
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.darkGray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(AppSpacing.xxl)
                            } else {
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
                            }
                        } else {
                            Text("👥 My Friends")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.primaryPurple)
                                .padding(.horizontal, AppSpacing.m)
                                .padding(.top, AppSpacing.l)
                            
                            if friends.isEmpty {
                                Spacer()
                                VStack(spacing: AppSpacing.l) {
                                    Text("👋")
                                        .font(.system(size: 80))
                                    Text("No friends yet!")
                                        .font(AppFonts.headline)
                                        .foregroundColor(AppColors.primaryBlue)
                                    Text("Start adding friends to connect and have fun together!")
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.darkGray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, AppSpacing.xl)
                                }
                                .padding(AppSpacing.xxl)
                                Spacer()
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: AppSpacing.m) {
                                        ForEach(friends) { friend in
                                            FriendRow(friend: friend, showAddButton: false)
                                        }
                                    }
                                    .padding(.horizontal, AppSpacing.m)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddFriend) {
                AddFriendView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showScanQR) {
                ScanFriendQRView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showEnterCode) {
                EnterFriendCodeView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showMyCode) {
                ShowMyFriendCodeView()
                    .environmentObject(authManager)
            }
            .onAppear {
                Task {
                    await loadFriends()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
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
        guard let token = authManager.getValidatedToken() else { return }
        
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
                
                // Refresh friends list
                await loadFriends()
            } catch {
                print("Error adding friend: \(error)")
            }
        }
    }
    
    private func loadFriends() async {
        guard let token = authManager.getValidatedToken() else { return }
        
        do {
            let apiService = ApiService.shared
            
            struct FriendsResponse: Codable {
                let friends: [FriendResult]
            }
            
            struct FriendResult: Codable {
                let id: String
                let profile: ProfileResult
                let isVerified: Bool
            }
            
            struct ProfileResult: Codable {
                let displayName: String?
                let avatar: String?
            }
            
            let response: FriendsResponse = try await apiService.makeRequest(
                endpoint: "friends",
                method: "GET",
                token: token
            )
            
            await MainActor.run {
                self.friends = response.friends.map { friend in
                    Friend(
                        id: UUID(uuidString: friend.id) ?? UUID(),
                        displayName: friend.profile.displayName ?? "Unknown",
                        avatar: friend.profile.avatar,
                        isVerified: friend.isVerified
                    )
                }
            }
        } catch {
            print("Error loading friends: \(error)")
        }
    }
}

struct Friend: Identifiable {
    let id: UUID
    let displayName: String
    let avatar: String?
    let isVerified: Bool
    
    init(id: UUID = UUID(), displayName: String, avatar: String?, isVerified: Bool) {
        self.id = id
        self.displayName = displayName
        self.avatar = avatar
        self.isVerified = isVerified
    }
}

struct FriendRow: View {
    let friend: Friend
    let showAddButton: Bool
    var onAdd: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: AppSpacing.m) {
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
                    .frame(width: 70, height: 70)
                
                Text("👤")
                    .font(.system(size: 36))
            }
            
            // Friend Info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(friend.displayName)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.black)
                
                if friend.isVerified {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(AppColors.success)
                            .font(.system(size: 16))
                        Text("Verified Friend")
                            .font(AppFonts.small)
                            .foregroundColor(AppColors.success)
                    }
                }
            }
            
            Spacer()
            
            if showAddButton {
                Button(action: {
                    onAdd?()
                }) {
                    Text("➕ Add")
                        .font(AppFonts.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.m)
                        .padding(.vertical, AppSpacing.s)
                        .background(
                            LinearGradient(
                                colors: [AppColors.primaryGreen, AppColors.primaryBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(AppCornerRadius.medium)
                }
            }
        }
        .padding(AppSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    FriendsView()
}
