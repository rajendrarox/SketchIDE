package com.rajendra.sketchide;

import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.drawerlayout.widget.DrawerLayout;

import com.google.android.material.navigation.NavigationView;

public class MainActivity extends AppCompatActivity {

    DrawerLayout drawerLayout;
    Toolbar toolbar;
    NavigationView navigationView;
    MenuItem lastCheckedItem; // Keep track of the last checked item

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        drawerLayout = findViewById(R.id.drawer_layout);
        toolbar = findViewById(R.id.toolbar);
        navigationView = findViewById(R.id.navigation_view);

        // Set the toolbar as the action bar
        setSupportActionBar(toolbar);

        // Set click listener for the navigation icon
        toolbar.setNavigationOnClickListener(v -> drawerLayout.open());

        // Set item selected listener for navigation view
        navigationView.setNavigationItemSelectedListener(menuItem -> {
            // Handle menu item selected
            if (lastCheckedItem != null) {
                lastCheckedItem.setChecked(false);
            }

            // Check the current item
            menuItem.setChecked(true);
            lastCheckedItem = menuItem;

            //Drawer Item Click Action

            int ItemId = menuItem.getItemId();

            if (ItemId == R.id.drawer_about) {
                Toast.makeText(MainActivity.this, "Abuot Clicked", Toast.LENGTH_SHORT).show();
            }
            if (ItemId == R.id.drawer_settings) {
                Toast.makeText(MainActivity.this, "Settings Clicked", Toast.LENGTH_SHORT).show();
            }
            if (ItemId == R.id.drawer_information) {
                Toast.makeText(MainActivity.this, "Information Clicked", Toast.LENGTH_SHORT).show();
            }
            if (ItemId == R.id.drawer_tools) {
                Toast.makeText(MainActivity.this, "Tools Clicked", Toast.LENGTH_SHORT).show();
            }
            if (ItemId == R.id.drawer_sign) {
                Toast.makeText(MainActivity.this, "Sign Clicked", Toast.LENGTH_SHORT).show();
            }

            drawerLayout.close();
            return false;
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_items, menu);
        return true;
    }


}