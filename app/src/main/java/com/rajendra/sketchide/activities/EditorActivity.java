package com.rajendra.sketchide.activities;

import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.ContextCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.material.navigation.NavigationView;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.rajendra.sketchide.R;
import com.rajendra.sketchide.adapters.ViewPagerEditorAdapter;
import com.rajendra.sketchide.databinding.ActivityEditorBinding;

public class EditorActivity extends BaseActivity {
    private ViewPagerEditorAdapter adapter;
    private NavigationView navigationView;
    private TabLayout tabLayout; // Declare TabLayout variable
    private ActionBarDrawerToggle actionBarDrawerToggle;
    private DrawerLayout drawerLayout;
    private ViewPager2 viewPager2; // Declare ViewPager2 variable

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ActivityEditorBinding binding = ActivityEditorBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        Toolbar toolbar = binding.toolbar;
        setSupportActionBar(toolbar);
// Initialize adapter
        adapter = new ViewPagerEditorAdapter(this);
        viewPager2 = binding.viewPager;
        navigationView = binding.navigationViews;
        tabLayout = binding.tabLayout; // Initialize TabLayout variable
        drawerLayout = binding.drawerLayoutView;

        adapter = new ViewPagerEditorAdapter(this); // Initialize adapter
        viewPager2.setAdapter(adapter); // Set adapter to ViewPager2

        new TabLayoutMediator(tabLayout, viewPager2,
                (tab, position) -> tab.setText(adapter.getTabTitle(position))
        ).attach();
        // Register a ViewPager2.OnPageChangeCallback to listen for page changes
        viewPager2.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                super.onPageSelected(position);
                invalidateOptionsMenu(); // Force recreation of options menu
            }
        });


        // Customize ActionBarDrawerToggle and set custom toggle icon
        actionBarDrawerToggle = new ActionBarDrawerToggle(this, drawerLayout, toolbar, R.string.app_name, R.string.app_name);
        actionBarDrawerToggle.setDrawerIndicatorEnabled(false); // Disable default hamburger icon
        actionBarDrawerToggle.setHomeAsUpIndicator(ContextCompat.getDrawable(this, R.drawable.drag_indicator)); // Set custom icon
        actionBarDrawerToggle.setToolbarNavigationClickListener(view -> {
            // Handle toggle icon click to open/close drawer
            if (drawerLayout.isDrawerOpen(navigationView)) {
                drawerLayout.closeDrawer(navigationView);
            } else {
                drawerLayout.openDrawer(navigationView);
            }
        });
        actionBarDrawerToggle.syncState();
        drawerLayout.addDrawerListener(actionBarDrawerToggle);

        navigationView.setNavigationItemSelectedListener(menuItem -> {
            // Handle menu item selected
            // Your existing code here...
            return true;
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_editor_item, menu);
        MenuItem undoItem = menu.findItem(R.id.undo);
        MenuItem redoItem = menu.findItem(R.id.redo);

        // Get the current fragment position from the ViewPager
        int currentFragmentPosition = viewPager2.getCurrentItem();

        // Use ViewPagerEditorAdapter to determine whether to show Undo and Redo menu items
        boolean shouldShowUndoRedoMenu = adapter.shouldShowUndoRedoMenu(currentFragmentPosition);

        // Set the visibility of Undo and Redo menu items based on the condition
        undoItem.setVisible(shouldShowUndoRedoMenu);
        redoItem.setVisible(shouldShowUndoRedoMenu);

        return true;
    }
    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        // Handle other menu items
        if (actionBarDrawerToggle.onOptionsItemSelected(item)) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
