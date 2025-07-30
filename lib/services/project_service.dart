import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/sketchide_project.dart';
import '../models/project_complexity.dart';
import 'native_storage_service.dart';
import 'adaptive_file_generator.dart';
import 'dart:math' as math;

class ProjectService {
  // Sketchware Pro-style directory structure
  static const String _sketchideDir = '.sketchide';
  static const String _dataDir = 'data';
  static const String _myscDir = 'mysc';
  static const String _listDir = 'list';
  static const String _libsDir = 'libs';
  static const String _resourcesDir = 'resources';
  static const String _tempDir = 'temp';
  static const String _bakDir = 'bak';
  static const String _downloadDir = 'download';

  // Get root SketchIDE directory (like Sketchware Pro)
  Future<String> getSketchideRootDirectory() async {
    // Check if we have permission first (don't request automatically)
    if (!await isExternalStorageAccessible()) {
      throw Exception(
          'External storage not accessible. Please grant storage permissions.');
    }

    // Use native Android method to get external storage path (like Sketchware Pro)
    final externalStoragePath =
        await NativeStorageService.getExternalStoragePath();
    if (externalStoragePath == null) {
      throw Exception('External storage not accessible');
    }

    final sketchideDir = path.join(externalStoragePath, _sketchideDir);

    // Create root directory if it doesn't exist
    await Directory(sketchideDir).create(recursive: true);
    return sketchideDir;
  }

  // Get projects data directory (like Sketchware Pro's data folder)
  Future<String> getProjectsDataDirectory() async {
    final rootDir = await getSketchideRootDirectory();
    final dataDir = path.join(rootDir, _dataDir);
    await Directory(dataDir).create(recursive: true);
    return dataDir;
  }

  // Get project list directory (like Sketchware Pro's mysc/list)
  Future<String> getProjectListDirectory() async {
    final rootDir = await getSketchideRootDirectory();
    final listDir = path.join(rootDir, _myscDir, _listDir);
    await Directory(listDir).create(recursive: true);
    return listDir;
  }

  // Get individual project directory (like Sketchware Pro's data/<sc_id>)
  Future<String> getProjectDirectory(String projectId) async {
    final dataDir = await getProjectsDataDirectory();
    final projectDir = path.join(dataDir, projectId);
    await Directory(projectDir).create(recursive: true);
    return projectDir;
  }

  // Get project files directory (like Sketchware Pro's data/<sc_id>/files)
  Future<String> getProjectFilesDirectory(String projectId) async {
    final projectDir = await getProjectDirectory(projectId);
    final filesDir = path.join(projectDir, 'files');
    await Directory(filesDir).create(recursive: true);
    return filesDir;
  }

  // Get project Dart files directory (lib/ for Flutter convention)
  Future<String> getProjectLibDirectory(String projectId) async {
    final filesDir = await getProjectFilesDirectory(projectId);
    final libDir = path.join(filesDir, 'lib');
    await Directory(libDir).create(recursive: true);
    return libDir;
  }

  // Get project assets directory
  Future<String> getProjectAssetsDirectory(String projectId) async {
    final filesDir = await getProjectFilesDirectory(projectId);
    final assetsDir = path.join(filesDir, 'assets');
    await Directory(assetsDir).create(recursive: true);
    return assetsDir;
  }

  // Get project resources directory
  Future<String> getProjectResourcesDirectory(String projectId) async {
    final filesDir = await getProjectFilesDirectory(projectId);
    final resourcesDir = path.join(filesDir, 'resources');
    await Directory(resourcesDir).create(recursive: true);
    return resourcesDir;
  }

  // Get project UI directory
  Future<String> getProjectUIDirectory(String projectId) async {
    final filesDir = await getProjectFilesDirectory(projectId);
    final uiDir = path.join(filesDir, 'ui');
    await Directory(uiDir).create(recursive: true);
    return uiDir;
  }

  // Get project logic directory
  Future<String> getProjectLogicDirectory(String projectId) async {
    final filesDir = await getProjectFilesDirectory(projectId);
    final logicDir = path.join(filesDir, 'logic');
    await Directory(logicDir).create(recursive: true);
    return logicDir;
  }

