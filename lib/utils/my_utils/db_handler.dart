//handle all the data that are store in directory

import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHandler {
  /// Singleton
  DbHandler._();

  static final DbHandler getInstence = DbHandler._();

  ///  Table project
  static const String TABLE_PROJECT = "project";
  static const String COLUMN_PROJECT_ID = "project_id";
  static const String COLUMN_APP_NAME = "app_name";
  static const String COLUMN_PROJECT_NAME = "project_name";
  static const String COLUMN_APP_PACKAGE_NAME = "app_package_name";
  static const String COLUMN_APP_LOGO_PATH = "app_logo_path";

  Database? myDB;

  /// db open (path -> if exist then else create db)
  Future<Database> getDB() async {
    /// short db return code
    myDB ??= await openDB();
    return myDB!;

    /// Long db return code

    /* if (myDB == null) {
      return myDB!;
    } else {
      myDB = await openDB();
      return myDB!;
    }*/
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();

    /// Project Store Directory Name

    String dbPath = join(appDir.path, 'projects.db');

    return await openDatabase(dbPath, onCreate: (db, version) {
      /// Create all your table here
      db.execute("Create Table $TABLE_PROJECT ("
          "$COLUMN_PROJECT_ID INTEGER PRIMARY KEY,"
          "$COLUMN_APP_NAME TEXT,"
          "$COLUMN_PROJECT_NAME TEXT,"
          "$COLUMN_APP_PACKAGE_NAME TEXT,"
          "$COLUMN_APP_LOGO_PATH TEXT"
          ")");

      /// Create all your table here
    }, version: 1);
  }

  /// all queries
  /// Create Project
  Future<bool> addProject(
      {required String appName,
      required String projectName,
      required String appPackageName,
      required File appLogo}) async {
    var db = await getDB();

    // Store App Icon in File System
    final appDir = await getApplicationDocumentsDirectory();
    final appLogoName = '${DateTime.now().millisecondsSinceEpoch}.png'; // Example filename
    final appLogoPath = join(appDir.path, appLogoName);
    await appLogo.copy(appLogoPath);

    int rowsEffected = await db.insert(TABLE_PROJECT, {
      COLUMN_APP_NAME: appName,
      COLUMN_PROJECT_NAME: projectName,
      COLUMN_APP_PACKAGE_NAME: appPackageName,
      COLUMN_APP_LOGO_PATH: appLogoPath
    });

    return rowsEffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllProject() async {
    var db = await getDB();
    List<Map<String, dynamic>> projectData = await db.query(TABLE_PROJECT);

    return projectData;
  }
}
