package com.example.familynovaparent.fragments;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.familynovaparent.R;
import com.example.familynovaparent.api.ApiClient;
import com.example.familynovaparent.api.SubscriptionApi;
import com.example.familynovaparent.models.Subscription;
import com.example.familynovaparent.models.SubscriptionStatus;
import com.google.android.material.card.MaterialCardView;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class SubscriptionFragment extends Fragment {
    
    private TextView currentPlanTitle;
    private TextView currentPlanStatus;
    private TextView currentPlanRenewal;
    private MaterialCardView currentPlanCard;
    private RecyclerView plansRecyclerView;
    private Button cancelButton;
    private Subscription currentSubscription;
    private SubscriptionApi subscriptionApi;
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_subscription, container, false);
        
        initializeViews(view);
        setupApi();
        loadSubscriptionStatus();
        
        return view;
    }
    
    private void initializeViews(View view) {
        currentPlanCard = view.findViewById(R.id.currentPlanCard);
        currentPlanTitle = view.findViewById(R.id.currentPlanTitle);
        currentPlanStatus = view.findViewById(R.id.currentPlanStatus);
        currentPlanRenewal = view.findViewById(R.id.currentPlanRenewal);
        plansRecyclerView = view.findViewById(R.id.plansRecyclerView);
        cancelButton = view.findViewById(R.id.cancelButton);
        
        plansRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        
        cancelButton.setOnClickListener(v -> {
            cancelSubscription();
        });
    }
    
    private void setupApi() {
        Context context = requireContext();
        subscriptionApi = ApiClient.getClient(context).create(SubscriptionApi.class);
    }
    
    private void loadSubscriptionStatus() {
        Call<SubscriptionStatus> call = subscriptionApi.getSubscriptionStatus();
        call.enqueue(new Callback<SubscriptionStatus>() {
            @Override
            public void onResponse(Call<SubscriptionStatus> call, Response<SubscriptionStatus> response) {
                if (response.isSuccessful() && response.body() != null) {
                    currentSubscription = response.body().getSubscription();
                    updateUI();
                    loadPlans();
                } else {
                    Toast.makeText(getContext(), "Failed to load subscription status", Toast.LENGTH_SHORT).show();
                }
            }
            
            @Override
            public void onFailure(Call<SubscriptionStatus> call, Throwable t) {
                Toast.makeText(getContext(), "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }
    
    private void updateUI() {
        if (currentSubscription == null) return;
        
        String planName = "free".equals(currentSubscription.getPlan()) ? "Free" : "Pro Family";
        currentPlanTitle.setText(planName);
        
        if ("active".equals(currentSubscription.getStatus())) {
            currentPlanStatus.setText("Active");
            currentPlanStatus.setTextColor(getResources().getColor(android.R.color.holo_green_dark, null));
        } else {
            currentPlanStatus.setText(currentSubscription.getStatus());
        }
        
        if (currentSubscription.getEndDate() != null && "pro".equals(currentSubscription.getPlan())) {
            SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy", Locale.getDefault());
            currentPlanRenewal.setText("Renews: " + sdf.format(currentSubscription.getEndDate()));
            currentPlanRenewal.setVisibility(View.VISIBLE);
        } else {
            currentPlanRenewal.setVisibility(View.GONE);
        }
        
        if ("pro".equals(currentSubscription.getPlan()) && "active".equals(currentSubscription.getStatus())) {
            cancelButton.setVisibility(View.VISIBLE);
        } else {
            cancelButton.setVisibility(View.GONE);
        }
    }
    
    private void loadPlans() {
        List<PlanItem> plans = new ArrayList<>();
        
        // Free Plan
        plans.add(new PlanItem(
            "Free",
            "£0",
            "month",
            null,
            new String[]{
                "1-2 child accounts",
                "Basic monitoring",
                "Standard features",
                "Community support"
            },
            "free".equals(currentSubscription != null ? currentSubscription.getPlan() : "free"),
            false,
            () -> {
                // Already on free plan
            }
        ));
        
        // Pro Monthly
        plans.add(new PlanItem(
            "Pro Family",
            "£9.99",
            "month",
            null,
            new String[]{
                "Unlimited child accounts",
                "Advanced monitoring & analytics",
                "Priority support",
                "Enhanced safety features",
                "Extended data retention",
                "Early access to new features"
            },
            "pro".equals(currentSubscription != null ? currentSubscription.getPlan() : null) && 
            "monthly".equals(currentSubscription != null ? currentSubscription.getBillingCycle() : null),
            true,
            () -> {
                purchaseProMonthly();
            }
        ));
        
        // Pro Annual
        plans.add(new PlanItem(
            "Pro Family",
            "£99",
            "year",
            "Save 17%",
            new String[]{
                "Unlimited child accounts",
                "Advanced monitoring & analytics",
                "Priority support",
                "Enhanced safety features",
                "Extended data retention",
                "Early access to new features",
                "Best value - Save £20/year"
            },
            "pro".equals(currentSubscription != null ? currentSubscription.getPlan() : null) && 
            "annual".equals(currentSubscription != null ? currentSubscription.getBillingCycle() : null),
            false,
            () -> {
                purchaseProAnnual();
            }
        ));
        
        // TODO: Set adapter with plans
        // plansRecyclerView.setAdapter(new PlansAdapter(plans));
    }
    
    private void purchaseProMonthly() {
        // TODO: Implement Google Play Billing purchase flow
        Toast.makeText(getContext(), "Google Play Billing integration coming soon", Toast.LENGTH_SHORT).show();
    }
    
    private void purchaseProAnnual() {
        // TODO: Implement Google Play Billing purchase flow
        Toast.makeText(getContext(), "Google Play Billing integration coming soon", Toast.LENGTH_SHORT).show();
    }
    
    private void cancelSubscription() {
        Call<com.example.familynovaparent.models.CreateSubscriptionResponse> call = subscriptionApi.cancelSubscription();
        call.enqueue(new Callback<com.example.familynovaparent.models.CreateSubscriptionResponse>() {
            @Override
            public void onResponse(Call<com.example.familynovaparent.models.CreateSubscriptionResponse> call, Response<com.example.familynovaparent.models.CreateSubscriptionResponse> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(getContext(), "Subscription cancelled", Toast.LENGTH_SHORT).show();
                    loadSubscriptionStatus();
                } else {
                    Toast.makeText(getContext(), "Failed to cancel subscription", Toast.LENGTH_SHORT).show();
                }
            }
            
            @Override
            public void onFailure(Call<com.example.familynovaparent.models.CreateSubscriptionResponse> call, Throwable t) {
                Toast.makeText(getContext(), "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }
    
    // Plan item model
    public static class PlanItem {
        public String title;
        public String price;
        public String period;
        public String subtitle;
        public String[] features;
        public boolean isSelected;
        public boolean isPopular;
        public Runnable action;
        
        public PlanItem(String title, String price, String period, String subtitle, String[] features, boolean isSelected, boolean isPopular, Runnable action) {
            this.title = title;
            this.price = price;
            this.period = period;
            this.subtitle = subtitle;
            this.features = features;
            this.isSelected = isSelected;
            this.isPopular = isPopular;
            this.action = action;
        }
    }
}

