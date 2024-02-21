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

    private final Context context;
    private final ArrayList<ProjectModel> arrProjectModel;

    public MyProjectsAdapter(Context context, ArrayList<ProjectModel> arrProjectModel) {
        this.context = context;
        this.arrProjectModel = arrProjectModel;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_myprojects_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ProjectModel project = arrProjectModel.get(position);
        holder.projectIcon.setImageResource(project.projectIcon);
        holder.appName.setText(project.appName);
        holder.projectName.setText(project.projectName);
        holder.packageName.setText(project.packageName);
        holder.projectVersion.setText(String.valueOf(project.projectVersion));
        holder.projectId.setText(String.valueOf(project.projectId));
    }

    @Override
    public int getItemCount() {
        return arrProjectModel.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView projectIcon;
        TextView appName, projectName, packageName, projectVersion, projectId;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            projectIcon = itemView.findViewById(R.id.project_icon);
            appName = itemView.findViewById(R.id.app_name);
            projectName = itemView.findViewById(R.id.project_name);
            packageName = itemView.findViewById(R.id.package_name);
            projectVersion = itemView.findViewById(R.id.project_version);
            projectId = itemView.findViewById(R.id.project_id);
        }
    }
}
