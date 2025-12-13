//
//  MoreView.swift
//  FamilyNovaParent
//
//  Comprehensive More menu for parents with monitoring tools

import SwiftUI

struct MoreView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var children: [Child] = []
    @State private var selectedChild: Child? = nil
    @State private var showProfile = false
    @State private var showSettings = false
    @State private var showManageChildren = false
    @State private var showFriends = false
    @State private var showNotifications = false
    @State private var showMyPosts = false
    @State private var showSafetyDashboard = false
    @State private var showActivityReports = false
    @State private var isLoadingChildren = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                ScrollView {
                    VStack(spacing: CosmicSpacing.xl) {
                        // Profile Section (Personal)
                        VStack(spacing: CosmicSpacing.m) {
                            Group {
                                if let user = authManager.currentUser,
                                   let avatarUrl = user.profile.avatar,
                                   !avatarUrl.isEmpty {
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
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(CosmicColors.nebulaPurple.opacity(0.5), lineWidth: 3)
                            )
                            .shadow(color: CosmicColors.nebulaPurple.opacity(0.5), radius: 15)
                            
                            if let user = authManager.currentUser {
                                Text(user.profile.displayName)
                                    .font(CosmicFonts.headline)
                                    .foregroundColor(CosmicColors.textPrimary)
                            }
                            
                            HStack(spacing: CosmicSpacing.xl) {
                                VStack {
                                    Text("0")
                                        .font(CosmicFonts.headline)
                                        .foregroundColor(CosmicColors.nebulaPurple)
                                    Text("Friends")
                                        .font(CosmicFonts.caption)
                                        .foregroundColor(CosmicColors.textMuted)
                                }
                                
                                VStack {
                                    Text("0")
                                        .font(CosmicFonts.headline)
                                        .foregroundColor(CosmicColors.nebulaPurple)
                                    Text("Posts")
                                        .font(CosmicFonts.caption)
                                        .foregroundColor(CosmicColors.textMuted)
                                }
                            }
                        }
                        .padding(CosmicSpacing.l)
                        .cosmicCard()
                        .padding(.horizontal, CosmicSpacing.m)
                        .padding(.top, CosmicSpacing.m)
                        
                        // Personal Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("Personal")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            MenuRow(icon: "person.fill", title: "My Profile", action: { showProfile = true })
                            MenuRow(icon: "person.2.fill", title: "My Friends", action: { showFriends = true })
                            MenuRow(icon: "bell.fill", title: "My Notifications", action: { showNotifications = true })
                            MenuRow(icon: "square.and.pencil", title: "My Posts", action: { showMyPosts = true })
                        }
                        .padding(.top, CosmicSpacing.m)
                        
                        // Parent Tools Section
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            HStack {
                                Text("Parent Tools")
                                    .font(CosmicFonts.headline)
                                    .foregroundColor(CosmicColors.textPrimary)
                                
                                Spacer()
                                
                                // Badge indicating parent mode
                                Text("Nova+")
                                    .font(CosmicFonts.caption)
                                    .foregroundColor(CosmicColors.starGold)
                                    .padding(.horizontal, CosmicSpacing.s)
                                    .padding(.vertical, CosmicSpacing.xs)
                                    .background(
                                        Capsule()
                                            .fill(CosmicColors.starGold.opacity(0.2))
                                            .overlay(
                                                Capsule()
                                                    .stroke(CosmicColors.starGold.opacity(0.5), lineWidth: 1)
                                            )
                                    )
                            }
                            .padding(.horizontal, CosmicSpacing.m)
                            
                            // Manage Children
                            MenuRow(
                                icon: "person.2.fill",
                                title: "Manage Children",
                                subtitle: "\(children.count) child\(children.count == 1 ? "" : "ren")",
                                action: { showManageChildren = true }
                            )
                            
                            // Safety Dashboard
                            MenuRow(
                                icon: "shield.fill",
                                title: "Safety Dashboard",
                                subtitle: "Quick view of all children",
                                action: { showSafetyDashboard = true }
                            )
                            
                            // Activity Reports
                            MenuRow(
                                icon: "chart.bar.fill",
                                title: "Activity Reports",
                                subtitle: "Weekly & monthly summaries",
                                action: { showActivityReports = true }
                            )
                        }
                        .padding(.top, CosmicSpacing.l)
                        
                        // Settings
                        VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                            Text("Settings")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                                .padding(.horizontal, CosmicSpacing.m)
                            
                            MenuRow(icon: "gearshape.fill", title: "Account Settings", action: { showSettings = true })
                            MenuRow(icon: "bell.badge.fill", title: "Notification Preferences", action: {})
                            MenuRow(icon: "lock.fill", title: "Security", action: {})
                            MenuRow(icon: "book.fill", title: "Parenting Resources", action: {})
                            MenuRow(icon: "questionmark.circle.fill", title: "Help & Support", action: {})
                        }
                        .padding(.top, CosmicSpacing.m)
                        
                        // Log Out
                        Button(action: {
                            authManager.logout()
                        }) {
                            Text("Log Out")
                                .font(CosmicFonts.button)
                                .frame(maxWidth: .infinity)
                                .padding(CosmicSpacing.m)
                        }
                        .buttonStyle(CosmicButtonStyle(isPrimary: false))
                        .padding(.horizontal, CosmicSpacing.m)
                        .padding(.bottom, CosmicSpacing.xxl)
                    }
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showProfile) {
                ProfileView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showManageChildren) {
                ManageChildrenView(children: $children)
                    .environmentObject(authManager)
                    .onAppear {
                        // Reload children when modal appears
                        loadChildren()
                    }
            }
            .sheet(isPresented: $showFriends) {
                FriendsView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showMyPosts) {
                MyPostsView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showSafetyDashboard) {
                SafetyDashboardView(children: children)
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showActivityReports) {
                ActivityReportsView(children: children)
                    .environmentObject(authManager)
            }
            .onAppear {
                // Try to get children from currentUser first
                if let currentUser = authManager.currentUser, !currentUser.children.isEmpty {
                    self.children = currentUser.children
                }
                
                // Always try to reload to get latest data
                loadChildren()
            }
        }
    }
    
    private func loadChildren() {
        guard let token = authManager.token else {
            // Try to get from currentUser if no token
            if let currentUser = authManager.currentUser {
                self.children = currentUser.children
            }
            return
        }
        
        // Don't show loading if we already have children from currentUser
        if children.isEmpty {
            isLoadingChildren = true
        }
        
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
                    
                    // Also update authManager's currentUser with latest children
                    if var currentUser = authManager.currentUser {
                        // Note: ParentUser is a struct, so we'd need to create a new instance
                        // For now, just update the local state
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoadingChildren = false
                    print("Error loading children: \(error)")
                    // If API fails, try to use children from currentUser
                    if self.children.isEmpty, let currentUser = authManager.currentUser {
                        self.children = currentUser.children
                    }
                }
            }
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: CosmicSpacing.m) {
                Image(systemName: icon)
                    .cosmicIcon(size: 20, color: CosmicColors.nebulaPurple)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                    Text(title)
                        .font(CosmicFonts.body)
                        .foregroundColor(CosmicColors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.textMuted)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .cosmicIcon(size: 14, color: CosmicColors.textMuted)
            }
            .padding(CosmicSpacing.m)
            .cosmicCard()
            .padding(.horizontal, CosmicSpacing.m)
        }
    }
}

