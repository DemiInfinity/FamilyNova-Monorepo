package com.example.familynovaparent.fragments;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import androidx.fragment.app.Fragment;
import com.example.familynovaparent.MainActivity;
import com.example.familynovaparent.R;

public class SettingsFragment extends Fragment {
    
    private Button subscriptionButton;
    private Button logoutButton;
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_settings, container, false);
        
        subscriptionButton = view.findViewById(R.id.subscriptionButton);
        logoutButton = view.findViewById(R.id.logoutButton);
        
        subscriptionButton.setOnClickListener(v -> {
            // Navigate to subscription fragment
            if (getActivity() instanceof MainActivity) {
                MainActivity activity = (MainActivity) getActivity();
                activity.replaceFragment(new SubscriptionFragment());
            }
        });
        
        logoutButton.setOnClickListener(v -> {
            SharedPreferences prefs = requireActivity().getSharedPreferences("FamilyNovaParent", 0);
            prefs.edit().clear().apply();
            // TODO: Navigate to login activity
        });
        
        return view;
    }
}
