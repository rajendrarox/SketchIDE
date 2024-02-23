package com.rajendra.sketchide.activities;

import android.os.Bundle;
import android.view.Menu;

import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.widget.Toolbar;

import com.rajendra.sketchide.R;
import com.rajendra.sketchide.databinding.ActivityEditorBinding;

public class EditorActivity extends BaseActivity {

    private ActivityEditorBinding binding;
    Toolbar toolbar;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityEditorBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        toolbar = binding.toolbar; // Initialize the toolbar

        setSupportActionBar(toolbar);
        getSupportActionBar().setSubtitle("01");

        ActionBarDrawerToggle actionBarDrawerToggle = new ActionBarDrawerToggle(this, binding.drawerLayoutView, binding.toolbar, R.string.app_name, R.string.app_name);
        binding.drawerLayoutView.addDrawerListener(actionBarDrawerToggle);
        actionBarDrawerToggle.syncState();

    // Set item selected listener for navigation view
        binding.navigationViews.setNavigationItemSelectedListener(menuItem -> {
        // Handle menu item selected
        // Your existing code here...
        return true;
    });


}


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_editor_item, menu);
        return true;
    }
}
