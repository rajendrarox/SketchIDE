package com.rajendra.sketchide.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.rajendra.sketchide.activities.EditorActivity;
import com.rajendra.sketchide.databinding.FragmentViewBinding;

public class ViewFragment extends Fragment {

  private FragmentViewBinding binding;

  public ViewFragment() {
    // Required empty public constructor
  }

  @NonNull
  public static ViewFragment newInstance() {
    ViewFragment fragment = new ViewFragment();
    Bundle args = new Bundle();
    fragment.setArguments(args);
    return fragment;
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    if (requireActivity() instanceof EditorActivity activity) {
      binding.editor.setUndoRedoManager(activity.getUndoRedoManager());
      binding.editor.updateUndoRedoHistory();
      activity.updateUndoRedoState();
    }
  }

  @Override
  public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
    binding = FragmentViewBinding.inflate(inflater, container, false);
    return binding.getRoot();
  }
}