  // Get project widgets cache directory (like Sketchware Pro's widget cache)
  Future<String> getProjectWidgetsDirectory(String projectId) async {
    final filesDir = await getProjectFilesDirectory(projectId);
    final widgetsDir = path.join(filesDir, 'widgets');
    await Directory(widgetsDir).create(recursive: true);
    return widgetsDir;
  }

  // Get global libraries directory (like Sketchware Pro's libs)
  Future<String> getGlobalLibsDirectory() async {
    final rootDir = await getSketchideRootDirectory();
    final libsDir = path.join(rootDir, _libsDir);
    await Directory(libsDir).create(recursive: true);
    return libsDir;
  }

  // Get global resources directory (like Sketchware Pro's resources)
  Future<String> getGlobalResourcesDirectory() async {
    final rootDir = await getSketchideRootDirectory();
    final resourcesDir = path.join(rootDir, _resourcesDir);
    await Directory(resourcesDir).create(recursive: true);
    return resourcesDir;
  }

  // Get temporary files directory (like Sketchware Pro's temp)
  Future<String> getTempDirectory() async {
    final rootDir = await getSketchideRootDirectory();
    final tempDir = path.join(rootDir, _tempDir);
    await Directory(tempDir).create(recursive: true);
    return tempDir;
  }

  // Get backup directory (like Sketchware Pro's bak)
  Future<String> getBackupDirectory() async {
    final rootDir = await getSketchideRootDirectory();
    final bakDir = path.join(rootDir, _bakDir);
    await Directory(bakDir).create(recursive: true);
    return bakDir;
  }

  // Get download directory (like Sketchware Pro's download)
  Future<String> getDownloadDirectory() async {
    final rootDir = await getSketchideRootDirectory();
    final downloadDir = path.join(rootDir, _downloadDir);
    await Directory(downloadDir).create(recursive: true);
    return downloadDir;
  }

  // Request storage permissions (only when explicitly called)
  Future<void> _requestStoragePermissions() async {
    if (Platform.isAndroid) {
      // Use native Android permission checking (like Sketchware Pro)
      final hasPermission = await NativeStorageService.checkStoragePermission();
      if (!hasPermission) {
        final granted = await NativeStorageService.requestStoragePermission();
        if (!granted) {
          throw Exception(
              'Storage permission is required to access external storage');
        }
      }
    }
  }

  // Generate unique project ID (like Sketchware Pro's sc_id)
  Future<String> _generateProjectId() async {
    // SKETCHWARE PRO STYLE: Start from 601 and find highest existing ID
    int nextId = 601;

    try {
      final listDir = await getProjectListDirectory();
      final projectListFile = File(path.join(listDir, 'projects.json'));

      if (await projectListFile.exists()) {
        final content = await projectListFile.readAsString();
        final List<dynamic> projectList = jsonDecode(content);

        // Find the highest existing project ID
        for (final project in projectList) {
          final projectId = project['project_id'] as String;
          // Extract numeric part from project ID
          final numericId = int.tryParse(projectId) ?? 0;
          nextId = math.max(nextId, numericId + 1);
        }
      }
    } catch (e) {
      print('Error reading project list for ID generation: $e');
      // Fallback to timestamp-based ID if there's an error
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (timestamp % 1000000).toString().padLeft(6, '0');
      return 'sketchide_$timestamp$random';
    }

    return nextId.toString();
  }

