//
//  SettingsView.swift
//  FamilyNovaKids
//
//  Simple settings view for kids

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var showAbout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                ScrollView {
                    VStack(spacing: CosmicSpacing.l) {
                        // Account Settings
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("Account")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            MenuRow(icon: "person.fill", title: "Edit Profile", action: {})
                            MenuRow(icon: "lock.fill", title: "Privacy Settings", action: {})
                        }
                        .padding(.top, CosmicSpacing.m)
                        
                        // Safety
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("Safety")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            MenuRow(icon: "person.fill.badge.minus", title: "Blocked Users", action: {})
                            MenuRow(icon: "shield.fill", title: "Report a Problem", action: {})
                        }
                        .padding(.top, CosmicSpacing.m)
                        
                        // Help
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("Help")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            MenuRow(icon: "questionmark.circle.fill", title: "Help & Support", action: {})
                            MenuRow(icon: "info.circle.fill", title: "About Nova", action: {
                                showAbout = true
                            })
                        }
                        .padding(.top, CosmicSpacing.m)
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
                    .foregroundColor(CosmicColors.nebulaPurple)
                }
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}

