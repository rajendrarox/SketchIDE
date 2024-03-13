package com.rajendra.sketchide.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.rajendra.sketchide.R;
import com.rajendra.sketchide.activities.MainActivity;
import com.rajendra.sketchide.adapters.MyProjectsAdapter;
import com.rajendra.sketchide.databinding.DialogMyprojectBinding;
import com.rajendra.sketchide.managers.SourceManager;
import com.rajendra.sketchide.models.ProjectModel;
import com.rajendra.sketchide.utils.StorageUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class MyProjectsFragment extends Fragment {
  // Array to store ProjectModel objects
  private final List<ProjectModel> arrProjectModel = new ArrayList<>();
  private MyProjectsAdapter adapter;

  public MyProjectsFragment() {
    // Required empty public constructor
  }

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
  }

  @Override
  public View onCreateView(LayoutInflater inflater, ViewGroup container,
                           Bundle savedInstanceState) {
    // Inflate the layout for this fragment
    View view = inflater.inflate(R.layout.activity_myprojects, container, false); // Corrected layout resource name

    RecyclerView recyclerView = view.findViewById(R.id.projects_recycler_view);

    // Layout manager is used to show recyclerview in a linear layout
    recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));

    // Adding dummy data to the ArrayList
//        arrProjectModel.add(getDummyData(1, "My"));

    // Creating adapter and setting it to the RecyclerView
    arrProjectModel.addAll(StorageUtils.getProjectsInfo(getContext()));
    adapter = new MyProjectsAdapter(getActivity(), arrProjectModel);
    recyclerView.setAdapter(adapter);

    // Access MainActivity to get create_project FloatingActionButton
    MainActivity mainActivity = (MainActivity) requireActivity();
    // Corrected variable name
    FloatingActionButton createNewProjectFloatingBtn = mainActivity.getCreateProjectFloatingBtn(); // Corrected variable assignment

    // Floating Button Action
    createNewProjectFloatingBtn.setOnClickListener(v -> {
      var dialog = new MaterialAlertDialogBuilder(requireContext());
      var dBinding = DialogMyprojectBinding.inflate(dialog.create().getLayoutInflater());

      dialog.setView(dBinding.getRoot());
      dialog.setPositiveButton("Okay", (d, w) -> {
        String appName = dBinding.edittextAppName.getText().toString().trim();
        if (!appName.isEmpty()) {
          // Calculate the next projectId
          int nextProjectId = arrProjectModel.size() + 1;

          // Add items in RecyclerView
          arrProjectModel.add(0, getNewProject(nextProjectId, appName));
          adapter.notifyItemInserted(0);
          recyclerView.scrollToPosition(0);
        } else {
          Toast.makeText(requireContext(), "Please Enter App Name", Toast.LENGTH_SHORT).show();
        }
        d.dismiss();
      });

      dialog.setNegativeButton("Cancel", (d, w) -> {
        Toast.makeText(requireContext(), "Cancelled", Toast.LENGTH_SHORT).show();
        d.dismiss();
      });

      dialog.show();
    });

    return view;
  }

  // Method to add dummy data to the ArrayList

  /**
   * Template for a new project
   *
   * @param projectId
   * @param prefix
   */
  private ProjectModel getNewProject(int projectId, String prefix) {
    // Add more dummy data as needed
    prefix = prefix.trim();
    String id = String.valueOf(projectId);

    String path = String.format("%2$s%1$s%3$s", File.separator, SourceManager.DIR_PROJECTS_INFO, id);
    StorageUtils.makeDirs(requireContext(), path);

    String pathToIcon = String.format("%2$s%1$s%3$s", File.separator, path, SourceManager.FILE_ICON);
    ProjectModel projectModel = new ProjectModel(pathToIcon, prefix + " App", prefix.replaceAll("\\s+", "_") + "_App", "com." + prefix.toLowerCase().replaceAll("\\s+", ".") + ".app", "0.1", id);
    SourceManager.initProject(requireContext(), projectModel);
    return projectModel;
  }
}