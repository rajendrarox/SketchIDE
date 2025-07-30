import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/sketchide_project.dart';
import 'project_file_utils.dart';

class AndroidCodeGenerator {
  /// Generate complete Android project structure
  static Future<void> generateAndroidProject(
    String projectId,
    SketchIDEProject project,
  ) async {
    final filesDir = await ProjectFileUtils.getProjectFilesDirectory(projectId);
    final androidDir = path.join(filesDir, 'android');
    await Directory(androidDir).create(recursive: true);

    // Create app directory
    final appDir = path.join(androidDir, 'app');
    await Directory(appDir).create(recursive: true);

    // Create src/main directory
    final mainDir = path.join(appDir, 'src', 'main');
    await Directory(mainDir).create(recursive: true);

    // Create java directory
    final javaDir = path.join(mainDir, 'java', 'com', 'sketchide', 'app');
    await Directory(javaDir).create(recursive: true);

    // Create res directory
    final resDir = path.join(mainDir, 'res');
    await Directory(resDir).create(recursive: true);

    // Create res subdirectories
    final resSubdirs = [
      'drawable',
      'drawable-hdpi',
      'drawable-mdpi',
      'drawable-xhdpi',
      'drawable-xxhdpi',
      'drawable-xxxhdpi',
      'mipmap-hdpi',
      'mipmap-mdpi',
      'mipmap-xhdpi',
      'mipmap-xxhdpi',
      'mipmap-xxxhdpi',
      'values',
      'values-night'
    ];
    for (final subdir in resSubdirs) {
      await Directory(path.join(resDir, subdir)).create(recursive: true);
    }

    // Generate Android files
    await _generateAndroidManifest(mainDir, project);
    await _generateAppBuildGradle(appDir, project);
    await _generateProjectBuildGradle(androidDir, project);
    await _generateGradleProperties(androidDir, project);
    await _generateSettingsGradle(androidDir, project);
    await _generateMainActivity(javaDir, project);
    await _generateStyles(resDir, project);
    await _generateDefaultIcons(resDir, project);
    await _generateLaunchBackground(resDir, project);
  }

  /// Generate AndroidManifest.xml
  static Future<void> _generateAndroidManifest(
    String mainDir,
    SketchIDEProject project,
  ) async {
    final manifestContent = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="${project.projectInfo.packageName}">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

    <application
        android:label="${project.projectInfo.appName}"
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

    final manifestFile = File(path.join(mainDir, 'AndroidManifest.xml'));
    await manifestFile.writeAsString(manifestContent);
  }

