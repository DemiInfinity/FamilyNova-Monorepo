//
//  FriendsView.swift
//  FamilyNovaKids
//

import SwiftUI

struct FriendsView: View {
    @State private var searchText = ""
    @State private var friends: [Friend] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.darkGray)
                    
                    TextField("Search Friends", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(AppSpacing.m)
                .background(Color.white)
                .cornerRadius(AppCornerRadius.medium)
                .padding(.horizontal, AppSpacing.m)
                .padding(.top, AppSpacing.m)
                
                // Add Friend Button
                Button(action: handleAddFriend) {
                    Text("Add Friend")
                        .font(AppFonts.caption)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AppColors.primaryGreen)
                        .cornerRadius(AppCornerRadius.medium)
                }
                .padding(.horizontal, AppSpacing.m)
                .padding(.top, AppSpacing.m)
                
                // Friends List
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    Text("My Friends")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.black)
                        .padding(.horizontal, AppSpacing.m)
                        .padding(.top, AppSpacing.l)
                    
                    if friends.isEmpty {
                        Spacer()
                        VStack(spacing: AppSpacing.m) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 48))
                                .foregroundColor(AppColors.mediumGray)
                            Text("No friends yet. Start adding friends!")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.darkGray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: AppSpacing.s) {
                                ForEach(friends) { friend in
                                    FriendRow(friend: friend)
                                }
                            }
                            .padding(.horizontal, AppSpacing.m)
                        }
                    }
                }
            }
            .background(AppColors.lightGray)
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func handleAddFriend() {
        // TODO: Implement add friend functionality
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
    
    var body: some View {
        HStack(spacing: AppSpacing.m) {
            // Avatar
            Circle()
                .fill(AppColors.mediumGray)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                )
            
            // Friend Info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(friend.displayName)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.black)
                
                if friend.isVerified {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(AppColors.success)
                            .font(.system(size: 12))
                        Text("Verified")
                            .font(AppFonts.small)
                            .foregroundColor(AppColors.success)
                    }
                }
            }
            
            Spacer()
        }
        .padding(AppSpacing.m)
        .background(Color.white)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    FriendsView()
}

