//
//  ProfileComponents.swift
//  FamilyNovaParent
//

import SwiftUI

struct StatItem: View {
    let count: Int
    let label: String
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                Text("\(count)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ParentAppColors.black)
                Text(label)
                    .font(ParentAppFonts.caption)
                    .foregroundColor(ParentAppColors.darkGray)
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
            VStack(spacing: ParentAppSpacing.xs) {
                Text(title)
                    .font(ParentAppFonts.headline)
                    .foregroundColor(isSelected ? ParentAppColors.primaryBlue : ParentAppColors.darkGray)
                
                Rectangle()
                    .fill(isSelected ? ParentAppColors.primaryBlue : Color.clear)
                    .frame(height: 3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ParentAppSpacing.s)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

