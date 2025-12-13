//
//  SettingsView.swift
//  FamilyNovaParent
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ParentAppSpacing.m) {
                    // Profile Section
                    SettingsSection(title: "Profile") {
                        SettingsRow(icon: "person.fill", title: "Edit Profile", action: {})
                        SettingsRow(icon: "bell.fill", title: "Notifications", action: {})
                    }
                    .padding(.top, ParentAppSpacing.m)
                    
                    // Safety Section
                    SettingsSection(title: "Safety") {
                        SettingsRow(icon: "shield.fill", title: "Privacy Settings", action: {})
                        SettingsRow(icon: "lock.fill", title: "Security", action: {})
                    }
                    
                    // Logout Button
                    Button(action: handleLogout) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                            Text("Logout")
                                .font(ParentAppFonts.headline)
                        }
                        .foregroundColor(ParentAppColors.error)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                .stroke(ParentAppColors.error, lineWidth: 2)
                        )
                    }
                    .padding(.horizontal, ParentAppSpacing.m)
                    .padding(.top, ParentAppSpacing.l)
                }
                .padding(.bottom, ParentAppSpacing.l)
            }
            .background(ParentAppColors.lightGray)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func handleLogout() {
        authManager.logout()
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
            Text(title)
                .font(ParentAppFonts.headline)
                .foregroundColor(ParentAppColors.black)
                .padding(.horizontal, ParentAppSpacing.m)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(ParentAppCornerRadius.medium)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .padding(.horizontal, ParentAppSpacing.m)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ParentAppSpacing.m) {
                Image(systemName: icon)
                    .foregroundColor(ParentAppColors.primaryTeal)
                    .frame(width: 24)
                
                Text(title)
                    .font(ParentAppFonts.body)
                    .foregroundColor(ParentAppColors.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(ParentAppColors.mediumGray)
                    .font(.system(size: 14))
            }
            .padding(ParentAppSpacing.m)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}

