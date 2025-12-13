//
//  ActivityReportsView.swift
//  FamilyNovaParent
//
//  Activity Reports showing weekly and monthly summaries

import SwiftUI

struct ActivityReportsView: View {
    let children: [Child]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedPeriod: ReportPeriod = .week
    @State private var selectedChild: Child? = nil
    @State private var isLoading = false
    @State private var reports: [ActivityReport] = []
    
    enum ReportPeriod: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                if children.isEmpty {
                    VStack(spacing: CosmicSpacing.xl) {
                        Image(systemName: "chart.bar.fill")
                            .cosmicIcon(size: 60, color: CosmicColors.nebulaPurple)
                        Text("No Activity Data")
                            .font(CosmicFonts.headline)
                            .foregroundColor(CosmicColors.textPrimary)
                        Text("Activity reports will appear here once children start using the app")
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CosmicSpacing.xl)
                    }
                } else {
                    VStack(spacing: 0) {
                        // Period Selector
                        HStack(spacing: 0) {
                            ForEach(ReportPeriod.allCases, id: \.self) { period in
                                Button(action: {
                                    selectedPeriod = period
                                    loadReports()
                                }) {
                                    Text(period.rawValue)
                                        .font(CosmicFonts.caption)
                                        .foregroundColor(selectedPeriod == period ? CosmicColors.nebulaPurple : CosmicColors.textMuted)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, CosmicSpacing.s)
                                        .background(
                                            selectedPeriod == period ?
                                            CosmicColors.nebulaPurple.opacity(0.1) : Color.clear
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, CosmicSpacing.m)
                        .padding(.top, CosmicSpacing.m)
                        .background(
                            RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                .fill(CosmicColors.glassBackground.opacity(0.5))
                        )
                        .padding(.horizontal, CosmicSpacing.m)
                        
                        if isLoading {
                            VStack(spacing: CosmicSpacing.l) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(CosmicColors.nebulaPurple)
                                Text("Loading reports...")
                                    .font(CosmicFonts.body)
                                    .foregroundColor(CosmicColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if reports.isEmpty {
                            VStack(spacing: CosmicSpacing.l) {
                                Image(systemName: "chart.bar.xaxis")
                                    .cosmicIcon(size: 60, color: CosmicColors.textMuted)
                                Text("No Activity Yet")
                                    .font(CosmicFonts.headline)
                                    .foregroundColor(CosmicColors.textPrimary)
                                Text("Activity data will appear here as children use the app")
                                    .font(CosmicFonts.body)
                                    .foregroundColor(CosmicColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, CosmicSpacing.xl)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                VStack(spacing: CosmicSpacing.l) {
                                    // Summary Cards
                                    HStack(spacing: CosmicSpacing.m) {
                                        ReportStatCard(
                                            icon: "message.fill",
                                            title: "Messages",
                                            value: "\(totalMessages)",
                                            color: CosmicColors.nebulaBlue
                                        )
                                        
                                        ReportStatCard(
                                            icon: "square.and.pencil",
                                            title: "Posts",
                                            value: "\(totalPosts)",
                                            color: CosmicColors.nebulaPurple
                                        )
                                        
                                        ReportStatCard(
                                            icon: "person.2.fill",
                                            title: "Friends",
                                            value: "\(totalFriends)",
                                            color: CosmicColors.planetTeal
                                        )
                                    }
                                    .padding(.horizontal, CosmicSpacing.m)
                                    .padding(.top, CosmicSpacing.m)
                                    
                                    // Per-Child Reports
                                    VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                                        Text("Per-Child Activity")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                            .padding(.horizontal, CosmicSpacing.m)
                                        
                                        ForEach(children) { child in
                                            if let report = reports.first(where: { $0.childId == child.id }) {
                                                ActivityReportChildCard(child: child, report: report)
                                                    .padding(.horizontal, CosmicSpacing.m)
                                                    .onTapGesture {
                                                        selectedChild = child
                                                    }
                                            }
                                        }
                                    }
                                    .padding(.top, CosmicSpacing.m)
                                }
                                .padding(.bottom, CosmicSpacing.xl)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Activity Reports")
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
            .onAppear {
                loadReports()
            }
        }
    }
    
    private var totalMessages: Int {
        reports.reduce(0) { $0 + $1.messagesCount }
    }
    
    private var totalPosts: Int {
        reports.reduce(0) { $0 + $1.postsCount }
    }
    
    private var totalFriends: Int {
        reports.reduce(0) { $0 + $1.friendsCount }
    }
    
    private func loadReports() {
        // TODO: Implement actual API call to fetch activity reports
        // For now, generate mock data
        isLoading = true
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // Simulate API call
            
            await MainActor.run {
                // Generate mock reports for each child
                reports = children.map { child in
                    ActivityReport(
                        childId: child.id,
                        period: selectedPeriod,
                        messagesCount: Int.random(in: 0...50),
                        postsCount: Int.random(in: 0...20),
                        friendsCount: Int.random(in: 0...15),
                        lastActivity: Date().addingTimeInterval(-Double.random(in: 0...86400))
                    )
                }
                isLoading = false
            }
        }
    }
}

struct ActivityReport {
    let childId: String
    let period: ActivityReportsView.ReportPeriod
    let messagesCount: Int
    let postsCount: Int
    let friendsCount: Int
    let lastActivity: Date
}

struct ReportStatCard: View {
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

struct ActivityReportChildCard: View {
    let child: Child
    let report: ActivityReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
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
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                    Text(child.profile.displayName)
                        .font(CosmicFonts.headline)
                        .foregroundColor(CosmicColors.textPrimary)
                    
                    Text("Last active: \(report.lastActivity, style: .relative)")
                        .font(CosmicFonts.caption)
                        .foregroundColor(CosmicColors.textMuted)
                }
                
                Spacer()
            }
            
            Divider()
                .background(CosmicColors.glassBorder)
            
            // Activity Stats
            HStack(spacing: CosmicSpacing.l) {
                ActivityItem(icon: "message.fill", count: report.messagesCount, label: "Messages")
                ActivityItem(icon: "square.and.pencil", count: report.postsCount, label: "Posts")
                ActivityItem(icon: "person.2.fill", count: report.friendsCount, label: "Friends")
            }
        }
        .padding(CosmicSpacing.m)
        .cosmicCard()
    }
}

struct ActivityItem: View {
    let icon: String
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: CosmicSpacing.xs) {
            HStack(spacing: CosmicSpacing.xs) {
                Image(systemName: icon)
                    .cosmicIcon(size: 16, color: CosmicColors.nebulaPurple)
                Text("\(count)")
                    .font(CosmicFonts.headline)
                    .foregroundColor(CosmicColors.textPrimary)
            }
            
            Text(label)
                .font(CosmicFonts.caption)
                .foregroundColor(CosmicColors.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

