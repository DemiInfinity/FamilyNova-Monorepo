package com.example.familynova.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.familynova.R;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;

public class ChatActivity extends AppCompatActivity {
    
    private RecyclerView messagesRecyclerView;
    private TextInputEditText messageInput;
    private MaterialButton sendButton;
    private String friendId;
    private String friendName;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);
        
        friendId = getIntent().getStringExtra("friendId");
        friendName = getIntent().getStringExtra("friendName");
        
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(friendName != null ? friendName : "Chat");
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
        
        messagesRecyclerView = findViewById(R.id.messagesRecyclerView);
        messageInput = findViewById(R.id.messageInput);
        sendButton = findViewById(R.id.sendButton);
        
        messagesRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        
        sendButton.setOnClickListener(v -> {
            String message = messageInput.getText() != null ? messageInput.getText().toString().trim() : "";
            if (!message.isEmpty() && friendId != null) {
                // TODO: Send message via API
                // POST /api/messages with receiver: friendId
                messageInput.setText("");
            }
        });
        
        // TODO: Load messages for this conversation
    }
    
    @Override
    public boolean onSupportNavigateUp() {
        finish();
        return true;
    }
}

