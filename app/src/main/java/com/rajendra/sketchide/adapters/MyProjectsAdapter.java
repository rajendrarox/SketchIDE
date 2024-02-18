package com.rajendra.sketchide.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.rajendra.sketchide.R;
import com.rajendra.sketchide.activities.ProjectModel;

import java.util.ArrayList;

public class MyProjectsAdapter extends RecyclerView.Adapter<MyProjectsAdapter.ViewHolder> {

    Context context;
    ArrayList<ProjectModel> arrProjectModel;

    public MyProjectsAdapter(Context context, ArrayList<ProjectModel> arrProjectModel){
        this.context = context;
        this.arrProjectModel = arrProjectModel;

    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {

        // add your created layout item design

       View v = LayoutInflater.from(context).inflate(R.layout.layout_myprojects_item, viewGroup, false);
       ViewHolder viewHolder = new ViewHolder(v);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder viewHolder, int i) {
        viewHolder.projectIcon.setImageResource(arrProjectModel.get(i).projectIcon);
        viewHolder.appName.setText(arrProjectModel.get(i).appName);
        viewHolder.projectName.setText(arrProjectModel.get(i).projectName);
        viewHolder.packageName.setText(arrProjectModel.get(i).packageName);
        viewHolder.projectVersion.setText(arrProjectModel.get(i).projectVersion);
        viewHolder.projectId.setText(arrProjectModel.get(i).projectId);


    }

    @Override
    public int getItemCount() {
        return arrProjectModel.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder{

        TextView appName,projectName,packageName,projectVersion,projectId;
        ImageView projectIcon;
        public  ViewHolder(View itemView){
            super(itemView);

            appName = itemView.findViewById(R.id.app_name);
            projectName = itemView.findViewById(R.id.project_name);
            packageName = itemView.findViewById(R.id.package_name);
            projectVersion = itemView.findViewById(R.id.project_version);
            projectId = itemView.findViewById(R.id.project_id);
            projectIcon = itemView.findViewById(R.id.project_icon);


        }
    }
}
