package com.example.familynova.fragments;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.fragment.app.Fragment;
import com.example.familynova.LoginActivity;
import com.example.familynova.R;
import com.google.android.material.button.MaterialButton;

public class ProfileFragment extends Fragment {
    
    private TextView displayName;
    private TextView email;
    private TextView school;
    private TextView grade;
    private TextView parentVerified;
    private TextView schoolVerified;
    private MaterialButton logoutButton;
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_profile, container, false);
        
        displayName = view.findViewById(R.id.displayName);
        email = view.findViewById(R.id.email);
        school = view.findViewById(R.id.school);
        grade = view.findViewById(R.id.grade);
        parentVerified = view.findViewById(R.id.parentVerified);
        schoolVerified = view.findViewById(R.id.schoolVerified);
        logoutButton = view.findViewById(R.id.logoutButton);
        
        // TODO: Load user data from API
        
        logoutButton.setOnClickListener(v -> {
            SharedPreferences prefs = requireActivity().getSharedPreferences("FamilyNova", 0);
            prefs.edit().clear().apply();
            startActivity(new Intent(getActivity(), LoginActivity.class));
            requireActivity().finish();
        });
        
        return view;
    }
}

