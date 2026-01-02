//
//  ToastNotification.swift
//  FamilyNovaKids
//
//  Toast notification system for in-app notifications

import SwiftUI

struct ToastNotification: View {
    let title: String
    let message: String
    let icon: String
    let color: Color
    
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            if isPresented {
                HStack(spacing: CosmicSpacing.m) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: CosmicSpacing.xs) {
                        Text(title)
                            .font(CosmicFonts.headline)
                            .foregroundColor(CosmicColors.textPrimary)
                        
                        Text(message)
                            .font(CosmicFonts.caption)
                            .foregroundColor(CosmicColors.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(CosmicSpacing.m)
                .background(
                    RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                        .fill(CosmicColors.glassBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: CosmicCornerRadius.medium)
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.horizontal, CosmicSpacing.m)
                .padding(.bottom, CosmicSpacing.xl)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
    }
}

struct ToastNotificationModifier: ViewModifier {
    @Binding var toast: ToastNotificationData?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let toast = toast {
                ToastNotification(
                    title: toast.title,
                    message: toast.message,
                    icon: toast.icon,
                    color: toast.color,
                    isPresented: Binding(
                        get: { self.toast != nil },
                        set: { if !$0 { self.toast = nil } }
                    )
                )
            }
        }
    }
}

extension View {
    func toastNotification(_ toast: Binding<ToastNotificationData?>) -> some View {
        modifier(ToastNotificationModifier(toast: toast))
    }
}

struct ToastNotificationData: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let icon: String
    let color: Color
}

