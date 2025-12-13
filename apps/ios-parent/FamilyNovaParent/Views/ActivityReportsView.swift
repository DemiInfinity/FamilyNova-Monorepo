//
//  ActivityReportsView.swift
//  FamilyNovaParent
//
//  Activity Reports showing weekly and monthly summaries

import SwiftUI

struct ActivityReportsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedPeriod: ReportPeriod = .week
    @State private var selectedChild: Child? = nil
    @State private var isLoading = false
    @State private var isLoadingChildren = false
    @State private var reports: [ActivityReport] = []
    @State private var children: [Child] = []
    
    enum ReportPeriod: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                mainContent
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
                loadChildren()
            }
            .onChange(of: children) { _ in
                loadReports()
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if children.isEmpty {
            emptyStateView
        } else {
            reportsContentView
        }
    }
    
    private var emptyStateView: some View {
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
    }
    
    @ViewBuilder
    private var reportsContentView: some View {
        VStack(spacing: 0) {
            periodSelector
            reportsList
        }
    }
    
    private var periodSelector: some View {
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
    }
    
    @ViewBuilder
    private var reportsList: some View {
        if isLoading {
            loadingView
        } else if reports.isEmpty {
            noReportsView
        } else {
            reportsScrollView
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: CosmicSpacing.l) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(CosmicColors.nebulaPurple)
            Text("Loading reports...")
                .font(CosmicFonts.body)
                .foregroundColor(CosmicColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var noReportsView: some View {
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
    }
    
    private var reportsScrollView: some View {
        ScrollView {
            VStack(spacing: CosmicSpacing.l) {
                summaryCards
                perChildReports
            }
            .padding(.bottom, CosmicSpacing.xl)
        }
    }
    
    private var summaryCards: some View {
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
    }
    
    private var perChildReports: some View {
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
    
    private var totalMessages: Int {
        reports.reduce(0) { $0 + $1.messagesCount }
    }
    
    private var totalPosts: Int {
        reports.reduce(0) { $0 + $1.postsCount }
    }
    
    private var totalFriends: Int {
        reports.reduce(0) { $0 + $1.friendsCount }
    }
    
    private func loadChildren() {
        // First try to get from currentUser
        if let currentUser = authManager.currentUser, !currentUser.children.isEmpty {
            self.children = currentUser.children
            loadReports()
        }
        
        // Then load from API for latest data
        guard let token = authManager.token else {
            return
        }
        
        isLoadingChildren = true
        Task {
            do {
                let apiService = ApiService.shared
                
                struct DashboardResponse: Codable {
                    let parent: ParentDashboardData
                }
                
                struct ParentDashboardData: Codable {
                    let id: String
                    let profile: ParentProfile
                    let children: [Child]
                    let parentConnections: [ParentConnection]?
                }
                
                let response: DashboardResponse = try await apiService.makeRequest(
                    endpoint: "parents/dashboard",
                    method: "GET",
                    token: token
                )
                
                await MainActor.run {
                    self.children = response.parent.children
                    self.isLoadingChildren = false
                    loadReports()
                }
            } catch {
                await MainActor.run {
                    self.isLoadingChildren = false
                    print("[ActivityReports] Error loading children: \(error)")
                    // Keep children from currentUser if API fails
                    if self.children.isEmpty, let currentUser = authManager.currentUser {
                        self.children = currentUser.children
                        loadReports()
                    }
                }
            }
        }
    }
    
    private func loadReports() {
        guard !children.isEmpty else { return }
        
        isLoading = true
        
        Task {
            guard let token = authManager.token else {
                await MainActor.run {
                    isLoading = false
                }
                return
            }
            
            let apiService = ApiService.shared
            var loadedReports: [ActivityReport] = []
            
            // Fetch activity data for each child
            for child in children {
                do {
                    struct ActivityResponse: Codable {
                        let childId: String
                        let postsCount: Int
                        let messagesCount: Int
                        let friendsCount: Int
                        let lastActivity: String?
                    }
                    
                    let response: ActivityResponse = try await apiService.makeRequest(
                        endpoint: "parents/children/\(child.id)/activity",
                        method: "GET",
                        token: token
                    )
                    
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    let lastActivityDate = response.lastActivity != nil
                        ? dateFormatter.date(from: response.lastActivity!)
                        : nil
                    
                    loadedReports.append(ActivityReport(
                        childId: response.childId,
                        period: selectedPeriod,
                        messagesCount: response.messagesCount,
                        postsCount: response.postsCount,
                        friendsCount: response.friendsCount,
                        lastActivity: lastActivityDate
                    ))
                } catch {
                    print("[ActivityReports] Error loading activity for child \(child.id): \(error)")
                    // Add empty report for this child if API fails
                    loadedReports.append(ActivityReport(
                        childId: child.id,
                        period: selectedPeriod,
                        messagesCount: 0,
                        postsCount: 0,
                        friendsCount: 0,
                        lastActivity: nil
                    ))
                }
            }
            
            await MainActor.run {
                reports = loadedReports
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
    let lastActivity: Date?
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
                    
                    if let lastActivity = report.lastActivity {
                        Text("Last active: \(lastActivity, style: .relative)")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.textMuted)
                    } else {
                        Text("No recent activity")
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.textMuted)
                    }
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

