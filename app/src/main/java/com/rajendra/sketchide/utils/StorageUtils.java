package com.rajendra.sketchide.utils;

import android.content.Context;
import android.os.Build;
import android.util.Log;

import com.rajendra.sketchide.managers.SourceManager;
import com.rajendra.sketchide.models.ProjectModel;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Scoped storage implementation
 */
public class StorageUtils {

    private static List<ProjectModel> allProjects = new ArrayList<>();

    public static void makeDirs(Context context, String relPath) {
        File file = new File(context.getExternalFilesDir(null), relPath);
        if (!file.exists()) file.mkdirs();
    }

    public static void writeToFile(Context context, String filename, List<String> lines) {
        Log.e("Storage Util", "SDK = " + Build.VERSION.SDK_INT);

//        if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
        File file = new File(context.getExternalFilesDir(null), filename);

        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        Log.e("Storage Util", file.getAbsolutePath());

        try (BufferedWriter fw = new BufferedWriter(new FileWriter(file))) {
            for (String line : lines) {
                fw.write(line + System.lineSeparator());
            }
            fw.flush();
        } catch (IOException e) {
            Log.e("writeToFile", e.getMessage());
        }
//        }
    }

    public static List<String> readFromFile(Context context, String filename) {
        List<String> result = new ArrayList<>();

//        if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED
//                || Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED_READ_ONLY) {
        File file = new File(context.getExternalFilesDir(null), filename);

        Log.e("Storage Util", file.getAbsolutePath());

        try (BufferedReader fr = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = fr.readLine()) != null) {
                result.add(line);
            }
        } catch (IOException e) {
            Log.e("writeToFile", e.getMessage());
        }
//        }
        return result;
    }

    public static void copyFile(InputStream from, OutputStream to) {
        try (BufferedInputStream bis = new BufferedInputStream(from);
             BufferedOutputStream bos = new BufferedOutputStream(to)) {
            byte[] buffer = new byte[1024];
            while (bis.read(buffer) > 0) {
                bos.write(buffer);
            }
        } catch (IOException e) {
            Log.e("COPY", e.getMessage());
        }
    }

    public static List<ProjectModel> getProjectsInfo(Context context) {
        allProjects = new ArrayList<>();
        String path = context.getExternalFilesDir(null) + File.separator + SourceManager.DIR_PROJECTS_INFO;
        String[] files = new File(path).list();
        Log.e("ALL_PROJECTS", Arrays.toString(files));
        if (files != null) {
            for (String projectId : files) {
                String pathInfoFile = SourceManager.DIR_PROJECTS_INFO + File.separator + projectId + File.separator + SourceManager.FILE_INFO;
                List<String> lines = readFromFile(context, pathInfoFile);
                if (!lines.isEmpty()) {
                    try {
                        JSONObject jo = new JSONObject(lines.get(0));
                        ProjectModel projectModel = new ProjectModel(jo);
                        allProjects.add(projectModel);
                    } catch (JSONException e) {
                        Log.e("GET_PROJECT_INFO", e.getMessage());
                    }
                }
            }
        }
        return allProjects;
    }

}
