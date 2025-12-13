package com.example.familynova.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.familynova.R;
import com.example.familynova.activities.ChatActivity;
import java.util.ArrayList;
import java.util.List;

public class MessagesFragment extends Fragment {
    
    private RecyclerView conversationsRecyclerView;
    private View emptyState;
    private List<Conversation> conversations = new ArrayList<>();
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_messages, container, false);
        
        conversationsRecyclerView = view.findViewById(R.id.conversationsRecyclerView);
        emptyState = view.findViewById(R.id.emptyState);
        
        setupRecyclerView();
        loadConversations();
        
        return view;
    }
    
    private void setupRecyclerView() {
        conversationsRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        // TODO: Set adapter with conversations
        // When conversation clicked, open ChatActivity with friend ID
    }
    
    private void loadConversations() {
        // TODO: Load conversations from API
        if (conversations.isEmpty()) {
            emptyState.setVisibility(View.VISIBLE);
            conversationsRecyclerView.setVisibility(View.GONE);
        } else {
            emptyState.setVisibility(View.GONE);
            conversationsRecyclerView.setVisibility(View.VISIBLE);
        }
    }
    
    private void openChat(String friendId, String friendName) {
        Intent intent = new Intent(getContext(), ChatActivity.class);
        intent.putExtra("friendId", friendId);
        intent.putExtra("friendName", friendName);
        startActivity(intent);
    }
    
    public static class Conversation {
        public String friendId;
        public String friendName;
        public String lastMessage;
        public String timestamp;
        public boolean hasUnread;
    }
}
