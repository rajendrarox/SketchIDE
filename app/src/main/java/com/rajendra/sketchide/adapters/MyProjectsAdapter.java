package com.rajendra.sketchide.adapters;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.rajendra.sketchide.R;
import com.rajendra.sketchide.activities.EditorActivity;
import com.rajendra.sketchide.models.ProjectModel;

import java.util.List;
import java.util.Objects;

public class MyProjectsAdapter extends RecyclerView.Adapter<MyProjectsAdapter.ViewHolder> {

    private final Context context;
    private final List<ProjectModel> arrProjectModel;

    public MyProjectsAdapter(Context context, List<ProjectModel> arrProjectModel) {
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
        holder.projectIcon.setImageDrawable(Drawable.createFromPath(project.getProjectIcon()));
        holder.appName.setText(project.getAppName());
        holder.projectName.setText(project.getProjectName());
        holder.packageName.setText(project.getPackageName());
        holder.projectVersion.setText(String.valueOf(project.getProjectVersion()));
        holder.projectId.setText(String.valueOf(project.getProjectId()));

        // Long-press listener for RecyclerView items
        holder.LayoutProjectItem.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                Dialog dialogOptions = new Dialog(context);
                dialogOptions.setContentView(R.layout.dialog_myproject_options);
                //find buttons.json ides
                TextView editor = dialogOptions.findViewById(R.id.editor);
                TextView config = dialogOptions.findViewById(R.id.config);
                TextView delete = dialogOptions.findViewById(R.id.delete);
                TextView rename = dialogOptions.findViewById(R.id.rename);
                TextView backup = dialogOptions.findViewById(R.id.backup);
                TextView settings = dialogOptions.findViewById(R.id.settings);

                //Click action dialog Item
                editor.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent intentEditor = new Intent(context, EditorActivity.class);
                        context.startActivity(intentEditor);

                        dialogOptions.dismiss();
                    }

                });

                // Dialog Size Match_Parent
                WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams();
                layoutParams.copyFrom(Objects.requireNonNull(dialogOptions.getWindow()).getAttributes());
                layoutParams.width = WindowManager.LayoutParams.MATCH_PARENT;
                layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
                dialogOptions.getWindow().setAttributes(layoutParams);

                dialogOptions.show();

                return true;
            }
        });

        // Click listener for RecyclerView items
        holder.LayoutProjectItem.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intentEditor = new Intent(context, EditorActivity.class);
                context.startActivity(intentEditor);

            }
        });

    }

    @Override
    public int getItemCount() {
        return arrProjectModel.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView projectIcon;
        TextView appName, projectName, packageName, projectVersion, projectId;
        LinearLayout LayoutProjectItem;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            projectIcon = itemView.findViewById(R.id.project_icon);
            appName = itemView.findViewById(R.id.app_name);
            projectName = itemView.findViewById(R.id.project_name);
            packageName = itemView.findViewById(R.id.package_name);
            projectVersion = itemView.findViewById(R.id.project_version);
            projectId = itemView.findViewById(R.id.project_id);
            LayoutProjectItem = itemView.findViewById(R.id.layout_project_item);
        }
    }
}
