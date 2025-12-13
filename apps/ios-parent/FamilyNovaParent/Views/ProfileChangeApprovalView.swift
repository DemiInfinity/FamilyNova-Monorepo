//
//  ProfileChangeApprovalView.swift
//  FamilyNovaParent
//

import SwiftUI

struct ProfileChangeApprovalView: View {
    @State private var requests: [ProfileChangeRequest] = []
    @State private var isLoading = false
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading && requests.isEmpty {
                    VStack(spacing: ParentAppSpacing.m) {
                        ProgressView()
                        Text("Loading requests...")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if requests.isEmpty {
                    VStack(spacing: ParentAppSpacing.m) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(ParentAppColors.success)
                        Text("No pending requests")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                        Text("All profile change requests have been reviewed")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, ParentAppSpacing.xl)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: ParentAppSpacing.l) {
                            ForEach(requests) { request in
                                ProfileChangeRequestCard(request: request)
                            }
                        }
                        .padding(ParentAppSpacing.m)
                    }
                }
            }
            .background(ParentAppColors.lightGray)
            .navigationTitle("Profile Changes")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadRequests()
            }
            .refreshable {
                await loadRequestsAsync()
            }
        }
    }
    
    private func loadRequests() {
        isLoading = true
        Task {
            await loadRequestsAsync()
        }
    }
    
    private func loadRequestsAsync() async {
        // TODO: Implement API call to fetch profile change requests
        // GET /api/profile-changes/pending
        try? await Task.sleep(nanoseconds: 500_000_000)
        requests = []
        isLoading = false
    }
}

struct ProfileChangeRequest: Identifiable {
    let id = UUID()
    let requestId: String
    let childName: String
    let changes: ProfileChanges
    let createdAt: Date
}

struct ProfileChanges {
    let displayName: String?
    let oldDisplayName: String?
    let school: String?
    let oldSchool: String?
    let grade: String?
    let oldGrade: String?
}

struct ProfileChangeRequestCard: View {
    let request: ProfileChangeRequest
    @State private var isProcessing = false
    @State private var showRejectReason = false
    @State private var rejectReason = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text("From: \(request.childName)")
                        .font(ParentAppFonts.headline)
                        .foregroundColor(ParentAppColors.primaryNavy)
                    Text(request.createdAt, style: .relative)
                        .font(ParentAppFonts.small)
                        .foregroundColor(ParentAppColors.darkGray)
                }
                
                Spacer()
                
                Text("Pending")
                    .font(ParentAppFonts.caption)
                    .foregroundColor(ParentAppColors.warning)
                    .padding(.horizontal, ParentAppSpacing.m)
                    .padding(.vertical, ParentAppSpacing.xs)
                    .background(ParentAppColors.warning.opacity(0.2))
                    .cornerRadius(ParentAppCornerRadius.small)
            }
            
            Divider()
            
            // Changes
            VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
                if let displayName = request.changes.displayName, let oldName = request.changes.oldDisplayName {
                    ChangeRow(
                        label: "Display Name",
                        oldValue: oldName,
                        newValue: displayName
                    )
                }
                
                if let school = request.changes.school, let oldSchool = request.changes.oldSchool {
                    ChangeRow(
                        label: "School",
                        oldValue: oldSchool,
                        newValue: school
                    )
                }
                
                if let grade = request.changes.grade, let oldGrade = request.changes.oldGrade {
                    ChangeRow(
                        label: "Grade",
                        oldValue: oldGrade,
                        newValue: grade
                    )
                }
            }
            
            // Actions
            HStack(spacing: ParentAppSpacing.m) {
                Button(action: { approveRequest() }) {
                    HStack(spacing: ParentAppSpacing.xs) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        Text("Approve")
                            .font(ParentAppFonts.button)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ParentAppSpacing.m)
                    .background(ParentAppColors.success)
                    .cornerRadius(ParentAppCornerRadius.medium)
                }
                .disabled(isProcessing)
                
                Button(action: { showRejectReason = true }) {
                    HStack(spacing: ParentAppSpacing.xs) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Reject")
                            .font(ParentAppFonts.button)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ParentAppSpacing.m)
                    .background(ParentAppColors.error)
                    .cornerRadius(ParentAppCornerRadius.medium)
                }
                .disabled(isProcessing)
            }
        }
        .padding(ParentAppSpacing.l)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.large)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .alert("Reject Request", isPresented: $showRejectReason) {
            TextField("Reason (optional)", text: $rejectReason)
            Button("Cancel", role: .cancel) {
                rejectReason = ""
            }
            Button("Reject") {
                rejectRequest()
            }
        } message: {
            Text("Please provide a reason for rejecting this request (optional)")
        }
    }
    
    private func approveRequest() {
        isProcessing = true
        // TODO: Implement API call to approve request
        // PUT /api/profile-changes/:requestId/approve
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            isProcessing = false
        }
    }
    
    private func rejectRequest() {
        isProcessing = true
        // TODO: Implement API call to reject request
        // PUT /api/profile-changes/:requestId/approve with action: "reject"
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            isProcessing = false
            rejectReason = ""
        }
    }
}

struct ChangeRow: View {
    let label: String
    let oldValue: String
    let newValue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
            Text(label)
                .font(ParentAppFonts.caption)
                .foregroundColor(ParentAppColors.darkGray)
            
            HStack(spacing: ParentAppSpacing.s) {
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text("Current")
                        .font(ParentAppFonts.small)
                        .foregroundColor(ParentAppColors.darkGray)
                    Text(oldValue)
                        .font(ParentAppFonts.body)
                        .foregroundColor(ParentAppColors.black)
                }
                .frame(maxWidth: .infinity)
                .padding(ParentAppSpacing.s)
                .background(ParentAppColors.lightGray)
                .cornerRadius(ParentAppCornerRadius.small)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(ParentAppColors.primaryTeal)
                
                VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                    Text("New")
                        .font(ParentAppFonts.small)
                        .foregroundColor(ParentAppColors.darkGray)
                    Text(newValue)
                        .font(ParentAppFonts.body)
                        .foregroundColor(ParentAppColors.primaryTeal)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(ParentAppSpacing.s)
                .background(ParentAppColors.primaryTeal.opacity(0.1))
                .cornerRadius(ParentAppCornerRadius.small)
            }
        }
    }
}

#Preview {
    ProfileChangeApprovalView()
        .environmentObject(AuthManager())
}

