import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../../../domain/models/project.dart';
import '../models/dart_file_bean.dart';
import '../models/widget_data.dart';
import '../services/file_sync_service.dart';
import 'code_generator.dart';

class DartFileManager {
  static const String _filesConfigName = 'dart_files.json';
  
  // Get all Dart files for a project
  static Future<List<DartFileBean>> getAllDartFiles(Project project) async {
    try {
      final configFile = File('${project.projectPath}/$_filesConfigName');
      List<DartFileBean> files = [];
      
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        final List<dynamic> filesJson = jsonDecode(content);
        files = filesJson.map((json) => DartFileBean.fromJson(json)).toList();
      } else {
        // Create default files if config doesn't exist
        files = await _createDefaultFiles(project);
        await _saveFilesConfig(project, files);
      }
      
      return files;
    } catch (e) {
      print('Error getting Dart files: $e');
      return await _createDefaultFiles(project);
    }
  }

  // Create default files for a new project
  static Future<List<DartFileBean>> _createDefaultFiles(Project project) async {
    final List<DartFileBean> files = [
      DartFileBean.mainDart(project.projectPath),
    ];
    
    // Create the actual files
    for (final file in files) {
      await _createDartFile(file, project);
    }
    
    // Create default widgets for main.dart
    await _createDefaultWidgetsForMain(project);
    
    return files;
  }

  // Create default widgets for main.dart (Hello World structure)
  static Future<void> _createDefaultWidgetsForMain(Project project) async {
    try {
      final List<WidgetData> defaultWidgets = [
        // Text widget for Hello World
        WidgetData(
          id: 'text_1',
          type: WidgetData.TYPE_TEXT,
          properties: {
            'text': 'Hello, World!',
            'style': 'Theme.of(context).textTheme.headlineMedium',
            'fileId': 'main.dart',
          },
        ),
      ];

      // Save default widgets to main.dart
      await FileSyncService.saveWidgetsToProject(project, defaultWidgets);
      
      print('Created default Hello World widgets for main.dart');
    } catch (e) {
      print('Error creating default widgets: $e');
    }
  }

  // Create a new Dart file
  static Future<DartFileBean> createDartFile(
    Project project,
    DartFileType fileType,
    String name,
  ) async {
    final DartFileBean newFile;
    
    switch (fileType) {
      case DartFileType.page:
        newFile = DartFileBean.customPage(project.projectPath, name);
        break;
      case DartFileType.service:
        newFile = DartFileBean.service(project.projectPath, name);
        break;
      case DartFileType.model:
        newFile = DartFileBean.model(project.projectPath, name);
        break;
      case DartFileType.widget:
        newFile = DartFileBean.widget(project.projectPath, name);
        break;
      default:
        throw ArgumentError('Cannot create main.dart file manually');
    }
    
    // Create the actual file
    await _createDartFile(newFile, project);
    
    // Add to files list
    final files = await getAllDartFiles(project);
    files.add(newFile);
    await _saveFilesConfig(project, files);
    
    return newFile;
  }

  // Create the actual Dart file with default content
  static Future<void> _createDartFile(DartFileBean file, Project project) async {
    try {
      final dartFile = File(file.filePath);
      final directory = dartFile.parent;
      
      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      // Generate default content based on file type
      final content = _generateDefaultContent(file, project);
      await dartFile.writeAsString(content);
      
      print('Created Dart file: ${file.filePath}');
    } catch (e) {
      print('Error creating Dart file: $e');
      rethrow;
    }
  }

  // Generate default content for a Dart file
  static String _generateDefaultContent(DartFileBean file, Project project) {
    switch (file.fileType) {
      case DartFileType.main:
        return _generateDefaultMainDartContent(project);
      case DartFileType.page:
        return _generatePageContent(file, project);
      case DartFileType.service:
        return _generateServiceContent(file, project);
      case DartFileType.model:
        return _generateModelContent(file, project);
      case DartFileType.widget:
        return _generateWidgetContent(file, project);
    }
  }

  // Generate default main.dart with Hello World structure
  static String _generateDefaultMainDartContent(Project project) {
    final StringBuffer code = StringBuffer();
    
    code.writeln("import 'package:flutter/material.dart';");
    code.writeln();
    code.writeln("void main() {");
    code.writeln("  runApp(MyApp());");
    code.writeln("}");
    code.writeln();
    code.writeln("class MyApp extends StatelessWidget {");
    code.writeln("  @override");
    code.writeln("  Widget build(BuildContext context) {");
    code.writeln("    return MaterialApp(");
    code.writeln("      title: '${project.appName}',");
    code.writeln("      theme: ThemeData(");
    code.writeln("        primarySwatch: Colors.blue,");
    code.writeln("        useMaterial3: true,");
    code.writeln("      ),");
    code.writeln("      home: MyHomePage(),");
    code.writeln("    );");
    code.writeln("  }");
    code.writeln("}");
    code.writeln();
    code.writeln("class MyHomePage extends StatelessWidget {");
    code.writeln("  @override");
    code.writeln("  Widget build(BuildContext context) {");
    code.writeln("    return Scaffold(");
    code.writeln("      body: Text(");
    code.writeln("        'Hello, World!',");
    code.writeln("        style: Theme.of(context).textTheme.headlineMedium,");
    code.writeln("      ),");
    code.writeln("    );");
    code.writeln("  }");
    code.writeln("}");
    
    return code.toString();
  }

  static String _generatePageContent(DartFileBean file, Project project) {
    final className = file.className;
    final StringBuffer code = StringBuffer();
    
    code.writeln("import 'package:flutter/material.dart';");
    code.writeln();
    code.writeln("class $className extends StatefulWidget {");
    code.writeln("  @override");
    code.writeln("  _${className}State createState() => _${className}State();");
    code.writeln("}");
    code.writeln();
    code.writeln("class _${className}State extends State<$className> {");
    code.writeln("  @override");
    code.writeln("  Widget build(BuildContext context) {");
    code.writeln("    return Scaffold(");
    code.writeln("      appBar: AppBar(");
    code.writeln("        title: Text('${file.metadata['pageName'] ?? className}'),");
    code.writeln("        backgroundColor: Colors.blue,");
    code.writeln("        foregroundColor: Colors.white,");
    code.writeln("      ),");
    code.writeln("      body: Center(");
    code.writeln("        child: Column(");
    code.writeln("          mainAxisAlignment: MainAxisAlignment.center,");
    code.writeln("          children: [");
    code.writeln("            Icon(Icons.pageview, size: 64, color: Colors.grey),");
    code.writeln("            SizedBox(height: 16),");
    code.writeln("            Text('${file.metadata['pageName'] ?? className} Page', style: TextStyle(fontSize: 24)),");
    code.writeln("            SizedBox(height: 8),");
    code.writeln("            Text('This is a custom page', style: TextStyle(color: Colors.grey)),");
    code.writeln("          ],");
    code.writeln("        ),");
    code.writeln("      ),");
    code.writeln("    );");
    code.writeln("  }");
    code.writeln("}");
    
    return code.toString();
  }

  static String _generateServiceContent(DartFileBean file, Project project) {
    final className = file.className;
    final StringBuffer code = StringBuffer();
    
    code.writeln("import 'package:flutter/material.dart';");
    code.writeln();
    code.writeln("class $className {");
    code.writeln("  static final $className _instance = $className._internal();");
    code.writeln("  factory $className() => _instance;");
    code.writeln("  $className._internal();");
    code.writeln();
    code.writeln("  // Add your service methods here");
    code.writeln("  void initialize() {");
    code.writeln("    // Initialize service");
    code.writeln("  }");
    code.writeln();
    code.writeln("  void dispose() {");
    code.writeln("    // Clean up resources");
    code.writeln("  }");
    code.writeln("}");
    
    return code.toString();
  }

  static String _generateModelContent(DartFileBean file, Project project) {
    final className = file.className;
    final StringBuffer code = StringBuffer();
    
    code.writeln("class $className {");
    code.writeln("  final String id;");
    code.writeln("  final String name;");
    code.writeln();
    code.writeln("  $className({");
    code.writeln("    required this.id,");
    code.writeln("    required this.name,");
    code.writeln("  });");
    code.writeln();
    code.writeln("  factory $className.fromJson(Map<String, dynamic> json) {");
    code.writeln("    return $className(");
    code.writeln("      id: json['id'],");
    code.writeln("      name: json['name'],");
    code.writeln("    );");
    code.writeln("  }");
    code.writeln();
    code.writeln("  Map<String, dynamic> toJson() {");
    code.writeln("    return {");
    code.writeln("      'id': id,");
    code.writeln("      'name': name,");
    code.writeln("    };");
    code.writeln("  }");
    code.writeln();
    code.writeln("  $className copyWith({");
    code.writeln("    String? id,");
    code.writeln("    String? name,");
    code.writeln("  }) {");
    code.writeln("    return $className(");
    code.writeln("      id: id ?? this.id,");
    code.writeln("      name: name ?? this.name,");
    code.writeln("    );");
    code.writeln("  }");
    code.writeln("}");
    
    return code.toString();
  }

  static String _generateWidgetContent(DartFileBean file, Project project) {
    final className = file.className;
    final StringBuffer code = StringBuffer();
    
    code.writeln("import 'package:flutter/material.dart';");
    code.writeln();
    code.writeln("class $className extends StatelessWidget {");
    code.writeln("  final String title;");
    code.writeln();
    code.writeln("  const $className({");
    code.writeln("    super.key,");
    code.writeln("    required this.title,");
    code.writeln("  });");
    code.writeln();
    code.writeln("  @override");
    code.writeln("  Widget build(BuildContext context) {");
    code.writeln("    return Container(");
    code.writeln("      padding: EdgeInsets.all(16),");
    code.writeln("      decoration: BoxDecoration(");
    code.writeln("        color: Colors.white,");
    code.writeln("        borderRadius: BorderRadius.circular(8),");
    code.writeln("        boxShadow: [");
    code.writeln("          BoxShadow(");
    code.writeln("            color: Colors.grey.withOpacity(0.2),");
    code.writeln("            spreadRadius: 1,");
    code.writeln("            blurRadius: 4,");
    code.writeln("            offset: Offset(0, 2),");
    code.writeln("          ),");
    code.writeln("        ],");
    code.writeln("      ),");
    code.writeln("      child: Column(");
    code.writeln("        mainAxisSize: MainAxisSize.min,");
    code.writeln("        children: [");
    code.writeln("          Icon(Icons.widgets, size: 32, color: Colors.blue),");
    code.writeln("          SizedBox(height: 8),");
    code.writeln("          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),");
    code.writeln("          SizedBox(height: 4),");
    code.writeln("          Text('Custom Widget', style: TextStyle(color: Colors.grey)),");
    code.writeln("        ],");
    code.writeln("      ),");
    code.writeln("    );");
    code.writeln("  }");
    code.writeln("}");
    
    return code.toString();
  }

  // Delete a Dart file
  static Future<bool> deleteDartFile(Project project, DartFileBean file) async {
    try {
      // Don't allow deletion of main.dart
      if (file.fileType == DartFileType.main) {
        return false;
      }
      
      // Delete the actual file
      final dartFile = File(file.filePath);
      if (await dartFile.exists()) {
        await dartFile.delete();
      }
      
      // Remove from files list
      final files = await getAllDartFiles(project);
      files.removeWhere((f) => f.fileName == file.fileName);
      await _saveFilesConfig(project, files);
      
      print('Deleted Dart file: ${file.filePath}');
      return true;
    } catch (e) {
      print('Error deleting Dart file: $e');
      return false;
    }
  }

  // Update widgets in a specific Dart file
  static Future<void> updateFileWithWidgets(
    Project project,
    DartFileBean file,
    List<WidgetData> widgets,
  ) async {
    try {
      if (!file.canContainWidgets) {
        throw ArgumentError('This file type cannot contain widgets');
      }
      
      String content;
      switch (file.fileType) {
        case DartFileType.main:
          content = CodeGenerator.generateMainDartCode(widgets, project.appName);
          break;
        case DartFileType.page:
          content = _generatePageWithWidgets(file, project, widgets);
          break;
        case DartFileType.widget:
          content = _generateWidgetWithWidgets(file, project, widgets);
          break;
        default:
          throw ArgumentError('Unsupported file type for widgets');
      }
      
      // Write the updated content
      final dartFile = File(file.filePath);
      await dartFile.writeAsString(content);
      
      print('Updated ${file.fileName} with ${widgets.length} widgets');
    } catch (e) {
      print('Error updating file with widgets: $e');
      rethrow;
    }
  }

  static String _generatePageWithWidgets(DartFileBean file, Project project, List<WidgetData> widgets) {
    final className = file.className;
    final StringBuffer code = StringBuffer();
    
    code.writeln("import 'package:flutter/material.dart';");
    code.writeln();
    code.writeln("class $className extends StatefulWidget {");
    code.writeln("  @override");
    code.writeln("  _${className}State createState() => _${className}State();");
    code.writeln("}");
    code.writeln();
    code.writeln("class _${className}State extends State<$className> {");
    
    // Generate controllers for EditText widgets
    final editTextWidgets = widgets.where((w) => w.type == WidgetData.TYPE_EDITTEXT).toList();
    if (editTextWidgets.isNotEmpty) {
      code.writeln("  // Controllers");
      for (final widget in editTextWidgets) {
        code.writeln("  final TextEditingController _${widget.id}Controller = TextEditingController();");
      }
      code.writeln();
    }
    
    code.writeln("  @override");
    code.writeln("  Widget build(BuildContext context) {");
    code.writeln("    return Scaffold(");
    code.writeln("      appBar: AppBar(");
    code.writeln("        title: Text('${file.metadata['pageName'] ?? className}'),");
    code.writeln("        backgroundColor: Colors.blue,");
    code.writeln("        foregroundColor: Colors.white,");
    code.writeln("      ),");
    code.writeln("      body: _buildBody(),");
    code.writeln("    );");
    code.writeln("  }");
    code.writeln();
    
         // Generate body method
     code.writeln("  Widget _buildBody() {");
     if (widgets.isEmpty) {
       code.writeln("    return Center(");
       code.writeln("      child: Column(");
       code.writeln("        mainAxisAlignment: MainAxisAlignment.center,");
       code.writeln("        children: [");
       code.writeln("          Icon(Icons.pageview, size: 64, color: Colors.grey),");
       code.writeln("          SizedBox(height: 16),");
       code.writeln("          Text('${file.metadata['pageName'] ?? className} Page', style: TextStyle(fontSize: 24)),");
       code.writeln("          SizedBox(height: 8),");
       code.writeln("          Text('Drag widgets here to build your UI', style: TextStyle(color: Colors.grey)),");
       code.writeln("        ],");
       code.writeln("      ),");
       code.writeln("    );");
     } else {
       final rootWidgets = widgets.where((w) => w.parentId == null).toList();
       if (rootWidgets.isNotEmpty) {
         code.writeln("    return ${_generateWidgetCode(rootWidgets.first)};");
       } else {
         code.writeln("    return Container();");
       }
     }
     code.writeln("  }");
    code.writeln();
    
    // Generate helper methods for widgets
    for (final widget in widgets) {
      if (widget.type == WidgetData.TYPE_BUTTON) {
        code.writeln("  void _${widget.id}Pressed() {");
        code.writeln("    // TODO: Implement button action");
        code.writeln("    ScaffoldMessenger.of(context).showSnackBar(");
        code.writeln("      SnackBar(content: Text('${widget.properties['text'] ?? 'Button'} pressed')),");
        code.writeln("    );");
        code.writeln("  }");
        code.writeln();
      }
    }
    
    code.writeln("}");
    
    return code.toString();
  }

  static String _generateWidgetWithWidgets(DartFileBean file, Project project, List<WidgetData> widgets) {
    final className = file.className;
    final StringBuffer code = StringBuffer();
    
    code.writeln("import 'package:flutter/material.dart';");
    code.writeln();
    code.writeln("class $className extends StatelessWidget {");
    code.writeln("  final String title;");
    code.writeln();
    code.writeln("  const $className({");
    code.writeln("    super.key,");
    code.writeln("    required this.title,");
    code.writeln("  });");
    code.writeln();
    code.writeln("  @override");
    code.writeln("  Widget build(BuildContext context) {");
    code.writeln("    return Container(");
    code.writeln("      padding: EdgeInsets.all(16),");
    code.writeln("      decoration: BoxDecoration(");
    code.writeln("        color: Colors.white,");
    code.writeln("        borderRadius: BorderRadius.circular(8),");
    code.writeln("        boxShadow: [");
    code.writeln("          BoxShadow(");
    code.writeln("            color: Colors.grey.withOpacity(0.2),");
    code.writeln("            spreadRadius: 1,");
    code.writeln("            blurRadius: 4,");
    code.writeln("            offset: Offset(0, 2),");
    code.writeln("          ),");
    code.writeln("        ],");
    code.writeln("      ),");
    code.writeln("      child: _buildContent(),");
    code.writeln("    );");
    code.writeln("  }");
    code.writeln();
    
         // Generate content method
     code.writeln("  Widget _buildContent() {");
     if (widgets.isEmpty) {
       code.writeln("    return Column(");
       code.writeln("      mainAxisSize: MainAxisSize.min,");
       code.writeln("      children: [");
       code.writeln("        Icon(Icons.widgets, size: 32, color: Colors.blue),");
       code.writeln("        SizedBox(height: 8),");
       code.writeln("        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),");
       code.writeln("        SizedBox(height: 4),");
       code.writeln("        Text('Custom Widget', style: TextStyle(color: Colors.grey)),");
       code.writeln("      ],");
       code.writeln("    );");
     } else {
       final rootWidgets = widgets.where((w) => w.parentId == null).toList();
       if (rootWidgets.isNotEmpty) {
         code.writeln("    return ${_generateWidgetCode(rootWidgets.first)};");
       } else {
         code.writeln("    return Container();");
       }
     }
     code.writeln("  }");
    code.writeln("}");
    
    return code.toString();
  }

  // Save files configuration
  static Future<void> _saveFilesConfig(Project project, List<DartFileBean> files) async {
    try {
      final configFile = File('${project.projectPath}/$_filesConfigName');
      final filesJson = files.map((file) => file.toJson()).toList();
      await configFile.writeAsString(jsonEncode(filesJson));
    } catch (e) {
      print('Error saving files config: $e');
      rethrow;
    }
  }

  // Get the default file (main.dart)
  static Future<DartFileBean?> getDefaultFile(Project project) async {
    final files = await getAllDartFiles(project);
    return files.firstWhere(
      (file) => file.isDefault,
      orElse: () => files.first,
    );
  }

     // Get a specific file by name
   static Future<DartFileBean?> getFileByName(Project project, String fileName) async {
     final files = await getAllDartFiles(project);
     try {
       return files.firstWhere((file) => file.fileName == fileName);
     } catch (e) {
       return null;
     }
   }

   // Helper method to generate widget code (copied from CodeGenerator)
   static String _generateWidgetCode(WidgetData widget) {
     switch (widget.type) {
       case WidgetData.TYPE_COLUMN:
         return _generateColumnCode(widget);
       case WidgetData.TYPE_ROW:
         return _generateRowCode(widget);
       case WidgetData.TYPE_STACK:
         return _generateStackCode(widget);
       case WidgetData.TYPE_TEXT:
         return _generateTextCode(widget);
       case WidgetData.TYPE_BUTTON:
         return _generateButtonCode(widget);
       case WidgetData.TYPE_EDITTEXT:
         return _generateEditTextCode(widget);
       case WidgetData.TYPE_IMAGE:
         return _generateImageCode(widget);
       case WidgetData.TYPE_CHECKBOX:
         return _generateCheckboxCode(widget);
       case WidgetData.TYPE_SWITCH:
         return _generateSwitchCode(widget);
       case WidgetData.TYPE_PROGRESSBAR:
         return _generateProgressBarCode(widget);
       case WidgetData.TYPE_APPBAR:
         return _generateAppBarCode(widget);
       case WidgetData.TYPE_CENTER:
         return _generateCenterCode(widget);
       case WidgetData.TYPE_SCAFFOLD:
         return _generateScaffoldCode(widget);
       case WidgetData.TYPE_MATERIALAPP:
         return _generateMaterialAppCode(widget);
       default:
         return "Container()";
     }
   }

   static String _generateColumnCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("Column(");
     
     // Properties
     final mainAxisAlignment = widget.properties['mainAxisAlignment'] ?? 'MainAxisAlignment.start';
     final crossAxisAlignment = widget.properties['crossAxisAlignment'] ?? 'CrossAxisAlignment.center';
     final mainAxisSize = widget.properties['mainAxisSize'] ?? 'MainAxisSize.max';
     
     code.write("mainAxisAlignment: $mainAxisAlignment, ");
     code.write("crossAxisAlignment: $crossAxisAlignment, ");
     code.write("mainAxisSize: $mainAxisSize, ");
     
     // Children
     final children = widget.children;
     if (children.isNotEmpty) {
       code.write("children: [");
       for (int i = 0; i < children.length; i++) {
         if (i > 0) code.write(", ");
         code.write(_generateWidgetCode(children[i]));
       }
       code.write("],");
     } else {
       code.write("children: [],");
     }
     
     code.write(")");
     return code.toString();
   }

   static String _generateRowCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("Row(");
     
     // Properties
     final mainAxisAlignment = widget.properties['mainAxisAlignment'] ?? 'MainAxisAlignment.start';
     final crossAxisAlignment = widget.properties['crossAxisAlignment'] ?? 'CrossAxisAlignment.center';
     final mainAxisSize = widget.properties['mainAxisSize'] ?? 'MainAxisSize.max';
     
     code.write("mainAxisAlignment: $mainAxisAlignment, ");
     code.write("crossAxisAlignment: $crossAxisAlignment, ");
     code.write("mainAxisSize: $mainAxisSize, ");
     
     // Children
     final children = widget.children;
     if (children.isNotEmpty) {
       code.write("children: [");
       for (int i = 0; i < children.length; i++) {
         if (i > 0) code.write(", ");
         code.write(_generateWidgetCode(children[i]));
       }
       code.write("],");
     } else {
       code.write("children: [],");
     }
     
     code.write(")");
     return code.toString();
   }

   static String _generateStackCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("Stack(");
     
     // Properties
     final alignment = widget.properties['alignment'] ?? 'Alignment.topLeft';
     final fit = widget.properties['fit'] ?? 'StackFit.loose';
     
     code.write("alignment: $alignment, ");
     code.write("fit: $fit, ");
     
     // Children
     final children = widget.children;
     if (children.isNotEmpty) {
       code.write("children: [");
       for (int i = 0; i < children.length; i++) {
         if (i > 0) code.write(", ");
         code.write(_generateWidgetCode(children[i]));
       }
       code.write("],");
     } else {
       code.write("children: [],");
     }
     
     code.write(")");
     return code.toString();
   }

   static String _generateTextCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("Text(");
     
     final text = widget.properties['text'] ?? 'Text';
     code.write("'$text', ");
     
     // Style
     final style = widget.properties['style'];
     if (style != null) {
       code.write("style: TextStyle(");
       if (style['fontSize'] != null) {
         code.write("fontSize: ${style['fontSize']}, ");
       }
       if (style['color'] != null) {
         final color = style['color'];
         if (color.startsWith('#')) {
           code.write("color: Color(0xFF${color.substring(1)}), ");
         } else {
           code.write("color: $color, ");
         }
       }
       if (style['fontWeight'] != null) {
         code.write("fontWeight: ${style['fontWeight']}, ");
       }
       code.write("), ");
     }
     
     code.write(")");
     return code.toString();
   }

   static String _generateButtonCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("ElevatedButton(");
     
     final text = widget.properties['text'] ?? 'Button';
     code.write("onPressed: _${widget.id}Pressed, ");
     code.write("child: Text('$text'), ");
     
     // Style
     final style = widget.properties['style'];
     if (style != null) {
       code.write("style: ElevatedButton.styleFrom(");
       if (style['backgroundColor'] != null) {
         final color = style['backgroundColor'];
         if (color.startsWith('#')) {
           code.write("backgroundColor: Color(0xFF${color.substring(1)}), ");
         } else {
           code.write("backgroundColor: $color, ");
         }
       }
       if (style['foregroundColor'] != null) {
         final color = style['foregroundColor'];
         if (color.startsWith('#')) {
           code.write("foregroundColor: Color(0xFF${color.substring(1)}), ");
         } else {
           code.write("foregroundColor: $color, ");
         }
       }
       code.write("), ");
     }
     
     code.write(")");
     return code.toString();
   }

   static String _generateEditTextCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("TextField(");
     
     final hintText = widget.properties['hintText'] ?? 'Enter text...';
     code.write("controller: _${widget.id}Controller, ");
     code.write("decoration: InputDecoration(");
     code.write("hintText: '$hintText', ");
     code.write("border: OutlineInputBorder(), ");
     code.write("), ");
     
     code.write(")");
     return code.toString();
   }

   static String _generateImageCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("Container(");
     
     final width = widget.properties['width'] ?? 100.0;
     final height = widget.properties['height'] ?? 100.0;
     final src = widget.properties['src'] ?? '';
     
     code.write("width: $width, ");
     code.write("height: $height, ");
     
     if (src.isNotEmpty) {
       code.write("child: Image.asset('$src'), ");
     } else {
       code.write("color: Colors.grey[300], ");
       code.write("child: Icon(Icons.image, size: 32), ");
     }
     
     code.write(")");
     return code.toString();
   }

   static String _generateCheckboxCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("Row(");
     code.write("children: [");
     code.write("Checkbox(");
     code.write("value: false, ");
     code.write("onChanged: (value) {}, ");
     code.write("), ");
     
     final text = widget.properties['text'] ?? 'Checkbox';
     code.write("Text('$text'), ");
     
     code.write("], ");
     code.write(")");
     return code.toString();
   }

   static String _generateSwitchCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("Row(");
     code.write("children: [");
     code.write("Switch(");
     code.write("value: false, ");
     code.write("onChanged: (value) {}, ");
     code.write("), ");
     
     final text = widget.properties['text'] ?? 'Switch';
     code.write("Text('$text'), ");
     
     code.write("], ");
     code.write(")");
     return code.toString();
   }

   static String _generateProgressBarCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("LinearProgressIndicator(");
     
     final value = widget.properties['value'] ?? 0.5;
     code.write("value: $value, ");
     
     // Background color
     final backgroundColor = widget.properties['backgroundColor'];
     if (backgroundColor != null) {
       if (backgroundColor.startsWith('#')) {
         code.write("backgroundColor: Color(0xFF${backgroundColor.substring(1)}), ");
       } else {
         code.write("backgroundColor: $backgroundColor, ");
       }
     }
     
     // Value color
     final valueColor = widget.properties['valueColor'];
     if (valueColor != null) {
       if (valueColor.startsWith('#')) {
         code.write("valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF${valueColor.substring(1)})), ");
       } else {
         code.write("valueColor: AlwaysStoppedAnimation<Color>($valueColor), ");
       }
     }
     
     code.write(")");
     return code.toString();
   }

   static String _generateAppBarCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("AppBar(");
     
     final title = widget.properties['title'] ?? 'App Title';
     code.write("title: Text('$title'), ");
     
     final backgroundColor = widget.properties['backgroundColor'];
     if (backgroundColor != null) {
       code.write("backgroundColor: $backgroundColor, ");
     }
     
     final elevation = widget.properties['elevation'];
     if (elevation != null) {
       code.write("elevation: $elevation, ");
     }
     
     code.write(")");
     return code.toString();
   }

   static String _generateCenterCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("Center(");
     
     // Children
     final children = widget.children;
     if (children.isNotEmpty) {
       code.write("child: ${_generateWidgetCode(children.first)}, ");
     } else {
       code.write("child: Container(), ");
     }
     
     code.write(")");
     return code.toString();
   }

   static String _generateScaffoldCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("Scaffold(");
     
     // AppBar
     final appBarWidgets = widget.children.where((w) => w.type == WidgetData.TYPE_APPBAR).toList();
     if (appBarWidgets.isNotEmpty) {
       code.write("appBar: ${_generateWidgetCode(appBarWidgets.first)}, ");
     }
     
     // Body
     final bodyWidgets = widget.children.where((w) => w.type != WidgetData.TYPE_APPBAR).toList();
     if (bodyWidgets.isNotEmpty) {
       code.write("body: ${_generateWidgetCode(bodyWidgets.first)}, ");
     } else {
       code.write("body: Container(), ");
     }
     
     final backgroundColor = widget.properties['backgroundColor'];
     if (backgroundColor != null) {
       code.write("backgroundColor: $backgroundColor, ");
     }
     
     code.write(")");
     return code.toString();
   }

   static String _generateMaterialAppCode(WidgetData widget) {
     final StringBuffer code = StringBuffer();
     code.write("MaterialApp(");
     
     final title = widget.properties['title'] ?? 'Flutter App';
     code.write("title: '$title', ");
     
     final theme = widget.properties['theme'];
     if (theme != null) {
       code.write("theme: $theme, ");
     }
     
     // Home
     final homeWidgets = widget.children;
     if (homeWidgets.isNotEmpty) {
       code.write("home: ${_generateWidgetCode(homeWidgets.first)}, ");
     }
     
     code.write(")");
     return code.toString();
   }
 } 