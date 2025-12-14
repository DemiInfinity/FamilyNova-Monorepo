//
//  FriendsView.swift
//  FamilyNovaParent
//

import SwiftUI

struct FriendsView: View {
    @State private var searchText = ""
    @State private var friends: [Friend] = []
    @State private var searchResults: [Friend] = []
    @State private var isSearching = false
    @State private var showAddFriend = false
    @State private var showScanQR = false
    @State private var showEnterCode = false
    @State private var showMyCode = false
    @State private var errorMessage = ""
    @State private var showError = false
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                VStack(spacing: 0) {
                    // Fun Search Bar
                    HStack(spacing: CosmicSpacing.m) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(CosmicColors.nebulaBlue)
                        
                        TextField("Search for friends...", text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundColor(CosmicColors.textPrimary)
                            .font(CosmicFonts.body)
                            .onChange(of: searchText) { newValue in
                                if !newValue.isEmpty {
                                    isSearching = true
                                    performSearch(query: newValue)
                                } else {
                                    isSearching = false
                                    searchResults = []
                                }
                            }
                    }
                    .padding(CosmicSpacing.l)
                    .background(
                        RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                            .fill(Color.white)
                            .shadow(color: CosmicColors.nebulaBlue.opacity(0.2), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal, CosmicSpacing.m)
                    .padding(.top, CosmicSpacing.m)
                    
                    // Add Friend Buttons
                    VStack(spacing: CosmicSpacing.m) {
                        // Main Add Friend Button
                        Button(action: {
                            showAddFriend = true
                        }) {
                            HStack(spacing: CosmicSpacing.s) {
                                Text("➕")
                                    .font(.system(size: 24))
                                Text("Add New Friend")
                                    .font(CosmicFonts.button)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [CosmicColors.planetTeal, CosmicColors.nebulaBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(CosmicCornerRadius.large)
                            .shadow(color: CosmicColors.planetTeal.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        // Quick Add Options
                        HStack(spacing: CosmicSpacing.m) {
                            Button(action: {
                                showScanQR = true
                            }) {
                                HStack(spacing: CosmicSpacing.xs) {
                                    Image(systemName: "qrcode.viewfinder")
                                        .font(.system(size: 18))
                                    Text("Scan QR")
                                        .font(CosmicFonts.caption)
                                        .foregroundColor(CosmicColors.nebulaBlue)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, CosmicSpacing.s)
                                .background(Color.white)
                                .cornerRadius(CosmicCornerRadius.medium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                        .stroke(CosmicColors.nebulaBlue, lineWidth: 2)
                                )
                            }
                            
                            Button(action: {
                                showEnterCode = true
                            }) {
                                HStack(spacing: CosmicSpacing.xs) {
                                    Image(systemName: "keyboard")
                                        .font(.system(size: 18))
                                    Text("Enter Code")
                                        .font(CosmicFonts.caption)
                                        .foregroundColor(CosmicColors.nebulaPurple)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, CosmicSpacing.s)
                                .background(Color.white)
                                .cornerRadius(CosmicCornerRadius.medium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                        .stroke(CosmicColors.nebulaPurple, lineWidth: 2)
                                )
                            }
                        }
                        
                        // Show My Code Button
                        Button(action: {
                            showMyCode = true
                        }) {
                            HStack(spacing: CosmicSpacing.xs) {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 18))
                                Text("Show My Code")
                                    .font(CosmicFonts.caption)
                                    .foregroundColor(CosmicColors.planetTeal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, CosmicSpacing.s)
                            .background(Color.white)
                            .cornerRadius(CosmicCornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                    .stroke(CosmicColors.planetTeal, lineWidth: 2)
                            )
                        }
                        .padding(.top, CosmicSpacing.xs)
                    }
                    .padding(.horizontal, CosmicSpacing.m)
                    .padding(.top, CosmicSpacing.m)
                    
                    // Friends List or Search Results
                    VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                        if isSearching {
                            Text("🔍 Search Results")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.nebulaPurple)
                                .padding(.horizontal, CosmicSpacing.m)
                                .padding(.top, CosmicSpacing.l)
                            
                            if searchResults.isEmpty && !searchText.isEmpty {
                                VStack(spacing: CosmicSpacing.m) {
                                    Text("😕")
                                        .font(.system(size: 60))
                                    Text("No friends found")
                                        .font(CosmicFonts.body)
                                        .foregroundColor(CosmicColors.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(CosmicSpacing.xxl)
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: CosmicSpacing.m) {
                                        ForEach(searchResults) { friend in
                                            FriendRow(friend: friend, showAddButton: true, onAdd: {
                                                addFriend(friendId: friend.id.uuidString)
                                            })
                                        }
                                    }
                                    .padding(.horizontal, CosmicSpacing.m)
                                }
                            }
                        } else {
                            Text("👥 My Friends")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.nebulaPurple)
                                .padding(.horizontal, CosmicSpacing.m)
                                .padding(.top, CosmicSpacing.l)
                            
                            if friends.isEmpty {
                                Spacer()
                                VStack(spacing: CosmicSpacing.l) {
                                    Text("👋")
                                        .font(.system(size: 80))
                                    Text("No friends yet!")
                                        .font(CosmicFonts.headline)
                                        .foregroundColor(CosmicColors.nebulaBlue)
                                    Text("Start adding friends to connect and have fun together!")
                                        .font(CosmicFonts.body)
                                        .foregroundColor(CosmicColors.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, CosmicSpacing.xl)
                                }
                                .padding(CosmicSpacing.xxl)
                                Spacer()
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: CosmicSpacing.m) {
                                        ForEach(friends) { friend in
                                            NavigationLink(destination: FriendProfileView(friend: friend)) {
                                                FriendRow(friend: friend, showAddButton: false)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal, CosmicSpacing.m)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddFriend) {
                AddFriendView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showScanQR) {
                ScanFriendQRView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showEnterCode) {
                EnterFriendCodeView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showMyCode) {
                ShowMyFriendCodeView()
                    .environmentObject(authManager)
            }
            .onAppear {
                Task {
                    await loadFriends()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func performSearch(query: String) {
        guard let token = authManager.getValidatedToken() else { return }
        
        Task {
            do {
                let apiService = ApiService.shared
                
                struct SearchResponse: Codable {
                    let results: [FriendSearchResult]
                }
                
                struct FriendSearchResult: Codable {
                    let id: String
                    let profile: ProfileResult
                    let isVerified: Bool
                    let isFriend: Bool
                }
                
                struct ProfileResult: Codable {
                    let displayName: String?
                    let avatar: String?
                }
                
                let response: SearchResponse = try await apiService.makeRequest(
                    endpoint: "friends/search?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)",
                    method: "GET",
                    token: token
                )
                
                await MainActor.run {
                    self.searchResults = response.results.map { result in
                        Friend(
                            id: UUID(uuidString: result.id) ?? UUID(),
                            displayName: result.profile.displayName ?? "Unknown",
                            avatar: result.profile.avatar,
                            isVerified: result.isVerified
                        )
                    }
                }
            } catch {
                print("Error searching friends: \(error)")
            }
        }
    }
    
    private func addFriend(friendId: String) {
        guard let token = authManager.getValidatedToken() else { return }
        
        Task {
            do {
                let apiService = ApiService.shared
                
                struct AddFriendResponse: Codable {
                    let message: String
                    let friend: FriendResponse
                }
                
                struct FriendResponse: Codable {
                    let id: String
                    let profile: ProfileResponse
                    let isVerified: Bool
                }
                
                struct ProfileResponse: Codable {
                    let displayName: String?
                    let avatar: String?
                }
                
                let body: [String: Any] = ["friendId": friendId]
                
                let _: AddFriendResponse = try await apiService.makeRequest(
                    endpoint: "friends/request",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                // Show success notification
                await MainActor.run {
                    // Use haptic feedback for notification
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
                
                // Refresh friends list
                await loadFriends()
            } catch {
                print("Error adding friend: \(error)")
            }
        }
    }
    
    private func loadFriends() async {
        guard let token = authManager.getValidatedToken() else { return }
        
        do {
            let apiService = ApiService.shared
            
            struct FriendsResponse: Codable {
                let friends: [FriendResult]
            }
            
            struct FriendResult: Codable {
                let id: String
                let profile: ProfileResult
                let isVerified: Bool
            }
            
            struct ProfileResult: Codable {
                let displayName: String?
                let avatar: String?
            }
            
            let response: FriendsResponse = try await apiService.makeRequest(
                endpoint: "friends",
                method: "GET",
                token: token
            )
            
            await MainActor.run {
                self.friends = response.friends.map { friend in
                    Friend(
                        id: UUID(uuidString: friend.id) ?? UUID(),
                        displayName: friend.profile.displayName ?? "Unknown",
                        avatar: friend.profile.avatar,
                        isVerified: friend.isVerified
                    )
                }
            }
        } catch {
            print("Error loading friends: \(error)")
        }
    }
}

struct Friend: Identifiable {
    let id: UUID
    let displayName: String
    let avatar: String?
    let isVerified: Bool
    
    init(id: UUID = UUID(), displayName: String, avatar: String?, isVerified: Bool) {
        self.id = id
        self.displayName = displayName
        self.avatar = avatar
        self.isVerified = isVerified
    }
}

struct FriendRow: View {
    let friend: Friend
    let showAddButton: Bool
    var onAdd: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: CosmicSpacing.m) {
            // Avatar with fun gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [CosmicColors.nebulaBlue, CosmicColors.nebulaPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Text("👤")
                    .font(.system(size: 36))
            }
            
            // Friend Info
            VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                Text(friend.displayName)
                    .font(CosmicFonts.headline)
                    .foregroundColor(CosmicColors.textPrimary)
                
                if friend.isVerified {
                    HStack(spacing: CosmicSpacing.xs) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(CosmicColors.success)
                            .font(.system(size: 16))
                        Text("Verified Friend")
                            .font(CosmicFonts.small)
                            .foregroundColor(CosmicColors.success)
                    }
                }
            }
            
            Spacer()
            
            if showAddButton {
                Button(action: {
                    onAdd?()
                }) {
                    Text("➕ Add")
                        .font(CosmicFonts.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, CosmicSpacing.m)
                        .padding(.vertical, CosmicSpacing.s)
                        .background(
                            LinearGradient(
                                colors: [CosmicColors.planetTeal, CosmicColors.nebulaBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(CosmicCornerRadius.medium)
                }
            }
        }
        .padding(CosmicSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// Friend Profile View
struct FriendProfileView: View {
    let friend: Friend
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var friendProfile: FriendProfileData?
    @State private var isLoading = false
    @State private var posts: [Post] = []
    @State private var selectedTab = 0
    @State private var showMessage = false
    
    var body: some View {
        ZStack {
            CosmicBackground()
            
            if isLoading {
                VStack(spacing: CosmicSpacing.l) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(CosmicColors.nebulaPurple)
                    Text("Loading profile...")
                        .font(CosmicFonts.body)
                        .foregroundColor(CosmicColors.textSecondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Cover Banner
                        ZStack(alignment: .bottomLeading) {
                            CosmicColors.spaceGradient
                                .frame(height: 200)
                                .clipped()
                            
                            // Profile Picture overlaying the cover
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 120, height: 120)
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                
                                Group {
                                    if let avatarUrl = friend.avatar, !avatarUrl.isEmpty {
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
                                            .overlay(
                                                Text(friend.displayName.prefix(1).uppercased())
                                                    .font(.system(size: 48, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                            }
                            .offset(x: CosmicSpacing.m, y: 60)
                        }
                        
                        // Profile Info
                        VStack(alignment: .leading, spacing: CosmicSpacing.m) {
                            HStack {
                                VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                                    Text(friend.displayName)
                                        .font(CosmicFonts.title)
                                        .foregroundColor(CosmicColors.textPrimary)
                                    
                                    if friend.isVerified {
                                        HStack(spacing: CosmicSpacing.xs) {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(CosmicColors.planetTeal)
                                            Text("Verified")
                                                .font(CosmicFonts.caption)
                                                .foregroundColor(CosmicColors.planetTeal)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                // Message Button
                                Button(action: {
                                    showMessage = true
                                }) {
                                    HStack(spacing: CosmicSpacing.xs) {
                                        Image(systemName: "message.fill")
                                        Text("Message")
                                            .font(CosmicFonts.button)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, CosmicSpacing.l)
                                    .padding(.vertical, CosmicSpacing.s)
                                    .background(CosmicColors.nebulaPurple)
                                    .cornerRadius(CosmicCornerRadius.medium)
                                }
                            }
                            .padding(.horizontal, CosmicSpacing.m)
                            .padding(.top, 80)
                            
                            // Stats (if available)
                            if let profile = friendProfile {
                                HStack(spacing: CosmicSpacing.l) {
                                    VStack {
                                        Text("\(profile.postsCount)")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                        Text("Posts")
                                            .font(CosmicFonts.caption)
                                            .foregroundColor(CosmicColors.textMuted)
                                    }
                                    
                                    VStack {
                                        Text("\(profile.friendsCount)")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                        Text("Friends")
                                            .font(CosmicFonts.caption)
                                            .foregroundColor(CosmicColors.textMuted)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, CosmicSpacing.m)
                            }
                            
                            // Tabs
                            HStack(spacing: 0) {
                                FriendProfileTabButton(title: "Posts", isSelected: selectedTab == 0) {
                                    selectedTab = 0
                                }
                                
                                FriendProfileTabButton(title: "Photos", isSelected: selectedTab == 1) {
                                    selectedTab = 1
                                }
                            }
                            .padding(.horizontal, CosmicSpacing.m)
                            .padding(.top, CosmicSpacing.l)
                            
                            // Posts/Photos Content
                            if selectedTab == 0 {
                                if posts.isEmpty {
                                    VStack(spacing: CosmicSpacing.m) {
                                        Text("📝")
                                            .font(.system(size: 60))
                                        Text("No posts yet")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(CosmicSpacing.xxl)
                                } else {
                                    LazyVStack(spacing: CosmicSpacing.m) {
                                        ForEach(posts) { post in
                                            CosmicPostCard(post: post)
                                                .environmentObject(authManager)
                                        }
                                    }
                                    .padding(.horizontal, CosmicSpacing.m)
                                    .padding(.top, CosmicSpacing.m)
                                }
                            } else {
                                let photos = posts.filter { $0.imageUrl != nil && !$0.imageUrl!.isEmpty }
                                if photos.isEmpty {
                                    VStack(spacing: CosmicSpacing.m) {
                                        Text("📷")
                                            .font(.system(size: 60))
                                        Text("No photos yet")
                                            .font(CosmicFonts.headline)
                                            .foregroundColor(CosmicColors.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(CosmicSpacing.xxl)
                                } else {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: CosmicSpacing.s) {
                                        ForEach(photos) { post in
                                            if let imageUrl = post.imageUrl {
                                                AsyncImage(url: URL(string: imageUrl)) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                } placeholder: {
                                                    Rectangle()
                                                        .fill(CosmicColors.glassBackground)
                                                }
                                                .frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: CosmicCornerRadius.small))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, CosmicSpacing.m)
                                    .padding(.top, CosmicSpacing.m)
                                }
                            }
                        }
                        .padding(.bottom, CosmicSpacing.xl)
                    }
                }
            }
        }
        .navigationTitle(friend.displayName)
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
            loadFriendProfile()
        }
        .sheet(isPresented: $showMessage) {
            // Navigate to chat with this friend
            NavigationView {
                MessagesView(initialFriend: friend)
                    .environmentObject(authManager)
            }
        }
    }
    
    private func loadFriendProfile() {
        isLoading = true
        Task {
            guard let token = authManager.getValidatedToken() else {
                await MainActor.run {
                    isLoading = false
                }
                return
            }
            
            do {
                let apiService = ApiService.shared
                
                // Load posts and filter by friend
                struct PostsResponse: Codable {
                    let posts: [PostResponse]
                }
                
                struct PostResponse: Codable {
                    let id: String
                    let content: String
                    let imageUrl: String?
                    let author: AuthorResponse
                    let likes: [String]?
                    let comments: [CommentResponse]?
                    let createdAt: String
                    let status: String
                }
                
                struct AuthorResponse: Codable {
                    let id: String
                    let profile: AuthorProfileResponse
                }
                
                struct AuthorProfileResponse: Codable {
                    let displayName: String?
                    let avatar: String?
                }
                
                struct CommentResponse: Codable {
                    let id: String
                    let content: String
                    let author: AuthorResponse
                    let createdAt: String
                }
                
                // Get all posts by this friend using userId query parameter
                let postsResponse: PostsResponse = try await apiService.makeRequest(
                    endpoint: "posts?userId=\(friend.id.uuidString)",
                    method: "GET",
                    token: token
                )
                
                await MainActor.run {
                    // All posts returned are already filtered by userId, just ensure they're approved
                    let friendPosts = postsResponse.posts.filter { postResponse in
                        postResponse.status == "approved"
                    }
                    
                    print("[FriendProfileView] Total posts from API: \(postsResponse.posts.count)")
                    print("[FriendProfileView] Filtered friend posts: \(friendPosts.count)")
                    print("[FriendProfileView] Friend ID: \(friend.id.uuidString)")
                    
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    self.posts = friendPosts.compactMap { postResponse in
                        guard let createdAt = dateFormatter.date(from: postResponse.createdAt) else { return nil }
                        
                        let currentUserId = authManager.currentUser?.id ?? ""
                        let isLiked = postResponse.likes?.contains(currentUserId.lowercased()) ?? false
                        
                        return Post(
                            id: UUID(uuidString: postResponse.id) ?? UUID(),
                            authorId: postResponse.author.id,
                            author: postResponse.author.profile.displayName ?? "Unknown",
                            authorAvatar: postResponse.author.profile.avatar,
                            content: postResponse.content,
                            imageUrl: postResponse.imageUrl,
                            likes: postResponse.likes?.count ?? 0,
                            comments: postResponse.comments?.count ?? 0,
                            createdAt: createdAt,
                            isLiked: isLiked
                        )
                    }
                    
                    // Get friend count from friends list
                    struct FriendsResponse: Codable {
                        let friends: [FriendResult]
                    }
                    
                    struct FriendResult: Codable {
                        let id: String
                    }
                    
                    Task {
                        do {
                            let friendsResponse: FriendsResponse = try await apiService.makeRequest(
                                endpoint: "friends",
                                method: "GET",
                                token: token
                            )
                            
                            await MainActor.run {
                                self.friendProfile = FriendProfileData(
                                    postsCount: friendPosts.count,
                                    friendsCount: friendsResponse.friends.count
                                )
                                self.isLoading = false
                            }
                        } catch {
                            await MainActor.run {
                                self.friendProfile = FriendProfileData(
                                    postsCount: friendPosts.count,
                                    friendsCount: 0
                                )
                                self.isLoading = false
                            }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("[FriendProfileView] Error loading profile: \(error)")
                }
            }
        }
    }
}

struct FriendProfileData {
    let postsCount: Int
    let friendsCount: Int
}

struct FriendProfileTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: CosmicSpacing.xs) {
                Text(title)
                    .font(CosmicFonts.headline)
                    .foregroundColor(isSelected ? CosmicColors.nebulaPurple : CosmicColors.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CosmicSpacing.s)
                
                Rectangle()
                    .fill(isSelected ? CosmicColors.nebulaPurple : Color.clear)
                    .frame(height: 2)
            }
        }
    }
}

#Preview {
    FriendsView()
}
