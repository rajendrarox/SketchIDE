import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import '../../models/sketchide_project.dart';
import '../widgets/export_location_dialog.dart';

class ExportService {
  static Future<bool> exportProject(SketchIDEProject project) async {
    try {

      final exportLocation = await _showExportLocationDialog();
      if (exportLocation == null) return false;


      final archiveData = await _createCompleteProjectArchive(project);


      final success = await _saveToLocation(
          exportLocation, '${project.projectInfo.appName}.ide', archiveData);

      return success;
    } catch (e) {
      print('Export failed: $e');
      return false;
    }
  }

  static Future<bool> exportProjectWithLocation(
      SketchIDEProject project, String location) async {
    try {
      final archiveData = await _createCompleteProjectArchive(project);

      final success = await _saveToLocation(
          location, '${project.projectInfo.appName}.ide', archiveData);

      return success;
    } catch (e) {
      print('Export failed: $e');
      return false;
    }
  }

  static Future<String?> _showExportLocationDialog() async {

    return 'app_documents';
  }

  static Future<String?> showExportLocationDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const ExportLocationDialog(),
    );
    return result;
  }

  static Future<Uint8List> _createCompleteProjectArchive(
      SketchIDEProject project) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_createArchiveInIsolate, {
      'projectPath':
          'projects', 
      'projectName': project.projectInfo.appName,
      'sendPort': receivePort.sendPort,
    });

    final result = await receivePort.first as Uint8List;
    return result;
  }

  static void _createArchiveInIsolate(Map<String, dynamic> data) {
    final projectPath = data['projectPath'] as String;
    final projectName = data['projectName'] as String;
    final sendPort = data['sendPort'] as SendPort;

    try {
      final archive = Archive();
      final projectDir = Directory(projectPath);

      if (projectDir.existsSync()) {
        _addDirectoryToArchiveRecursive(projectDir, archive, projectName);

        final manifest = _createProjectManifest(projectName);
        final manifestBytes =
            utf8.encode(JsonEncoder.withIndent('  ').convert(manifest));
        archive.addFile(ArchiveFile(
            'project_manifest.json', manifestBytes.length, manifestBytes));

        final zipEncoder = ZipEncoder();
        final encoded = zipEncoder.encode(archive);
        final result =
            encoded != null ? Uint8List.fromList(encoded) : Uint8List(0);

        sendPort.send(result);
      } else {
        sendPort.send(Uint8List(0));
      }
    } catch (e) {
      sendPort.send(Uint8List(0));
    }
  }

  static void _addDirectoryToArchiveRecursive(
      Directory dir, Archive archive, String basePath) {
    try {
      final entities = dir.listSync(recursive: false);

      for (final entity in entities) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: dir.path);
          final archivePath = '$basePath/$relativePath';

          if (!_shouldSkipFile(entity, relativePath)) {
            try {
              final bytes = entity.readAsBytesSync();
              final archiveFile = ArchiveFile(archivePath, bytes.length, bytes);
              archive.addFile(archiveFile);
            } catch (e) {
              print('Could not read file: ${entity.path}');
            }
          }
        } else if (entity is Directory) {
          final relativePath = path.relative(entity.path, from: dir.path);
          final archivePath = '$basePath/$relativePath';
          _addDirectoryToArchiveRecursive(entity, archive, archivePath);
        }
      }
    } catch (e) {
      print('Error reading directory: ${dir.path}');
    }
  }

  static bool _shouldSkipFile(File file, String relativePath) {
    final skipPatterns = [
      '.DS_Store',
      'Thumbs.db',
      '*.tmp',
      '*.temp',
      '*.log',
    ];

    for (final pattern in skipPatterns) {
      if (relativePath.contains(pattern.replaceAll('*', ''))) {
        return true;
      }
    }

    return false;
  }

  static Map<String, dynamic> _createProjectManifest(String projectName) {
    return {
      'projectInfo': {
        'name': projectName,
        'exportedAt': DateTime.now().toIso8601String(),
        'exportVersion': '3.0.0',
        'sketchideVersion': '0.1.0',
        'format': 'complete_archive',
      },
      'fileStructure': {
        'description': 'Complete project archive with all files',
        'includes': [
          'All source code files',
          'All UI layout files',
          'All logic block files',
          'All asset files',
          'All configuration files',
          'Project metadata',
        ],
        'excludes': [
          'System temporary files',
          'Build artifacts (can be regenerated)',
          'IDE cache files',
        ]
      }
    };
  }

  static Future<bool> _saveToLocation(
      String location, String fileName, Uint8List data) async {
    switch (location) {
      case 'app_documents':
        return await _saveToAppDirectory(fileName, data);
      case 'downloads':
        return await _saveToDownloads(fileName, data);
      case 'external_storage':
        return await _saveToExternalStorage(fileName, data);
      case 'custom_location':
        return await _saveToCustomLocation(fileName, data);
      default:
        return await _saveToAppDirectory(fileName, data);
    }
  }

  static Future<bool> _saveToAppDirectory(
      String fileName, Uint8List fileBytes) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final file = File('${documentsDir.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      print('File saved to app directory: ${file.path}');
      return true;
    } catch (e) {
      print('App directory save failed: $e');
      return false;
    }
  }

  static Future<bool> _saveToDownloads(
      String fileName, Uint8List fileBytes) async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(fileBytes);
        print('File saved to Downloads: ${file.path}');
        return true;
      }
      return false;
    } catch (e) {
      print('Downloads save failed: $e');
      return false;
    }
  }

  static Future<bool> _saveToExternalStorage(
      String fileName, Uint8List fileBytes) async {
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final file = File('${externalDir.path}/$fileName');
        await file.writeAsBytes(fileBytes);
        print('File saved to external storage: ${file.path}');
        return true;
      }
      return false;
    } catch (e) {
      print('External storage save failed: $e');
      return false;
    }
  }

  static Future<bool> _saveToCustomLocation(
      String fileName, Uint8List fileBytes) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Project Export',
        fileName: fileName,
        allowedExtensions: ['ide'],
        type: FileType.custom,
        lockParentWindow: true,
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(fileBytes);
        print('File saved to custom location: ${file.path}');
        return true;
      }
      return false;
    } catch (e) {
      print('Custom location save failed: $e');
      return false;
    }
  }

  static Future<SketchIDEProject?> importProject() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Import Project',
        allowedExtensions: ['ide'],
        type: FileType.custom,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final bytes = await file.readAsBytes();

        try {
          final archive = ZipDecoder().decodeBytes(bytes);

          final manifestFile = archive.findFile('project_manifest.json');
          if (manifestFile != null) {
            final manifestData =
                json.decode(utf8.decode(manifestFile.content as List<int>));
            final projectInfo = manifestData['projectInfo'];

            final project = SketchIDEProject.createEmpty(
              appName: projectInfo['name'],
              packageName: projectInfo['packageName'] ??
                  'com.sketchide.${projectInfo['name'].toLowerCase()}',
              projectName: projectInfo['name'], // Use app name as project name
              iconPath: projectInfo['iconPath'] ?? '',
            );

            return project;
          }
        } catch (e) {
          try {
            final decompressed = GZipDecoder().decodeBytes(bytes);
            final jsonData = utf8.decode(decompressed);
            final projectData = json.decode(jsonData);
            final projectInfo = projectData['projectInfo'];

            final project = SketchIDEProject.createEmpty(
              appName: projectInfo['name'],
              packageName: projectInfo['packageName'],
              projectName: projectInfo['name'], // Use app name as project name
              iconPath: projectInfo['iconPath'],
            );

            return project;
          } catch (e2) {
            print('Both ZIP and JSON import failed: $e2');
            return null;
          }
        }
      }

      return null;
    } catch (e) {
      print('Import failed: $e');
      return null;
    }
  }
}
