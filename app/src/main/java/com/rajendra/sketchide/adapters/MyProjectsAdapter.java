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
import androidx.appcompat.app.AlertDialog;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
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
                // Inflate custom dialog view
                LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                View dialogView = inflater.inflate(R.layout.dialog_myproject_options, null);

                // Create the AlertDialog
                MaterialAlertDialogBuilder dialogBuilder = new MaterialAlertDialogBuilder(context);
                dialogBuilder.setView(dialogView);

                // Create and show the dialog
                AlertDialog dialog = dialogBuilder.create();
                dialog.show();

                // Find buttons by their IDs
                TextView editor = dialogView.findViewById(R.id.editor);
                TextView config = dialogView.findViewById(R.id.config);
                TextView delete = dialogView.findViewById(R.id.delete);
                TextView rename = dialogView.findViewById(R.id.rename);
                TextView backup = dialogView.findViewById(R.id.backup);
                TextView settings = dialogView.findViewById(R.id.settings);

                // Click action for dialog items
                editor.setOnClickListener(v1 -> {
                    Intent intentEditor = new Intent(context, EditorActivity.class);
                    context.startActivity(intentEditor);
                    dialog.dismiss();
                });

                // Add similar OnClickListener implementations for config, delete, rename, backup, and settings here...

                // Set dialog window size to match parent width
                WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams();
                layoutParams.copyFrom(Objects.requireNonNull(dialog.getWindow()).getAttributes());
                layoutParams.width = WindowManager.LayoutParams.MATCH_PARENT;
                layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
                dialog.getWindow().setAttributes(layoutParams);

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
