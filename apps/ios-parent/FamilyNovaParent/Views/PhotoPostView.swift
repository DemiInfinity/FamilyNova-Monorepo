//
//  PhotoPostView.swift
//  FamilyNovaParent
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
    @State private var visibleToChildren = true // Default: children can see parent posts
    
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
                    colors: [ParentAppColors.gradientBlue.opacity(0.1), ParentAppColors.gradientPurple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: ParentAppSpacing.xl) {
                        // Header
                        VStack(spacing: ParentAppSpacing.m) {
                            Text("📷")
                                .font(.system(size: 60))
                            Text("Share a Photo!")
                                .font(ParentAppFonts.title)
                                .foregroundColor(ParentAppColors.primaryPurple)
                            Text("Take or choose a photo to share with your friends")
                                .font(ParentAppFonts.body)
                                .foregroundColor(ParentAppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, ParentAppSpacing.xl)
                        }
                        .padding(.top, ParentAppSpacing.xxl)
                        
                        // Photo Preview/Selector
                        VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                            Text("Photo")
                                .font(ParentAppFonts.caption)
                                .foregroundColor(ParentAppColors.darkGray)
                            
                            Button(action: {
                                showImageSourceActionSheet = true
                            }) {
                                ZStack {
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                                            .fill(ParentAppColors.mediumGray.opacity(0.3))
                                        
                                        VStack(spacing: ParentAppSpacing.m) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(ParentAppColors.primaryBlue)
                                            Text("Tap to add photo")
                                                .font(ParentAppFonts.body)
                                                .foregroundColor(ParentAppColors.darkGray)
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
                                .cornerRadius(ParentAppCornerRadius.large)
                                .overlay(
                                    RoundedRectangle(cornerRadius: ParentAppCornerRadius.large)
                                        .stroke(ParentAppColors.mediumGray, lineWidth: selectedImage == nil ? 2 : 0)
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
                                    .font(ParentAppFonts.button)
                                    .foregroundColor(ParentAppColors.primaryBlue)
                                    .frame(maxWidth: .infinity)
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(ParentAppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                            .stroke(ParentAppColors.primaryBlue, lineWidth: 1)
                                    )
                                }
                                .padding(.top, ParentAppSpacing.s)
                            }
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        // Caption
                        VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                            Text("Caption (optional)")
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
                                    Text("Add a caption...")
                                        .font(ParentAppFonts.body)
                                        .foregroundColor(ParentAppColors.mediumGray)
                                        .padding(.horizontal, ParentAppSpacing.m + 4)
                                        .padding(.vertical, ParentAppSpacing.m + 8)
                                        .allowsHitTesting(false)
                                }
                                
                                TextEditor(text: $postContent)
                                    .font(ParentAppFonts.body)
                                    .foregroundColor(ParentAppColors.black)
                                    .frame(minHeight: 100)
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .tint(ParentAppColors.primaryBlue)
                            }
                            .frame(minHeight: 100)
                            .onAppear {
                                UITextView.appearance().backgroundColor = .clear
                                UITextView.appearance().textColor = UIColor(ParentAppColors.black)
                            }
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
                        
                        // Post Button
                        Button(action: createPost) {
                            HStack(spacing: ParentAppSpacing.s) {
                                if isPosting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("📤")
                                        .font(.system(size: 24))
                                    Text("Post")
                                        .font(ParentAppFonts.button)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(ParentAppCornerRadius.large)
                            .shadow(color: ParentAppColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        .disabled(isPosting || selectedImage == nil || isUploadingImage)
                        .opacity((selectedImage != nil && !isUploadingImage) ? 1.0 : 0.5)
                        
                        Spacer()
                    }
                    .padding(.bottom, ParentAppSpacing.xxl)
                }
            }
            .navigationTitle("Create Photo Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(ParentAppFonts.button)
                    .foregroundColor(ParentAppColors.primaryBlue)
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
                    "imageUrl": imageUrl,
                    "visibleToChildren": visibleToChildren
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

