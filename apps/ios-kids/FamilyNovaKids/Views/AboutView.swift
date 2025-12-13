//
//  AboutView.swift
//  FamilyNovaKids
//
//  About screen showing app icon, version, and creator info

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                ScrollView {
                    VStack(spacing: CosmicSpacing.xxl) {
                        // App Icon
                        VStack(spacing: CosmicSpacing.m) {
                            Image("AppIconImage")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .cornerRadius(26)
                                .shadow(color: CosmicColors.nebulaPurple.opacity(0.5), radius: 20, x: 0, y: 10)
                            
                            Text("Nova")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(CosmicColors.textPrimary)
                            
                            Text("Safe Social Networking for Kids")
                                .font(CosmicFonts.body)
                                .foregroundColor(CosmicColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, CosmicSpacing.xxl)
                        
                        // Version Info
                        VStack(spacing: CosmicSpacing.m) {
                            InfoRow(title: "Version", value: getAppVersion())
                            InfoRow(title: "Build", value: getAppBuild())
                        }
                        .padding(.horizontal, CosmicSpacing.m)
                        
                        // Creator Info
                        VStack(spacing: CosmicSpacing.m) {
                            Text("Created by")
                                .font(CosmicFonts.caption)
                                .foregroundColor(CosmicColors.textMuted)
                                .textCase(.uppercase)
                            
                            Text("FamilyNova Team")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                        }
                        .padding(.top, CosmicSpacing.l)
                        
                        Spacer()
                    }
                    .padding(CosmicSpacing.xl)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(CosmicFonts.button)
                    .foregroundColor(CosmicColors.nebulaPurple)
                }
            }
        }
    }
    
    private func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0"
    }
    
    private func getAppBuild() -> String {
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "1"
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(CosmicFonts.body)
                .foregroundColor(CosmicColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(CosmicFonts.body)
                .foregroundColor(CosmicColors.textPrimary)
        }
        .padding(CosmicSpacing.m)
        .background(CosmicColors.glassBackground)
        .cornerRadius(CosmicCornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                .stroke(CosmicColors.glassBorder, lineWidth: 1)
        )
    }
}

#Preview {
    AboutView()
}

