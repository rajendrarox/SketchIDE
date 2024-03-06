package com.rajendra.sketchide.fragments;

import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.rajendra.sketchide.R;
import com.rajendra.sketchide.activities.ProjectModel;
import com.rajendra.sketchide.adapters.EventLogicAdapter;
import com.rajendra.sketchide.adapters.MyProjectsAdapter;
import com.rajendra.sketchide.models.LogicModel;

import java.util.ArrayList;

public class LogicFragmentActivity extends Fragment {

    private final ArrayList<LogicModel> arrLogicModel = new ArrayList<>();
    private EventLogicAdapter adapter;

    public LogicFragmentActivity() {
        // Required empty public constructor
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {

        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_logic_activity, container, false); // Corrected layout resource name

        RecyclerView recyclerView = view.findViewById(R.id.list);

        // Layout manager is used to show recyclerview in a linear layout
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));

        // Adding dummy data to the ArrayList fot test
        addDummyData();

        // Creating adapter and setting it to the RecyclerView
        adapter = new EventLogicAdapter(getActivity(), arrLogicModel);
        recyclerView.setAdapter(adapter);

        return view;
    }

    private void addDummyData() {
        // Add more dummy data as needed
        arrLogicModel.add(new LogicModel("onCreate","On activity create"));
        arrLogicModel.add(new LogicModel("onBackPressed","on back button press"));
        arrLogicModel.add(new LogicModel("onPostCreate","On activity start-up complete"));
        arrLogicModel.add(new LogicModel("onStart","On activity becoming visible"));
        arrLogicModel.add(new LogicModel("onResume","On activity resume"));
        arrLogicModel.add(new LogicModel("onStop","On activity no longer visible"));
    }
}