package com.rajendra.sketchide.managers

import android.content.Context
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.os.Environment
import android.util.Log
import androidx.annotation.DrawableRes
import androidx.core.content.ContextCompat
import com.rajendra.sketchide.R
import com.rajendra.sketchide.models.ProjectModel
import com.rajendra.sketchide.utils.StorageUtils
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.file.StandardOpenOption

/**
 * Work with files of a project source code
 */
object SourceManager {
  const val DIR_PROJECTS_INFO: String = "info"
  const val FILE_INFO: String = "info.json"
  const val FILE_ICON: String = "icon.png"
  const val DIR_PROJECTS: String = "projects"
  const val DIR_BACKUPS: String = "backups"
  const val DIR_SOURCE_JAVA: String = "app/src/main/java"

  var projectPackageName: String = "my.default"
    set(projectPackageName) {
      field = "/$projectPackageName/"
    }

  // BACKUP OF PROJECT
  /**
   * Prepare and save source code of project
   *
   * @param id identifier
   */
  @Throws(IOException::class)
  fun saveProjectBackup(context: Context, id: String, name: String?) {
    // prepare archive
    val archive = packProject(id)

    // save
    saveToFile(context, archive)

    Log.i("SAVE PROJECT", String(Files.readAllBytes(archive)))
  }

  /**
   * Save project archive to private storage area
   *
   * @param context of application
   * @param archive archive
   */
  @Throws(IOException::class)
  fun saveToFile(context: Context, archive: Path) {
    val destination = Paths.get(context.filesDir.absolutePath, archive.fileName.toString())
    Files.copy(archive, destination)
  }

  /**
   * Pack all parts of project to archive
   *
   * @param id identifier
   * @return project archive
   */
  @Throws(IOException::class)
  fun packProject(id: String): Path {
    // Destination directory for the archive
    val destDir =
      Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).absolutePath

    // Create the archive file
    val archive = Paths.get(destDir, DIR_BACKUPS, "$id.swp")
    Files.createFile(archive)

    // Replace the following line with your actual packing logic
    Files.write(archive, "TEST".toByteArray(StandardCharsets.UTF_8), StandardOpenOption.WRITE)

    return archive
  }

  // UPDATE SOURCE OF PROJECT TO STORAGE
  // When user has changed something in any file
  //   you must put all strings from file
  //   to Map < file_path, strings_in_file >
  // Don't save any changes to file immediately!
  // Only after either left editor or press button "Save".
  /**
   * Save the source code of project
   *
   * @param id    identifier
   * @param parts Map < file_path, strings_in_file >
   */
  @Throws(IOException::class)
  fun saveSource(id: String, parts: Map<String, Array<String>>) {
    val destDir =
      Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).absolutePath
    for ((key, value) in parts) {
      val path = Paths.get(destDir, DIR_PROJECTS, id, key)
      Files.deleteIfExists(path)
      Files.createFile(path)
      for (line in value) {
        Files.write(path, (line + "\n").toByteArray(), StandardOpenOption.WRITE)
      }
    }
  }

  fun saveIconFromDrawable(context: Context, @DrawableRes res: Int, pathToFile: String): String {
    val fullPath = context.getExternalFilesDir(null)?.absolutePath + File.separator + pathToFile

    val drawable = ContextCompat.getDrawable(context, res) as BitmapDrawable
    val bitmap = drawable.bitmap

    FileOutputStream(fullPath).use { fos ->
      bitmap.compress(Bitmap.CompressFormat.PNG, 100, fos)
    }

    return fullPath
  }

  @JvmStatic
  fun initProject(context: Context, projectModel: ProjectModel) {
    projectModel.projectIcon =
      saveIconFromDrawable(context, R.drawable.android_icon, projectModel.projectIcon)
    var path = DIR_PROJECTS_INFO + File.separator + projectModel.projectId
    StorageUtils.makeDirs(context, path)
    path += File.separator + FILE_INFO
    StorageUtils.writeToFile(context, path, listOf(projectModel.toString()))
  }
}
