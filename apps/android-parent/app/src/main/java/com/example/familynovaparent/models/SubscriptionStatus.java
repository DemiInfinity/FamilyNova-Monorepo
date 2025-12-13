package com.example.familynovaparent.models;

import com.google.gson.annotations.SerializedName;

public class SubscriptionStatus {
    @SerializedName("subscription")
    private Subscription subscription;
    
    public Subscription getSubscription() { return subscription; }
    public void setSubscription(Subscription subscription) { this.subscription = subscription; }
}

