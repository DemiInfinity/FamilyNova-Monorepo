package com.example.familynovaparent.models;

import com.google.gson.annotations.SerializedName;

public class CreateSubscriptionRequest {
    @SerializedName("plan")
    private String plan;
    
    @SerializedName("billingCycle")
    private String billingCycle;
    
    @SerializedName("provider")
    private String provider;
    
    @SerializedName("providerSubscriptionId")
    private String providerSubscriptionId;
    
    @SerializedName("receipt")
    private String receipt;
    
    public CreateSubscriptionRequest(String plan, String billingCycle, String provider, String providerSubscriptionId, String receipt) {
        this.plan = plan;
        this.billingCycle = billingCycle;
        this.provider = provider;
        this.providerSubscriptionId = providerSubscriptionId;
        this.receipt = receipt;
    }
    
    // Getters
    public String getPlan() { return plan; }
    public String getBillingCycle() { return billingCycle; }
    public String getProvider() { return provider; }
    public String getProviderSubscriptionId() { return providerSubscriptionId; }
    public String getReceipt() { return receipt; }
}

