package com.example.familynovaparent.api;

import com.example.familynovaparent.models.Subscription;
import com.example.familynovaparent.models.SubscriptionStatus;
import com.example.familynovaparent.models.CreateSubscriptionRequest;
import com.example.familynovaparent.models.CreateSubscriptionResponse;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;

public interface SubscriptionApi {
    @GET("subscriptions/status")
    Call<SubscriptionStatus> getSubscriptionStatus();
    
    @POST("subscriptions/create")
    Call<CreateSubscriptionResponse> createSubscription(@Body CreateSubscriptionRequest request);
    
    @POST("subscriptions/cancel")
    Call<CreateSubscriptionResponse> cancelSubscription();
}

