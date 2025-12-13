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

public class MessagesFragment extends Fragment {
    
    private RecyclerView messagesRecyclerView;
    private TextInputEditText messageInput;
    private MaterialButton sendButton;
    private View emptyState;
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_messages, container, false);
        
        messagesRecyclerView = view.findViewById(R.id.messagesRecyclerView);
        messageInput = view.findViewById(R.id.messageInput);
        sendButton = view.findViewById(R.id.sendButton);
        emptyState = view.findViewById(R.id.emptyState);
        
        messagesRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        // TODO: Set adapter with messages data
        
        sendButton.setOnClickListener(v -> {
            String message = messageInput.getText() != null ? messageInput.getText().toString().trim() : "";
            if (!message.isEmpty()) {
                // TODO: Send message via API
                messageInput.setText("");
            }
        });
        
        return view;
    }
}

