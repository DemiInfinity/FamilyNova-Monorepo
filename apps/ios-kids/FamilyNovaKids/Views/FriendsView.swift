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
                    
                    // Add Friend Button - Big and colorful
                    Button(action: { showAddFriend = true }) {
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
                                            FriendRow(friend: friend, showAddButton: true)
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
            }
        }
    }
    
    private func performSearch(query: String) {
        // TODO: Implement API call to search for friends
        // For now, simulate search results
        searchResults = [
            Friend(displayName: "Alex", avatar: nil, isVerified: true),
            Friend(displayName: "Sam", avatar: nil, isVerified: false)
        ].filter { $0.displayName.lowercased().contains(query.lowercased()) }
    }
}

struct Friend: Identifiable {
    let id = UUID()
    let displayName: String
    let avatar: String?
    let isVerified: Bool
}

struct FriendRow: View {
    let friend: Friend
    let showAddButton: Bool
    
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
                Button(action: { addFriend() }) {
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
    
    private func addFriend() {
        // TODO: Implement API call to add friend
    }
}

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchQuery = ""
    @State private var searchResults: [Friend] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppColors.gradientBlue.opacity(0.1), AppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
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
                                    FriendRow(friend: friend, showAddButton: true)
                                }
                            }
                            .padding(.horizontal, AppSpacing.m)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, AppSpacing.xxl)
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
        }
    }
}

#Preview {
    FriendsView()
}
