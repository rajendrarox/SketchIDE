package com.rajendra.sketchide.activities;

public class ProjectModel {
    public int projectIcon;
    public String appName;
    public String projectName;
    public String packageName;
    public String projectVersion;
    public String projectId;

    public  ProjectModel(int projectIcon, String appName,String projectName,String packageName ,String projectVersion,String projectId){
        this.projectIcon = projectIcon;
        this.appName = appName;
        this.projectName = projectName;
        this.packageName = packageName;
        this.projectVersion = projectVersion;
        this.projectId = projectId;
    }

}
