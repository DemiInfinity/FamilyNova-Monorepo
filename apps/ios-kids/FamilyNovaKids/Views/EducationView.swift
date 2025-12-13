//
//  EducationView.swift
//  FamilyNovaKids
//

import SwiftUI

struct EducationView: View {
    @State private var selectedTopic: EducationTopic?
    @State private var selectedTab = 0
    @State private var educationContent: [EducationContentItem] = []
    @State private var isLoading = false
    
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
                
                VStack(spacing: 0) {
                    // Tab Selector
                    HStack(spacing: 0) {
                        Button(action: { selectedTab = 0 }) {
                            VStack(spacing: AppSpacing.xs) {
                                Text("📚")
                                    .font(.system(size: 24))
                                Text("Learn")
                                    .font(AppFonts.caption)
                                    .foregroundColor(selectedTab == 0 ? AppColors.primaryPurple : AppColors.darkGray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.m)
                            .background(selectedTab == 0 ? Color.white.opacity(0.5) : Color.clear)
                        }
                        
                        Button(action: { selectedTab = 1 }) {
                            VStack(spacing: AppSpacing.xs) {
                                Text("📝")
                                    .font(.system(size: 24))
                                Text("Homework")
                                    .font(AppFonts.caption)
                                    .foregroundColor(selectedTab == 1 ? AppColors.primaryPurple : AppColors.darkGray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.m)
                            .background(selectedTab == 1 ? Color.white.opacity(0.5) : Color.clear)
                        }
                    }
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(AppCornerRadius.medium)
                    .padding(.horizontal, AppSpacing.m)
                    .padding(.top, AppSpacing.m)
                    
                    // Content
                    if selectedTab == 0 {
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
                    } else {
                        // Homework/Education Content
                        if isLoading {
                            VStack(spacing: AppSpacing.l) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Loading homework...")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.darkGray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if educationContent.isEmpty {
                            VStack(spacing: AppSpacing.l) {
                                Text("📝")
                                    .font(.system(size: 80))
                                Text("No homework yet!")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.primaryBlue)
                                Text("Your school will post homework and assignments here")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.darkGray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, AppSpacing.xl)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: AppSpacing.m) {
                                    ForEach(educationContent) { item in
                                        EducationContentCard(content: item)
                                    }
                                }
                                .padding(AppSpacing.m)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Education")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedTopic) { topic in
                EducationDetailView(topic: topic)
            }
            .onAppear {
                if selectedTab == 1 {
                    loadEducationContent()
                }
            }
            .onChange(of: selectedTab) { newValue in
                if newValue == 1 {
                    loadEducationContent()
                }
            }
        }
    }
    
    private func loadEducationContent() {
        isLoading = true
        Task {
            // TODO: Implement API call to fetch education content
            // GET /api/education
            try? await Task.sleep(nanoseconds: 500_000_000)
            educationContent = []
            isLoading = false
        }
    }
}

struct EducationContentItem: Identifiable {
    let id = UUID()
    let contentId: String
    let title: String
    let description: String?
    let contentType: String // homework, lesson, quiz, resource
    let subject: String
    let dueDate: Date?
    let school: String
    let isCompleted: Bool
}

struct EducationContentCard: View {
    let content: EducationContentItem
    @State private var showDetail = false
    
    var body: some View {
        Button(action: { showDetail = true }) {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(content.title)
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.black)
                        
                        Text(content.subject)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.darkGray)
                    }
                    
                    Spacer()
                    
                    if content.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.success)
                            .font(.system(size: 24))
                    } else {
                        Text(contentTypeEmoji)
                            .font(.system(size: 32))
                    }
                }
                
                if let description = content.description, !description.isEmpty {
                    Text(description)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.darkGray)
                        .lineLimit(2)
                }
                
                HStack {
                    Text("🏫 \(content.school)")
                        .font(AppFonts.small)
                        .foregroundColor(AppColors.darkGray)
                    
                    Spacer()
                    
                    if let dueDate = content.dueDate {
                        Text("Due: \(dueDate, style: .date)")
                            .font(AppFonts.small)
                            .foregroundColor(dueDate < Date() ? AppColors.error : AppColors.primaryBlue)
                    }
                }
            }
            .padding(AppSpacing.l)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            EducationContentDetailView(content: content)
        }
    }
    
    private var contentTypeEmoji: String {
        switch content.contentType {
        case "homework": return "📝"
        case "lesson": return "📚"
        case "quiz": return "📊"
        case "resource": return "📖"
        default: return "📄"
        }
    }
}

struct EducationContentDetailView: View {
    let content: EducationContentItem
    @Environment(\.dismiss) var dismiss
    @State private var submissionText = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.l) {
                    Text(content.title)
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryPurple)
                    
                    if let description = content.description, !description.isEmpty {
                        Text(description)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.black)
                    }
                    
                    HStack {
                        Text("Subject: \(content.subject)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.darkGray)
                        Spacer()
                        Text("🏫 \(content.school)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.darkGray)
                    }
                    
                    if let dueDate = content.dueDate {
                        Text("Due: \(dueDate, style: .date)")
                            .font(AppFonts.body)
                            .foregroundColor(dueDate < Date() ? AppColors.error : AppColors.primaryBlue)
                    }
                    
                    if !content.isCompleted && content.contentType == "homework" {
                        Divider()
                        
                        Text("Your Submission")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.primaryPurple)
                        
                        TextEditor(text: $submissionText)
                            .foregroundColor(AppColors.black)
                            .frame(minHeight: 200)
                            .padding(AppSpacing.m)
                            .background(Color.white)
                            .cornerRadius(AppCornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .stroke(AppColors.mediumGray, lineWidth: 1)
                            )
                        
                        Button(action: submitHomework) {
                            HStack(spacing: AppSpacing.s) {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("✅")
                                        .font(.system(size: 24))
                                    Text("Submit")
                                        .font(AppFonts.button)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(AppCornerRadius.large)
                        }
                        .disabled(isSubmitting || submissionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(AppSpacing.m)
            }
            .navigationTitle("Homework")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(AppFonts.button)
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
        }
    }
    
    private func submitHomework() {
        isSubmitting = true
        Task {
            // TODO: Implement API call to submit homework
            // POST /api/education/:contentId/complete
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isSubmitting = false
            dismiss()
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

