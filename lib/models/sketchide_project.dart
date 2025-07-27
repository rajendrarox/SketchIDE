import 'dart:convert';
import 'project_info.dart';
import 'ui_component.dart';
import 'logic_block.dart';
import 'page.dart';
import 'project_complexity.dart';

class SketchIDEProject {
  final String projectId; // Add project ID field
  final ProjectInfo projectInfo;
  final List<UIComponent> uiComponents;
  final List<LogicBlock> logicBlocks;
  final List<Page> pages;
  final Map<String, dynamic> resources;
  final ProjectTemplate template;
  final ProjectComplexity complexity;

  SketchIDEProject({
    required this.projectId, // Add project ID parameter
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
      projectId:
          json['project_id'] as String, // Assuming 'project_id' is in JSON
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
  factory SketchIDEProject.createEmpty({
    required String appName,
    required String packageName,
    required String projectName,
    String versionName = '1.0',
    int versionCode = 1,
    String? iconPath,
    ProjectTemplate template = ProjectTemplate.helloWorld,
  }) {
    final projectId = _generateProjectId(); // Generate ID here
    final complexity = ProjectTemplateInfo.templates[template]!.complexity;

    return SketchIDEProject(
      projectId: projectId, // Use generated ID
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
  static String _generateProjectId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000000).toString().padLeft(6, '0');
    return 'sketchide_$timestamp$random';
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
      projectId: projectId, // Keep existing projectId
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