  /// Generate app/build.gradle
  static Future<void> _generateAppBuildGradle(
    String appDir,
    SketchIDEProject project,
  ) async {
    final buildGradleContent = '''def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '${project.projectInfo.versionCode}'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '${project.projectInfo.versionName}'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "\$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    namespace "${project.projectInfo.packageName}"
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
        applicationId "${project.projectInfo.packageName}"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
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

    final buildGradleFile = File(path.join(appDir, 'build.gradle'));
    await buildGradleFile.writeAsString(buildGradleContent);
  }

  /// Generate project build.gradle
  static Future<void> _generateProjectBuildGradle(
    String androidDir,
    SketchIDEProject project,
  ) async {
    final buildGradleContent = '''buildscript {
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

    final buildGradleFile = File(path.join(androidDir, 'build.gradle'));
    await buildGradleFile.writeAsString(buildGradleContent);
  }

  /// Generate gradle.properties
  static Future<void> _generateGradleProperties(
    String androidDir,
    SketchIDEProject project,
  ) async {
    final gradlePropertiesContent = '''org.gradle.jvmargs=-Xmx1536M
android.useAndroidX=true
android.enableJetifier=true''';

    final gradlePropertiesFile =
        File(path.join(androidDir, 'gradle.properties'));
    await gradlePropertiesFile.writeAsString(gradlePropertiesContent);
  }

  /// Generate settings.gradle
  static Future<void> _generateSettingsGradle(
    String androidDir,
    SketchIDEProject project,
  ) async {
    final settingsGradleContent = '''include ':app'

def localPropertiesFile = new File(rootProject.projectDir, "local.properties")
def properties = new Properties()

assert localPropertiesFile.exists()
localPropertiesFile.withReader("UTF-8") { reader -> properties.load(reader) }

def flutterSdkPath = properties.getProperty("flutter.sdk")
assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
apply from: "\$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"''';

    final settingsGradleFile = File(path.join(androidDir, 'settings.gradle'));
    await settingsGradleFile.writeAsString(settingsGradleContent);
  }

  /// Generate MainActivity.kt
  static Future<void> _generateMainActivity(
    String javaDir,
    SketchIDEProject project,
  ) async {
    final mainActivityContent = '''package ${project.projectInfo.packageName}

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}''';

    final mainActivityFile = File(path.join(javaDir, 'MainActivity.kt'));
    await mainActivityFile.writeAsString(mainActivityContent);
  }

  /// Generate styles.xml
  static Future<void> _generateStyles(
    String resDir,
    SketchIDEProject project,
  ) async {
    final stylesContent = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>''';

    final stylesFile = File(path.join(resDir, 'values', 'styles.xml'));
    await stylesFile.writeAsString(stylesContent);
  }

  /// Generate default app icons for all densities
  static Future<void> _generateDefaultIcons(
    String resDir,
    SketchIDEProject project,
  ) async {
    // Generate default launcher icons for all densities
    await _generateLauncherIcon(resDir, 'mipmap-mdpi', 48);
    await _generateLauncherIcon(resDir, 'mipmap-hdpi', 72);
    await _generateLauncherIcon(resDir, 'mipmap-xhdpi', 96);
    await _generateLauncherIcon(resDir, 'mipmap-xxhdpi', 144);
    await _generateLauncherIcon(resDir, 'mipmap-xxxhdpi', 192);
  }

  /// Generate a single launcher icon
  static Future<void> _generateLauncherIcon(
    String resDir,
    String density,
    int size,
  ) async {
    // Create a simple default icon (blue circle with "S" for SketchIDE)
    final iconContent = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>''';

    final iconFile = File(path.join(resDir, density, 'ic_launcher.xml'));
    await iconFile.writeAsString(iconContent);

    // Create background color
    final backgroundContent = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#2196F3</color>
</resources>''';

    final backgroundFile = File(path.join(resDir, 'values', 'ic_launcher_background.xml'));
    await backgroundFile.writeAsString(backgroundContent);

    // Create foreground icon (simple "S" shape)
    final foregroundContent = '''<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="${size}dp"
    android:height="${size}dp"
    android:viewportWidth="${size}"
    android:viewportHeight="${size}">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M${size * 0.3},${size * 0.2} C${size * 0.2},${size * 0.2} ${size * 0.2},${size * 0.3} ${size * 0.2},${size * 0.4} C${size * 0.2},${size * 0.5} ${size * 0.3},${size * 0.6} ${size * 0.4},${size * 0.6} C${size * 0.5},${size * 0.6} ${size * 0.6},${size * 0.5} ${size * 0.6},${size * 0.4} C${size * 0.6},${size * 0.3} ${size * 0.5},${size * 0.2} ${size * 0.4},${size * 0.2} Z"/>
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M${size * 0.3},${size * 0.6} C${size * 0.2},${size * 0.6} ${size * 0.2},${size * 0.7} ${size * 0.2},${size * 0.8} C${size * 0.2},${size * 0.9} ${size * 0.3},${size} ${size * 0.4},${size} C${size * 0.5},${size} ${size * 0.6},${size * 0.9} ${size * 0.6},${size * 0.8} C${size * 0.6},${size * 0.7} ${size * 0.5},${size * 0.6} ${size * 0.4},${size * 0.6} Z"/>
</vector>''';

    final foregroundFile = File(path.join(resDir, 'drawable', 'ic_launcher_foreground.xml'));
    await foregroundFile.writeAsString(foregroundContent);
  }

  /// Generate launch background drawable
  static Future<void> _generateLaunchBackground(
    String resDir,
    SketchIDEProject project,
  ) async {
    final launchBackgroundContent = '''<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
    <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/ic_launcher" />
    </item>
</layer-list>''';

    final launchBackgroundFile = File(path.join(resDir, 'drawable', 'launch_background.xml'));
    await launchBackgroundFile.writeAsString(launchBackgroundContent);
  }
}
