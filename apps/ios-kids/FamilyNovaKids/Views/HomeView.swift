//
//  HomeView.swift
//  FamilyNovaKids
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Fun gradient background
                LinearGradient(
                    colors: [AppColors.gradientBlue.opacity(0.1), AppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.l) {
                        // Welcome Card with emoji and fun design
                        WelcomeCard()
                            .padding(.horizontal, AppSpacing.m)
                            .padding(.top, AppSpacing.m)
                        
                        // Quick Actions - Bigger, more colorful
                        VStack(alignment: .leading, spacing: AppSpacing.m) {
                            HStack {
                                Text("🚀 Quick Actions")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.primaryPurple)
                                Spacer()
                            }
                            .padding(.horizontal, AppSpacing.m)
                            
                            HStack(spacing: AppSpacing.m) {
                                QuickActionCard(
                                    icon: "person.2.fill",
                                    title: "Add Friend",
                                    emoji: "👥",
                                    color: AppColors.primaryGreen,
                                    gradient: [AppColors.primaryGreen, AppColors.primaryBlue]
                                )
                                
                                QuickActionCard(
                                    icon: "message.fill",
                                    title: "Messages",
                                    emoji: "💬",
                                    color: AppColors.primaryPink,
                                    gradient: [AppColors.primaryPink, AppColors.primaryPurple]
                                )
                                
                                QuickActionCard(
                                    icon: "book.fill",
                                    title: "Learn",
                                    emoji: "📚",
                                    color: AppColors.primaryYellow,
                                    gradient: [AppColors.primaryYellow, AppColors.primaryOrange]
                                )
                            }
                            .padding(.horizontal, AppSpacing.m)
                        }
                        .padding(.top, AppSpacing.m)
                        
                        // Education Section
                        EducationSection()
                            .padding(.horizontal, AppSpacing.m)
                            .padding(.top, AppSpacing.m)
                        
                        // Recent Activity
                        VStack(alignment: .leading, spacing: AppSpacing.m) {
                            HStack {
                                Text("⭐ Recent Activity")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.primaryOrange)
                                Spacer()
                            }
                            .padding(.horizontal, AppSpacing.m)
                            
                            ActivityCard()
                                .padding(.horizontal, AppSpacing.m)
                        }
                        .padding(.top, AppSpacing.l)
                    }
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WelcomeCard: View {
    var body: some View {
        ZStack {
            // Fun gradient background
            LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(AppCornerRadius.extraLarge)
            
            HStack(spacing: AppSpacing.m) {
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    Text("Hey there! 👋")
                        .font(AppFonts.title)
                        .foregroundColor(.white)
                    
                    Text("Ready to connect with friends and learn something new?")
                        .font(AppFonts.body)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Fun emoji decoration
                Text("🌟")
                    .font(.system(size: 60))
            }
            .padding(AppSpacing.xl)
        }
        .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let emoji: String
    let color: Color
    let gradient: [Color]
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: AppSpacing.s) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Text(emoji)
                        .font(.system(size: 36))
                }
                
                Text(title)
                    .font(AppFonts.button)
                    .foregroundColor(AppColors.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(Color.white)
                    .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EducationSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.m) {
            HStack {
                Text("🎓 Learn & Have Fun")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.primaryPurple)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.m)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.m) {
                    EducationCard(
                        title: "Online Safety",
                        emoji: "🛡️",
                        color: AppColors.primaryBlue
                    )
                    
                    EducationCard(
                        title: "Digital Friends",
                        emoji: "🤝",
                        color: AppColors.primaryGreen
                    )
                    
                    EducationCard(
                        title: "Be Kind Online",
                        emoji: "💝",
                        color: AppColors.primaryPink
                    )
                    
                    EducationCard(
                        title: "Privacy Tips",
                        emoji: "🔒",
                        color: AppColors.primaryPurple
                    )
                }
                .padding(.horizontal, AppSpacing.m)
            }
        }
    }
}

struct EducationCard: View {
    let title: String
    let emoji: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: AppSpacing.m) {
                Text(emoji)
                    .font(.system(size: 50))
                
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 140, height: 160)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppCornerRadius.large)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActivityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            HStack {
                Text("✨")
                    .font(.system(size: 24))
                Text("No recent activity yet")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.darkGray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    HomeView()
}
