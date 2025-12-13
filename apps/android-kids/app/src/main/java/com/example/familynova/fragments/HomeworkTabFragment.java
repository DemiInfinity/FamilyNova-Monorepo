package com.example.familynova.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.example.familynova.R;
import java.util.ArrayList;
import java.util.List;

public class HomeworkTabFragment extends Fragment {
    
    private RecyclerView homeworkRecyclerView;
    private List<HomeworkItem> homeworkItems = new ArrayList<>();
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_homework_tab, container, false);
        
        homeworkRecyclerView = view.findViewById(R.id.homeworkRecyclerView);
        homeworkRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        
        // TODO: Set adapter and load homework
        
        return view;
    }
    
    public static class HomeworkItem {
        public String id;
        public String title;
        public String description;
        public String subject;
        public String dueDate;
        public String school;
        public boolean isCompleted;
    }
}

