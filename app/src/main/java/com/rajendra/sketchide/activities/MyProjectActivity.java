package com.rajendra.sketchide.activities;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.rajendra.sketchide.R;
import com.rajendra.sketchide.adapters.MyProjectsAdapter;

import java.util.ArrayList;

public class MyProjectActivity extends AppCompatActivity {

    //Array get from ProjectModel

    ArrayList<ProjectModel> arrProjectModel = new ArrayList<>();

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_myprojects);
            RecyclerView recyclerView = findViewById(R.id.projects_recycler_view);


            // Layout manger is use to show recyclerview in linear you can set grid
            recyclerView.setLayoutManager(new LinearLayoutManager(this));



            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));
            arrProjectModel.add(new ProjectModel(R.drawable.android_icon, "Demo project", "Demo_Project","com.demo.project","0.1","01"));

            MyProjectsAdapter adapter = new MyProjectsAdapter(this,arrProjectModel);
            recyclerView.setAdapter(adapter);


}
}
