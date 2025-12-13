//
//  MoreView.swift
//  FamilyNovaKids
//
//  Simple More menu for kids

import SwiftUI

struct MoreView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showProfile = false
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                ScrollView {
                    VStack(spacing: CosmicSpacing.xl) {
                        // Profile Section
                        VStack(spacing: CosmicSpacing.m) {
                            // Profile Picture
                            Circle()
                                .fill(CosmicColors.primaryGradient)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(CosmicColors.nebulaPurple.opacity(0.5), lineWidth: 3)
                                )
                                .shadow(color: CosmicColors.nebulaPurple.opacity(0.5), radius: 15)
                            
                            // Username
                            if let user = authManager.currentUser {
                                Text(user.profile.displayName)
                                    .font(CosmicFonts.headline)
                                    .foregroundColor(CosmicColors.textPrimary)
                            }
                            
                            // Quick Stats
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
                        
                        // Menu Options
                        VStack(spacing: CosmicSpacing.s) {
                            MenuRow(icon: "person.fill", title: "My Profile", action: { showProfile = true })
                            MenuRow(icon: "person.2.fill", title: "Friends", action: {})
                            MenuRow(icon: "bell.fill", title: "Notifications", action: {})
                            MenuRow(icon: "paintbrush.fill", title: "Customize Theme", action: {})
                            MenuRow(icon: "gearshape.fill", title: "Settings", action: { showSettings = true })
                        }
                        .padding(.horizontal, CosmicSpacing.m)
                        
                        // Educational Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            Text("Digital Safety Tips")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                            
                            Text("Learn how to stay safe online and be a good digital citizen.")
                                .font(CosmicFonts.body)
                                .foregroundColor(CosmicColors.textSecondary)
                        }
                        .padding(CosmicSpacing.m)
                        .cosmicCard()
                        .padding(.horizontal, CosmicSpacing.m)
                        
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
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: CosmicSpacing.m) {
                Image(systemName: icon)
                    .cosmicIcon(size: 20, color: CosmicColors.nebulaPurple)
                    .frame(width: 30)
                
                Text(title)
                    .font(CosmicFonts.body)
                    .foregroundColor(CosmicColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .cosmicIcon(size: 14, color: CosmicColors.textMuted)
            }
            .padding(CosmicSpacing.m)
            .cosmicCard()
        }
    }
}

#Preview {
    MoreView()
        .environmentObject(AuthManager())
}

