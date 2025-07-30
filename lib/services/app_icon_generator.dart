import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'project_file_utils.dart';

class AppIconGenerator {
  static const List<int> androidSizes = [48, 72, 96, 144, 192];
  static const List<int> iosSizes = [
    20,
    29,
    40,
    58,
    60,
    76,
    80,
    87,
    120,
    152,
    167,
    180,
    1024
  ];

  static Future<void> generateDefaultIcons(
      String projectId, String appName) async {
    final projectDir =
        await ProjectFileUtils.getProjectFilesDirectory(projectId);

    await _generateAndroidIcons(projectDir, appName);
    await _generateIOSIcons(projectDir, appName);
  }

  static Future<void> _generateAndroidIcons(
      String projectDir, String appName) async {
    final androidDir =
        path.join(projectDir, 'android', 'app', 'src', 'main', 'res');

    for (final size in androidSizes) {
      final density = _getAndroidDensity(size);
      final iconDir = path.join(androidDir, 'mipmap-$density');

      await ProjectFileUtils.createDirectoryIfNotExists(iconDir);

      final iconPath = path.join(iconDir, 'ic_launcher.png');
      await _generateIcon(iconPath, size, appName);
    }
  }

  static Future<void> _generateIOSIcons(
      String projectDir, String appName) async {
    final iosDir = path.join(
        projectDir, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset');

    await ProjectFileUtils.createDirectoryIfNotExists(iosDir);

    for (final size in iosSizes) {
      final iconPath = path.join(iosDir, 'Icon-App-${size}x${size}@1x.png');
      await _generateIcon(iconPath, size, appName);
    }

    await _generateIOSContentsJson(iosDir);
  }

  static String _getAndroidDensity(int size) {
    switch (size) {
      case 48:
        return 'mdpi';
      case 72:
        return 'hdpi';
      case 96:
        return 'xhdpi';
      case 144:
        return 'xxhdpi';
      case 192:
        return 'xxxhdpi';
      default:
        return 'hdpi';
    }
  }

  static Future<void> _generateIcon(
      String iconPath, int size, String appName) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..color = _getColorFromString(appName)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), paint);

    final initials = _getAppInitials(appName);
    final textPainter = TextPainter(
      text: TextSpan(
        text: initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    await ProjectFileUtils.writeFileBytes(iconPath, bytes);
  }

  static String _getAppInitials(String appName) {
    if (appName.isEmpty) return 'A';

    final words = appName.trim().split(' ');
    if (words.length == 1) {
      return appName.substring(0, 1).toUpperCase();
    }

    final firstWord = words[0];
    final lastWord = words.last;

    if (firstWord == lastWord) {
      return firstWord.substring(0, 1).toUpperCase();
    }

    return '${firstWord.substring(0, 1)}${lastWord.substring(0, 1)}'
        .toUpperCase();
  }

  static Color _getColorFromString(String text) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.deepPurple,
    ];

    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }

    return colors[hash.abs() % colors.length];
  }

  static Future<void> _generateIOSContentsJson(String iosDir) async {
    const contentsJson = '''{
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

    await ProjectFileUtils.writeFile(
        path.join(iosDir, 'Contents.json'), contentsJson);
  }
}
