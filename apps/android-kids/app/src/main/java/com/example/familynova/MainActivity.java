package com.example.familynova;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.example.familynova.fragments.HomeFragment;
import com.example.familynova.fragments.FriendsFragment;
import com.example.familynova.fragments.MessagesFragment;
import com.example.familynova.fragments.ProfileFragment;

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
            if (itemId == R.id.nav_home) {
                selectedFragment = new HomeFragment();
            } else if (itemId == R.id.nav_friends) {
                selectedFragment = new FriendsFragment();
            } else if (itemId == R.id.nav_messages) {
                selectedFragment = new MessagesFragment();
            } else if (itemId == R.id.nav_profile) {
                selectedFragment = new ProfileFragment();
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
            bottomNavigation.setSelectedItemId(R.id.nav_home);
        }
    }
}