  // Create new project with adaptive structure
  Future<SketchIDEProject> createProject({
    required String appName,
    required String packageName,
    required String projectName,
    String versionName = '1.0',
    int versionCode = 1,
    String? iconPath,
    ProjectTemplate template = ProjectTemplate.helloWorld,
  }) async {
    // Create project with specified template
    final project = await SketchIDEProject.createEmpty(
      appName: appName,
      packageName: packageName,
      projectName: projectName,
      versionName: versionName,
      versionCode: versionCode,
      iconPath: iconPath,
      template: template,
    );

    // Use the project ID from the created project
    final projectId = project.projectId;

    // Create Sketchware Pro-style directory structure
    await _createProjectDirectoryStructure(projectId, project);

    // Save project metadata
    await _saveProjectMetadata(projectId, project);

    // Generate adaptive file structure based on complexity
    await AdaptiveFileGenerator.generateFiles(projectId, project);

    // Create default UI files
    await _createDefaultUIFiles(projectId, project);

    // Create default logic files
    await _createDefaultLogicFiles(projectId, project);

    // Add to project list
    await _addToProjectList(projectId, project);

    return project;
  }

  // Create project directory structure (like Sketchware Pro)
  Future<void> _createProjectDirectoryStructure(
      String projectId, SketchIDEProject project) async {
    // Create main project directory
    final projectDir = await getProjectDirectory(projectId);

    // Create files subdirectory
    final filesDir = await getProjectFilesDirectory(projectId);

    // Create project subdirectories
    await getProjectLibDirectory(projectId);
    await getProjectAssetsDirectory(projectId);
    await getProjectResourcesDirectory(projectId);
    await getProjectUIDirectory(projectId);
    await getProjectLogicDirectory(projectId);
    await getProjectWidgetsDirectory(projectId);

    // Create global system directories (like Sketchware Pro)
    await getGlobalLibsDirectory();
    await getGlobalResourcesDirectory();
    await getTempDirectory();
    await getBackupDirectory();
    await getDownloadDirectory();

    print(
        'Created complete Sketchware Pro-style directory structure: $projectDir');
  }

  // Save project metadata (like Sketchware Pro's project.json)
  Future<void> _saveProjectMetadata(
      String projectId, SketchIDEProject project) async {
    final projectDir = await getProjectDirectory(projectId);
    final metadataFile = File(path.join(projectDir, 'project.json'));

    final metadata = {
      'project_id': projectId,
      'app_name': project.projectInfo.appName,
      'package_name': project.projectInfo.packageName,
      'project_name': project.projectInfo.projectName,
      'version_name': project.projectInfo.versionName,
      'version_code': project.projectInfo.versionCode,
      'icon_path': project.projectInfo.iconPath,
      'created_at': project.projectInfo.createdAt.toIso8601String(),
      'modified_at': project.projectInfo.modifiedAt.toIso8601String(),
    };

    await metadataFile
        .writeAsString(JsonEncoder.withIndent('  ').convert(metadata));
  }

  // Create default Flutter lib files
  Future<void> _createDefaultLibFiles(
      String projectId, SketchIDEProject project) async {
    final libDir = await getProjectLibDirectory(projectId);

    // Create main.dart
    final mainDartContent = _generateMainDart(project);
    final mainDartFile = File(path.join(libDir, 'main.dart'));
    await mainDartFile.writeAsString(mainDartContent);

    // Create home_page.dart
    final homePageContent = _generateHomePage(project);
    final homePageFile = File(path.join(libDir, 'home_page.dart'));
    await homePageFile.writeAsString(homePageContent);

    // Create pubspec.yaml
    final pubspecContent = _generatePubspecYaml(project);
    final projectDir = await getProjectDirectory(projectId);
    final pubspecFile = File(path.join(projectDir, 'pubspec.yaml'));
    await pubspecFile.writeAsString(pubspecContent);
  }

  // Create default UI files
  Future<void> _createDefaultUIFiles(
      String projectId, SketchIDEProject project) async {
    final uiDir = await getProjectUIDirectory(projectId);

    // Create main UI layout
    final mainUILayout = {
      'id': 'main_layout',
      'type': 'scaffold',
      'properties': {
        'appBar': {
          'type': 'app_bar',
          'title': project.projectInfo.appName,
        },
        'body': {
          'type': 'center',
          'child': {
            'type': 'text',
            'text': 'Welcome to ${project.projectInfo.appName}',
          },
        },
      },
    };

    final mainUIFile = File(path.join(uiDir, 'main_layout.json'));
    await mainUIFile
        .writeAsString(JsonEncoder.withIndent('  ').convert(mainUILayout));
  }

