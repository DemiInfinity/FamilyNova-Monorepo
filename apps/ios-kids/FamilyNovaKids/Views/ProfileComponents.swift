//
//  ProfileComponents.swift
//  FamilyNovaKids
//

import SwiftUI

struct StatItem: View {
    let count: Int
    let label: String
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("\(count)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.black)
                Text(label)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.darkGray)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundColor(isSelected ? AppColors.primaryBlue : AppColors.darkGray)
                
                Rectangle()
                    .fill(isSelected ? AppColors.primaryBlue : Color.clear)
                    .frame(height: 3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.s)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

