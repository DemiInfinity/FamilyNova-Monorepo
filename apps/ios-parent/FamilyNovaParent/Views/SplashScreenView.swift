//
//  SplashScreenView.swift
//  FamilyNovaParent
//
//  Splash screen with cosmic theme and data loading

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isLoadingComplete: Bool
    @State private var loadingProgress: Double = 0.0
    @State private var loadingMessage = "Initializing..."
    
    var body: some View {
        ZStack {
            // Cosmic background
            CosmicBackground()
            
            VStack(spacing: CosmicSpacing.xl) {
                // App Icon
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .cornerRadius(CosmicCornerRadius.large)
                    .shadow(color: CosmicColors.nebulaPurple.opacity(0.5), radius: 20)
                
                // App Name
                Text("Nova+")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(CosmicColors.textPrimary)
                    .padding(.top, CosmicSpacing.m)
                
                // Loading Indicator
                VStack(spacing: CosmicSpacing.m) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(CosmicColors.nebulaPurple)
                        .padding(.top, CosmicSpacing.xl)
                    
                    Text(loadingMessage)
                        .font(CosmicFonts.body)
                        .foregroundColor(CosmicColors.textSecondary)
                        .padding(.top, CosmicSpacing.s)
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(CosmicColors.glassBackground.opacity(0.3))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [CosmicColors.nebulaPurple, CosmicColors.nebulaBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * loadingProgress, height: 4)
                                .animation(.linear(duration: 0.3), value: loadingProgress)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, CosmicSpacing.xl)
                    .padding(.top, CosmicSpacing.m)
                }
            }
        }
        .onAppear {
            loadInitialData()
        }
    }
    
    private func loadInitialData() {
        Task {
            await loadDataWithProgress()
        }
    }
    
    private func loadDataWithProgress() async {
        // Step 1: Validate token and load user
        await updateProgress(0.2, message: "Authenticating...")
        
        guard let token = authManager.token else {
            await MainActor.run {
                isLoadingComplete = true
            }
            return
        }
        
        // Step 2: Load user profile
        await updateProgress(0.4, message: "Loading profile...")
        await loadUserProfile(token: token)
        
        // Step 3: Load friends
        await updateProgress(0.6, message: "Loading friends...")
        await loadFriends(token: token)
        
        // Step 4: Load posts
        await updateProgress(0.8, message: "Loading posts...")
        await loadPosts(token: token)
        
        // Step 5: Load messages
        await updateProgress(0.9, message: "Loading messages...")
        await loadMessages(token: token)
        
        // Complete
        await updateProgress(1.0, message: "Ready!")
        
        // Small delay to show completion
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            isLoadingComplete = true
        }
    }
    
    private func updateProgress(_ progress: Double, message: String) async {
        await MainActor.run {
            loadingProgress = progress
            loadingMessage = message
        }
    }
    
    private func loadUserProfile(token: String) async {
        do {
            let apiService = ApiService.shared
            
            struct ProfileResponse: Codable {
                let user: UserProfileData
            }
            
            struct UserProfileData: Codable {
                let id: String
                let email: String
                let profile: ProfileData
                let postsCount: Int?
                let friendsCount: Int?
            }
            
            struct ProfileData: Codable {
                let displayName: String?
                let avatar: String?
                let banner: String?
            }
            
            let response: ProfileResponse = try await apiService.makeRequest(
                endpoint: "parents/profile",
                method: "GET",
                token: token
            )
            
            // Cache profile data
            if let encoded = try? JSONEncoder().encode(response.user) {
                UserDefaults.standard.set(encoded, forKey: "cached_user_profile")
            }
        } catch {
            print("[SplashScreen] Error loading profile: \(error)")
        }
    }
    
    private func loadFriends(token: String) async {
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
            
            // Cache friends
            if let encoded = try? JSONEncoder().encode(response.friends) {
                UserDefaults.standard.set(encoded, forKey: "cached_friends")
            }
        } catch {
            print("[SplashScreen] Error loading friends: \(error)")
        }
    }
    
    private func loadPosts(token: String) async {
        do {
            let apiService = ApiService.shared
            
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
            
            let response: PostsResponse = try await apiService.makeRequest(
                endpoint: "posts",
                method: "GET",
                token: token
            )
            
            // Cache posts (limit to 50 most recent)
            let postsToCache = Array(response.posts.prefix(50))
            if let encoded = try? JSONEncoder().encode(postsToCache) {
                UserDefaults.standard.set(encoded, forKey: "cached_posts")
                UserDefaults.standard.set(Date(), forKey: "cached_posts_timestamp")
            }
        } catch {
            print("[SplashScreen] Error loading posts: \(error)")
        }
    }
    
    private func loadMessages(token: String) async {
        do {
            let apiService = ApiService.shared
            
            struct MessagesResponse: Codable {
                let messages: [MessageResponse]
            }
            
            struct MessageResponse: Codable {
                let id: String
                let sender: SenderResponse
                let receiver: ReceiverResponse
                let content: String
                let createdAt: String
                let status: String
            }
            
            struct SenderResponse: Codable {
                let id: String
            }
            
            struct ReceiverResponse: Codable {
                let id: String
            }
            
            let response: MessagesResponse = try await apiService.makeRequest(
                endpoint: "messages",
                method: "GET",
                token: token
            )
            
            // Cache messages
            if let encoded = try? JSONEncoder().encode(response.messages) {
                UserDefaults.standard.set(encoded, forKey: "cached_messages")
                UserDefaults.standard.set(Date(), forKey: "cached_messages_timestamp")
            }
        } catch {
            print("[SplashScreen] Error loading messages: \(error)")
        }
    }
}

#Preview {
    SplashScreenView(isLoadingComplete: .constant(false))
        .environmentObject(AuthManager())
}

