package com.rajendra.sketchide;

import android.app.Dialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.rajendra.sketchide.activities.MainActivity;
import com.rajendra.sketchide.activities.ProjectModel;
import com.rajendra.sketchide.adapters.MyProjectsAdapter;

import java.util.ArrayList;
import java.util.Objects;

public class MyProjectsFragment extends Fragment {
    // Array to store ProjectModel objects
    private final ArrayList<ProjectModel> arrProjectModel = new ArrayList<>();
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
        addDummyData();

        // Creating adapter and setting it to the RecyclerView
        adapter = new MyProjectsAdapter(getContext(), arrProjectModel);
        recyclerView.setAdapter(adapter);

        // Access MainActivity to get create_project FloatingActionButton
        MainActivity mainActivity = (MainActivity) requireActivity();
        // Corrected variable name
        FloatingActionButton createNewProjectFloatingBtn = mainActivity.getCreateProjectFloatingBtn(); // Corrected variable assignment

        // Floating Button Action
        createNewProjectFloatingBtn.setOnClickListener(v -> {
            Dialog dialog = new Dialog(requireContext());
            dialog.setContentView(R.layout.myproject_dialog);
            EditText edittextAppName = dialog.findViewById(R.id.edittext_app_name);
            TextView dialogCancel = dialog.findViewById(R.id.dialog_cancel);
            TextView dialogOkay = dialog.findViewById(R.id.dialog_okay);
            dialogCancel.setOnClickListener(v1 -> {
                // Your code to handle button click goes here
                Toast.makeText(requireContext(), "Cancelled", Toast.LENGTH_SHORT).show();
                dialog.dismiss();
            });

            dialogOkay.setOnClickListener(v12 -> {
                // Your code to handle button click goes here
                String appName = edittextAppName.getText().toString();
                if (!appName.isEmpty()) {
                    // Calculate the next projectId
                    int nextProjectId = arrProjectModel.size() + 1;

                    // Add items in RecyclerView
                    arrProjectModel.add(0, new ProjectModel(R.drawable.android_icon, appName, "Demo_App", "com.demo.app", "0.1", String.valueOf(nextProjectId)));
                    adapter.notifyItemInserted(0);
                    recyclerView.scrollToPosition(0);
                } else {
                    Toast.makeText(requireContext(), "Please Enter App Name", Toast.LENGTH_SHORT).show();
                }
                dialog.dismiss();
            });

            // Dialog Size Match_Parent
            WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams();
            layoutParams.copyFrom(Objects.requireNonNull(dialog.getWindow()).getAttributes());
            layoutParams.width = WindowManager.LayoutParams.MATCH_PARENT;
            layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
            dialog.getWindow().setAttributes(layoutParams);

            dialog.show();
        });

        return view;
    }

    // Method to add dummy data to the ArrayList
    private void addDummyData() {
        // Add more dummy data as needed
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon,"My App","My_App","com.my.app", "0.1", "01"));
    }
}
