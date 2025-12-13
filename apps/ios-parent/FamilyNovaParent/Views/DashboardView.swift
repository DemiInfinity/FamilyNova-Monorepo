//
//  DashboardView.swift
//  FamilyNovaParent
//

import SwiftUI

struct DashboardView: View {
    @State private var children: [Child] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ParentAppSpacing.m) {
                    // Welcome Card
                    WelcomeCard()
                        .padding(.horizontal, ParentAppSpacing.m)
                        .padding(.top, ParentAppSpacing.m)
                    
                    // My Children Section
                    VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                        Text("My Children")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                            .padding(.horizontal, ParentAppSpacing.m)
                        
                        if children.isEmpty {
                            EmptyChildrenCard()
                                .padding(.horizontal, ParentAppSpacing.m)
                        } else {
                            ForEach(children) { child in
                                ChildCard(child: child)
                                    .padding(.horizontal, ParentAppSpacing.m)
                            }
                        }
                    }
                    .padding(.top, ParentAppSpacing.m)
                    
                    // Pending Posts
                    VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                        HStack {
                            Text("Pending Posts")
                                .font(ParentAppFonts.headline)
                                .foregroundColor(ParentAppColors.black)
                            Spacer()
                            NavigationLink(destination: PostApprovalView()) {
                                Text("View All")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.primaryTeal)
                            }
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        PendingPostsCard()
                            .padding(.horizontal, ParentAppSpacing.m)
                    }
                    .padding(.top, ParentAppSpacing.l)
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                        Text("Recent Activity")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                            .padding(.horizontal, ParentAppSpacing.m)
                        
                        ActivityCard()
                            .padding(.horizontal, ParentAppSpacing.m)
                    }
                    .padding(.top, ParentAppSpacing.l)
                }
                .padding(.bottom, ParentAppSpacing.l)
            }
            .background(ParentAppColors.lightGray)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WelcomeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
            Text("Parent Dashboard")
                .font(ParentAppFonts.title)
                .foregroundColor(ParentAppColors.primaryNavy)
            
            Text("Monitor and protect your children's online experience")
                .font(ParentAppFonts.body)
                .foregroundColor(ParentAppColors.darkGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ParentAppSpacing.l)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.large)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ChildCard: View {
    let child: Child
    
    var body: some View {
        HStack(spacing: ParentAppSpacing.m) {
            // Avatar
            Circle()
                .fill(ParentAppColors.mediumGray)
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                )
            
            // Child Info
            VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                Text(child.profile.displayName)
                    .font(ParentAppFonts.headline)
                    .foregroundColor(ParentAppColors.black)
                
                if child.verification.parentVerified && child.verification.schoolVerified {
                    HStack(spacing: ParentAppSpacing.xs) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(ParentAppColors.success)
                            .font(.system(size: 12))
                        Text("Verified")
                            .font(ParentAppFonts.small)
                            .foregroundColor(ParentAppColors.success)
                    }
                }
                
                if let lastLogin = child.lastLogin {
                    Text("Last active: \(lastLogin, style: .relative)")
                        .font(ParentAppFonts.small)
                        .foregroundColor(ParentAppColors.darkGray)
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("View Details")
                    .font(ParentAppFonts.small)
                    .foregroundColor(.white)
                    .padding(.horizontal, ParentAppSpacing.m)
                    .padding(.vertical, ParentAppSpacing.s)
                    .background(ParentAppColors.primaryTeal)
                    .cornerRadius(ParentAppCornerRadius.small)
            }
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct EmptyChildrenCard: View {
    var body: some View {
        VStack(spacing: ParentAppSpacing.m) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 48))
                .foregroundColor(ParentAppColors.mediumGray)
            Text("No children added yet")
                .font(ParentAppFonts.body)
                .foregroundColor(ParentAppColors.darkGray)
        }
        .frame(maxWidth: .infinity)
        .padding(ParentAppSpacing.l)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct PendingPostsCard: View {
    @State private var pendingCount = 0
    
    var body: some View {
        NavigationLink(destination: PostApprovalView()) {
            HStack(spacing: ParentAppSpacing.m) {
                ZStack {
                    Circle()
                        .fill(ParentAppColors.warning.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ParentAppColors.warning)
                }
                
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text("\(pendingCount) posts pending approval")
                        .font(ParentAppFonts.headline)
                        .foregroundColor(ParentAppColors.black)
                    Text("Review posts from your children")
                        .font(ParentAppFonts.caption)
                        .foregroundColor(ParentAppColors.darkGray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(ParentAppColors.mediumGray)
            }
            .padding(ParentAppSpacing.m)
            .background(Color.white)
            .cornerRadius(ParentAppCornerRadius.medium)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // TODO: Load pending count
            pendingCount = 0
        }
    }
}

struct ActivityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
            Text("No recent activity")
                .font(ParentAppFonts.caption)
                .foregroundColor(ParentAppColors.darkGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    DashboardView()
}

