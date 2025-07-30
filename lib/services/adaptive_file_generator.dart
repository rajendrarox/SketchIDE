import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/sketchide_project.dart';
import '../models/project_complexity.dart';
import 'android_code_generator.dart';
import 'ios_code_generator.dart';

class AdaptiveFileGenerator {
  /// Generate files based on project complexity
  static Future<void> generateFiles(
    String projectId,
    SketchIDEProject project,
  ) async {
    switch (project.complexity) {
      case ProjectComplexity.simple:
        await _generateSimpleProject(projectId, project);
        break;
      case ProjectComplexity.medium:
        await _generateMediumProject(projectId, project);
        break;
      case ProjectComplexity.complex:
        await _generateComplexProject(projectId, project);
        break;
    }
  }

  /// Generate simple project (single main.dart file)
  static Future<void> _generateSimpleProject(
    String projectId,
    SketchIDEProject project,
  ) async {
    final filesDir = await _getProjectFilesDirectory(projectId);
    final libDir = await _getProjectLibDirectory(projectId);

    // Create pubspec.yaml
    await _generatePubspecYaml(filesDir, project);

    // Create single main.dart with everything included
    final mainDartContent = _generateSimpleMainDart(project);
    final mainDartFile = File(path.join(libDir, 'main.dart'));
    await mainDartFile.writeAsString(mainDartContent);

    // Generate platform-specific files for simple projects too
    await _generatePlatformFiles(projectId, project);

    // Generated simple project structure for ${project.projectInfo.appName}
  }

  /// Generate medium project (main.dart + screens/)
  static Future<void> _generateMediumProject(
    String projectId,
    SketchIDEProject project,
  ) async {
    final filesDir = await _getProjectFilesDirectory(projectId);
    final libDir = await _getProjectLibDirectory(projectId);

    // Create pubspec.yaml
    await _generatePubspecYaml(filesDir, project);

    // Create main.dart (app entry point only)
    final mainDartContent = _generateMediumMainDart(project);
    final mainDartFile = File(path.join(libDir, 'main.dart'));
    await mainDartFile.writeAsString(mainDartContent);

    // Create screens directory
    final screensDir = Directory(path.join(libDir, 'screens'));
    await screensDir.create(recursive: true);

    // Create home screen
    final homeScreenContent = _generateHomeScreen(project);
    final homeScreenFile = File(path.join(screensDir.path, 'home_screen.dart'));
    await homeScreenFile.writeAsString(homeScreenContent);

    // Generate platform-specific files for medium projects too
    await _generatePlatformFiles(projectId, project);

    // Generated medium project structure for ${project.projectInfo.appName}
  }

  /// Generate complex project (full structure)
  static Future<void> _generateComplexProject(
    String projectId,
    SketchIDEProject project,
  ) async {
    final filesDir = await _getProjectFilesDirectory(projectId);
    final libDir = await _getProjectLibDirectory(projectId);

    // Create pubspec.yaml
    await _generatePubspecYaml(filesDir, project);

    // Create main.dart (app entry point only)
    final mainDartContent = _generateComplexMainDart(project);
    final mainDartFile = File(path.join(libDir, 'main.dart'));
    await mainDartFile.writeAsString(mainDartContent);

    // Create all directories
    await _createComplexDirectories(libDir);

    // Create default files
    await _createComplexDefaultFiles(libDir, project);

    // Generate platform-specific files
    await _generatePlatformFiles(projectId, project);

    // Generated complex project structure for ${project.projectInfo.appName}
  }

  /// Generate platform-specific files (Android and iOS)
  static Future<void> _generatePlatformFiles(
    String projectId,
    SketchIDEProject project,
  ) async {
    // Generate Android project structure
    await AndroidCodeGenerator.generateAndroidProject(projectId, project);

    // Generate iOS project structure
    await IOSCodeGenerator.generateIOSProject(projectId, project);
  }

  /// Generate simple main.dart (everything in one file)
  static String _generateSimpleMainDart(SketchIDEProject project) {
    final appName =
        project.projectInfo.appName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return '''import 'package:flutter/material.dart';

void main() => runApp(const ${appName}App());

class ${appName}App extends StatelessWidget {
  const ${appName}App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${project.projectInfo.appName}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${project.projectInfo.appName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(), // SKETCHWARE PRO STYLE: Empty container like empty LinearLayout
    );
  }
}''';
  }

