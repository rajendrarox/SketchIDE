package com.rajendra.sketchide;

import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.rajendra.sketchide.activities.ProjectModel;
import com.rajendra.sketchide.adapters.MyProjectsAdapter;

import java.util.ArrayList;

public class MyProjectsFragment extends Fragment {
    // Array to store ProjectModel objects
    private final ArrayList<ProjectModel> arrProjectModel = new ArrayList<>();

    public MyProjectsFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            // Handle any arguments here if needed
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.activity_myprojects, container, false);

        RecyclerView recyclerView = view.findViewById(R.id.projects_recycler_view);

        // Layout manager is used to show recyclerview in a linear layout
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));

        // Adding dummy data to the ArrayList
        addDummyData();

        // Creating adapter and setting it to the RecyclerView
        MyProjectsAdapter adapter = new MyProjectsAdapter(getContext(), arrProjectModel);
        recyclerView.setAdapter(adapter);

        return view;
    }

    // Method to add dummy data to the ArrayList
    private void addDummyData() {
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "My App", "My_App", "com.myapp", "0.1", "01"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project", "com.demo.project", "0.1", "02"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo App", "Demo_App", "com.demo.App", "1.1", "03"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Circle App", "CircleApp", "com.demo.Circle", "0.1", "04"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Test App", "Test_App", "com.test.com", "0.2", "05"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Book App", "Book_App", "com.demo.project", "0.1", "06"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "SketchIDE App", "SketchIDE", "com.sketchide", "1.1", "07"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "My App", "My_App", "com.myapp", "0.1", "01"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project", "com.demo.project", "0.1", "02"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo App", "Demo_App", "com.demo.App", "1.1", "03"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Circle App", "CircleApp", "com.demo.Circle", "0.1", "04"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Test App", "Test_App", "com.test.com", "0.2", "05"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Book App", "Book_App", "com.demo.project", "0.1", "06"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "SketchIDE App", "SketchIDE", "com.sketchide", "1.1", "07"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "My App", "My_App", "com.myapp", "0.1", "01"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project", "com.demo.project", "0.1", "02"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo App", "Demo_App", "com.demo.App", "1.1", "03"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Circle App", "CircleApp", "com.demo.Circle", "0.1", "04"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Test App", "Test_App", "com.test.com", "0.2", "05"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Book App", "Book_App", "com.demo.project", "0.1", "06"));
        arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "SketchIDE App", "SketchIDE", "com.sketchide", "1.1", "07"));

        // Add more dummy data as needed
    }
}
