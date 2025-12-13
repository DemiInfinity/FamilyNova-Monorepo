//
//  MoreView.swift
//  FamilyNovaParent
//
//  Comprehensive More menu for parents with monitoring tools

import SwiftUI

struct MoreView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var children: [Child] = []
    @State private var selectedChild: Child? = nil
    @State private var showProfile = false
    @State private var showSettings = false
    @State private var showManageChildren = false
    @State private var showFriends = false
    @State private var showNotifications = false
    @State private var showMyPosts = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                ScrollView {
                    VStack(spacing: CosmicSpacing.xl) {
                        // Profile Section (Personal)
                        VStack(spacing: CosmicSpacing.m) {
                            Circle()
                                .fill(CosmicColors.primaryGradient)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(CosmicColors.nebulaPurple.opacity(0.5), lineWidth: 3)
                                )
                                .shadow(color: CosmicColors.nebulaPurple.opacity(0.5), radius: 15)
                            
                            if let user = authManager.currentUser {
                                Text(user.profile.displayName)
                                    .font(CosmicFonts.headline)
                                    .foregroundColor(CosmicColors.textPrimary)
                            }
                            
                            HStack(spacing: CosmicSpacing.xl) {
                                VStack {
                                    Text("0")
                                        .font(CosmicFonts.headline)
                                        .foregroundColor(CosmicColors.nebulaPurple)
                                    Text("Friends")
                                        .font(CosmicFonts.caption)
                                        .foregroundColor(CosmicColors.textMuted)
                                }
                                
                                VStack {
                                    Text("0")
                                        .font(CosmicFonts.headline)
                                        .foregroundColor(CosmicColors.nebulaPurple)
                                    Text("Posts")
                                        .font(CosmicFonts.caption)
                                        .foregroundColor(CosmicColors.textMuted)
                                }
                            }
                        }
                        .padding(CosmicSpacing.l)
                        .cosmicCard()
                        .padding(.horizontal, CosmicSpacing.m)
                        .padding(.top, CosmicSpacing.m)
                        
                        // Personal Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("Personal")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            MenuRow(icon: "person.fill", title: "My Profile", action: { showProfile = true })
                            MenuRow(icon: "person.2.fill", title: "My Friends", action: { showFriends = true })
                            MenuRow(icon: "bell.fill", title: "My Notifications", action: { showNotifications = true })
                            MenuRow(icon: "square.and.pencil", title: "My Posts", action: { showMyPosts = true })
                        }
                        .padding(.top, CosmicSpacing.m)
                        
                        // Parent Tools Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            HStack {
                                Text("Parent Tools")
                                    .font(CosmicFonts.headline)
                                    .foregroundColor(CosmicColors.textPrimary)
                                
                                Spacer()
                                
                                // Badge indicating parent mode
                                Text("Nova+")
                                    .font(CosmicFonts.caption)
                                    .foregroundColor(CosmicColors.starGold)
                                    .padding(.horizontal, CosmicSpacing.s)
                                    .padding(.vertical, CosmicSpacing.xs)
                                    .background(
                                        Capsule()
                                            .fill(CosmicColors.starGold.opacity(0.2))
                                            .overlay(
                                                Capsule()
                                                    .stroke(CosmicColors.starGold.opacity(0.5), lineWidth: 1)
                                            )
                                    )
                            }
                            .padding(.horizontal, CosmicSpacing.m)
                            
                            // Manage Children
                            MenuRow(
                                icon: "person.2.fill",
                                title: "Manage Children",
                                subtitle: "\(children.count) child\(children.count == 1 ? "" : "ren")",
                                action: { showManageChildren = true }
                            )
                            
                            // Safety Dashboard
                            MenuRow(
                                icon: "shield.fill",
                                title: "Safety Dashboard",
                                subtitle: "Quick view of all children",
                                action: {}
                            )
                            
                            // Activity Reports
                            MenuRow(
                                icon: "chart.bar.fill",
                                title: "Activity Reports",
                                subtitle: "Weekly & monthly summaries",
                                action: {}
                            )
                        }
                        .padding(.top, CosmicSpacing.l)
                        
                        // Settings
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("Settings")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            MenuRow(icon: "gearshape.fill", title: "Account Settings", action: { showSettings = true })
                            MenuRow(icon: "bell.badge.fill", title: "Notification Preferences", action: {})
                            MenuRow(icon: "lock.fill", title: "Security", action: {})
                            MenuRow(icon: "book.fill", title: "Parenting Resources", action: {})
                            MenuRow(icon: "questionmark.circle.fill", title: "Help & Support", action: {})
                        }
                        .padding(.top, CosmicSpacing.m)
                        
                        // Log Out
                        Button(action: {
                            authManager.logout()
                        }) {
                            Text("Log Out")
                                .font(CosmicFonts.button)
                                .frame(maxWidth: .infinity)
                                .padding(CosmicSpacing.m)
                        }
                        .buttonStyle(CosmicButtonStyle(isPrimary: false))
                        .padding(.horizontal, CosmicSpacing.m)
                        .padding(.bottom, CosmicSpacing.xxl)
                    }
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showProfile) {
                ProfileView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showManageChildren) {
                ManageChildrenView(children: $children)
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showFriends) {
                FriendsView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showMyPosts) {
                MyPostsView()
                    .environmentObject(authManager)
            }
            .onAppear {
                loadChildren()
            }
        }
    }
    
    private func loadChildren() {
        // TODO: Load children from API
        // For now, placeholder
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: CosmicSpacing.m) {
                Image(systemName: icon)
                    .cosmicIcon(size: 20, color: CosmicColors.nebulaPurple)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                    Text(title)
                        .font(CosmicFonts.body)
                        .foregroundColor(CosmicColors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.textMuted)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .cosmicIcon(size: 14, color: CosmicColors.textMuted)
            }
            .padding(CosmicSpacing.m)
            .cosmicCard()
            .padding(.horizontal, CosmicSpacing.m)
        }
    }
}

// Placeholder for Manage Children View
struct ManageChildrenView: View {
    @Binding var children: [Child]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                ScrollView {
                    VStack(spacing: CosmicSpacing.l) {
                        // List of children
                        ForEach(children) { child in
                            MoreViewChildCard(child: child)
                                .padding(.horizontal, CosmicSpacing.m)
                        }
                        
                        // Add Child Button
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .cosmicIcon(size: 24, color: CosmicColors.nebulaPurple)
                                Text("Add Child")
                                    .font(CosmicFonts.button)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(CosmicSpacing.m)
                        }
                        .buttonStyle(CosmicButtonStyle(isPrimary: true))
                        .padding(.horizontal, CosmicSpacing.m)
                    }
                    .padding(.vertical, CosmicSpacing.m)
                }
            }
            .navigationTitle("Manage Children")
            .navigationBarTitleDisplayMode(.large)
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

struct MoreViewChildCard: View {
    let child: Child
    
    var body: some View {
        HStack(spacing: CosmicSpacing.m) {
            Circle()
                .fill(CosmicColors.primaryGradient)
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                Text(child.profile.displayName)
                    .font(CosmicFonts.headline)
                    .foregroundColor(CosmicColors.textPrimary)
                
                if let school = child.profile.school {
                    Text(school)
                        .font(CosmicFonts.caption)
                        .foregroundColor(CosmicColors.textMuted)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .cosmicIcon(size: 14, color: CosmicColors.textMuted)
        }
        .padding(CosmicSpacing.m)
        .cosmicCard()
    }
}

#Preview {
    MoreView()
        .environmentObject(AuthManager())
}
