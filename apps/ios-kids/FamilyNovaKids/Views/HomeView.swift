//
//  HomeView.swift
//  FamilyNovaKids
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.m) {
                    // Welcome Card
                    WelcomeCard()
                        .padding(.horizontal, AppSpacing.m)
                        .padding(.top, AppSpacing.m)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        Text("Quick Actions")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal, AppSpacing.m)
                        
                        HStack(spacing: AppSpacing.s) {
                            QuickActionCard(
                                icon: "person.badge.plus",
                                title: "Add Friend",
                                color: AppColors.primaryGreen
                            )
                            
                            QuickActionCard(
                                icon: "message.fill",
                                title: "Messages",
                                color: AppColors.primaryOrange
                            )
                        }
                        .padding(.horizontal, AppSpacing.m)
                    }
                    .padding(.top, AppSpacing.m)
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: AppSpacing.s) {
                        Text("Recent Activity")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.black)
                            .padding(.horizontal, AppSpacing.m)
                        
                        ActivityCard()
                            .padding(.horizontal, AppSpacing.m)
                    }
                    .padding(.top, AppSpacing.l)
                }
                .padding(.bottom, AppSpacing.l)
            }
            .background(AppColors.lightGray)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WelcomeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text("Welcome back!")
                .font(AppFonts.title)
                .foregroundColor(AppColors.primaryBlue)
            
            Text("Connect with your friends safely")
                .font(AppFonts.body)
                .foregroundColor(AppColors.darkGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.l)
        .background(Color.white)
        .cornerRadius(AppCornerRadius.large)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.s) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.black)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(Color.white)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ActivityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            Text("No recent activity")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.darkGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.m)
        .background(Color.white)
        .cornerRadius(AppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HomeView()
}