  // Create default logic files
  Future<void> _createDefaultLogicFiles(
      String projectId, SketchIDEProject project) async {
    final logicDir = await getProjectLogicDirectory(projectId);

    // Create main logic
    final mainLogic = {
      'id': 'main_logic',
      'events': [
        {
          'type': 'onCreate',
          'blocks': [
            {
              'type': 'print',
              'text': 'App started: ${project.projectInfo.appName}',
            },
          ],
        },
      ],
    };

    final mainLogicFile = File(path.join(logicDir, 'main_logic.json'));
    await mainLogicFile
        .writeAsString(JsonEncoder.withIndent('  ').convert(mainLogic));
  }

  // Add project to project list (like Sketchware Pro's mysc/list)
  Future<void> _addToProjectList(
      String projectId, SketchIDEProject project) async {
    final listDir = await getProjectListDirectory();
    final projectListFile = File(path.join(listDir, 'projects.json'));

    List<Map<String, dynamic>> projectList = [];

    if (await projectListFile.exists()) {
      final content = await projectListFile.readAsString();
      final List<dynamic> existingList = jsonDecode(content);
      projectList = existingList.cast<Map<String, dynamic>>();
    }

    // Add new project to list
    projectList.add({
      'project_id': projectId,
      'app_name': project.projectInfo.appName,
      'package_name': project.projectInfo.packageName,
      'project_name': project.projectInfo.projectName,
      'version_name': project.projectInfo.versionName,
      'version_code': project.projectInfo.versionCode,
      'created_at': project.projectInfo.createdAt.toIso8601String(),
      'modified_at': project.projectInfo.modifiedAt.toIso8601String(),
    });

    await projectListFile
        .writeAsString(JsonEncoder.withIndent('  ').convert(projectList));
  }

  // Generate main.dart content
  String _generateMainDart(SketchIDEProject project) {
    return '''import 'package:flutter/material.dart';
import 'home_page.dart';

void main() => runApp(const ${project.projectInfo.appName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}App());

class ${project.projectInfo.appName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}App extends StatelessWidget {
  const ${project.projectInfo.appName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${project.projectInfo.appName}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}''';
  }

  // Generate home_page.dart content
  String _generateHomePage(SketchIDEProject project) {
    return '''import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${project.projectInfo.appName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flutter_dash,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to ${project.projectInfo.appName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Created with SketchIDE',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}''';
  }

  // Generate pubspec.yaml content
  String _generatePubspecYaml(SketchIDEProject project) {
    return '''name: ${project.projectInfo.appName.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}
description: A Flutter project created with SketchIDE.
publish_to: 'none'

version: ${project.projectInfo.versionName}+${project.projectInfo.versionCode}

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
''';
  }

  // Get all projects (read from project list)
  Future<List<SketchIDEProject>> getAllProjects() async {
    try {
      final listDir = await getProjectListDirectory();
      final projectListFile = File(path.join(listDir, 'projects.json'));

      if (!await projectListFile.exists()) {
        return [];
      }

      final content = await projectListFile.readAsString();
      final List<dynamic> projectList = jsonDecode(content);

      List<SketchIDEProject> projects = [];

      for (final projectData in projectList) {
        final projectId = projectData['project_id'] as String;
        final project = await _loadProjectFromDirectory(projectId);
        if (project != null) {
          projects.add(project);
        }
      }

      return projects;
    } catch (e) {
      print('Error loading projects: $e');
      return [];
    }
  }

  // Load project from directory structure
  Future<SketchIDEProject?> loadProject(String projectId) async {
    return await _loadProjectFromDirectory(projectId);
  }

