import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/flutter_widget_bean.dart';
import '../models/sketchide_project.dart';

/// FlutterCodeGeneratorService - EXACTLY matches Sketchware Pro's Jx.java functionality
/// Generates Flutter Dart code from FlutterWidgetBean objects in real-time
class FlutterCodeGeneratorService {
  static const String _tag = 'FlutterCodeGeneratorService';

  /// Generate Flutter code from widget beans (like Sketchware Pro's generateCode method)
  static String generateFlutterCode(
    List<FlutterWidgetBean> widgets,
    SketchIDEProject project,
    String className,
  ) {
    final StringBuffer code = StringBuffer();

    // Package imports
    _addImports(code);

    // Class declaration
    _addClassDeclaration(code, className);

    // Widget declarations
    _addWidgetDeclarations(code, widgets);

    // Build method
    _addBuildMethod(code, widgets, className);

    // Event handlers
    _addEventHandlers(code, widgets);

    // Close class
    code.writeln('}');

    return code.toString();
  }

  /// Add necessary imports
  static void _addImports(StringBuffer code) {
    code.writeln("import 'package:flutter/material.dart';");
    code.writeln();
  }

  /// Add class declaration
  static void _addClassDeclaration(StringBuffer code, String className) {
    code.writeln('class $className extends StatefulWidget {');
    code.writeln('  const $className({super.key});');
    code.writeln();
    code.writeln('  @override');
    code.writeln('  _${className}State createState() => _${className}State();');
    code.writeln('}');
    code.writeln();
    code.writeln('class _${className}State extends State<$className> {');
    code.writeln();
  }

  /// Add widget declarations (like Sketchware Pro's addFieldsDeclaration)
  static void _addWidgetDeclarations(
      StringBuffer code, List<FlutterWidgetBean> widgets) {
    for (final widget in widgets) {
      switch (widget.type) {
        case 'TextField':
          code.writeln(
              '  final TextEditingController ${widget.id}Controller = TextEditingController();');
          break;
        case 'Button':
          code.writeln('  // Button ${widget.id} controller');
          break;
      }
    }
    code.writeln();
  }

  /// Add build method with widget tree
  static void _addBuildMethod(
      StringBuffer code, List<FlutterWidgetBean> widgets, String className) {
    code.writeln('  @override');
    code.writeln('  Widget build(BuildContext context) {');
    code.writeln('    return Scaffold(');
    code.writeln('      appBar: AppBar(');
    code.writeln('        title: const Text(\'$className\'),');
    code.writeln(
        '        backgroundColor: Theme.of(context).colorScheme.inversePrimary,');
    code.writeln('      ),');
    code.writeln('      body: ${_generateWidgetTree(widgets)},');
    code.writeln('    );');
    code.writeln('  }');
    code.writeln();
  }

  /// Generate widget tree recursively (like Sketchware Pro's writeWidget method)
  static String _generateWidgetTree(List<FlutterWidgetBean> widgets) {
    if (widgets.isEmpty) {
      return 'Container()'; // SKETCHWARE PRO STYLE: Empty container like empty LinearLayout
    }

    // Find root widgets (those with parent 'root' or no parent)
    final rootWidgets =
        widgets.where((w) => w.parent == 'root' || w.parent.isEmpty).toList();

    if (rootWidgets.isEmpty) {
      return 'Container()'; // SKETCHWARE PRO STYLE: Empty container when no root widgets
    }

    if (rootWidgets.length == 1) {
      return _generateWidgetCode(rootWidgets.first, widgets);
    }

    // Multiple root widgets - wrap in Column
    final children = rootWidgets
        .map((w) => _generateWidgetCode(w, widgets))
        .join(',\n        ');
    return 'Column(\n        children: [\n          $children\n        ],\n      )';
  }

  /// Generate code for a single widget
  static String _generateWidgetCode(
      FlutterWidgetBean widget, List<FlutterWidgetBean> allWidgets) {
    switch (widget.type) {
      case 'Text':
        return _generateTextWidget(widget);
      case 'TextField':
        return _generateTextFieldWidget(widget);
      case 'Container':
        return _generateContainerWidget(widget, allWidgets);
      case 'Icon':
        return _generateIconWidget(widget);
      case 'Row':
        return _generateRowWidget(widget, allWidgets);
      case 'Column':
        return _generateColumnWidget(widget, allWidgets);
      case 'Stack':
        return _generateStackWidget(widget, allWidgets);
      case 'Button':
        return _generateButtonWidget(widget);
      default:
        return 'Container(child: Text(\'Unknown widget: ${widget.type}\'))';
    }
  }

  /// Generate Text widget code
  static String _generateTextWidget(FlutterWidgetBean widget) {
    final text = widget.properties['text'] ?? 'Text';
    final textSize = widget.properties['textSize'] ?? 14.0;
    final textColor = widget.properties['textColor'] ?? 'Colors.black';

    return 'Text(\n        \'$text\',\n        style: TextStyle(\n          fontSize: $textSize,\n          color: $textColor,\n        ),\n      )';
  }

