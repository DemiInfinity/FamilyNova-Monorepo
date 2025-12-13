//
//  CreatePostView.swift
//  FamilyNovaParent
//
//  Full-page create post view with tabs for text, photo, and video

import SwiftUI
import UIKit

struct CreatePostView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0 // 0 = Text, 1 = Photo, 2 = Video
    @State private var postCreated = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CosmicBackground()
                
                VStack(spacing: 0) {
                    // Tab Selector
                    HStack(spacing: 0) {
                        TabSelectorButton(
                            title: "Text",
                            icon: "text.alignleft",
                            isSelected: selectedTab == 0,
                            action: { selectedTab = 0 }
                        )
                        
                        TabSelectorButton(
                            title: "Photo",
                            icon: "photo",
                            isSelected: selectedTab == 1,
                            action: { selectedTab = 1 }
                        )
                        
                        TabSelectorButton(
                            title: "Video",
                            icon: "video",
                            isSelected: selectedTab == 2,
                            action: { selectedTab = 2 }
                        )
                    }
                    .padding(.horizontal, CosmicSpacing.m)
                    .padding(.top, CosmicSpacing.m)
                    
                    // Content based on selected tab
                    TabView(selection: $selectedTab) {
                        // Text Post
                        TextPostView(onPostCreated: {
                            postCreated = true
                        })
                        .environmentObject(authManager)
                        .tag(0)
                        
                        // Photo Post
                        CreatePhotoPostView(onPostCreated: {
                            postCreated = true
                        })
                        .environmentObject(authManager)
                        .tag(1)
                        
                        // Video Post (placeholder for now)
                        VideoPostView(onPostCreated: {
                            postCreated = true
                        })
                        .environmentObject(authManager)
                        .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct TabSelectorButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: CosmicSpacing.xs) {
                Image(systemName: icon)
                    .cosmicIcon(size: 20, color: isSelected ? CosmicColors.nebulaPurple : CosmicColors.textMuted)
                
                Text(title)
                    .font(CosmicFonts.caption)
                    .foregroundColor(isSelected ? CosmicColors.textPrimary : CosmicColors.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, CosmicSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                    .fill(isSelected ? CosmicColors.glassBackground : Color.clear)
            )
        }
    }
}

