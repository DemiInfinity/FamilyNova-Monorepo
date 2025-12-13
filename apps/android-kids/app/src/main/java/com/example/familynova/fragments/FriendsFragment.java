package com.example.familynova.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.familynova.R;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;

public class FriendsFragment extends Fragment {
    
    private RecyclerView friendsRecyclerView;
    private TextInputEditText searchInput;
    private MaterialButton addFriendButton;
    private View emptyState;
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_friends, container, false);
        
        friendsRecyclerView = view.findViewById(R.id.friendsRecyclerView);
        searchInput = view.findViewById(R.id.searchInput);
        addFriendButton = view.findViewById(R.id.addFriendButton);
        emptyState = view.findViewById(R.id.emptyState);
        
        friendsRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        // TODO: Set adapter with friends data
        
        addFriendButton.setOnClickListener(v -> {
            // TODO: Implement add friend functionality
        });
        
        return view;
    }
}

