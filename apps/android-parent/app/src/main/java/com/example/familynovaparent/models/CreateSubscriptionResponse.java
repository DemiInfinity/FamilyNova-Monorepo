package com.example.familynovaparent.models;

import com.google.gson.annotations.SerializedName;

public class CreateSubscriptionResponse {
    @SerializedName("message")
    private String message;
    
    @SerializedName("subscription")
    private Subscription subscription;
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public Subscription getSubscription() { return subscription; }
    public void setSubscription(Subscription subscription) { this.subscription = subscription; }
}

