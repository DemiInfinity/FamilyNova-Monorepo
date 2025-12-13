//
//  Subscription.swift
//  FamilyNovaParent
//

import Foundation

struct Subscription: Codable {
    let plan: String // "free" or "pro"
    let status: String // "active", "cancelled", "expired", "trial"
    let billingCycle: String? // "monthly" or "annual"
    let startDate: String? // ISO date string
    let endDate: String? // ISO date string
    let nextBillingDate: String? // ISO date string
    let isTrial: Bool?
    let trialEndDate: String? // ISO date string
    
    // Computed properties to convert strings to Date
    var startDateAsDate: Date? {
        guard let startDate = startDate else { return nil }
        return ISO8601DateFormatter().date(from: startDate)
    }
    
    var endDateAsDate: Date? {
        guard let endDate = endDate else { return nil }
        return ISO8601DateFormatter().date(from: endDate)
    }
    
    var nextBillingDateAsDate: Date? {
        guard let nextBillingDate = nextBillingDate else { return nil }
        return ISO8601DateFormatter().date(from: nextBillingDate)
    }
    
    var trialEndDateAsDate: Date? {
        guard let trialEndDate = trialEndDate else { return nil }
        return ISO8601DateFormatter().date(from: trialEndDate)
    }
}

struct SubscriptionStatus: Codable {
    let subscription: Subscription
}

struct CreateSubscriptionRequest: Codable {
    let plan: String
    let billingCycle: String
    let provider: String
    let providerSubscriptionId: String
    let receipt: String
}

struct CreateSubscriptionResponse: Codable {
    let message: String
    let subscription: Subscription
}

