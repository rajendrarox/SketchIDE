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
                Toast.makeText(MainActivity.this, "Drawer Clicked", Toast.LENGTH_SHORT).show();
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
// Home OptionMenu
    public boolean onCreateOptionsMenu(Menu arg0) {
        super.onCreateOptionsMenu(arg0);
        getMenuInflater().inflate(R.menu.menu_items, arg0);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

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
            String url = "https://github.com/androidbulb/SketchIDE/tree/Design";
            Intent intentContribute = new Intent(Intent.ACTION_VIEW);
            intentContribute.setData(Uri.parse(url));
            startActivity(intentContribute);
            return true;

        } else {
            return super.onOptionsItemSelected(item);
        }
    }
}