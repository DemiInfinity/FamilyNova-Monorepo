//
//  EditProfileView.swift
//  FamilyNovaParent
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    let currentDisplayName: String
    let currentSchool: String
    let currentGrade: String
    let currentAvatarUrl: String?
    let currentBannerUrl: String?
    
    @State private var displayName: String
    @State private var school: String
    @State private var grade: String
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var avatarImage: UIImage? = nil
    @State private var bannerImage: UIImage? = nil
    @State private var avatarUrl: String? = nil
    @State private var bannerUrl: String? = nil
    @State private var isUploadingAvatar = false
    @State private var isUploadingBanner = false
    @State private var showImagePicker = false
    @State private var imagePickerType: ImagePickerType = .avatar
    
    enum ImagePickerType {
        case avatar, banner
    }
    
    let onSave: (String, String, String) -> Void
    let onImageUploaded: (() -> Void)?
    
    init(currentDisplayName: String, currentSchool: String, currentGrade: String, currentAvatarUrl: String? = nil, currentBannerUrl: String? = nil, onSave: @escaping (String, String, String) -> Void, onImageUploaded: (() -> Void)? = nil) {
        self.currentDisplayName = currentDisplayName
        self.currentSchool = currentSchool
        self.currentGrade = currentGrade
        self.currentAvatarUrl = currentAvatarUrl
        self.currentBannerUrl = currentBannerUrl
        self.onSave = onSave
        self.onImageUploaded = onImageUploaded
        _displayName = State(initialValue: currentDisplayName)
        _school = State(initialValue: currentSchool)
        _grade = State(initialValue: currentGrade)
        _avatarUrl = State(initialValue: currentAvatarUrl)
        _bannerUrl = State(initialValue: currentBannerUrl)
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
                            Text("✏️")
                                .font(.system(size: 60))
                            Text("Edit Your Profile")
                                .font(ParentAppFonts.title)
                                .foregroundColor(ParentAppColors.primaryPurple)
                            Text("Changes will be sent to your parent for approval")
                                .font(ParentAppFonts.body)
                                .foregroundColor(ParentAppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, ParentAppSpacing.xl)
                        }
                        .padding(.top, ParentAppSpacing.xxl)
                        
                        // Image Upload Section
                        VStack(spacing: ParentAppSpacing.l) {
                            // Banner Upload
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("Banner Image")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                
                                Button(action: {
                                    imagePickerType = .banner
                                    showImagePicker = true
                                }) {
                                    ZStack {
                                        Group {
                                            if let bannerImage = bannerImage {
                                                Image(uiImage: bannerImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } else if let bannerUrl = bannerUrl, !bannerUrl.isEmpty {
                                                AsyncImage(url: URL(string: bannerUrl)) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                } placeholder: {
                                                    LinearGradient(
                                                        colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                }
                                            } else {
                                                LinearGradient(
                                                    colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            }
                                        }
                                        
                                        VStack {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(.white)
                                            Text("Upload Banner")
                                                .font(ParentAppFonts.caption)
                                                .foregroundColor(.white)
                                        }
                                        .opacity(bannerImage == nil && (bannerUrl == nil || bannerUrl!.isEmpty) ? 1.0 : 0.0)
                                        
                                        if isUploadingBanner {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        }
                                    }
                                    .frame(height: 150)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(ParentAppCornerRadius.medium)
                                    .clipped()
                                }
                                .disabled(isUploadingBanner)
                            }
                            
                            // Avatar Upload
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("Profile Picture")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                
                                HStack {
                                    Button(action: {
                                        imagePickerType = .avatar
                                        showImagePicker = true
                                    }) {
                                        ZStack {
                                            Group {
                                                if let avatarImage = avatarImage {
                                                    Image(uiImage: avatarImage)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                } else if let avatarUrl = avatarUrl, !avatarUrl.isEmpty {
                                                    AsyncImage(url: URL(string: avatarUrl)) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                    } placeholder: {
                                                        Circle()
                                                            .fill(
                                                                LinearGradient(
                                                                    colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                )
                                                            )
                                                    }
                                                } else {
                                                    Circle()
                                                        .fill(
                                                            LinearGradient(
                                                                colors: [ParentAppColors.primaryBlue, ParentAppColors.primaryPurple],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )
                                                }
                                            }
                                            
                                            if avatarImage == nil && (avatarUrl == nil || avatarUrl!.isEmpty) {
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            if isUploadingAvatar {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            }
                                        }
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                    }
                                    .disabled(isUploadingAvatar)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        // Form Fields
                        VStack(spacing: ParentAppSpacing.m) {
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("Display Name")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                TextField("Display Name", text: $displayName)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(ParentAppColors.black)
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(ParentAppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                            .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("School")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                TextField("School Name", text: $school)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(ParentAppColors.black)
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(ParentAppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                            .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                                Text("Grade")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(ParentAppColors.darkGray)
                                TextField("Grade", text: $grade)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(ParentAppColors.black)
                                    .padding(ParentAppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(ParentAppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                                            .stroke(ParentAppColors.mediumGray, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        // Save Button
                        Button(action: saveChanges) {
                            HStack(spacing: ParentAppSpacing.s) {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("📤")
                                        .font(.system(size: 24))
                                    Text("Request Changes")
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
                        .disabled(isSaving || !hasChanges)
                        .opacity(hasChanges ? 1.0 : 0.5)
                        
                        Spacer()
                    }
                    .padding(.bottom, ParentAppSpacing.xxl)
                }
            }
            .navigationTitle("Edit Profile")
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(
                    sourceType: .photoLibrary,
                    selectedImage: imagePickerType == .avatar ? $avatarImage : $bannerImage,
                    onImageSelected: { image in
                        if imagePickerType == .avatar {
                            uploadAvatar(image: image)
                        } else {
                            uploadBanner(image: image)
                        }
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
    
    private func uploadAvatar(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process image"
            showError = true
            return
        }
        
        isUploadingAvatar = true
        Task {
            do {
                let apiService = ApiService.shared
                guard let token = authManager.getValidatedToken() else {
                    throw NSError(domain: "Not authenticated", code: 401)
                }
                
                // Create multipart form data
                let boundary = UUID().uuidString
                var request = URLRequest(url: URL(string: "https://family-nova-monorepo.vercel.app/api/upload/profile-picture")!)
                request.httpMethod = "POST"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                var body = Data()
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"image\"; filename=\"avatar.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                
                request.httpBody = body
                
                let (responseData, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "Invalid response", code: 0)
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    // Parse response to get avatar URL
                    if let jsonData = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                       let avatarUrlString = jsonData["avatarUrl"] as? String {
                        await MainActor.run {
                            isUploadingAvatar = false
                            avatarUrl = avatarUrlString
                            onImageUploaded?()
                        }
                    } else {
                        await MainActor.run {
                            isUploadingAvatar = false
                            onImageUploaded?()
                        }
                    }
                } else {
                    throw NSError(domain: "Upload failed", code: httpResponse.statusCode)
                }
            } catch {
                await MainActor.run {
                    isUploadingAvatar = false
                    errorMessage = "Failed to upload avatar: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func uploadBanner(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process image"
            showError = true
            return
        }
        
        isUploadingBanner = true
        Task {
            do {
                let apiService = ApiService.shared
                guard let token = authManager.getValidatedToken() else {
                    throw NSError(domain: "Not authenticated", code: 401)
                }
                
                // Create multipart form data
                let boundary = UUID().uuidString
                var request = URLRequest(url: URL(string: "https://family-nova-monorepo.vercel.app/api/upload/banner")!)
                request.httpMethod = "POST"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                var body = Data()
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"image\"; filename=\"banner.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                
                request.httpBody = body
                
                let (responseData, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "Invalid response", code: 0)
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    // Parse response to get banner URL
                    if let jsonData = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                       let bannerUrlString = jsonData["bannerUrl"] as? String {
                        await MainActor.run {
                            isUploadingBanner = false
                            bannerUrl = bannerUrlString
                            onImageUploaded?()
                        }
                    } else {
                        await MainActor.run {
                            isUploadingBanner = false
                            onImageUploaded?()
                        }
                    }
                } else {
                    throw NSError(domain: "Upload failed", code: httpResponse.statusCode)
                }
            } catch {
                await MainActor.run {
                    isUploadingBanner = false
                    errorMessage = "Failed to upload banner: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private var hasChanges: Bool {
        displayName != currentDisplayName ||
        school != currentSchool ||
        grade != currentGrade
    }
    
    private func saveChanges() {
        guard hasChanges else { return }
        
        isSaving = true
        Task {
            // TODO: Implement API call to request profile change
            // POST /api/profile-changes/request
            // Body: { displayName, school, grade }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            isSaving = false
            onSave(displayName, school, grade)
            dismiss()
        }
    }
}

#Preview {
    EditProfileView(
        currentDisplayName: "John Doe",
        currentSchool: "Elementary School",
        currentGrade: "Grade 5",
        onSave: { _, _, _ in }
    )
}

