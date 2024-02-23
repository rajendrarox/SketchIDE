package com.rajendra.sketchide.activities;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.Fragment;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.rajendra.sketchide.R;
import com.rajendra.sketchide.databinding.ActivityMainBinding;

public class MainActivity extends AppCompatActivity {

    private FloatingActionButton createProjectFloatingBtn;
    private ActivityMainBinding binding;
    private Toolbar toolbar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        // Initialize the toolbar
        toolbar = binding.toolbar;
        setSupportActionBar(toolbar);

        // Find and initialize the FloatingActionButton
        createProjectFloatingBtn = findViewById(R.id.create_new_project);

        // Set click listener for the navigation icon
        binding.toolbar.setNavigationOnClickListener(v -> binding.drawerLayout.open());

        // Set item selected listener for navigation view
        binding.navigationView.setNavigationItemSelectedListener(menuItem -> {
            // Handle menu item selected
            // Your existing code here...
            return true;
        });

        // MyProjectFragment Call
        Fragment fragment = getSupportFragmentManager().findFragmentById(androidx.fragment.R.id.fragment_container_view_tag);
    }

    // Method to return the FloatingActionButton instance
    public FloatingActionButton getCreateProjectFloatingBtn() {
        return createProjectFloatingBtn;
    }

    // Inflate the options menu
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_items, menu);
        return true;
    }

    // Handle options menu item selection
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        // Handle menu item clicks
        if (id == R.id.search_bar) {
            // Handle search bar click
            Toast.makeText(this, "Search clicked", Toast.LENGTH_SHORT).show();
            // Add your desired search functionality here
            return true;
        } else if (id == R.id.menu) {
            // Handle menu click
            Toast.makeText(this, "Sort clicked", Toast.LENGTH_SHORT).show();
            // Add your desired sorting functionality here
            return true;
        } else if (id == R.id.create_project) {
            // Handle create project click
            Toast.makeText(this, "Create project clicked", Toast.LENGTH_SHORT).show();
            // Add your desired project creation functionality here
            return true;
        } else if (id == R.id.contribute) {
            // Handle contribute click
            String url = "https://github.com/androidbulb/SketchIDE/tree/Design";
            Intent intentContribute = new Intent(Intent.ACTION_VIEW);
            intentContribute.setData(Uri.parse(url));
            startActivity(intentContribute);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
