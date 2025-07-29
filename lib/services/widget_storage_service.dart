import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/flutter_widget_bean.dart';

/// WidgetStorageService - EXACTLY matches Sketchware Pro's eC class functionality
/// Handles saving and loading widget data in JSON format
class WidgetStorageService {
  static const String _tag = 'WidgetStorageService';

  /// Save widgets to layout file (like Sketchware Pro's eC.a() method)
  static Future<void> saveWidgets(
    String projectId,
    String layoutName,
    List<FlutterWidgetBean> widgets,
  ) async {
    try {
      final layoutDir = await _getLayoutDirectory(projectId);
      final layoutFile = File(path.join(layoutDir, '$layoutName.json'));

      // Convert widgets to JSON
      final widgetsJson = widgets.map((widget) => widget.toJson()).toList();

      final layoutData = {
        'layoutName': layoutName,
        'widgets': widgetsJson,
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
      };

      await layoutFile
          .writeAsString(JsonEncoder.withIndent('  ').convert(layoutData));
      print('$_tag: Saved ${widgets.length} widgets to $layoutName');
    } catch (e) {
      print('$_tag: Error saving widgets: $e');
      rethrow;
    }
  }

  /// Load widgets from layout file (like Sketchware Pro's eC.d() method)
  static Future<List<FlutterWidgetBean>> loadWidgets(
    String projectId,
    String layoutName,
  ) async {
    try {
      final layoutDir = await _getLayoutDirectory(projectId);
      final layoutFile = File(path.join(layoutDir, '$layoutName.json'));

      if (!await layoutFile.exists()) {
        print(
            '$_tag: Layout file $layoutName.json not found, returning empty list');
        return [];
      }

      final jsonString = await layoutFile.readAsString();
      final layoutData = jsonDecode(jsonString) as Map<String, dynamic>;

      final widgetsJson = layoutData['widgets'] as List;
      final widgets =
          widgetsJson.map((json) => FlutterWidgetBean.fromJson(json)).toList();

      print('$_tag: Loaded ${widgets.length} widgets from $layoutName');
      return widgets;
    } catch (e) {
      print('$_tag: Error loading widgets: $e');
      return [];
    }
  }

  /// Save single widget (like Sketchware Pro's eC.c() method)
  static Future<void> saveWidget(
    String projectId,
    String layoutName,
    FlutterWidgetBean widget,
  ) async {
    try {
      // Load existing widgets
      final widgets = await loadWidgets(projectId, layoutName);

      // Find and update existing widget or add new one
      final existingIndex = widgets.indexWhere((w) => w.id == widget.id);
      if (existingIndex != -1) {
        widgets[existingIndex] = widget;
      } else {
        widgets.add(widget);
      }

      // Save updated widgets
      await saveWidgets(projectId, layoutName, widgets);
      print('$_tag: Saved widget ${widget.id} to $layoutName');
    } catch (e) {
      print('$_tag: Error saving widget: $e');
      rethrow;
    }
  }

  /// Get widget by ID (like Sketchware Pro's eC.c() method)
  static Future<FlutterWidgetBean?> getWidget(
    String projectId,
    String layoutName,
    String widgetId,
  ) async {
    try {
      final widgets = await loadWidgets(projectId, layoutName);
      return widgets.firstWhere((widget) => widget.id == widgetId);
    } catch (e) {
      print('$_tag: Widget $widgetId not found in $layoutName');
      return null;
    }
  }

  /// Delete widget (like Sketchware Pro's eC.a() method)
  static Future<void> deleteWidget(
    String projectId,
    String layoutName,
    String widgetId,
  ) async {
    try {
      final widgets = await loadWidgets(projectId, layoutName);
      widgets.removeWhere((widget) => widget.id == widgetId);
      await saveWidgets(projectId, layoutName, widgets);
      print('$_tag: Deleted widget $widgetId from $layoutName');
    } catch (e) {
      print('$_tag: Error deleting widget: $e');
      rethrow;
    }
  }

  /// Get all layout names for a project
  static Future<List<String>> getLayoutNames(String projectId) async {
    try {
      final layoutDir = await _getLayoutDirectory(projectId);
      final directory = Directory(layoutDir);

      if (!await directory.exists()) {
        return [];
      }

      final files = await directory.list().toList();
      final layoutNames = <String>[];

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final fileName = path.basename(file.path);
          final layoutName = fileName.replaceAll('.json', '');
          layoutNames.add(layoutName);
        }
      }

