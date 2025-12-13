//
//  SafetyDashboardView.swift
//  FamilyNovaParent
//
//  Safety Dashboard showing quick overview of all children

import SwiftUI

struct SafetyDashboardView: View {
    let children: [Child]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedChild: Child? = nil
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                if children.isEmpty {
                    VStack(spacing: CosmicSpacing.xl) {
                        Image(systemName: "person.2.fill")
                            .cosmicIcon(size: 60, color: CosmicColors.nebulaPurple)
                        Text("No Children Added")
                            .font(CosmicFonts.headline)
                            .foregroundColor(CosmicColors.textPrimary)
                        Text("Add children to see their safety status here")
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CosmicSpacing.xl)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: CosmicSpacing.l) {
                            // Overview Stats
                            HStack(spacing: CosmicSpacing.m) {
                                SafetyStatCard(
                                    icon: "checkmark.shield.fill",
                                    title: "Verified",
                                    value: "\(verifiedCount)",
                                    color: CosmicColors.planetTeal
                                )
                                
                                SafetyStatCard(
                                    icon: "exclamationmark.triangle.fill",
                                    title: "Pending",
                                    value: "\(pendingCount)",
                                    color: CosmicColors.starGold
                                )
                                
                                SafetyStatCard(
                                    icon: "eye.fill",
                                    title: "Monitoring",
                                    value: "\(monitoringCount)",
                                    color: CosmicColors.nebulaPurple
                                )
                            }
                            .padding(.horizontal, CosmicSpacing.m)
                            .padding(.top, CosmicSpacing.m)
                            
                            // Children List
                            VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                                Text("Children Overview")
                                    .font(CosmicFonts.headline)
                                    .foregroundColor(CosmicColors.textPrimary)
                                    .padding(.horizontal, CosmicSpacing.m)
                                
                                ForEach(children) { child in
                                    SafetyChildCard(child: child)
                                        .padding(.horizontal, CosmicSpacing.m)
                                        .onTapGesture {
                                            selectedChild = child
                                        }
                                }
                            }
                            .padding(.top, CosmicSpacing.m)
                        }
                        .padding(.bottom, CosmicSpacing.xl)
                    }
                }
            }
            .navigationTitle("Safety Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(CosmicColors.nebulaPurple)
                }
            }
            .sheet(item: $selectedChild) { child in
                ChildDetailsView(child: child)
                    .environmentObject(authManager)
            }
        }
    }
    
    private var verifiedCount: Int {
        children.filter { $0.verification.parentVerified && $0.verification.schoolVerified }.count
    }
    
    private var pendingCount: Int {
        children.filter { !$0.verification.parentVerified || !$0.verification.schoolVerified }.count
    }
    
    private var monitoringCount: Int {
        children.count
    }
}

struct SafetyStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: CosmicSpacing.s) {
            Image(systemName: icon)
                .cosmicIcon(size: 24, color: color)
            
            Text(value)
                .font(CosmicFonts.title)
                .foregroundColor(CosmicColors.textPrimary)
            
            Text(title)
                .font(CosmicFonts.caption)
                .foregroundColor(CosmicColors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(CosmicSpacing.m)
        .cosmicCard()
    }
}

struct SafetyChildCard: View {
    let child: Child
    
    var body: some View {
        HStack(spacing: CosmicSpacing.m) {
            // Avatar
            Group {
                if let avatarUrl = child.profile.avatar, !avatarUrl.isEmpty {
                    AsyncImage(url: URL(string: avatarUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(CosmicColors.primaryGradient)
                    }
                } else {
                    Circle()
                        .fill(CosmicColors.primaryGradient)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(CosmicColors.nebulaPurple.opacity(0.3), lineWidth: 2)
            )
            
            VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                Text(child.profile.displayName)
                    .font(CosmicFonts.headline)
                    .foregroundColor(CosmicColors.textPrimary)
                
                HStack(spacing: CosmicSpacing.s) {
                    if child.verification.parentVerified {
                        Label("Parent Verified", systemImage: "checkmark.shield.fill")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.planetTeal)
                    } else {
                        Label("Pending", systemImage: "clock.fill")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.starGold)
                    }
                    
                    if child.verification.schoolVerified {
                        Label("School Verified", systemImage: "building.2.fill")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.planetTeal)
                    } else {
                        Label("School Pending", systemImage: "clock.fill")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.starGold)
                    }
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

