//
//  SettingsView.swift
//  FamilyNovaParent
//
//  Settings view with cosmic theme

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var showSubscription = false
    @State private var showAbout = false
    @State private var moderationToolsEnabled = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                ScrollView {
                    VStack(spacing: CosmicSpacing.l) {
                        // Profile Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("Profile")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            SettingsMenuRow(icon: "person.fill", title: "Edit Profile", action: {})
                            SettingsMenuRow(icon: "bell.fill", title: "Notifications", action: {})
                        }
                        .padding(.top, CosmicSpacing.m)
                        
                        // Subscription Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("Subscription")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            Button(action: {
                                showSubscription = true
                            }) {
                                HStack(spacing: CosmicSpacing.m) {
                                    Image(systemName: "star.fill")
                                        .cosmicIcon(size: 20, color: CosmicColors.starGold)
                                    
                                    Text("Manage Subscription")
                                        .font(CosmicFonts.body)
                                        .foregroundColor(CosmicColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .cosmicIcon(size: 14, color: CosmicColors.textMuted)
                                }
                                .padding(CosmicSpacing.m)
                                .background(CosmicColors.glassBackground)
                                .cornerRadius(CosmicCornerRadius.medium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                        .stroke(CosmicColors.glassBorder, lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, CosmicSpacing.m)
                        }
                        
                        // Parent Tools Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("Parent Tools")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            // Moderation Tools Toggle
                            HStack(spacing: CosmicSpacing.m) {
                                Image(systemName: "person.2.badge.gearshape.fill")
                                    .cosmicIcon(size: 20, color: CosmicColors.nebulaPurple)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                                    Text("Kids Moderation Tools")
                                        .font(CosmicFonts.body)
                                        .foregroundColor(CosmicColors.textPrimary)
                                    
                                    Text(hasChildren ? "Enabled for your children" : "No children linked")
                                        .font(CosmicFonts.caption)
                                        .foregroundColor(CosmicColors.textMuted)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $moderationToolsEnabled)
                                    .labelsHidden()
                                    .disabled(!hasChildren)
                            }
                            .padding(CosmicSpacing.m)
                            .background(CosmicColors.glassBackground)
                            .cornerRadius(CosmicCornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                    .stroke(CosmicColors.glassBorder, lineWidth: 1)
                            )
                            .padding(.horizontal, CosmicSpacing.m)
                        }
                        .padding(.top, CosmicSpacing.m)
                        
                        // Safety Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("Safety")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            SettingsMenuRow(icon: "shield.fill", title: "Privacy Settings", action: {})
                            SettingsMenuRow(icon: "lock.fill", title: "Security", action: {})
                        }
                        .padding(.top, CosmicSpacing.m)
                        
                        // About Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("About")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            SettingsMenuRow(icon: "info.circle.fill", title: "About Nova+", action: {
                                showAbout = true
                            })
                        }
                        .padding(.top, CosmicSpacing.m)
                        
                        // Logout Button
                        Button(action: handleLogout) {
                            HStack(spacing: CosmicSpacing.s) {
                                Image(systemName: "arrow.right.square.fill")
                                    .cosmicIcon(size: 20, color: CosmicColors.error)
                                Text("Logout")
                                    .font(CosmicFonts.headline)
                                    .foregroundColor(CosmicColors.error)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(CosmicColors.glassBackground)
                            .cornerRadius(CosmicCornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                    .stroke(CosmicColors.error.opacity(0.5), lineWidth: 2)
                            )
                        }
                        .padding(.horizontal, CosmicSpacing.m)
                        .padding(.top, CosmicSpacing.l)
                        .padding(.bottom, CosmicSpacing.xxl)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(CosmicFonts.button)
                    .foregroundColor(CosmicColors.nebulaPurple)
                }
            }
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .onAppear {
                // Load saved preference or set default based on whether user has children
                if let saved = UserDefaults.standard.object(forKey: "moderationToolsEnabled") as? Bool {
                    moderationToolsEnabled = saved
                } else {
                    // Default: ON if has children, OFF if no children
                    moderationToolsEnabled = hasChildren
                }
            }
            .onChange(of: moderationToolsEnabled) { newValue in
                // Save preference
                UserDefaults.standard.set(newValue, forKey: "moderationToolsEnabled")
            }
        }
    }
    
    private var hasChildren: Bool {
        guard let user = authManager.currentUser else { return false }
        return !user.children.isEmpty
    }
    
    private func handleLogout() {
        authManager.logout()
    }
}

struct SettingsMenuRow: View {
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
    SettingsView()
        .environmentObject(AuthManager())
}
