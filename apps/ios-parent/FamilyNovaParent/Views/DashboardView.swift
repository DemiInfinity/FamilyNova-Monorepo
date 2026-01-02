//
//  DashboardView.swift
//  FamilyNovaParent
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var children: [Child] = []
    @State private var showCreateChild = false
    @State private var isLoading = false
    @State private var toast: ToastNotificationData? = nil
    
    private let cacheKey = "cached_children"
    
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
                        HStack {
                            Text("My Children")
                                .font(ParentAppFonts.headline)
                                .foregroundColor(ParentAppColors.black)
                            Spacer()
                            Button(action: { showCreateChild = true }) {
                                HStack(spacing: ParentAppSpacing.xs) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Child")
                                }
                                .font(ParentAppFonts.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, ParentAppSpacing.m)
                                .padding(.vertical, ParentAppSpacing.s)
                                .background(ParentAppColors.primaryTeal)
                                .cornerRadius(ParentAppCornerRadius.small)
                            }
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        if isLoading {
                            LoadingStateView(message: "Loading children...")
                                .padding()
                        } else if children.isEmpty {
                            EmptyChildrenCard(showCreateChild: $showCreateChild)
                                .padding(.horizontal, ParentAppSpacing.m)
                        } else {
                            ForEach(children) { child in
                                ChildCard(child: child)
                                    .environmentObject(authManager)
                                    .padding(.horizontal, ParentAppSpacing.m)
                            }
                        }
                    }
                    .padding(.top, ParentAppSpacing.m)
                    
                    // Pending Profile Changes
                    VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                        HStack {
                            Text("Profile Changes")
                                .font(ParentAppFonts.headline)
                                .foregroundColor(ParentAppColors.black)
                            Spacer()
                            NavigationLink(destination: ProfileChangeApprovalView()) {
                                Text("View All")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.primaryTeal)
                            }
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        ProfileChangesCard()
                            .padding(.horizontal, ParentAppSpacing.m)
                    }
                    .padding(.top, ParentAppSpacing.l)
                    
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
            .sheet(isPresented: $showCreateChild) {
                CreateChildAccountView()
                    .environmentObject(authManager)
                    .onDisappear {
                        // Clear cache and refresh children when the sheet is dismissed
                        clearCache()
                        Task {
                            await loadChildren()
                        }
                    }
            }
            .onAppear {
                Task {
                    await loadChildren()
                }
            }
            .refreshable {
                await loadChildren()
            }
            .toastNotification($toast)
        }
    }
    
    private func loadChildren() async {
        guard let token = authManager.token else {
            // Try to load from cache if no token
            loadFromCache()
            return
        }
        
        // First, try to load from cache for instant display
        loadFromCache()
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let apiService = ApiService.shared
            
            // Fetch dashboard data which includes children
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
                self.isLoading = false
                
                // Cache the children data
                self.saveToCache(children: response.parent.children)
            }
        } catch {
            // If API fails, keep cached data if available
            await MainActor.run {
                self.isLoading = false
                // If we don't have cached data and API failed, show empty
                if self.children.isEmpty {
                    loadFromCache()
                }
                ErrorHandler.shared.showError(error, toast: $toast)
            }
            print("Error loading children: \(error)")
        }
    }
    
    private func loadFromCache() {
        if let cachedData = UserDefaults.standard.data(forKey: cacheKey) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let decoded = try? decoder.decode([Child].self, from: cachedData) {
                DispatchQueue.main.async {
                    self.children = decoded
                }
            }
        }
    }
    
    private func saveToCache(children: [Child]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        if let encoded = try? encoder.encode(children) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
    
    private func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
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
    @EnvironmentObject var authManager: AuthManager
    
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
            
            NavigationLink(destination: ChildDetailsView(child: child)
                .environmentObject(authManager)) {
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
    @Binding var showCreateChild: Bool
    
    var body: some View {
        VStack(spacing: ParentAppSpacing.m) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(ParentAppColors.primaryTeal)
            Text("No children added yet")
                .font(ParentAppFonts.headline)
                .foregroundColor(ParentAppColors.black)
            Text("Create an account for your child to get started")
                .font(ParentAppFonts.body)
                .foregroundColor(ParentAppColors.darkGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ParentAppSpacing.m)
            
            Button(action: { showCreateChild = true }) {
                HStack(spacing: ParentAppSpacing.s) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Child Account")
                        .font(ParentAppFonts.button)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, ParentAppSpacing.l)
                .padding(.vertical, ParentAppSpacing.m)
                .background(ParentAppColors.primaryTeal)
                .cornerRadius(ParentAppCornerRadius.medium)
            }
            .padding(.top, ParentAppSpacing.s)
        }
        .frame(maxWidth: .infinity)
        .padding(ParentAppSpacing.l)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ProfileChangesCard: View {
    @State private var pendingCount = 0
    
    var body: some View {
        NavigationLink(destination: ProfileChangeApprovalView()) {
            HStack(spacing: ParentAppSpacing.m) {
                ZStack {
                    Circle()
                        .fill(ParentAppColors.warning.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 24))
                        .foregroundColor(ParentAppColors.warning)
                }
                
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text("\(pendingCount) profile changes pending")
                        .font(ParentAppFonts.headline)
                        .foregroundColor(ParentAppColors.black)
                    Text("Review profile change requests from your children")
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