      return layoutNames;
    } catch (e) {
      print('$_tag: Error getting layout names: $e');
      return [];
    }
  }

  /// Save widget events (like Sketchware Pro's event handling)
  static Future<void> saveWidgetEvents(
    String projectId,
    String layoutName,
    String widgetId,
    Map<String, String> events,
  ) async {
    try {
      final widget = await getWidget(projectId, layoutName, widgetId);
      if (widget != null) {
        final updatedWidget = widget.copyWith(events: events);
        await saveWidget(projectId, layoutName, updatedWidget);
        print('$_tag: Saved events for widget $widgetId');
      }
    } catch (e) {
      print('$_tag: Error saving widget events: $e');
      rethrow;
    }
  }

  /// Save widget properties (like Sketchware Pro's property updates)
  static Future<void> saveWidgetProperties(
    String projectId,
    String layoutName,
    String widgetId,
    Map<String, dynamic> properties,
  ) async {
    try {
      final widget = await getWidget(projectId, layoutName, widgetId);
      if (widget != null) {
        final updatedWidget = widget.copyWith(properties: properties);
        await saveWidget(projectId, layoutName, updatedWidget);
        print('$_tag: Saved properties for widget $widgetId');
      }
    } catch (e) {
      print('$_tag: Error saving widget properties: $e');
      rethrow;
    }
  }

  /// Save widget layout properties
  static Future<void> saveWidgetLayout(
    String projectId,
    String layoutName,
    String widgetId,
    LayoutBean layout,
  ) async {
    try {
      final widget = await getWidget(projectId, layoutName, widgetId);
      if (widget != null) {
        final updatedWidget = widget.copyWith(layout: layout);
        await saveWidget(projectId, layoutName, updatedWidget);
        print('$_tag: Saved layout for widget $widgetId');
      }
    } catch (e) {
      print('$_tag: Error saving widget layout: $e');
      rethrow;
    }
  }

  /// Get layout directory path
  static Future<String> _getLayoutDirectory(String projectId) async {
    final baseDir = '/storage/emulated/0/.sketchide/data/$projectId/files';
    final layoutDir = path.join(baseDir, 'layouts');
    await Directory(layoutDir).create(recursive: true);
    return layoutDir;
  }

  /// Export layout to JSON file (for backup/sharing)
  static Future<void> exportLayout(
    String projectId,
    String layoutName,
    String exportPath,
  ) async {
    try {
      final widgets = await loadWidgets(projectId, layoutName);
      final exportData = {
        'layoutName': layoutName,
        'widgets': widgets.map((w) => w.toJson()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      };

      final exportFile = File(exportPath);
      await exportFile
          .writeAsString(JsonEncoder.withIndent('  ').convert(exportData));
      print('$_tag: Exported layout $layoutName to $exportPath');
    } catch (e) {
      print('$_tag: Error exporting layout: $e');
      rethrow;
    }
  }

  /// Import layout from JSON file
  static Future<void> importLayout(
    String projectId,
    String layoutName,
    String importPath,
  ) async {
    try {
      final importFile = File(importPath);
      if (!await importFile.exists()) {
        throw Exception('Import file not found: $importPath');
      }

      final jsonString = await importFile.readAsString();
      final importData = jsonDecode(jsonString) as Map<String, dynamic>;

      final widgetsJson = importData['widgets'] as List;
      final widgets =
          widgetsJson.map((json) => FlutterWidgetBean.fromJson(json)).toList();

      await saveWidgets(projectId, layoutName, widgets);
      print('$_tag: Imported layout $layoutName from $importPath');
    } catch (e) {
      print('$_tag: Error importing layout: $e');
      rethrow;
    }
  }

  /// Get layout statistics
  static Future<Map<String, dynamic>> getLayoutStats(
    String projectId,
    String layoutName,
  ) async {
    try {
      final widgets = await loadWidgets(projectId, layoutName);

      final stats = <String, dynamic>{
        'totalWidgets': widgets.length,
        'widgetTypes': <String, int>{},
        'widgetsWithEvents': 0,
        'widgetsWithCustomProperties': 0,
      };

      for (final widget in widgets) {
        // Count widget types
        stats['widgetTypes'][widget.type] =
            (stats['widgetTypes'][widget.type] ?? 0) + 1;

        // Count widgets with events
        if (widget.events.isNotEmpty) {
          stats['widgetsWithEvents']++;
        }

        // Count widgets with custom properties
        if (widget.properties.length > 1) {
          // More than just default properties
          stats['widgetsWithCustomProperties']++;
        }
      }

      return stats;
    } catch (e) {
      print('$_tag: Error getting layout stats: $e');
      return {};
    }
  }
}
