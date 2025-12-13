package com.example.familynovaparent.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.familynovaparent.R;

public class DashboardFragment extends Fragment {
    
    private RecyclerView childrenRecyclerView;
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_dashboard, container, false);
        
        childrenRecyclerView = view.findViewById(R.id.childrenRecyclerView);
        childrenRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        // TODO: Set adapter with children data
        
        return view;
    }
}

