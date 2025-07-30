import 'dart:convert';
import 'project_info.dart';
import 'ui_component.dart';
import 'logic_block.dart';
import 'page.dart';
import 'project_complexity.dart';
import '../services/project_service.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:path/path.dart' as path;

class SketchIDEProject {
  final String projectId;
  final ProjectInfo projectInfo;
  final List<UIComponent> uiComponents;
  final List<LogicBlock> logicBlocks;
  final List<Page> pages;
  final Map<String, dynamic> resources;
  final ProjectTemplate template;
  final ProjectComplexity complexity;

  SketchIDEProject({
    required this.projectId,
    required this.projectInfo,
    this.uiComponents = const [],
    this.logicBlocks = const [],
    this.pages = const [],
    this.resources = const {},
    this.template = ProjectTemplate.helloWorld,
    this.complexity = ProjectComplexity.simple,
  });

  // Convert to JSON (for .ide file)
  Map<String, dynamic> toJson() {
    return {
      'project_info': projectInfo.toJson(),
      'ui_components':
          uiComponents.map((component) => component.toJson()).toList(),
      'logic_blocks': logicBlocks.map((block) => block.toJson()).toList(),
      'pages': pages.map((page) => page.toJson()).toList(),
      'resources': resources,
    };
  }

  // Create from JSON
  factory SketchIDEProject.fromJson(Map<String, dynamic> json) {
    return SketchIDEProject(
      projectId: json['project_id'] as String,
      projectInfo: ProjectInfo.fromJson(json['project_info']),
      uiComponents: (json['ui_components'] as List?)
              ?.map((component) => UIComponent.fromJson(component))
              .toList() ??
          [],
      logicBlocks: (json['logic_blocks'] as List?)
              ?.map((block) => LogicBlock.fromJson(block))
              .toList() ??
          [],
      pages: (json['pages'] as List?)
              ?.map((page) => Page.fromJson(page))
              .toList() ??
          [],
      resources: Map<String, dynamic>.from(json['resources'] ?? {}),
    );
  }

  // Create empty project with generated ID
  static Future<SketchIDEProject> createEmpty({
    required String appName,
    required String packageName,
    required String projectName,
    String versionName = '1.0',
    int versionCode = 1,
    String? iconPath,
    ProjectTemplate template = ProjectTemplate.helloWorld,
  }) async {
    final projectId = await _generateProjectId();
    final complexity = ProjectTemplateInfo.templates[template]!.complexity;

    return SketchIDEProject(
      projectId: projectId,
      projectInfo: ProjectInfo(
        appName: appName,
        packageName: packageName,
        projectName: projectName,
        versionName: versionName,
        versionCode: versionCode,
        iconPath: iconPath,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      ),
      uiComponents: [],
      logicBlocks: [],
      pages: [],
      resources: {},
      template: template,
      complexity: complexity,
    );
  }

  // Generate unique project ID (like Sketchware Pro's sc_id)
  static Future<String> _generateProjectId() async {
    // SKETCHWARE PRO STYLE: Start from 601 and find highest existing ID
    int nextId = 601;

    try {
      final projectService = ProjectService();
      final listDir = await projectService.getProjectListDirectory();
      final projectListFile = File(path.join(listDir, 'projects.json'));

      if (await projectListFile.exists()) {
        final content = await projectListFile.readAsString();
        final List<dynamic> projectList = jsonDecode(content);

        // Find the highest existing project ID
        for (final project in projectList) {
          final projectId = project['project_id'] as String;
          // Extract numeric part from project ID
          final numericId = int.tryParse(projectId) ?? 0;
          nextId = math.max(nextId, numericId + 1);
        }
      }
    } catch (e) {
      print('Error reading project list for ID generation: $e');
      // Fallback to timestamp-based ID if there's an error
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (timestamp % 1000000).toString().padLeft(6, '0');
      return 'sketchide_$timestamp$random';
    }

    return nextId.toString();
  }

  // Create empty project with existing ID (for loading from storage)
  factory SketchIDEProject.createEmptyWithId({
    required String projectId,
    required String appName,
    required String packageName,
    required String projectName,
    String versionName = '1.0',
    int versionCode = 1,
    String? iconPath,
  }) {
    return SketchIDEProject(
      projectId: projectId,
      projectInfo: ProjectInfo(
        appName: appName,
        packageName: packageName,
        projectName: projectName,
        versionName: versionName,
        versionCode: versionCode,
        iconPath: iconPath,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      ),
      uiComponents: [],
      logicBlocks: [],
      pages: [],
      resources: {},
    );
  }

  // Copy with updates
  SketchIDEProject copyWith({
    ProjectInfo? projectInfo,
    List<UIComponent>? uiComponents,
    List<LogicBlock>? logicBlocks,
    List<Page>? pages,
    Map<String, dynamic>? resources,
    ProjectTemplate? template,
    ProjectComplexity? complexity,
  }) {
    return SketchIDEProject(
      projectId: projectId,
      projectInfo: projectInfo ?? this.projectInfo,
      uiComponents: uiComponents ?? this.uiComponents,
      logicBlocks: logicBlocks ?? this.logicBlocks,
      pages: pages ?? this.pages,
      resources: resources ?? this.resources,
      template: template ?? this.template,
      complexity: complexity ?? this.complexity,
    );
  }

  // Convert to JSON string
  String toJsonString() {
    return JsonEncoder.withIndent('  ').convert(toJson());
  }

  // Create from JSON string
  factory SketchIDEProject.fromJsonString(String jsonString) {
    final json = JsonDecoder().convert(jsonString);
    return SketchIDEProject.fromJson(json);
  }
}
