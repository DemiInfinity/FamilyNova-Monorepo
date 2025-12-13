//
//  MoreView.swift
//  FamilyNovaParent
//

import SwiftUI

struct MoreView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedOption: MoreOption? = nil
    
    enum MoreOption: String, Identifiable {
        case dashboard = "Dashboard"
        case monitoring = "Monitoring"
        case postApproval = "Post Approvals"
        case homework = "Homework"
        case connections = "Connections"
        case settings = "Settings"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .monitoring: return "eye.fill"
            case .postApproval: return "doc.text.fill"
            case .homework: return "book.fill"
            case .connections: return "person.2.fill"
            case .settings: return "gearshape.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .dashboard: return ParentAppColors.primaryTeal
            case .monitoring: return ParentAppColors.primaryNavy
            case .postApproval: return ParentAppColors.accentGold
            case .homework: return ParentAppColors.primaryIndigo
            case .connections: return ParentAppColors.primaryTeal
            case .settings: return ParentAppColors.darkGray
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ParentAppSpacing.l) {
                    // Header
                    VStack(spacing: ParentAppSpacing.s) {
                        Text("More")
                            .font(ParentAppFonts.title)
                            .foregroundColor(ParentAppColors.primaryNavy)
                        Text("Parent Tools & Settings")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                    .padding(.top, ParentAppSpacing.xl)
                    .padding(.bottom, ParentAppSpacing.m)
                    
                    // Options Grid
                    VStack(spacing: ParentAppSpacing.m) {
                        MoreOptionRow(option: .dashboard) {
                            selectedOption = .dashboard
                        }
                        MoreOptionRow(option: .monitoring) {
                            selectedOption = .monitoring
                        }
                        MoreOptionRow(option: .postApproval) {
                            selectedOption = .postApproval
                        }
                        MoreOptionRow(option: .homework) {
                            selectedOption = .homework
                        }
                        MoreOptionRow(option: .connections) {
                            selectedOption = .connections
                        }
                        MoreOptionRow(option: .settings) {
                            selectedOption = .settings
                        }
                    }
                    .padding(.horizontal, ParentAppSpacing.m)
                }
                .padding(.bottom, ParentAppSpacing.xl)
            }
            .background(ParentAppColors.lightGray)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedOption) { option in
                destinationView(for: option)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for option: MoreOption) -> some View {
        switch option {
        case .dashboard:
            DashboardView()
                .environmentObject(authManager)
        case .monitoring:
            MonitoringView()
                .environmentObject(authManager)
        case .postApproval:
            PostApprovalView()
                .environmentObject(authManager)
        case .homework:
            HomeworkView()
                .environmentObject(authManager)
        case .connections:
            ConnectionsView()
                .environmentObject(authManager)
        case .settings:
            SettingsView()
                .environmentObject(authManager)
        }
    }
}

struct MoreOptionRow: View {
    let option: MoreView.MoreOption
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ParentAppSpacing.m) {
                ZStack {
                    Circle()
                        .fill(option.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: option.icon)
                        .font(.system(size: 24))
                        .foregroundColor(option.color)
                }
                
                Text(option.rawValue)
                    .font(ParentAppFonts.headline)
                    .foregroundColor(ParentAppColors.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(ParentAppColors.mediumGray)
            }
            .padding(ParentAppSpacing.m)
            .background(Color.white)
            .cornerRadius(ParentAppCornerRadius.medium)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    MoreView()
        .environmentObject(AuthManager())
}

