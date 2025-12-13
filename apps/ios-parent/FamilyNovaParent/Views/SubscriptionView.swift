//
//  SubscriptionView.swift
//  FamilyNovaParent
//

import SwiftUI

struct SubscriptionView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ParentAppSpacing.l) {
                    // Current Plan Status
                    if let subscription = subscriptionService.currentSubscription {
                        CurrentPlanCard(subscription: subscription)
                            .padding(.horizontal, ParentAppSpacing.m)
                            .padding(.top, ParentAppSpacing.m)
                    }
                    
                    // Available Plans
                    VStack(spacing: ParentAppSpacing.m) {
                        Text("Upgrade to Pro")
                            .font(ParentAppFonts.headline)
                            .foregroundColor(ParentAppColors.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, ParentAppSpacing.m)
                        
                        // Free Plan
                        PlanCard(
                            title: "Free",
                            price: "£0",
                            period: "month",
                            features: [
                                "1-2 child accounts",
                                "Basic monitoring",
                                "Standard features",
                                "Community support"
                            ],
                            isSelected: subscriptionService.currentSubscription?.plan == "free",
                            isPopular: false,
                            action: {}
                        )
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        // Pro Monthly
                        PlanCard(
                            title: "Pro Family",
                            price: "£9.99",
                            period: "month",
                            features: [
                                "Unlimited child accounts",
                                "Advanced monitoring & analytics",
                                "Priority support",
                                "Enhanced safety features",
                                "Extended data retention",
                                "Early access to new features"
                            ],
                            isSelected: subscriptionService.currentSubscription?.plan == "pro" && subscriptionService.currentSubscription?.billingCycle == "monthly",
                            isPopular: true,
                            action: {
                                Task {
                                    await purchaseProMonthly()
                                }
                            }
                        )
                        .padding(.horizontal, ParentAppSpacing.m)
                        
                        // Pro Annual
                        PlanCard(
                            title: "Pro Family",
                            price: "£99",
                            period: "year",
                            subtitle: "Save 17%",
                            features: [
                                "Unlimited child accounts",
                                "Advanced monitoring & analytics",
                                "Priority support",
                                "Enhanced safety features",
                                "Extended data retention",
                                "Early access to new features",
                                "Best value - Save £20/year"
                            ],
                            isSelected: subscriptionService.currentSubscription?.plan == "pro" && subscriptionService.currentSubscription?.billingCycle == "annual",
                            isPopular: false,
                            action: {
                                Task {
                                    await purchaseProAnnual()
                                }
                            }
                        )
                        .padding(.horizontal, ParentAppSpacing.m)
                    }
                    
                    // Cancel Subscription Button
                    if subscriptionService.currentSubscription?.plan == "pro" && subscriptionService.currentSubscription?.status == "active" {
                        Button(action: {
                            Task {
                                await cancelSubscription()
                            }
                        }) {
                            Text("Cancel Subscription")
                                .font(ParentAppFonts.body)
                                .foregroundColor(ParentAppColors.error)
                        }
                        .padding(.top, ParentAppSpacing.l)
                    }
                }
                .padding(.bottom, ParentAppSpacing.xl)
            }
            .background(ParentAppColors.lightGray)
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                subscriptionService.setAuthManager(authManager)
                Task {
                    await subscriptionService.fetchSubscriptionStatus()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func purchaseProMonthly() async {
        isLoading = true
        do {
            try await subscriptionService.purchaseProMonthly()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            }
        }
    }
    
    private func purchaseProAnnual() async {
        isLoading = true
        do {
            try await subscriptionService.purchaseProAnnual()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            }
        }
    }
    
    private func cancelSubscription() async {
        isLoading = true
        do {
            try await subscriptionService.cancelSubscription()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        isLoading = false
    }
}

struct CurrentPlanCard: View {
    let subscription: Subscription
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
            Text("Current Plan")
                .font(ParentAppFonts.headline)
                .foregroundColor(ParentAppColors.black)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscription.plan == "pro" ? "Pro Family" : "Free")
                        .font(ParentAppFonts.title)
                        .foregroundColor(ParentAppColors.black)
                    
                    if subscription.plan == "pro" {
                        if let billingCycle = subscription.billingCycle {
                            Text(billingCycle.capitalized)
                                .font(ParentAppFonts.caption)
                                .foregroundColor(ParentAppColors.mediumGray)
                        }
                    }
                }
                
                Spacer()
                
                if subscription.status == "active" {
                    Text("Active")
                        .font(ParentAppFonts.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(ParentAppColors.success)
                        .cornerRadius(12)
                }
            }
            
            if let endDate = subscription.endDateAsDate, subscription.plan == "pro" {
                Text("Renews: \(formatDate(endDate))")
                    .font(ParentAppFonts.caption)
                    .foregroundColor(ParentAppColors.mediumGray)
            }
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct PlanCard: View {
    let title: String
    let price: String
    let period: String
    var subtitle: String? = nil
    let features: [String]
    let isSelected: Bool
    let isPopular: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: ParentAppSpacing.m) {
            if isPopular {
                HStack {
                    Spacer()
                    Text("Most Popular")
                        .font(ParentAppFonts.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(ParentAppColors.primaryTeal)
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                Text(title)
                    .font(ParentAppFonts.title)
                    .foregroundColor(ParentAppColors.black)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(price)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(ParentAppColors.black)
                    Text("/\(period)")
                        .font(ParentAppFonts.body)
                        .foregroundColor(ParentAppColors.mediumGray)
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(ParentAppFonts.caption)
                        .foregroundColor(ParentAppColors.primaryTeal)
                }
                
                VStack(alignment: .leading, spacing: ParentAppSpacing.s) {
                    ForEach(features, id: \.self) { feature in
                        HStack(alignment: .top, spacing: ParentAppSpacing.s) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ParentAppColors.success)
                                .font(.system(size: 16))
                            Text(feature)
                                .font(ParentAppFonts.body)
                                .foregroundColor(ParentAppColors.black)
                        }
                    }
                }
                .padding(.top, ParentAppSpacing.m)
            }
            
            Button(action: action) {
                Text(isSelected ? "Current Plan" : "Upgrade")
                    .font(ParentAppFonts.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isSelected ? ParentAppColors.mediumGray : ParentAppColors.primaryTeal)
                    .cornerRadius(ParentAppCornerRadius.medium)
            }
            .disabled(isSelected)
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: ParentAppCornerRadius.medium)
                .stroke(isSelected ? ParentAppColors.primaryTeal : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(AuthManager())
}

