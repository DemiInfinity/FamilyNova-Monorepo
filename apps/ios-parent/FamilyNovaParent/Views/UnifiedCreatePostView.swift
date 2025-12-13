//
//  UnifiedCreatePostView.swift
//  FamilyNovaParent
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
    @State private var visibleToChildren = true // Default: children can see parent posts
    
    let onPostCreated: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [ParentAppColors.gradientBlue.opacity(0.1), ParentAppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: ParentAppSpacing.xl) {
                        // Header
                        VStack(spacing: ParentAppSpacing.m) {
                            Text("✨")
                                .font(.system(size: 60))
                            Text("Create Post")
                                .font(ParentAppFonts.title)
                                .foregroundColor(ParentAppColors.primaryPurple)
                            Text("Share what's on your mind with other parents and your children!")
                                .font(ParentAppFonts.body)
                                .foregroundColor(ParentAppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, ParentAppSpacing.xl)
                        }
                        .padding(.top, ParentAppSpacing.xxl)
                        
                        // Text Content
                        VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                            Text("What's on your mind?")
                                .font(ParentAppFonts.caption)
                                .foregroundColor(ParentAppColors.darkGray)
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                                            .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                                    )
                                
                                if postContent.isEmpty {
                                    Text("Share what you're up to...")
                                        .font(ParentAppFonts.body)
                                        .foregroundColor(ParentAppColors.mediumGray)
                                        .padding(.horizontal, ParentAppSpacing.m + 4)
                                        .padding(.vertical, ParentAppSpacing.m + 8)
                                        .allowsHitTesting(false)
                                }
                                
                                TextEditor(text: $postContent)
                                    .font(ParentAppFonts.body)
                                    .foregroundColor(ParentAppColors.black)
                                    .frame(minHeight: 150)
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .tint(ParentAppColors.primaryBlue)
                            }
                            .frame(minHeight: 150)
                            .onAppear {
                                UITextView.appearance().backgroundColor = .clear
                                UITextView.appearance().textColor = UIColor(ParentAppColors.black)
                            }
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        // Photo Section
                        VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                            HStack {
                                Text("Add Photo")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                Spacer()
                                if selectedImage != nil {
                                    Button(action: {
                                        selectedImage = nil
                                        uploadedImageUrl = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(ParentAppColors.error)
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
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                            .fill(ParentAppColors.mediumGray.opacity(0.2))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                                    .stroke(ParentAppColors.mediumGray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                            )
                                        
                                        HStack(spacing: ParentAppSpacing.s) {
                                            Image(systemName: "photo.on.rectangle")
                                                .font(.system(size: 24))
                                                .foregroundColor(ParentAppColors.primaryBlue)
                                            Text("Add Photo")
                                                .font(ParentAppFonts.body)
                                                .foregroundColor(ParentAppColors.primaryBlue)
                                        }
                                    }
                                    
                                    if isUploadingImage {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(1.5)
                                            .background(Color.black.opacity(0.3))
                                            .cornerRadius(ParentAppCornerRadius.medium)
                                    }
                                }
                                .frame(height: selectedImage != nil ? 200 : 80)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(ParentAppCornerRadius.medium)
                            }
                            .disabled(isUploadingImage)
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        // Visibility Toggle (for parents)
                        VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                            HStack {
                                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                                    Text("Visibility")
                                        .font(ParentAppFonts.headline)
                                        .foregroundColor(ParentAppColors.black)
                                    Text("Allow children to see this post")
                                        .font(ParentAppFonts.caption)
                                        .foregroundColor(ParentAppColors.darkGray)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $visibleToChildren)
                                    .labelsHidden()
                            }
                            .padding(ParentAppSpacing.m)
                            .background(Color.white)
                            .cornerRadius(ParentAppCornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                    .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        Spacer()
                    }
                    .padding(.bottom, ParentAppSpacing.xxl)
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(ParentAppFonts.button)
                    .foregroundColor(ParentAppColors.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createPost) {
                        if isPosting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: ParentAppColors.primaryBlue))
                        } else {
                            Text("Post")
                                .font(ParentAppFonts.button)
                                .foregroundColor(
                                    (postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil)
                                        ? ParentAppColors.mediumGray
                                        : ParentAppColors.primaryBlue
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

