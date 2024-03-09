package com.rajendra.sketchide.models;

import android.util.Log;

import androidx.annotation.NonNull;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class ProjectModel {

    /**
     * Path to image file
     */
    private String projectIcon;

    /**
     * Name of the Application
     */
    private String appName;

    /**
     * Like appName
     */
    private String projectName;

    /**
     * Package name of the project
     */
    private String packageName;

    /**
     * Name of version
     */
    private String projectVersion;

    /**
     * Name of folder of project sources
     */
    private String projectId;

    public ProjectModel(String projectIcon, String appName, String projectName, String packageName, String projectVersion, String projectId) {
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

    public ProjectModel(JSONObject jsonObject) {
        projectIcon = jsonObject.optString("projectIcon", "");
        appName = jsonObject.optString("appName", "");
        projectName = jsonObject.optString("projectName", "");
        packageName = jsonObject.optString("packageName", "");
        projectVersion = jsonObject.optString("projectVersion", "");
        projectId = jsonObject.optString("projectId", "");
    }

    @NonNull
    @Override
    public String toString() {
        try {
            JSONObject jo = new JSONObject();
            jo.put("projectIcon", projectIcon);
            jo.put("appName", appName);
            jo.put("projectName", projectName);
            jo.put("packageName", packageName);
            jo.put("projectVersion", projectVersion);
            return jo.toString();
        } catch (JSONException e) {
            Log.e("PROJECT_TO_JSON", e.getMessage());
        }
        return "{}";
    }

    public String getProjectIcon() {
        return projectIcon;
    }

    public void setProjectIcon(String projectIcon) {
        this.projectIcon = projectIcon;
    }

    public String getAppName() {
        return appName;
    }

    public void setAppName(String appName) {
        this.appName = appName;
    }

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }

    public String getProjectVersion() {
        return projectVersion;
    }

    public void setProjectVersion(String projectVersion) {
        this.projectVersion = projectVersion;
    }

    public String getProjectId() {
        return projectId;
    }

    public void setProjectId(String projectId) {
        this.projectId = projectId;
    }
}
