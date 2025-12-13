package com.example.familynovaparent.models;

import com.google.gson.annotations.SerializedName;
import java.util.Date;

public class Subscription {
    @SerializedName("plan")
    private String plan; // "free" or "pro"
    
    @SerializedName("status")
    private String status; // "active", "cancelled", "expired", "trial"
    
    @SerializedName("billingCycle")
    private String billingCycle; // "monthly" or "annual"
    
    @SerializedName("startDate")
    private Date startDate;
    
    @SerializedName("endDate")
    private Date endDate;
    
    @SerializedName("nextBillingDate")
    private Date nextBillingDate;
    
    @SerializedName("isTrial")
    private Boolean isTrial;
    
    @SerializedName("trialEndDate")
    private Date trialEndDate;
    
    // Getters and setters
    public String getPlan() { return plan; }
    public void setPlan(String plan) { this.plan = plan; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getBillingCycle() { return billingCycle; }
    public void setBillingCycle(String billingCycle) { this.billingCycle = billingCycle; }
    
    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }
    
    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }
    
    public Date getNextBillingDate() { return nextBillingDate; }
    public void setNextBillingDate(Date nextBillingDate) { this.nextBillingDate = nextBillingDate; }
    
    public Boolean getIsTrial() { return isTrial; }
    public void setIsTrial(Boolean isTrial) { this.isTrial = isTrial; }
    
    public Date getTrialEndDate() { return trialEndDate; }
    public void setTrialEndDate(Date trialEndDate) { this.trialEndDate = trialEndDate; }
}