  // Load project from directory structure (private)
  Future<SketchIDEProject?> _loadProjectFromDirectory(String projectId) async {
    try {
      final projectDir = await getProjectDirectory(projectId);
      final metadataFile = File(path.join(projectDir, 'project.json'));

      if (!await metadataFile.exists()) {
        return null;
      }

      final content = await metadataFile.readAsString();
      final metadata = jsonDecode(content) as Map<String, dynamic>;

      return SketchIDEProject.createEmptyWithId(
        projectId: projectId, // Use the actual project ID
        appName: metadata['app_name'],
        packageName: metadata['package_name'],
        projectName: metadata['project_name'],
        versionName: metadata['version_name'],
        versionCode: metadata['version_code'],
        iconPath: metadata['icon_path'],
      );
    } catch (e) {
      print('Error loading project $projectId: $e');
      return null;
    }
  }

  // Save project (update metadata)
  Future<void> saveProject(SketchIDEProject project) async {
    // Use the project ID directly from the project object
    final projectId = project.projectId;

    // Update metadata
    await _saveProjectMetadata(projectId, project);
  }

  // Delete project
  Future<void> deleteProject(String projectId) async {
    final projectDir = await getProjectDirectory(projectId);
    final projectDirFile = Directory(projectDir);

    if (await projectDirFile.exists()) {
      await projectDirFile.delete(recursive: true);
    }

    // Remove from project list
    await _removeFromProjectList(projectId);
  }

  // Remove project from project list
  Future<void> _removeFromProjectList(String projectId) async {
    final listDir = await getProjectListDirectory();
    final projectListFile = File(path.join(listDir, 'projects.json'));

    if (!await projectListFile.exists()) {
      return;
    }

    final content = await projectListFile.readAsString();
    final List<dynamic> projectList = jsonDecode(content);

    projectList.removeWhere((project) => project['project_id'] == projectId);

    await projectListFile
        .writeAsString(JsonEncoder.withIndent('  ').convert(projectList));
  }

  // Check if external storage is accessible (fixed version)
  Future<bool> isExternalStorageAccessible() async {
    try {
      // Use native Android permission checking (like Sketchware Pro)
      return await NativeStorageService.checkStoragePermission();
    } catch (e) {
      print('External storage not accessible: $e');
      return false;
    }
  }

  // Export project (copy to downloads directory)
  Future<String> exportProject(SketchIDEProject project) async {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('Downloads directory not accessible');
    }

    // Use the project ID directly from the project object
    final projectId = project.projectId;
    final projectDir = await getProjectDirectory(projectId);
    final exportPath = path.join(
        downloadsDir.path, '${project.projectInfo.appName}_export.zip');

    // Create ZIP archive of project directory
    // This would require the archive package
    // For now, just copy the project.json
    final metadataFile = File(path.join(projectDir, 'project.json'));
    final exportFile = File(exportPath);
    await exportFile.writeAsString(await metadataFile.readAsString());

    return exportPath;
  }

  // Get downloads directory
  Future<Directory?> getDownloadsDirectory() async {
    try {
      return await getExternalStorageDirectory();
    } catch (e) {
      print('Error getting downloads directory: $e');
      return null;
    }
  }

  // Check if project exists
  Future<bool> projectExists(String appName) async {
    try {
      final projects = await getAllProjects();
      return projects.any((project) => project.projectInfo.appName == appName);
    } catch (e) {
      print('Error checking if project exists: $e');
      return false;
    }
  }

  // Import project from external file
  Future<SketchIDEProject> importProject(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Import file not found: $filePath');
    }

    final jsonString = await file.readAsString();
    final projectData = jsonDecode(jsonString) as Map<String, dynamic>;

    // Create new project with imported data
    final project = await SketchIDEProject.createEmpty(
      appName: projectData['app_name'] ?? 'Imported Project',
      packageName: projectData['package_name'] ?? 'com.sketchide.imported',
      projectName: projectData['project_name'] ?? 'Imported Project',
      versionName: projectData['version_name'] ?? '1.0',
      versionCode: projectData['version_code'] ?? 1,
      iconPath: projectData['icon_path'],
    );

    // Generate new project ID and create directory structure
    final projectId = await _generateProjectId();
    await _createProjectDirectoryStructure(projectId, project);
    await _saveProjectMetadata(projectId, project);
    await _addToProjectList(projectId, project);

    return project;
  }
}
