//
//  UnifiedCreatePostView.swift
//  FamilyNovaKids
//
//  Unified post creation view that supports both text and photo (like Facebook)

import SwiftUI
import UIKit

struct UnifiedCreatePostView: View {
    @Environment(\.dismiss) var dismiss
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
    
    let onPostCreated: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
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
                            Text("✨")
                                .font(.system(size: 60))
                            Text("Create Post")
                                .font(AppFonts.title)
                                .foregroundColor(AppColors.primaryPurple)
                            Text("Share what's on your mind with your friends!")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.xl)
                        }
                        .padding(.top, AppSpacing.xxl)
                        
                        // Text Content
                        VStack(alignment: .leading, spacing: AppSpacing.s) {
                            Text("What's on your mind?")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.darkGray)
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                            .stroke(AppColors.mediumGray, lineWidth: 1)
                                    )
                                
                                if postContent.isEmpty {
                                    Text("Share what you're up to...")
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.mediumGray)
                                        .padding(.horizontal, AppSpacing.m + 4)
                                        .padding(.vertical, AppSpacing.m + 8)
                                        .allowsHitTesting(false)
                                }
                                
                                TextEditor(text: $postContent)
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.black)
                                    .frame(minHeight: 150)
                                    .padding(AppSpacing.m)
                                    .background(Color.white)
                                    .tint(AppColors.primaryBlue)
                            }
                            .frame(minHeight: 150)
                            .onAppear {
                                UITextView.appearance().backgroundColor = .clear
                                UITextView.appearance().textColor = UIColor(AppColors.black)
                            }
                        }
                        .padding(.horizontal, AppSpacing.m)
                        
                        // Photo Section
                        VStack(alignment: .leading, spacing: AppSpacing.s) {
                            HStack {
                                Text("Add Photo")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.darkGray)
                                Spacer()
                                if selectedImage != nil {
                                    Button(action: {
                                        selectedImage = nil
                                        uploadedImageUrl = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(AppColors.error)
                                            .font(.system(size: 20))
                                    }
                                }
                            }
                            
                            Button(action: {
                                showImageSourceActionSheet = true
                            }) {
                                ZStack {
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                            .fill(AppColors.mediumGray.opacity(0.2))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                                    .stroke(AppColors.mediumGray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                            )
                                        
                                        HStack(spacing: AppSpacing.s) {
                                            Image(systemName: "photo.on.rectangle")
                                                .font(.system(size: 24))
                                                .foregroundColor(AppColors.primaryBlue)
                                            Text("Add Photo")
                                                .font(AppFonts.body)
                                                .foregroundColor(AppColors.primaryBlue)
                                        }
                                    }
                                    
                                    if isUploadingImage {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(1.5)
                                            .background(Color.black.opacity(0.3))
                                            .cornerRadius(AppCornerRadius.medium)
                                    }
                                }
                                .frame(height: selectedImage != nil ? 200 : 80)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(AppCornerRadius.medium)
                            }
                            .disabled(isUploadingImage)
                        }
                        .padding(.horizontal, AppSpacing.m)
                        
                        Spacer()
                    }
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppFonts.button)
                    .foregroundColor(AppColors.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createPost) {
                        if isPosting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryBlue))
                        } else {
                            Text("Post")
                                .font(AppFonts.button)
                                .foregroundColor(
                                    (postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil)
                                        ? AppColors.mediumGray
                                        : AppColors.primaryBlue
                                )
                        }
                    }
                    .disabled((postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil) || isPosting)
                }
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
        // Must have either text or image
        guard !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil else {
            return
        }
        
        // If image is selected but not uploaded yet, wait
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
                    "imageUrl": uploadedImageUrl ?? NSNull()
                ]
                
                let _: CreatePostResponse = try await apiService.makeRequest(
                    endpoint: "posts",
                    method: "POST",
                    body: body,
                    token: token
                )
                
                await MainActor.run {
                    isPosting = false
                    onPostCreated()
                    dismiss()
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

