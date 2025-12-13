package com.example.familynova.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.fragment.app.Fragment;
import androidx.viewpager2.widget.ViewPager2;
import com.example.familynova.R;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;

public class EducationFragment extends Fragment {
    
    private TabLayout tabLayout;
    private ViewPager2 viewPager;
    private EducationPagerAdapter pagerAdapter;
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_education, container, false);
        
        tabLayout = view.findViewById(R.id.tabLayout);
        viewPager = view.findViewById(R.id.viewPager);
        
        setupViewPager();
        
        return view;
    }
    
    private void setupViewPager() {
        pagerAdapter = new EducationPagerAdapter(this);
        viewPager.setAdapter(pagerAdapter);
        
        new TabLayoutMediator(tabLayout, viewPager, (tab, position) -> {
            if (position == 0) {
                tab.setText("Learn");
            } else {
                tab.setText("Homework");
            }
        }).attach();
    }
    
    // Pager adapter inner class
    private static class EducationPagerAdapter extends androidx.viewpager2.adapter.FragmentStateAdapter {
        public EducationPagerAdapter(Fragment fragment) {
            super(fragment);
        }
        
        @Override
        public Fragment createFragment(int position) {
            if (position == 0) {
                return new LearnTabFragment();
            } else {
                return new HomeworkTabFragment();
            }
        }
        
        @Override
        public int getItemCount() {
            return 2;
        }
    }
}

