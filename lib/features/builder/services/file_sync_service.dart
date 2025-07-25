import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../../../domain/models/project.dart';
import '../models/widget_data.dart';
import 'code_generator.dart';

class FileSyncService {
  static Future<void> syncWidgetsToCode(Project project, List<WidgetData> widgets) async {
    try {
      final projectPath = project.projectPath;
      
      // Generate updated code
      final mainDartCode = CodeGenerator.generateMainDartCode(widgets, project.appName);
      final homePageCode = CodeGenerator.generateHomePageCode(widgets, project.appName);
      
      // Update main.dart
      await _updateFile('$projectPath/lib/main.dart', mainDartCode);
      
      
      
      // Save widgets data to JSON for persistence
      final widgetsJson = CodeGenerator.generateWidgetsJson(widgets);
      await _updateFile('$projectPath/ui/main.json', widgetsJson);
      
      print('Successfully synced ${widgets.length} widgets to code files');
    } catch (e) {
      print('Error syncing widgets to code: $e');
      rethrow;
    }
  }

  static Future<void> _updateFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      final directory = file.parent;
      
      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      // Write the content
      await file.writeAsString(content);
      print('Updated file: $filePath');
    } catch (e) {
      print('Error updating file $filePath: $e');
      rethrow;
    }
  }

  static Future<List<WidgetData>> loadWidgetsFromProject(Project project) async {
    try {
      final uiDir = Directory('${project.projectPath}/ui');
      if (!await uiDir.exists()) {
        return [];
      }
      
      final List<WidgetData> allWidgets = [];
      
      // Load all widget files
      final files = await uiDir.list().where((entity) => 
        entity is File && entity.path.endsWith('.json')
      ).toList();
      
      for (final file in files) {
        try {
          final content = await File(file.path).readAsString();
          final widgets = CodeGenerator.parseWidgetsFromJson(content);
          allWidgets.addAll(widgets);
        } catch (e) {
          print('Error loading widgets from ${file.path}: $e');
        }
      }
      
      return allWidgets;
    } catch (e) {
      print('Error loading widgets from project: $e');
      return [];
    }
  }

  static Future<List<WidgetData>> loadWidgetsForFile(Project project, String fileName) async {
    try {
      final widgetsFile = File('${project.projectPath}/ui/${fileName.replaceAll('.dart', '.json')}');
      
      if (await widgetsFile.exists()) {
        final content = await widgetsFile.readAsString();
        return CodeGenerator.parseWidgetsFromJson(content);
      }
      
      return [];
    } catch (e) {
      print('Error loading widgets for file $fileName: $e');
      return [];
    }
  }

  static Future<void> saveWidgetsToProject(Project project, List<WidgetData> widgets) async {
    try {
      // Group widgets by file
      final Map<String, List<WidgetData>> widgetsByFile = {};
      
      for (final widget in widgets) {
        final fileId = widget.properties['fileId'] ?? 'main.dart';
        if (!widgetsByFile.containsKey(fileId)) {
          widgetsByFile[fileId] = [];
        }
        widgetsByFile[fileId]!.add(widget);
      }
      
      // Save each file's widgets separately
      for (final entry in widgetsByFile.entries) {
        final fileName = entry.key;
        final fileWidgets = entry.value;
        final widgetsJson = CodeGenerator.generateWidgetsJson(fileWidgets);
        await _updateFile('${project.projectPath}/ui/${fileName.replaceAll('.dart', '.json')}', widgetsJson);
      }
      
      print('Successfully saved widgets to ${widgetsByFile.length} files');
    } catch (e) {
      print('Error saving widgets to project: $e');
      rethrow;
    }
  }

  // Update the mobile frame's widget storage to use the new system
  static Future<void> updateMobileFrameWidgets(String projectId, List<WidgetData> widgets) async {
    try {
      final widgetsJson = CodeGenerator.generateWidgetsJson(widgets);
      await _updateFile('projects/$projectId/widgets.json', widgetsJson);
      print('Updated mobile frame widgets for project: $projectId');
    } catch (e) {
      print('Error updating mobile frame widgets: $e');
      rethrow;
    }
  }

  // Load widgets from mobile frame storage
  static Future<List<WidgetData>> loadMobileFrameWidgets(String projectId) async {
    try {
      final widgetsFile = File('projects/$projectId/widgets.json');
      
      if (await widgetsFile.exists()) {
        final content = await widgetsFile.readAsString();
        return CodeGenerator.parseWidgetsFromJson(content);
      }
      
      return [];
    } catch (e) {
      print('Error loading mobile frame widgets: $e');
      return [];
    }
  }

  // Convert old PlacedWidget format to new WidgetData format
  static WidgetData convertPlacedWidgetToWidgetData(dynamic placedWidget) {
    return WidgetData(
      id: placedWidget.id,
      type: placedWidget.type,
      properties: Map<String, dynamic>.from(placedWidget.properties),
    );
  }

  // Convert WidgetData to PlacedWidget format for backward compatibility
  static dynamic convertWidgetDataToPlacedWidget(WidgetData widgetData) {
    return PlacedWidget(
      id: widgetData.id,
      type: widgetData.type,
      properties: widgetData.properties,
    );
  }
}

// Temporary class for backward compatibility
class PlacedWidget {
  final String id;
  final String type;
  final Map<String, dynamic> properties;

  PlacedWidget({
    required this.id,
    required this.type,
    required this.properties,
  });
} 