// Placeholder for Manage Children View
struct ManageChildrenView: View {
    @Binding var children: [Child]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var isLoading = false
    @State private var showLinkChild = false
    @State private var linkEmail = ""
    @State private var isLinking = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                if isLoading && children.isEmpty {
                    VStack(spacing: CosmicSpacing.l) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(CosmicColors.nebulaPurple)
                        Text("Loading children...")
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                    }
                } else if children.isEmpty {
                    VStack(spacing: CosmicSpacing.xl) {
                        Image(systemName: "person.2.fill")
                            .cosmicIcon(size: 60, color: CosmicColors.nebulaPurple)
                        Text("No Children Added")
                            .font(CosmicFonts.headline)
                            .foregroundColor(CosmicColors.textPrimary)
                        Text("Add children to manage them here")
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CosmicSpacing.xl)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: CosmicSpacing.l) {
                            // List of children
                            ForEach(children) { child in
                                MoreViewChildCard(child: child)
                                    .padding(.horizontal, CosmicSpacing.m)
                            }
                            
                            // Add Child Button
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .cosmicIcon(size: 24, color: CosmicColors.nebulaPurple)
                                    Text("Add Child")
                                        .font(CosmicFonts.button)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(CosmicSpacing.m)
                            }
                            .buttonStyle(CosmicButtonStyle(isPrimary: true))
                            .padding(.horizontal, CosmicSpacing.m)
                        }
                        .padding(.vertical, CosmicSpacing.m)
                    }
                }
            }
            .navigationTitle("Manage Children")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(CosmicColors.nebulaPurple)
                }
            }
            .onAppear {
                // Debug: Print current children count
                print("ManageChildrenView appeared with \(children.count) children")
                if let currentUser = authManager.currentUser {
                    print("CurrentUser has \(currentUser.children.count) children")
                }
            }
            .sheet(isPresented: $showLinkChild) {
                LinkChildByEmailView(
                    email: $linkEmail,
                    isLinking: $isLinking,
                    onLink: {
                        linkChildByEmail()
                    },
                    onDismiss: {
                        showLinkChild = false
                        linkEmail = ""
                    }
                )
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    // Reload children after successful link
                    if let parent = authManager.currentUser {
                        children = parent.children
                    }
                }
            } message: {
                Text("Child linked successfully!")
            }
        }
    }
    
    private func linkChildByEmail() {
        guard !linkEmail.isEmpty else { return }
        guard let token = authManager.token else {
            errorMessage = "Not authenticated"
            showError = true
            return
        }
        
        isLinking = true
        Task {
            do {
                let apiService = ApiService.shared
                
                struct LinkResponse: Codable {
                    let message: String
                    let child: ChildResponse
                }
                
                struct ChildResponse: Codable {
                    let id: String
                    let email: String
                    let profile: ProfileData
                    let verification: VerificationData
                }
                
                struct ProfileData: Codable {
                    let displayName: String?
                    let avatar: String?
                    let school: String?
                    let grade: String?
                }
                
                struct VerificationData: Codable {
                    let parentVerified: Bool?
                    let schoolVerified: Bool?
                }
                
                let response: LinkResponse = try await apiService.makeRequest(
                    endpoint: "parents/children/link-by-email",
                    method: "POST",
                    body: ["email": linkEmail],
                    token: token
                )
                
                await MainActor.run {
                    isLinking = false
                    linkEmail = ""
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLinking = false
                    errorMessage = "Failed to link child: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

struct LinkChildByEmailView: View {
    @Binding var email: String
    @Binding var isLinking: Bool
    let onLink: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                VStack(spacing: CosmicSpacing.xl) {
                    Image(systemName: "link.circle.fill")
                        .cosmicIcon(size: 60, color: CosmicColors.nebulaPurple)
                    
                    Text("Link Existing Child")
                        .font(CosmicFonts.headline)
                        .foregroundColor(CosmicColors.textPrimary)
                    
                    Text("Enter your child's email address to link their existing Nova account to your Nova+ account.")
                        .font(CosmicFonts.body)
                        .foregroundColor(CosmicColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CosmicSpacing.m)
                    
                    TextField("Child's Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .padding(CosmicSpacing.m)
                        .background(CosmicColors.glassBackground)
                        .cornerRadius(CosmicCornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                .stroke(CosmicColors.glassBorder, lineWidth: 1)
                        )
                        .padding(.horizontal, CosmicSpacing.m)
                    
                    Button(action: onLink) {
                        HStack {
                            if isLinking {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Link Child")
                                    .font(CosmicFonts.button)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(CosmicSpacing.m)
                    }
                    .buttonStyle(CosmicButtonStyle(isPrimary: true))
                    .disabled(email.isEmpty || isLinking)
                    .padding(.horizontal, CosmicSpacing.m)
                }
                .padding(CosmicSpacing.xl)
            }
            .navigationTitle("Link Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(CosmicColors.nebulaPurple)
                }
            }
        }
    }
}

struct MoreViewChildCard: View {
    let child: Child
    
    var body: some View {
        HStack(spacing: CosmicSpacing.m) {
            Circle()
                .fill(CosmicColors.primaryGradient)
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                Text(child.profile.displayName)
                    .font(CosmicFonts.headline)
                    .foregroundColor(CosmicColors.textPrimary)
                
                if let school = child.profile.school {
                    Text(school)
                        .font(CosmicFonts.caption)
                        .foregroundColor(CosmicColors.textMuted)
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

#Preview {
    MoreView()
        .environmentObject(AuthManager())
}