  /// Generate TextField widget code
  static String _generateTextFieldWidget(FlutterWidgetBean widget) {
    final hint = widget.properties['hint'] ?? '';
    final controller = '${widget.id}Controller';

    return 'TextField(\n        controller: $controller,\n        decoration: InputDecoration(\n          hintText: \'$hint\',\n        ),\n      )';
  }

  /// Generate Container widget code
  static String _generateContainerWidget(
      FlutterWidgetBean widget, List<FlutterWidgetBean> allWidgets) {
    final backgroundColor =
        widget.properties['backgroundColor'] ?? 'Colors.transparent';
    final borderColor =
        widget.properties['borderColor'] ?? 'Colors.transparent';
    final borderWidth = widget.properties['borderWidth'] ?? 0.0;
    final borderRadius = widget.properties['borderRadius'] ?? 0.0;

    // Find child widgets
    final children = allWidgets.where((w) => w.parent == widget.id).toList();
    String childCode = '';

    if (children.isNotEmpty) {
      if (children.length == 1) {
        childCode = _generateWidgetCode(children.first, allWidgets);
      } else {
        final childrenCode = children
            .map((w) => _generateWidgetCode(w, allWidgets))
            .join(',\n          ');
        childCode =
            'Column(\n          children: [\n            $childrenCode\n          ],\n        )';
      }
    }

    return 'Container(\n        decoration: BoxDecoration(\n          color: $backgroundColor,\n          border: Border.all(\n            color: $borderColor,\n            width: $borderWidth,\n          ),\n          borderRadius: BorderRadius.circular($borderRadius),\n        ),\n        child: $childCode,\n      )';
  }

  /// Generate Icon widget code
  static String _generateIconWidget(FlutterWidgetBean widget) {
    final iconName = widget.properties['iconName'] ?? 'Icons.star';
    final iconSize = widget.properties['iconSize'] ?? 24.0;
    final iconColor = widget.properties['iconColor'] ?? 'Colors.black';

    return 'Icon(\n        $iconName,\n        size: $iconSize,\n        color: $iconColor,\n      )';
  }

  /// Generate Row widget code
  static String _generateRowWidget(
      FlutterWidgetBean widget, List<FlutterWidgetBean> allWidgets) {
    final children = allWidgets.where((w) => w.parent == widget.id).toList();
    final childrenCode = children
        .map((w) => _generateWidgetCode(w, allWidgets))
        .join(',\n          ');

    return 'Row(\n        children: [\n          $childrenCode\n        ],\n      )';
  }

  /// Generate Column widget code
  static String _generateColumnWidget(
      FlutterWidgetBean widget, List<FlutterWidgetBean> allWidgets) {
    final children = allWidgets.where((w) => w.parent == widget.id).toList();
    final childrenCode = children
        .map((w) => _generateWidgetCode(w, allWidgets))
        .join(',\n          ');

    return 'Column(\n        children: [\n          $childrenCode\n        ],\n      )';
  }

  /// Generate Stack widget code
  static String _generateStackWidget(
      FlutterWidgetBean widget, List<FlutterWidgetBean> allWidgets) {
    final children = allWidgets.where((w) => w.parent == widget.id).toList();
    final childrenCode = children
        .map((w) => _generateWidgetCode(w, allWidgets))
        .join(',\n          ');

    return 'Stack(\n        children: [\n          $childrenCode\n        ],\n      )';
  }

  /// Generate Button widget code
  static String _generateButtonWidget(FlutterWidgetBean widget) {
    final text = widget.properties['text'] ?? 'Button';
    final onPressed = widget.events['onPressed'] ?? '';

    return 'ElevatedButton(\n        onPressed: () {\n          // TODO: Add button logic\n        },\n        child: Text(\'$text\'),\n      )';
  }

  /// Add event handlers
  static void _addEventHandlers(
      StringBuffer code, List<FlutterWidgetBean> widgets) {
    for (final widget in widgets) {
      for (final event in widget.events.entries) {
        code.writeln('  void ${event.key}() {');
        code.writeln('    // TODO: Implement ${event.key} for ${widget.id}');
        code.writeln('    print(\'${event.key} called for ${widget.id}\');');
        code.writeln('  }');
        code.writeln();
      }
    }
  }

  /// Generate and save Flutter code to file
  static Future<void> generateAndSaveCode(
    String projectId,
    List<FlutterWidgetBean> widgets,
    SketchIDEProject project,
    String className,
  ) async {
    final code = generateFlutterCode(widgets, project, className);

    // Get project lib directory
    final baseDir = '/storage/emulated/0/.sketchide/data/$projectId/files';
    final libDir = path.join(baseDir, 'lib');
    await Directory(libDir).create(recursive: true);

    // Save generated code
    final filePath = path.join(libDir, '${className.toLowerCase()}.dart');
    final file = File(filePath);
    await file.writeAsString(code);

    print('$_tag: Generated Flutter code saved to $filePath');
  }

  /// Update existing code file with new widgets
  static Future<void> updateCodeFile(
    String projectId,
    List<FlutterWidgetBean> widgets,
    SketchIDEProject project,
    String className,
  ) async {
    await generateAndSaveCode(projectId, widgets, project, className);
  }
}
