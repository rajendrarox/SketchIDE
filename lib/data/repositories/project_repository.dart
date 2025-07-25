import 'dart:io';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../domain/models/project.dart';

class ProjectRepository {
  static const String _boxName = 'projects';
  late Box<Project> _projectBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProjectAdapter());
    _projectBox = await Hive.openBox<Project>(_boxName);
  }

  Future<List<Project>> getAllProjects() async {
    return _projectBox.values.toList();
  }

  Future<Project?> getProjectById(String id) async {
    return _projectBox.get(id);
  }

  Future<void> saveProject(Project project) async {
    await _projectBox.put(project.id, project);
  }

  Future<void> deleteProject(String id) async {
    final project = await getProjectById(id);
    if (project != null) {
      // Delete project directory
      final projectDir = Directory(project.projectPath);
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
      }
      // Remove from Hive
      await _projectBox.delete(id);
    }
  }

  Future<bool> hasProjects() async {
    return _projectBox.isNotEmpty;
  }

  Future<String> getProjectsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, 'SketchIDE', 'projects');
  }

  Future<String> createProjectDirectory(String projectName) async {
    final projectsDir = await getProjectsDirectory();
    
    // Sanitize project name for directory name (remove special characters, replace spaces with underscores)
    final sanitizedName = projectName
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-\s]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
        .toLowerCase(); // Convert to lowercase
    
    final projectDir = path.join(projectsDir, sanitizedName);
    
    // Create directories if they don't exist
    await Directory(projectsDir).create(recursive: true);
    await Directory(projectDir).create(recursive: true);
    
    return projectDir;
  }

  Future<void> generateProjectStructure(Project project) async {
    final projectDir = project.projectPath;
    
    try {
      // Create complete directory structure
      final directories = [
        'lib',
        'ui',
        'logic',
        'assets',
        'android/app/src/main/java',
        'android/app/src/main/res/mipmap-hdpi',
        'android/app/src/main/res/mipmap-mdpi',
        'android/app/src/main/res/mipmap-xhdpi',
        'android/app/src/main/res/mipmap-xxhdpi',
        'android/app/src/main/res/mipmap-xxxhdpi',
        'android/app/src/main/res/values',
        'android/app/src/main/res/drawable',
        'ios/Runner',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset',
        'ios/Runner/Base.lproj',
        'build/android',
        'build/ios',
      ];

      for (final dir in directories) {
        final dirPath = path.join(projectDir, dir);
        await Directory(dirPath).create(recursive: true);
        print('Created directory: $dirPath');
      }

      // Generate all project files
      await _generateMetaJson(project);
      await _generateDartFiles(project);
      await _generateJsonFiles(project);
      await _generateAndroidFiles(project);
      await _generateIOSFiles(project);
      await _generatePubspecYaml(project);
      await _generateDefaultAssets(project);
      
      print('Project structure generated successfully for: ${project.name}');
    } catch (e) {
      print('Error generating project structure: $e');
      rethrow;
    }
  }

  Future<void> _generateMetaJson(Project project) async {
    final metaJson = {
      'appName': project.appName,
      'packageName': project.packageName,
      'version': project.version,
      'versionCode': project.versionCode,
      'description': project.description,
      'created': project.createdAt.toIso8601String(),
      'modified': project.modifiedAt.toIso8601String(),
      'projectId': project.id,
      'projectPath': project.projectPath,
    };

    final metaFile = File(path.join(project.projectPath, 'meta.json'));
    await metaFile.writeAsString(JsonEncoder.withIndent('  ').convert(metaJson));
  }

  Future<void> _generateDartFiles(Project project) async {
    // Generate main.dart
    final mainDart = '''
import 'package:flutter/material.dart';

void main() {
  runApp(const ${project.appName.replaceAll(' ', '')}App());
}

class ${project.appName.replaceAll(' ', '')}App extends StatelessWidget {
  const ${project.appName.replaceAll(' ', '')}App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${project.appName}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(
        'Hello, World!',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
''';

    await File(path.join(project.projectPath, 'lib', 'main.dart'))
        .writeAsString(mainDart);
  }

  Future<void> _generateJsonFiles(Project project) async {
    // Generate default UI JSON
    final uiJson = {
      'screens': [
        {
          'name': 'main',
          'title': 'Main Screen',
          'widgets': [
            {
              'id': 'scaffold_1',
              'type': 'Scaffold',
              'properties': {
                'appBar': {
                  'type': 'AppBar',
                  'title': '${project.appName}',
                  'backgroundColor': 'Theme.of(context).colorScheme.inversePrimary',
                },
                'body': {
                  'type': 'Center',
                  'child': {
                    'type': 'Column',
                    'mainAxisAlignment': 'MainAxisAlignment.center',
                    'children': [
                      {
                        'type': 'Icon',
                        'icon': 'Icons.home',
                        'size': 64,
                        'color': 'Colors.blue',
                      },
                      {
                        'type': 'SizedBox',
                        'height': 16,
                      },
                      {
                        'type': 'Text',
                        'data': 'Welcome to ${project.appName}!',
                        'style': {
                          'fontSize': 24,
                          'fontWeight': 'FontWeight.bold',
                        },
                      },
                    ],
                  },
                },
              },
            },
          ],
        },
      ],
    };

    await File(path.join(project.projectPath, 'ui', 'main.json'))
        .writeAsString(JsonEncoder.withIndent('  ').convert(uiJson));

    // Generate default logic JSON
    final logicJson = {
      'events': [
        {
          'name': 'onCreate',
          'type': 'activity',
          'target': 'main',
          'actions': [],
        },
      ],
      'functions': [],
      'variables': [],
    };

    await File(path.join(project.projectPath, 'logic', 'main_logic.json'))
        .writeAsString(JsonEncoder.withIndent('  ').convert(logicJson));
  }

  Future<void> _generateAndroidFiles(Project project) async {
    // Generate AndroidManifest.xml
    final androidManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="${project.packageName}">

    <application
        android:label="${project.appName}"
        android:name="\${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>''';

    await File(path.join(project.projectPath, 'android/app/src/main/AndroidManifest.xml'))
        .writeAsString(androidManifest);

    // Generate MainActivity.kt
    final mainActivity = '''package ${project.packageName}

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}''';

    // Create the kotlin directory structure for the package
    final kotlinDir = path.join(project.projectPath, 'android/app/src/main/kotlin/${project.packageName.replaceAll('.', '/')}');
    await Directory(kotlinDir).create(recursive: true);
    
    await File(path.join(kotlinDir, 'MainActivity.kt'))
        .writeAsString(mainActivity);

    // Generate strings.xml
    final stringsXml = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">${project.appName}</string>
</resources>''';

    await File(path.join(project.projectPath, 'android/app/src/main/res/values/strings.xml'))
        .writeAsString(stringsXml);

    // Generate build.gradle (app level)
    final appBuildGradle = '''plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

android {
    namespace "${project.packageName}"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "${project.packageName}"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode ${project.versionCode}
        versionName "${project.version}"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:\$kotlin_version"
}''';

    await File(path.join(project.projectPath, 'android/app/build.gradle'))
        .writeAsString(appBuildGradle);

    // Generate build.gradle (project level)
    final projectBuildGradle = '''buildscript {
    ext.kotlin_version = '1.7.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:\$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "\${rootProject.buildDir}/\${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}''';

    await File(path.join(project.projectPath, 'android/build.gradle'))
        .writeAsString(projectBuildGradle);

    // Generate settings.gradle
    final settingsGradle = '''include ':app'

def localPropertiesFile = new File(rootProject.projectDir, "local.properties")
def properties = new Properties()

assert localPropertiesFile.exists()
localPropertiesFile.withReader("UTF-8") { reader -> properties.load(reader) }

def flutterSdkPath = properties.getProperty("flutter.sdk")
assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
apply from: "\$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"''';

    await File(path.join(project.projectPath, 'android/settings.gradle'))
        .writeAsString(settingsGradle);
  }

  Future<void> _generateIOSFiles(Project project) async {
    // Generate AppDelegate.swift
    final appDelegate = '''import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}''';

    await File(path.join(project.projectPath, 'ios/Runner/AppDelegate.swift'))
        .writeAsString(appDelegate);

    // Generate Info.plist
    final infoPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>\$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>${project.appName}</string>
	<key>CFBundleExecutable</key>
	<string>\$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>${project.appName}</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>${project.version}</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>${project.versionCode}</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIMainStoryboardFile</key>
	<string>Main</string>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<false/>
	<key>CADisableMinimumFrameDurationOnPhone</key>
	<true/>
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
</dict>
</plist>''';

    await File(path.join(project.projectPath, 'ios/Runner/Info.plist'))
        .writeAsString(infoPlist);

    // Generate Podfile
    final podfile = '''# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end''';

    await File(path.join(project.projectPath, 'ios/Podfile'))
        .writeAsString(podfile);
  }

  Future<void> _generatePubspecYaml(Project project) async {
    final pubspecYaml = '''name: ${project.appName.toLowerCase().replaceAll(' ', '_')}
description: ${project.description}
publish_to: 'none'
version: ${project.version}

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
  assets:
    - assets/default_banner.png
    - assets/example.png''';

    await File(path.join(project.projectPath, 'pubspec.yaml'))
        .writeAsString(pubspecYaml);
  }

  Future<void> _generateDefaultAssets(Project project) async {
    // Create default banner image (placeholder)
    final defaultBannerContent = '''
This is a placeholder for the default banner image.
Replace this file with an actual PNG image for your app banner.
''';
    await File(path.join(project.projectPath, 'assets/default_banner.png'))
        .writeAsString(defaultBannerContent);

    // Create example image (placeholder)
    final exampleImageContent = '''
This is a placeholder for the example image.
Replace this file with an actual PNG image for your app.
''';
    await File(path.join(project.projectPath, 'assets/example.png'))
        .writeAsString(exampleImageContent);

    // Copy app icon if provided
    if (project.iconPath != null && project.iconPath!.isNotEmpty) {
      final sourceIcon = File(project.iconPath!);
      if (await sourceIcon.exists()) {
        final targetIcon = File(path.join(project.projectPath, 'icon.png'));
        await sourceIcon.copy(targetIcon.path);
      }
    }
  }
} 