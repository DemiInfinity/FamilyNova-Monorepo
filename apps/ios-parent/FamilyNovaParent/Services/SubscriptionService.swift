//
//  SubscriptionService.swift
//  FamilyNovaParent
//

import Foundation
import StoreKit

class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var currentSubscription: Subscription?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = ApiService.shared
    private var authManager: AuthManager?
    
    private init() {}
    
    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    // MARK: - API Methods
    
    func fetchSubscriptionStatus() async {
        guard let token = authManager?.token else {
            errorMessage = "Not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let status: SubscriptionStatus = try await apiService.makeRequest(
                endpoint: "subscriptions/status",
                method: "GET",
                token: token
            )
            
            await MainActor.run {
                self.currentSubscription = status.subscription
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch subscription: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func createSubscription(plan: String, billingCycle: String, providerSubscriptionId: String, receipt: String) async throws {
        guard let token = authManager?.token else {
            throw NSError(domain: "SubscriptionService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let request = CreateSubscriptionRequest(
            plan: plan,
            billingCycle: billingCycle,
            provider: "ios",
            providerSubscriptionId: providerSubscriptionId,
            receipt: receipt
        )
        
        let body = try JSONEncoder().encode(request)
        let bodyDict = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        
        let _: CreateSubscriptionResponse = try await apiService.makeRequest(
            endpoint: "subscriptions/create",
            method: "POST",
            body: bodyDict,
            token: token
        )
        
        // Refresh subscription status
        await fetchSubscriptionStatus()
    }
    
    func cancelSubscription() async throws {
        guard let token = authManager?.token else {
            throw NSError(domain: "SubscriptionService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let _: [String: String] = try await apiService.makeRequest(
            endpoint: "subscriptions/cancel",
            method: "POST",
            token: token
        )
        
        // Refresh subscription status
        await fetchSubscriptionStatus()
    }
    
    // MARK: - StoreKit Methods (Placeholder - needs full StoreKit implementation)
    
    func purchaseProMonthly() async throws {
        // TODO: Implement StoreKit 2 purchase flow
        // This is a placeholder - actual implementation requires:
        // 1. Product IDs configured in App Store Connect
        // 2. StoreKit 2 transaction handling
        // 3. Receipt validation
        
        throw NSError(domain: "SubscriptionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "StoreKit integration not yet implemented"])
    }
    
    func purchaseProAnnual() async throws {
        // TODO: Implement StoreKit 2 purchase flow
        throw NSError(domain: "SubscriptionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "StoreKit integration not yet implemented"])
    }
}

