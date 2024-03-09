package com.rajendra.sketchide.activities;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.Fragment;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.rajendra.sketchide.R;
import com.rajendra.sketchide.databinding.ActivityMainBinding;

import java.util.ArrayList;
import java.util.Arrays;

public class MainActivity extends BaseActivity {

    private ActivityMainBinding binding;

    Toolbar toolbar;
    FloatingActionButton createProjectFloatingBtn;

    private boolean minSdk29 = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q;
    private boolean read, write;
    private ArrayList<String> permissions = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        toolbar = binding.toolbar; // Initialize the toolbar

        setSupportActionBar(toolbar);

        ActionBarDrawerToggle actionBarDrawerToggle = new ActionBarDrawerToggle(this, binding.drawerLayout, binding.toolbar, R.string.app_name, R.string.app_name);
        binding.drawerLayout.addDrawerListener(actionBarDrawerToggle);
        actionBarDrawerToggle.syncState();

        // Find and initialize the FloatingActionButton
        createProjectFloatingBtn = findViewById(R.id.create_new_project);

        // Set item selected listener for navigation view
        binding.navigationView.setNavigationItemSelectedListener(menuItem -> {
            // Handle menu item selected
            // Your existing code here...
            return true;
        });

        requestOrUpdatePermissions();
    }

    public void requestOrUpdatePermissions() {
        read = checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED;
        write = minSdk29 || checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED;
        permissions = new ArrayList<>();
        if (!read) {
            permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE);
        }
        if (!write) {
            permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
        }
        if (!permissions.isEmpty()) {
            requestPermissions(permissions.toArray(new String[0]), 1000);
        } else {
            // MyProjectFragment Call
            Fragment fragment = getSupportFragmentManager().findFragmentById(androidx.fragment.R.id.fragment_container_view_tag);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 1000) {
            Log.e("PERMISSIONS", Arrays.toString(permissions) + " -- " + Arrays.toString(grantResults));
            int res = 0;
            for (int r : grantResults) res += r;
            if (res < 0) requestOrUpdatePermissions();
        }
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
