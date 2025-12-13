package com.example.familynovaparent;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.example.familynovaparent.fragments.DashboardFragment;
import com.example.familynovaparent.fragments.MonitoringFragment;
import com.example.familynovaparent.fragments.PostApprovalFragment;
import com.example.familynovaparent.fragments.HomeworkFragment;
import com.example.familynovaparent.fragments.ConnectionsFragment;
import com.example.familynovaparent.fragments.SettingsFragment;

public class MainActivity extends AppCompatActivity {
    
    private BottomNavigationView bottomNavigation;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        bottomNavigation = findViewById(R.id.bottomNavigation);
        bottomNavigation.setOnItemSelectedListener(item -> {
            Fragment selectedFragment = null;
            
            int itemId = item.getItemId();
            if (itemId == R.id.nav_dashboard) {
                selectedFragment = new DashboardFragment();
            } else if (itemId == R.id.nav_monitoring) {
                selectedFragment = new MonitoringFragment();
            } else if (itemId == R.id.nav_posts) {
                selectedFragment = new PostApprovalFragment();
            } else if (itemId == R.id.nav_homework) {
                selectedFragment = new HomeworkFragment();
            } else if (itemId == R.id.nav_connections) {
                selectedFragment = new ConnectionsFragment();
            } else if (itemId == R.id.nav_settings) {
                selectedFragment = new SettingsFragment();
            }
            
            if (selectedFragment != null) {
                getSupportFragmentManager().beginTransaction()
                    .replace(R.id.fragmentContainer, selectedFragment)
                    .commit();
                return true;
            }
            return false;
        });
        
        // Set default fragment
        if (savedInstanceState == null) {
            bottomNavigation.setSelectedItemId(R.id.nav_dashboard);
        }
    }
    
    // Helper method to replace fragment (used by SettingsFragment)
    public void replaceFragment(Fragment fragment) {
        getSupportFragmentManager().beginTransaction()
            .replace(R.id.fragmentContainer, fragment)
            .addToBackStack(null)
            .commit();
    }
}

