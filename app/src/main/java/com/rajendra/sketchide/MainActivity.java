package com.rajendra.sketchide;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.rajendra.sketchide.databinding.ActivityMainBinding;
import com.rajendra.sketchide.ui.activities.InformationActivity;

public class MainActivity extends AppCompatActivity {

    private ActivityMainBinding binding;

    Toolbar toolbar;
    MenuItem lastCheckedItem; // Keep track of the last checked item

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        toolbar = binding.toolbar; // Initialize the toolbar

        setSupportActionBar(toolbar);

        // Set click listener for the navigation icon
        binding.toolbar.setNavigationOnClickListener(v -> binding.drawerLayout.open());



        // Set item selected listener for navigation view
        binding.navigationView.setNavigationItemSelectedListener(menuItem -> {
            // Handle menu item selected
            if (lastCheckedItem != null) {
                lastCheckedItem.setChecked(true);
            }

            // Check the current item
            menuItem.setChecked(true);
            lastCheckedItem = menuItem;

            //Drawer Item Click Action

            int ItemId = menuItem.getItemId();

            if (ItemId == R.id.drawer_about) {
                // Define the URL of the external link
                String url = "https://github.com/androidbulb/SketchIDE/tree/Design"; // Replace this with your desired URL
                // Create an intent with ACTION_VIEW action and the URL data
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(url));
                // Start the activity
                startActivity(intent);
            }
            if (ItemId == R.id.drawer_settings) {
                Toast.makeText(MainActivity.this, "Settings Clicked", Toast.LENGTH_SHORT).show();
            }
            if (ItemId == R.id.drawer_information) {
                Intent ideInformationIntent = new Intent(MainActivity.this, InformationActivity.class);
                startActivity(ideInformationIntent);
            }
            if (ItemId == R.id.drawer_tools) {
                Toast.makeText(MainActivity.this, "Tools Clicked", Toast.LENGTH_SHORT).show();
            }
            if (ItemId == R.id.drawer_sign) {
                Toast.makeText(MainActivity.this, "Sign Clicked", Toast.LENGTH_SHORT).show();
            }

            binding.drawerLayout.close();
            return true;
        });
    }

    public boolean onCreateOptionsMenu(Menu arg0) {
        super.onCreateOptionsMenu(arg0);
        getMenuInflater().inflate(R.menu.menu_items, arg0);
        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem arg0) {
        if (arg0.getItemId() == R.id.create_project) {
            // Display a toast message
            Toast.makeText(this, "Create Project Clicked", Toast.LENGTH_SHORT).show();
            return true; // Indicate that the menu item selection has been handled
        }

        // If the selected menu item is not "Show Source Code", let the superclass handle it
        return super.onOptionsItemSelected(arg0);
    }


}
