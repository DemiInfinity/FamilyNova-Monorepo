//
//  PhotoPostView.swift
//  FamilyNovaKids
//

import SwiftUI

struct PhotoPostView: View {
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
    @State private var shouldShowImagePickerOnAppear = false
    
    let initialSourceType: UIImagePickerController.SourceType?
    let onPostCreated: () -> Void
    
    init(initialSourceType: UIImagePickerController.SourceType? = nil, onPostCreated: @escaping () -> Void) {
        self.initialSourceType = initialSourceType
        self.onPostCreated = onPostCreated
    }
    
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
                            Text("📷")
                                .font(.system(size: 60))
                            Text("Share a Photo!")
                                .font(AppFonts.title)
                                .foregroundColor(AppColors.primaryPurple)
                            Text("Take or choose a photo to share with your friends")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.xl)
                        }
                        .padding(.top, AppSpacing.xxl)
                        
                        // Photo Preview/Selector
                        VStack(alignment: .leading, spacing: AppSpacing.s) {
                            Text("Photo")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.darkGray)
                            
                            Button(action: {
                                showImageSourceActionSheet = true
                            }) {
                                ZStack {
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                            .fill(AppColors.mediumGray.opacity(0.3))
                                        
                                        VStack(spacing: AppSpacing.m) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(AppColors.primaryBlue)
                                            Text("Tap to add photo")
                                                .font(AppFonts.body)
                                                .foregroundColor(AppColors.darkGray)
                                        }
                                    }
                                    
                                    if isUploadingImage {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(1.5)
                                    }
                                }
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(AppCornerRadius.large)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                        .stroke(AppColors.mediumGray, lineWidth: selectedImage == nil ? 2 : 0)
                                )
                            }
                            .disabled(isUploadingImage)
                            
                            // Change photo button
                            if selectedImage != nil {
                                Button(action: {
                                    showImageSourceActionSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle")
                                        Text("Change Photo")
                                    }
                                    .font(AppFonts.button)
                                    .foregroundColor(AppColors.primaryBlue)
                                    .frame(maxWidth: .infinity)
                                    .padding(AppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(AppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                            .stroke(AppColors.primaryBlue, lineWidth: 1)
                                    )
                                }
                                .padding(.top, AppSpacing.s)
                            }
                        }
                        .padding(.horizontal, AppSpacing.m)
                        
                        // Caption
                        VStack(alignment: .leading, spacing: AppSpacing.s) {
                            Text("Caption (optional)")
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
                                    Text("Add a caption...")
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.mediumGray)
                                        .padding(.horizontal, AppSpacing.m + 4)
                                        .padding(.vertical, AppSpacing.m + 8)
                                        .allowsHitTesting(false)
                                }
                                
                                TextEditor(text: $postContent)
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.black)
                                    .frame(minHeight: 100)
                                    .padding(AppSpacing.m)
                                    .background(Color.white)
                                    .tint(AppColors.primaryBlue)
                            }
                            .frame(minHeight: 100)
                            .onAppear {
                                UITextView.appearance().backgroundColor = .clear
                                UITextView.appearance().textColor = UIColor(AppColors.black)
                            }
                        }
                        .padding(.horizontal, AppSpacing.m)
                        
                        // Post Button
                        Button(action: createPost) {
                            HStack(spacing: AppSpacing.s) {
                                if isPosting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("📤")
                                        .font(.system(size: 24))
                                    Text("Post")
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
                            .shadow(color: AppColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, AppSpacing.m)
                        .disabled(isPosting || selectedImage == nil || isUploadingImage)
                        .opacity((selectedImage != nil && !isUploadingImage) ? 1.0 : 0.5)
                        
                        Spacer()
                    }
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
            .navigationTitle("Create Photo Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppFonts.button)
                    .foregroundColor(AppColors.primaryBlue)
                }
            }
            .onAppear {
                // If a source type was provided from HomeView, use it directly
                if let sourceType = initialSourceType {
                    imagePickerSourceType = sourceType
                    // Check if the source type is available
                    if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showImagePicker = true
                        }
                    } else {
                        // Fallback to photo library if camera is not available
                        imagePickerSourceType = .photoLibrary
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showImagePicker = true
                        }
                    }
                } else if selectedImage == nil {
                    // Show image source picker when view first appears if no image is selected and no source type provided
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showImageSourceActionSheet = true
                    }
                }
            }
            .confirmationDialog("Select Photo", isPresented: $showImageSourceActionSheet, titleVisibility: .visible) {
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
                
                // Upload image to backend
                // First, we'll upload to a posts images endpoint or use the upload endpoint
                // For now, let's create an endpoint that uploads and returns the URL
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
        guard let imageUrl = uploadedImageUrl else {
            errorMessage = "Please wait for image to upload"
            showError = true
            return
        }
        
        guard let token = authManager.getValidatedToken() else {
            errorMessage = "Not authenticated. Please log in again."
            showError = true
            return
        }
        
        isPosting = true
        Task {
            do {
                let apiService = ApiService.shared
                
                struct PostResponse: Codable {
                    let post: PostData
                    let message: String
                }
                
                struct PostData: Codable {
                    let id: String
                    let content: String
                    let imageUrl: String?
                }
                
                let body: [String: Any] = [
                    "content": postContent.isEmpty ? "📷" : postContent,
                    "imageUrl": imageUrl
                ]
                
                let _: PostResponse = try await apiService.makeRequest(
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
                    errorMessage = "Failed to create post: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