// Text Post View
struct TextPostView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var postContent = ""
    @State private var isPosting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var visibleToChildren = true // Default: children can see parent posts
    
    let onPostCreated: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: CosmicSpacing.xl) {
                // Header
                VStack(spacing: CosmicSpacing.m) {
                    Text("✨")
                        .font(.system(size: 60))
                    Text("Share Your Thoughts")
                        .font(CosmicFonts.title)
                        .foregroundColor(CosmicColors.textPrimary)
                    Text("Share what's on your mind with other parents and your children!")
                        .font(CosmicFonts.body)
                        .foregroundColor(CosmicColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CosmicSpacing.xl)
                }
                .padding(.top, CosmicSpacing.xxl)
                
                // Text Content
                VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                    Text("What's on your mind?")
                        .font(CosmicFonts.caption)
                        .foregroundColor(CosmicColors.textMuted)
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                            .fill(CosmicColors.glassBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                                    .stroke(CosmicColors.glassBorder, lineWidth: 1)
                            )
                        
                        if postContent.isEmpty {
                            Text("Share what you're up to...")
                                .font(CosmicFonts.body)
                                .foregroundColor(CosmicColors.textMuted)
                                .padding(.horizontal, CosmicSpacing.m + 4)
                                .padding(.vertical, CosmicSpacing.m + 8)
                                .allowsHitTesting(false)
                        }
                        
                        TextEditor(text: $postContent)
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textPrimary)
                            .frame(minHeight: 200)
                            .padding(CosmicSpacing.m)
                            .background(Color.clear)
                            .tint(CosmicColors.nebulaPurple)
                    }
                    .frame(minHeight: 200)
                    .onAppear {
                        UITextView.appearance().backgroundColor = .clear
                        UITextView.appearance().textColor = UIColor(CosmicColors.textPrimary)
                    }
                }
                .padding(.horizontal, CosmicSpacing.m)
                
                // Visibility Toggle (for parents)
                VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                    HStack {
                        VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                            Text("Visibility")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                            Text("Allow children to see this post")
                                .font(CosmicFonts.caption)
                                .foregroundColor(CosmicColors.textMuted)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $visibleToChildren)
                            .labelsHidden()
                    }
                    .padding(CosmicSpacing.m)
                    .background(CosmicColors.glassBackground)
                    .cornerRadius(CosmicCornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                            .stroke(CosmicColors.glassBorder, lineWidth: 1)
                    )
                }
                .padding(.horizontal, CosmicSpacing.m)
                
                // Post Button
                Button(action: createPost) {
                    HStack(spacing: CosmicSpacing.s) {
                        if isPosting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Post")
                                .font(CosmicFonts.button)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: [CosmicColors.nebulaPurple, CosmicColors.nebulaBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(CosmicCornerRadius.large)
                    .shadow(color: CosmicColors.nebulaPurple.opacity(0.4), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal, CosmicSpacing.m)
                .disabled(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
                .opacity(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                
                Spacer()
            }
            .padding(.bottom, CosmicSpacing.xxl)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func createPost() {
        guard !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        guard let token = authManager.getValidatedToken() else {
            errorMessage = "Invalid authentication token. Please log out and log in again."
            showError = true
            return
        }
        
        isPosting = true
        Task {
            do {
                let apiService = ApiService.shared
                
                struct CreatePostResponse: Codable {
                    let post: PostResponse
                    let message: String
                }
                
                struct PostResponse: Codable {
                    let id: String
                    let content: String
                    let imageUrl: String?
                    let status: String
                }
                
                let body: [String: Any] = [
                    "content": postContent.trimmingCharacters(in: .whitespacesAndNewlines),
                    "visibleToChildren": visibleToChildren
                ]
                
                let _: CreatePostResponse = try await apiService.makeRequest(
                    endpoint: "posts",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                await MainActor.run {
                    isPosting = false
                    postContent = ""
                    onPostCreated()
                }
            } catch {
                await MainActor.run {
                    isPosting = false
                    
                    if let apiError = error as? ApiError {
                        switch apiError {
                        case .invalidResponse:
                            errorMessage = "Invalid authentication token. Please log out and log in again."
                            authManager.logout()
                        case .httpError(let statusCode):
                            if statusCode == 401 {
                                errorMessage = "Session expired. Please log in again."
                                authManager.logout()
                            } else {
                                errorMessage = "Failed to create post (Error \(statusCode))"
                            }
                        default:
                            errorMessage = "Failed to create post: \(error.localizedDescription)"
                        }
                    } else {
                        errorMessage = "Failed to create post: \(error.localizedDescription)"
                    }
                    
                    showError = true
                }
            }
        }
    }
}

// Photo Post View
struct CreatePhotoPostView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var postContent = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var isUploadingImage = false
    @State private var isPosting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var uploadedImageUrl: String? = nil
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showImageSourceActionSheet = false
    @State private var visibleToChildren = true // Default: children can see parent posts
    
    let onPostCreated: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: CosmicSpacing.xl) {
                // Header
                VStack(spacing: CosmicSpacing.m) {
                    Text("📷")
                        .font(.system(size: 60))
                    Text("Share a Photo")
                        .font(CosmicFonts.title)
                        .foregroundColor(CosmicColors.textPrimary)
                    Text("Take or choose a photo to share")
                        .font(CosmicFonts.body)
                        .foregroundColor(CosmicColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CosmicSpacing.xl)
                }
                .padding(.top, CosmicSpacing.xxl)
                
                // Photo Section
                VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                    Text("Photo")
                        .font(CosmicFonts.caption)
                        .foregroundColor(CosmicColors.textMuted)
                    
                    Button(action: {
                        showImageSourceActionSheet = true
                    }) {
                        ZStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                    .fill(CosmicColors.glassBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                            .stroke(CosmicColors.glassBorder, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    )
                                
                                HStack(spacing: CosmicSpacing.s) {
                                    Image(systemName: "photo.on.rectangle")
                                        .cosmicIcon(size: 24, color: CosmicColors.nebulaPurple)
                                    Text("Add Photo")
                                        .font(CosmicFonts.body)
                                        .foregroundColor(CosmicColors.nebulaPurple)
                                }
                            }
                            
                            if isUploadingImage {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(CosmicCornerRadius.medium)
                            }
                        }
                        .frame(height: selectedImage != nil ? 300 : 100)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(CosmicCornerRadius.medium)
                    }
                    .disabled(isUploadingImage)
                    
                    if selectedImage != nil {
                        Button(action: {
                            selectedImage = nil
                            uploadedImageUrl = nil
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .cosmicIcon(size: 18, color: CosmicColors.error)
                                Text("Remove Photo")
                                    .font(CosmicFonts.caption)
                                    .foregroundColor(CosmicColors.error)
                            }
                        }
                        .padding(.top, CosmicSpacing.s)
                    }
                }
                .padding(.horizontal, CosmicSpacing.m)
                
                // Caption
                VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                    Text("Caption (optional)")
                        .font(CosmicFonts.caption)
                        .foregroundColor(CosmicColors.textMuted)
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                            .fill(CosmicColors.glassBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: CosmicCornerRadius.large)
                                    .stroke(CosmicColors.glassBorder, lineWidth: 1)
                            )
                        
                        if postContent.isEmpty {
                            Text("Add a caption...")
                                .font(CosmicFonts.body)
                                .foregroundColor(CosmicColors.textMuted)
                                .padding(.horizontal, CosmicSpacing.m + 4)
                                .padding(.vertical, CosmicSpacing.m + 8)
                                .allowsHitTesting(false)
                        }
                        
                        TextEditor(text: $postContent)
                            .font(CosmicFonts.body)
                            .foregroundColor(CosmicColors.textPrimary)
                            .frame(minHeight: 100)
                            .padding(CosmicSpacing.m)
                            .background(Color.clear)
                            .tint(CosmicColors.nebulaPurple)
                    }
                    .frame(minHeight: 100)
                    .onAppear {
                        UITextView.appearance().backgroundColor = .clear
                        UITextView.appearance().textColor = UIColor(CosmicColors.textPrimary)
                    }
                }
                .padding(.horizontal, CosmicSpacing.m)
                
                // Visibility Toggle (for parents)
                VStack(alignment: .leading, spacing: CosmicSpacing.s) {
                    HStack {
                        VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                            Text("Visibility")
                                .font(CosmicFonts.headline)
                                .foregroundColor(CosmicColors.textPrimary)
                            Text("Allow children to see this post")
                                .font(CosmicFonts.caption)
                                .foregroundColor(CosmicColors.textMuted)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $visibleToChildren)
                            .labelsHidden()
                    }
                    .padding(CosmicSpacing.m)
                    .background(CosmicColors.glassBackground)
                    .cornerRadius(CosmicCornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                            .stroke(CosmicColors.glassBorder, lineWidth: 1)
                    )
                }
                .padding(.horizontal, CosmicSpacing.m)
                
                // Post Button
                Button(action: createPost) {
                    HStack(spacing: CosmicSpacing.s) {
                        if isPosting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Post")
                                .font(CosmicFonts.button)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: [CosmicColors.nebulaPurple, CosmicColors.nebulaBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(CosmicCornerRadius.large)
                    .shadow(color: CosmicColors.nebulaPurple.opacity(0.4), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal, CosmicSpacing.m)
                .disabled((postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil) || isPosting || isUploadingImage)
                .opacity((postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil) ? 0.5 : 1.0)
                
                Spacer()
            }
            .padding(.bottom, CosmicSpacing.xxl)
        }
        .confirmationDialog("Add Photo", isPresented: $showImageSourceActionSheet, titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo") {
                    imagePickerSourceType = .camera
                    showImagePicker = true
                }
            }
            Button("Choose from Library") {
                imagePickerSourceType = .photoLibrary
                showImagePicker = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Select a photo to add to your post")
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                sourceType: imagePickerSourceType,
                selectedImage: $selectedImage,
                onImageSelected: { image in
                    uploadImage(image: image)
                }
            )
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func uploadImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process image"
            showError = true
            return
        }
        
        isUploadingImage = true
        Task {
            do {
                guard let token = authManager.getValidatedToken() else {
                    throw NSError(domain: "Not authenticated", code: 401)
                }
                
                let boundary = UUID().uuidString
                var request = URLRequest(url: URL(string: "https://family-nova-monorepo.vercel.app/api/upload/post-image")!)
                request.httpMethod = "POST"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                var body = Data()
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"image\"; filename=\"post.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                
                request.httpBody = body
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "Invalid response", code: 0)
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    struct UploadResponse: Codable {
                        let message: String?
                        let imageUrl: String
                    }
                    let uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
                    
                    await MainActor.run {
                        uploadedImageUrl = uploadResponse.imageUrl
                        isUploadingImage = false
                    }
                } else {
                    let errorData = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw NSError(domain: "Upload failed: \(errorData)", code: httpResponse.statusCode)
                }
            } catch {
                await MainActor.run {
                    isUploadingImage = false
                    errorMessage = "Failed to upload image: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func createPost() {
        guard !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil else {
            return
        }
        
        if selectedImage != nil && uploadedImageUrl == nil {
            errorMessage = "Please wait for image to upload"
            showError = true
            return
        }
        
        guard let token = authManager.getValidatedToken() else {
            errorMessage = "Invalid authentication token. Please log out and log in again."
            showError = true
            return
        }
        
        isPosting = true
        Task {
            do {
                let apiService = ApiService.shared
                
                struct CreatePostResponse: Codable {
                    let post: PostResponse
                    let message: String
                }
                
                struct PostResponse: Codable {
                    let id: String
                    let content: String
                    let imageUrl: String?
                    let status: String
                }
                
                let content = postContent.trimmingCharacters(in: .whitespacesAndNewlines)
                let finalContent = content.isEmpty ? (selectedImage != nil ? "📷" : "") : content
                
                let body: [String: Any] = [
                    "content": finalContent,
                    "imageUrl": uploadedImageUrl ?? NSNull(),
                    "visibleToChildren": visibleToChildren
                ]
                
                let _: CreatePostResponse = try await apiService.makeRequest(
                    endpoint: "posts",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                await MainActor.run {
                    isPosting = false
                    postContent = ""
                    selectedImage = nil
                    uploadedImageUrl = nil
                    onPostCreated()
                }
            } catch {
                await MainActor.run {
                    isPosting = false
                    
                    if let apiError = error as? ApiError {
                        switch apiError {
                        case .invalidResponse:
                            errorMessage = "Invalid authentication token. Please log out and log in again."
                            authManager.logout()
                        case .httpError(let statusCode):
                            if statusCode == 401 {
                                errorMessage = "Session expired. Please log in again."
                                authManager.logout()
                            } else {
                                errorMessage = "Failed to create post (Error \(statusCode))"
                            }
                        default:
                            errorMessage = "Failed to create post: \(error.localizedDescription)"
                        }
                    } else {
                        errorMessage = "Failed to create post: \(error.localizedDescription)"
                    }
                    
                    showError = true
                }
            }
        }
    }
}

// Video Post View (placeholder for future)
struct VideoPostView: View {
    @EnvironmentObject var authManager: AuthManager
    let onPostCreated: () -> Void
    
    var body: some View {
        VStack(spacing: CosmicSpacing.xl) {
            Image(systemName: "video.fill")
                .cosmicIcon(size: 80, color: CosmicColors.nebulaPurple)
            
            Text("Video Posts")
                .font(CosmicFonts.title)
                .foregroundColor(CosmicColors.textPrimary)
            
            Text("Video posting coming soon!")
                .font(CosmicFonts.body)
                .foregroundColor(CosmicColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CosmicSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(CosmicSpacing.xxl)
    }
}

#Preview {
    CreatePostView()
        .environmentObject(AuthManager())
}

