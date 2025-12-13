//
//  EditProfileView.swift
//  FamilyNovaKids
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    let currentDisplayName: String
    let currentSchool: String
    let currentGrade: String
    
    @State private var displayName: String
    @State private var school: String
    @State private var grade: String
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
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
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
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

