import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/sketchide_project.dart';
import 'project_file_utils.dart';

class IOSCodeGenerator {
  /// Generate complete iOS project structure
  static Future<void> generateIOSProject(
    String projectId,
    SketchIDEProject project,
  ) async {
    final filesDir = await ProjectFileUtils.getProjectFilesDirectory(projectId);
    final iosDir = path.join(filesDir, 'ios');
    await Directory(iosDir).create(recursive: true);

    // Create Runner directory
    final runnerDir = path.join(iosDir, 'Runner');
    await Directory(runnerDir).create(recursive: true);

    // Create Runner.xcodeproj directory
    final xcodeprojDir = path.join(iosDir, 'Runner.xcodeproj');
    await Directory(xcodeprojDir).create(recursive: true);

    // Create Assets.xcassets directory
    final assetsDir = path.join(runnerDir, 'Assets.xcassets');
    await Directory(assetsDir).create(recursive: true);

    // Generate iOS files
    await _generateInfoPlist(runnerDir, project);
    await _generateAppDelegate(runnerDir, project);
    await _generateLaunchScreen(runnerDir, project);
    await _generateDefaultIcons(assetsDir, project);
  }

  /// Generate Info.plist
  static Future<void> _generateInfoPlist(
    String runnerDir,
    SketchIDEProject project,
  ) async {
    final infoPlistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>\$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>${project.projectInfo.appName}</string>
	<key>CFBundleExecutable</key>
	<string>\$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>${project.projectInfo.appName}</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>${project.projectInfo.versionName}</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>${project.projectInfo.versionCode}</string>
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

    final infoPlistFile = File(path.join(runnerDir, 'Info.plist'));
    await infoPlistFile.writeAsString(infoPlistContent);
  }

  /// Generate AppDelegate.swift
  static Future<void> _generateAppDelegate(
    String runnerDir,
    SketchIDEProject project,
  ) async {
    final appDelegateContent = '''import UIKit
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

    final appDelegateFile = File(path.join(runnerDir, 'AppDelegate.swift'));
    await appDelegateFile.writeAsString(appDelegateContent);
  }

  /// Generate LaunchScreen.storyboard
  static Future<void> _generateLaunchScreen(
    String runnerDir,
    SketchIDEProject project,
  ) async {
    final launchScreenContent = '''<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="21507" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES" initialViewController="01J-lp-oVM">
    <device id="retina6_12" orientation="portrait" appearance="light"/>
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="21505"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="System colors in document resources" minToolsVersion="11.0"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <scenes>
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <rect key="frame" x="0.0" y="0.0" width="393" height="852"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <imageView opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="scaleAspectFit" image="LaunchImage" translatesAutoresizingMaskIntoConstraints="NO" id="YRO-k0-Ey4">
                                <rect key="frame" x="0.0" y="0.0" width="393" height="852"/>
                            </imageView>
                        </subviews>
                        <viewLayoutGuide key="safeArea" id="Bcu-3y-fUS"/>
                        <color key="backgroundColor" systemColor="systemBackgroundColor"/>
                        <constraints>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="leading" secondItem="Ze5-6b-2t3" secondAttribute="leading" id="3p8-FC-h6j"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="top" secondItem="Ze5-6b-2t3" secondAttribute="top" id="Q3B-4B-g5h"/>
                            <constraint firstAttribute="trailing" secondItem="YRO-k0-Ey4" secondAttribute="trailing" id="RwV-gh-h6j"/>
                            <constraint firstAttribute="bottom" secondItem="YRO-k0-Ey4" secondAttribute="bottom" id="SdS-Ul-gh6"/>
                        </constraints>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
    <resources>
        <image name="LaunchImage" width="168" height="185"/>
        <systemColor name="systemBackgroundColor">
            <color white="1" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
        </systemColor>
    </resources>
</document>''';

    final launchScreenFile =
        File(path.join(runnerDir, 'Base.lproj', 'LaunchScreen.storyboard'));
    await Directory(path.dirname(launchScreenFile.path))
        .create(recursive: true);
    await launchScreenFile.writeAsString(launchScreenContent);
  }

  /// Generate default app icons for iOS
  static Future<void> _generateDefaultIcons(
    String assetsDir,
    SketchIDEProject project,
  ) async {
    // Create AppIcon.appiconset directory
    final appIconDir = path.join(assetsDir, 'AppIcon.appiconset');
    await Directory(appIconDir).create(recursive: true);

    // Generate Contents.json for AppIcon
    final contentsJson = '''{
  "images" : [
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}''';

    final contentsFile = File(path.join(appIconDir, 'Contents.json'));
    await contentsFile.writeAsString(contentsJson);

    // Create a simple default icon placeholder
    final defaultIconContent = '''// Default iOS App Icon
// This is a placeholder for the actual icon files
// In a real implementation, you would generate actual PNG files for each size
// For now, we create a simple SVG that can be converted to PNG later

<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <rect width="1024" height="1024" fill="#2196F3"/>
  <text x="512" y="512" font-family="Arial, sans-serif" font-size="400" fill="white" text-anchor="middle" dominant-baseline="middle">S</text>
</svg>''';

    final defaultIconFile = File(path.join(appIconDir, 'Icon-App-1024x1024@1x.png'));
    await defaultIconFile.writeAsString(defaultIconContent);
  }
}
