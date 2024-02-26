package com.rajendra.sketchide.activities;

import android.annotation.SuppressLint;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.Menu;
import android.view.MenuItem;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.widget.Toolbar;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.rajendra.sketchide.R;
import com.rajendra.sketchide.adapters.PaletteListAdapter;
import com.rajendra.sketchide.adapters.ViewPagerEditorAdapter;
import com.rajendra.sketchide.databinding.ActivityEditorBinding;
import com.rajendra.sketchide.managers.ProjectManager;
import com.rajendra.sketchide.managers.UndoRedoManager;
import com.rajendra.sketchide.utils.Constants;

public class EditorActivity extends BaseActivity {
  private ViewPagerEditorAdapter adapter;
  private ActionBarDrawerToggle actionBarDrawerToggle;
  private ViewPager2 viewPager2; // Declare ViewPager2 variable

  private ActivityEditorBinding binding;

  private ProjectManager projectManager;

  private UndoRedoManager undoRedoManager;

  private final Runnable updateUndoRedoState = () -> undoRedoManager.updateButtons();

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    binding = ActivityEditorBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());

    Toolbar toolbar = binding.toolbar;
    setSupportActionBar(toolbar);

    // Initialize adapter
    adapter = new ViewPagerEditorAdapter(this);
    viewPager2 = binding.viewPager;
    // Declare TabLayout variable
    TabLayout tabLayout = binding.tabLayout; // Initialize TabLayout variable
    DrawerLayout drawerLayout = binding.drawerLayoutView;

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

    actionBarDrawerToggle = new ActionBarDrawerToggle(this, drawerLayout, toolbar, R.string.app_name, R.string.app_name);
    drawerLayout.addDrawerListener(actionBarDrawerToggle);
    actionBarDrawerToggle.syncState();

    tabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
      @Override
      public void onTabSelected(TabLayout.Tab tab) {
        if (undoRedoManager != null) {
          undoRedoManager.updateButtons();
        }
      }

      @Override
      public void onTabUnselected(TabLayout.Tab tab) {
        if (undoRedoManager != null) {
          undoRedoManager.updateButtons();
        }
      }

      @Override
      public void onTabReselected(TabLayout.Tab tab) {
        if (undoRedoManager != null) {
          undoRedoManager.updateButtons();
        }
      }
    });

    projectManager = ProjectManager.getInstance();

    setupDrawerNavigationRail();
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

    undoRedoManager = new UndoRedoManager(undoItem, redoItem);

    return true;
  }

  @Override
  protected void onPostCreate(@Nullable Bundle savedInstanceState) {
    super.onPostCreate(savedInstanceState);
    actionBarDrawerToggle.syncState();
    if (undoRedoManager != null) {
      undoRedoManager.updateButtons();
    }
  }

  @Override
  public void onConfigurationChanged(@NonNull Configuration newConfig) {
    super.onConfigurationChanged(newConfig);
    actionBarDrawerToggle.onConfigurationChanged(newConfig);
    if (undoRedoManager != null) {
      undoRedoManager.updateButtons();
    }
  }

  @Override
  protected void onResume() {
    super.onResume();
    if (undoRedoManager != null) {
      undoRedoManager.updateButtons();
    }
  }

  @Override
  public boolean onOptionsItemSelected(@NonNull MenuItem item) {
    // Handle other menu items
    if (actionBarDrawerToggle.onOptionsItemSelected(item)) {
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    binding = null;
  }

  @SuppressLint("SetTextI18n")
  public void setupDrawerNavigationRail() {
    var paletteMenu = binding.paletteNavigation.getMenu();
    paletteMenu.add(Menu.NONE, 0, Menu.NONE, Constants.TAB_TITLE_COMMON).setIcon(R.drawable.ic_android);
    paletteMenu.add(Menu.NONE, 1, Menu.NONE, Constants.TAB_TITLE_TEXT).setIcon(R.mipmap.ic_palette_text_view);
    paletteMenu.add(Menu.NONE, 2, Menu.NONE, Constants.TAB_TITLE_BUTTONS).setIcon(R.mipmap.ic_palette_button);
    paletteMenu.add(Menu.NONE, 3, Menu.NONE, Constants.TAB_TITLE_WIDGETS).setIcon(R.mipmap.ic_palette_view);
    paletteMenu.add(Menu.NONE, 4, Menu.NONE, Constants.TAB_TITLE_LAYOUTS).setIcon(R.mipmap.ic_palette_relative_layout);
    paletteMenu.add(Menu.NONE, 5, Menu.NONE, Constants.TAB_TITLE_CONTAINERS).setIcon(R.mipmap.ic_palette_view_pager);
    paletteMenu.add(Menu.NONE, 6, Menu.NONE, Constants.TAB_TITLE_LEGACY).setIcon(R.mipmap.ic_palette_grid_layout);

    binding.listView.setLayoutManager(new LinearLayoutManager(this, RecyclerView.VERTICAL, false));

    var adapter = new PaletteListAdapter(binding.drawerLayoutView);
    adapter.submitPaletteList(projectManager.getPalette(0));

    binding.paletteNavigation.setOnItemSelectedListener(item -> {
//      adapter.submitPaletteList(projectManager.getPalette(item.getItemId()));
      binding.paletteText.setText("Palette");
      binding.title.setText(item.getTitle());
      return true;
    });

    binding.listView.setAdapter(adapter);
  }

  public void updateUndoRedoState() {
    new Handler(Looper.getMainLooper()).postDelayed(updateUndoRedoState, 50);
  }

  public UndoRedoManager getUndoRedoManager() {
    return undoRedoManager;
  }
}
