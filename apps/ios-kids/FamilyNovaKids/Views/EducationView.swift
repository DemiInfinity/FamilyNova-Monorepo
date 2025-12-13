//
//  EducationView.swift
//  FamilyNovaKids
//

import SwiftUI

struct EducationView: View {
    @State private var selectedTopic: EducationTopic?
    
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
                    VStack(spacing: AppSpacing.xl) {
                        // Header
                        VStack(spacing: AppSpacing.m) {
                            Text("🎓")
                                .font(.system(size: 80))
                            Text("Learn & Have Fun!")
                                .font(AppFonts.title)
                                .foregroundColor(AppColors.primaryPurple)
                            Text("Learn about staying safe online while having fun!")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.xl)
                        }
                        .padding(.top, AppSpacing.xl)
                        
                        // Education Topics
                        VStack(spacing: AppSpacing.l) {
                            EducationTopicCard(
                                topic: EducationTopic(
                                    title: "Online Safety",
                                    emoji: "🛡️",
                                    description: "Learn how to stay safe while having fun online",
                                    color: AppColors.primaryBlue,
                                    lessons: [
                                        "Never share your password",
                                        "Only talk to verified friends",
                                        "Tell a parent if something feels wrong"
                                    ]
                                )
                            )
                            
                            EducationTopicCard(
                                topic: EducationTopic(
                                    title: "Being a Good Friend",
                                    emoji: "🤝",
                                    description: "Learn how to be kind and respectful online",
                                    color: AppColors.primaryGreen,
                                    lessons: [
                                        "Be kind in your messages",
                                        "Include everyone",
                                        "Stand up for friends"
                                    ]
                                )
                            )
                            
                            EducationTopicCard(
                                topic: EducationTopic(
                                    title: "Privacy & Sharing",
                                    emoji: "🔒",
                                    description: "Learn what's safe to share and what's not",
                                    color: AppColors.primaryPurple,
                                    lessons: [
                                        "Don't share personal info",
                                        "Ask before sharing photos",
                                        "Keep your location private"
                                    ]
                                )
                            )
                            
                            EducationTopicCard(
                                topic: EducationTopic(
                                    title: "Digital Citizenship",
                                    emoji: "🌟",
                                    description: "Be a good digital citizen and make the internet better",
                                    color: AppColors.primaryOrange,
                                    lessons: [
                                        "Think before you post",
                                        "Respect others online",
                                        "Help make the internet a positive place"
                                    ]
                                )
                            )
                        }
                        .padding(.horizontal, AppSpacing.m)
                    }
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
            .navigationTitle("Education")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedTopic) { topic in
                EducationDetailView(topic: topic)
            }
        }
    }
}

struct EducationTopic: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let description: String
    let color: Color
    let lessons: [String]
}

struct EducationTopicCard: View {
    let topic: EducationTopic
    @State private var selectedTopic: EducationTopic?
    
    var body: some View {
        Button(action: { selectedTopic = topic }) {
            HStack(spacing: AppSpacing.l) {
                // Emoji icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [topic.color, topic.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text(topic.emoji)
                        .font(.system(size: 40))
                }
                
                // Content
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    Text(topic.title)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.black)
                    
                    Text(topic.description)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.darkGray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(topic.color)
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(AppSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(Color.white)
                    .shadow(color: topic.color.opacity(0.2), radius: 10, x: 0, y: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(item: $selectedTopic) { topic in
            EducationDetailView(topic: topic)
        }
    }
}

struct EducationDetailView: View {
    let topic: EducationTopic
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [topic.color.opacity(0.1), topic.color.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        // Header
                        VStack(spacing: AppSpacing.m) {
                            Text(topic.emoji)
                                .font(.system(size: 100))
                            Text(topic.title)
                                .font(AppFonts.title)
                                .foregroundColor(topic.color)
                            Text(topic.description)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.xl)
                        }
                        .padding(.top, AppSpacing.xxl)
                        
                        // Lessons
                        VStack(alignment: .leading, spacing: AppSpacing.l) {
                            Text("📚 What You'll Learn")
                                .font(AppFonts.headline)
                                .foregroundColor(topic.color)
                                .padding(.horizontal, AppSpacing.m)
                            
                            ForEach(Array(topic.lessons.enumerated()), id: \.offset) { index, lesson in
                                HStack(alignment: .top, spacing: AppSpacing.m) {
                                    ZStack {
                                        Circle()
                                            .fill(topic.color.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        Text("\(index + 1)")
                                            .font(AppFonts.headline)
                                            .foregroundColor(topic.color)
                                    }
                                    
                                    Text(lesson)
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.black)
                                    
                                    Spacer()
                                }
                                .padding(AppSpacing.l)
                                .background(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                                .padding(.horizontal, AppSpacing.m)
                            }
                        }
                        .padding(.top, AppSpacing.xl)
                        
                        // Fun completion message
                        VStack(spacing: AppSpacing.m) {
                            Text("🎉")
                                .font(.system(size: 60))
                            Text("Great job learning!")
                                .font(AppFonts.headline)
                                .foregroundColor(topic.color)
                            Text("Keep practicing these tips to stay safe online!")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.darkGray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(AppSpacing.xl)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                .fill(Color.white)
                                .shadow(color: topic.color.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, AppSpacing.m)
                        .padding(.top, AppSpacing.xl)
                    }
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
            .navigationTitle(topic.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(AppFonts.button)
                    .foregroundColor(topic.color)
                }
            }
        }
    }
}

#Preview {
    EducationView()
}

