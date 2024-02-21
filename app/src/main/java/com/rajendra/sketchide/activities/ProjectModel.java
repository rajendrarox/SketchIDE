package com.rajendra.sketchide.activities;

import java.util.ArrayList;

public class ProjectModel {
    public int projectIcon;
    public String appName;
    public String projectName;
    public String packageName;
    public String projectVersion;
    public String projectId;

    public ProjectModel(int projectIcon, String appName, String projectName, String packageName, String projectVersion, String projectId) {
        this.projectIcon = projectIcon;
        this.appName = appName;
        this.projectName = projectName;
        this.packageName = packageName;
        this.projectVersion = projectVersion;
        this.projectId = projectId;
    }

    // Constructor for input
    public ProjectModel(String appName, ArrayList<ProjectModel> existingProjects) {
        this.appName = appName;
        // Generate a new projectId
        int maxProjectId = 0;
        for (ProjectModel project : existingProjects) {
            int projectId = Integer.parseInt(project.projectId);
            if (projectId > maxProjectId) {
                maxProjectId = projectId;
            }
        }
        this.projectId = String.valueOf(maxProjectId + 1);
    }
}
