import 'dart:io';
import 'package:path/path.dart' as path;

/// Shared utilities for project file operations
class ProjectFileUtils {
  /// Get project files directory (shared between Android and iOS generators)
  static Future<String> getProjectFilesDirectory(String projectId) async {
    final baseDir = '/storage/emulated/0/.sketchide/data/$projectId/files';
    await Directory(baseDir).create(recursive: true);
    return baseDir;
  }

  /// Create directory if it doesn't exist
  static Future<void> createDirectoryIfNotExists(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  /// Write content to file
  static Future<void> writeFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }

  /// Write binary data to file
  static Future<void> writeFileBytes(String filePath, List<int> bytes) async {
    final file = File(filePath);
    await file.writeAsBytes(bytes);
  }

  /// Create multiple subdirectories
  static Future<void> createSubdirectories(
      String parentDir, List<String> subdirs) async {
    for (final subdir in subdirs) {
      await createDirectoryIfNotExists(path.join(parentDir, subdir));
    }
  }
}
