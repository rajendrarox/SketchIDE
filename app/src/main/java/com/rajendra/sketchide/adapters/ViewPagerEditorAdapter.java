package com.rajendra.sketchide.adapters;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import com.rajendra.sketchide.fragments.ComponentFragment;
import com.rajendra.sketchide.fragments.LogicFragment;
import com.rajendra.sketchide.fragments.ViewFragment;

public class ViewPagerEditorAdapter extends FragmentStateAdapter {
    public ViewPagerEditorAdapter(@NonNull FragmentActivity fragmentActivity) {
        super(fragmentActivity);
    }

    @NonNull
    @Override
    public Fragment createFragment(int position) {
        if (position == 0) {
            return ViewFragment.newInstance();
        } else if (position == 1) {
            return new LogicFragment();
        } else {
            return new ComponentFragment();
        }
    }

    @Override
    public int getItemCount() {
        return 3; // Number of tabs
    }

    public String getTabTitle(int position) {
        if (position == 0) {
            return "View";
        } else if (position == 1) {
            return "Logic";
        } else {
            return "Component";
        }
    }
    // Method to determine whether to show Undo and Redo menu items
    public boolean shouldShowUndoRedoMenu(int position) {
        return position == 0; // Show only for the "View" fragment
    }
}