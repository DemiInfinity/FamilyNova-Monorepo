//
//  HomeworkView.swift
//  FamilyNovaParent
//

import SwiftUI

struct HomeworkView: View {
    @State private var homeworkItems: [HomeworkItem] = []
    @State private var isLoading = false
    @State private var selectedChild: String? = nil
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter by child
                if !homeworkItems.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: ParentAppSpacing.s) {
                            Button(action: { selectedChild = nil }) {
                                Text("All Children")
                                    .font(ParentAppFonts.caption)
                                    .foregroundColor(selectedChild == nil ? .white : ParentAppColors.primaryNavy)
                                    .padding(.horizontal, ParentAppSpacing.m)
                                    .padding(.vertical, ParentAppSpacing.s)
                                    .background(selectedChild == nil ? ParentAppColors.primaryNavy : Color.white)
                                    .cornerRadius(ParentAppCornerRadius.small)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ParentAppCornerRadius.small)
                                            .stroke(ParentAppColors.primaryNavy, lineWidth: selectedChild == nil ? 0 : 1)
                                    )
                            }
                            
                            // TODO: Add child filter buttons
                        }
                        .padding(.horizontal, ParentAppSpacing.m)
                        .padding(.vertical, ParentAppSpacing.s)
                    }
                    .background(Color.white)
                }
                
                if isLoading {
                    VStack(spacing: ParentAppSpacing.m) {
                        ProgressView()
                        Text("Loading homework...")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if homeworkItems.isEmpty {
                    VStack(spacing: ParentAppSpacing.m) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 48))
                            .foregroundColor(ParentAppColors.mediumGray)
                        Text("No homework")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                        Text("Homework and assignments from your children's schools will appear here")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, ParentAppSpacing.xl)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: ParentAppSpacing.m) {
                            ForEach(filteredHomework) { item in
                                HomeworkCard(item: item)
                            }
                        }
                        .padding(ParentAppSpacing.m)
                    }
                }
            }
            .background(ParentAppColors.lightGray)
            .navigationTitle("Homework")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadHomework()
            }
            .refreshable {
                await loadHomeworkAsync()
            }
        }
    }
    
    private var filteredHomework: [HomeworkItem] {
        if let selectedChild = selectedChild {
            return homeworkItems.filter { $0.childName == selectedChild }
        }
        return homeworkItems
    }
    
    private func loadHomework() {
        isLoading = true
        Task {
            await loadHomeworkAsync()
        }
    }
    
    private func loadHomeworkAsync() async {
        // TODO: Implement API call to fetch homework
        // GET /api/education
        try? await Task.sleep(nanoseconds: 500_000_000)
        homeworkItems = []
        isLoading = false
    }
}

struct HomeworkItem: Identifiable {
    let id = UUID()
    let contentId: String
    let title: String
    let description: String
    let subject: String
    let dueDate: Date?
    let school: String
    let childName: String
    let isCompleted: Bool
    let completedAt: Date?
}

struct HomeworkCard: View {
    let item: HomeworkItem
    @State private var showDetail = false
    
    var body: some View {
        Button(action: { showDetail = true }) {
            VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
                HStack {
                    VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                        Text(item.title)
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                        
                        Text("\(item.childName) • \(item.subject)")
                            .font(ParentAppFonts.caption)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                    
                    Spacer()
                    
                    if item.isCompleted {
                        VStack(spacing: ParentAppSpacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ParentAppColors.success)
                                .font(.system(size: 24))
                            if let completedAt = item.completedAt {
                                Text(completedAt, style: .date)
                                    .font(ParentAppFonts.small)
                                    .foregroundColor(ParentAppColors.success)
                            }
                        }
                    } else {
                        Image(systemName: "clock")
                            .foregroundColor(ParentAppColors.warning)
                            .font(.system(size: 24))
                    }
                }
                
                if let description = item.description, !description.isEmpty {
                    Text(description)
                        .font(ParentAppFonts.body)
                        .foregroundColor(ParentAppColors.darkGray)
                        .lineLimit(2)
                }
                
                HStack {
                    Text("🏫 \(item.school)")
                        .font(ParentAppFonts.small)
                        .foregroundColor(ParentAppColors.darkGray)
                    
                    Spacer()
                    
                    if let dueDate = item.dueDate {
                        Text("Due: \(dueDate, style: .date)")
                            .font(ParentAppFonts.small)
                            .foregroundColor(dueDate < Date() ? ParentAppColors.error : ParentAppColors.primaryTeal)
                    }
                }
            }
            .padding(ParentAppSpacing.m)
            .background(Color.white)
            .cornerRadius(ParentAppCornerRadius.medium)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            HomeworkDetailView(item: item)
        }
    }
}

struct HomeworkDetailView: View {
    let item: HomeworkItem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: ParentAppSpacing.l) {
                    Text(item.title)
                        .font(ParentAppFonts.title)
                        .foregroundColor(ParentAppColors.primaryNavy)
                    
                    if let description = item.description, !description.isEmpty {
                        Text(description)
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.black)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
                        InfoRow(label: "Child", value: item.childName)
                        InfoRow(label: "Subject", value: item.subject)
                        InfoRow(label: "School", value: item.school)
                        
                        if let dueDate = item.dueDate {
                            InfoRow(
                                label: "Due Date",
                                value: dueDate, style: .date
                            )
                        }
                        
                        InfoRow(
                            label: "Status",
                            value: item.isCompleted ? "Completed" : "Pending",
                            valueColor: item.isCompleted ? ParentAppColors.success : ParentAppColors.warning
                        )
                        
                        if let completedAt = item.completedAt {
                            InfoRow(
                                label: "Completed",
                                value: completedAt, style: .date
                            )
                        }
                    }
                }
                .padding(ParentAppSpacing.m)
            }
            .background(ParentAppColors.lightGray)
            .navigationTitle("Homework Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(ParentAppFonts.button)
                    .foregroundColor(ParentAppColors.primaryTeal)
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = ParentAppColors.black
    
    init(label: String, value: String, valueColor: Color = ParentAppColors.black) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
    }
    
    init(label: String, value: Date, style: Date.FormatStyle, valueColor: Color = ParentAppColors.black) {
        self.label = label
        self.value = value.formatted(style)
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(ParentAppFonts.caption)
                .foregroundColor(ParentAppColors.darkGray)
            Spacer()
            Text(value)
                .font(ParentAppFonts.body)
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    HomeworkView()
        .environmentObject(AuthManager())
}