  /// Generate medium main.dart (app entry point only)
  static String _generateMediumMainDart(SketchIDEProject project) {
    final appName =
        project.projectInfo.appName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return '''import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const ${appName}App());

class ${appName}App extends StatelessWidget {
  const ${appName}App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${project.projectInfo.appName}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}''';
  }

  /// Generate complex main.dart (app entry point only)
  static String _generateComplexMainDart(SketchIDEProject project) {
    final appName =
        project.projectInfo.appName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return '''import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const ${appName}App());

class ${appName}App extends StatelessWidget {
  const ${appName}App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${project.projectInfo.appName}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}''';
  }

  /// Generate home screen
  static String _generateHomeScreen(SketchIDEProject project) {
    return '''import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${project.projectInfo.appName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(), // SKETCHWARE PRO STYLE: Empty container like empty LinearLayout
    );
  }
}''';
  }

  /// Create complex project directories
  static Future<void> _createComplexDirectories(String libDir) async {
    final directories = [
      'screens',
      'widgets',
      'services',
      'models',
      'utils',
    ];

    for (final dirName in directories) {
      final dir = Directory(path.join(libDir, dirName));
      await dir.create(recursive: true);
    }
  }

  /// Create complex project default files
  static Future<void> _createComplexDefaultFiles(
    String libDir,
    SketchIDEProject project,
  ) async {
    // Create home screen
    final homeScreenContent = _generateHomeScreen(project);
    final homeScreenFile =
        File(path.join(libDir, 'screens', 'home_screen.dart'));
    await homeScreenFile.writeAsString(homeScreenContent);

    // Create constants file
    final constantsContent = _generateConstantsFile(project);
    final constantsFile = File(path.join(libDir, 'utils', 'constants.dart'));
    await constantsFile.writeAsString(constantsContent);

    // Create helpers file
    final helpersContent = _generateHelpersFile();
    final helpersFile = File(path.join(libDir, 'utils', 'helpers.dart'));
    await helpersFile.writeAsString(helpersContent);
  }

  /// Generate constants file
  static String _generateConstantsFile(SketchIDEProject project) {
    return '''// App Constants
class AppConstants {
  static const String appName = '${project.projectInfo.appName}';
  static const String appVersion = '${project.projectInfo.versionName}';
  
  // Colors
  static const int primaryColor = 0xFF2196F3;
  static const int secondaryColor = 0xFF1976D2;
  
  // Dimensions
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  
  // Strings
  static const String welcomeMessage = 'Welcome to \$appName';
  static const String createdWithSketchIDE = 'Created with SketchIDE';
}''';
  }

  /// Generate helpers file
  static String _generateHelpersFile() {
    return '''// Helper Functions
import 'package:flutter/material.dart';

class AppHelpers {
  /// Show a snackbar with the given message
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\\.[^@]+').hasMatch(email);
  }
  
  /// Format date to readable string
  static String formatDate(DateTime date) {
    return '\${date.day}/\${date.month}/\${date.year}';
  }
}''';
  }

  /// Get project files directory
  static Future<String> _getProjectFilesDirectory(String projectId) async {
    final baseDir = '/storage/emulated/0/.sketchide/data/$projectId/files';
    await Directory(baseDir).create(recursive: true);
    return baseDir;
  }

  /// Get project lib directory
  static Future<String> _getProjectLibDirectory(String projectId) async {
    final filesDir = await _getProjectFilesDirectory(projectId);
    final libDir = path.join(filesDir, 'lib');
    await Directory(libDir).create(recursive: true);
    return libDir;
  }

  /// Generate pubspec.yaml file
  static Future<void> _generatePubspecYaml(
    String filesDir,
    SketchIDEProject project,
  ) async {
    final pubspecContent = '''name: ${project.projectInfo.appName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}
description: ${project.projectInfo.appName} created with SketchIDE
publish_to: 'none'
version: ${project.projectInfo.versionName}

environment:
  sdk: ^3.5.4

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
''';

    final pubspecFile = File(path.join(filesDir, 'pubspec.yaml'));
    await pubspecFile.writeAsString(pubspecContent);
  }

  /// Upgrade project complexity
  static Future<void> upgradeProjectComplexity(
    String projectId,
    SketchIDEProject project,
    ProjectComplexity newComplexity,
  ) async {
    // Upgrading project ${project.projectInfo.appName} to ${newComplexity.name}

    // Regenerate files with new complexity
    final upgradedProject = project.copyWith(complexity: newComplexity);
    await generateFiles(projectId, upgradedProject);

    // Project upgraded successfully
  }
}
