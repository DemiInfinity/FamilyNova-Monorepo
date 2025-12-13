//
//  EditProfileView.swift
//  FamilyNovaKids
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    let currentDisplayName: String
    let currentSchool: String
    let currentGrade: String
    
    @State private var displayName: String
    @State private var school: String
    @State private var grade: String
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var avatarImage: UIImage? = nil
    @State private var bannerImage: UIImage? = nil
    @State private var isUploadingAvatar = false
    @State private var isUploadingBanner = false
    @State private var showImagePicker = false
    @State private var imagePickerType: ImagePickerType = .avatar
    
    enum ImagePickerType {
        case avatar, banner
    }
    
    let onSave: (String, String, String) -> Void
    
    init(currentDisplayName: String, currentSchool: String, currentGrade: String, onSave: @escaping (String, String, String) -> Void) {
        self.currentDisplayName = currentDisplayName
        self.currentSchool = currentSchool
        self.currentGrade = currentGrade
        self.onSave = onSave
        _displayName = State(initialValue: currentDisplayName)
        _school = State(initialValue: currentSchool)
        _grade = State(initialValue: currentGrade)
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
                            Text("✏️")
                                .font(.system(size: 60))
                            Text("Edit Your Profile")
                                .font(AppFonts.title)
                                .foregroundColor(AppColors.primaryPurple)
                            Text("Changes will be sent to your parent for approval")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.darkGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.xl)
                        }
                        .padding(.top, AppSpacing.xxl)
                        
                        // Image Upload Section
                        VStack(spacing: AppSpacing.l) {
                            // Banner Upload
                            VStack(alignment: .leading, spacing: AppSpacing.s) {
                                Text("Banner Image")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.darkGray)
                                
                                Button(action: {
                                    imagePickerType = .banner
                                    showImagePicker = true
                                }) {
                                    ZStack {
                                        if let bannerImage = bannerImage {
                                            Image(uiImage: bannerImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } else {
                                            LinearGradient(
                                                colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        }
                                        
                                        VStack {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(.white)
                                            Text("Upload Banner")
                                                .font(AppFonts.caption)
                                                .foregroundColor(.white)
                                        }
                                        .opacity(bannerImage == nil ? 1.0 : 0.0)
                                        
                                        if isUploadingBanner {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        }
                                    }
                                    .frame(height: 150)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(AppCornerRadius.medium)
                                }
                                .disabled(isUploadingBanner)
                            }
                            
                            // Avatar Upload
                            VStack(alignment: .leading, spacing: AppSpacing.s) {
                                Text("Profile Picture")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.darkGray)
                                
                                HStack {
                                    Button(action: {
                                        imagePickerType = .avatar
                                        showImagePicker = true
                                    }) {
                                        ZStack {
                                            if let avatarImage = avatarImage {
                                                Image(uiImage: avatarImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } else {
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            }
                                            
                                            if avatarImage == nil {
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
                        .padding(.horizontal, AppSpacing.m)
                        
                        // Form Fields
                        VStack(spacing: AppSpacing.m) {
                            VStack(alignment: .leading, spacing: AppSpacing.s) {
                                Text("Display Name")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.darkGray)
                                TextField("Display Name", text: $displayName)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(AppColors.black)
                                    .padding(AppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(AppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                            .stroke(AppColors.mediumGray, lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: AppSpacing.s) {
                                Text("School")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.darkGray)
                                TextField("School Name", text: $school)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(AppColors.black)
                                    .padding(AppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(AppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                            .stroke(AppColors.mediumGray, lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: AppSpacing.s) {
                                Text("Grade")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.darkGray)
                                TextField("Grade", text: $grade)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(AppColors.black)
                                    .padding(AppSpacing.m)
                                    .background(Color.white)
                                    .cornerRadius(AppCornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                            .stroke(AppColors.mediumGray, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, AppSpacing.m)
                        
                        // Save Button
                        Button(action: saveChanges) {
                            HStack(spacing: AppSpacing.s) {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("📤")
                                        .font(.system(size: 24))
                                    Text("Request Changes")
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
                        .disabled(isSaving || !hasChanges)
                        .opacity(hasChanges ? 1.0 : 0.5)
                        
                        Spacer()
                    }
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
            .navigationTitle("Edit Profile")
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
                
                let (_, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "Invalid response", code: 0)
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    await MainActor.run {
                        isUploadingAvatar = false
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
                
                let (_, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "Invalid response", code: 0)
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    await MainActor.run {
                        isUploadingBanner = false
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

