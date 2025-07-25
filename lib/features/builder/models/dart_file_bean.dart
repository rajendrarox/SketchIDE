import 'package:flutter/material.dart';

class DartFileBean {
  final String fileName;
  final String filePath;
  final DartFileType fileType;
  final String displayName;
  final IconData icon;
  final bool isDefault;
  final Map<String, dynamic> metadata;

  DartFileBean({
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.displayName,
    required this.icon,
    this.isDefault = false,
    this.metadata = const {},
  });

  // Factory constructor for main.dart
  factory DartFileBean.mainDart(String projectPath) {
    return DartFileBean(
      fileName: 'main.dart',
      filePath: '$projectPath/lib/main.dart',
      fileType: DartFileType.main,
      displayName: 'main.dart',
      icon: Icons.home,
      isDefault: true,
      metadata: {
        'isEntryPoint': true,
        'containsApp': true,
      },
    );
  }

  // Factory constructor for home_page.dart
  factory DartFileBean.homePage(String projectPath) {
    return DartFileBean(
      fileName: 'home_page.dart',
      filePath: '$projectPath/lib/home_page.dart',
      fileType: DartFileType.page,
      displayName: 'home_page.dart',
      icon: Icons.dashboard,
      isDefault: false,
      metadata: {
        'isEntryPoint': false,
        'containsApp': false,
        'pageName': 'HomePage',
      },
    );
  }

  // Factory constructor for custom page
  factory DartFileBean.customPage(String projectPath, String pageName) {
    final fileName = '${_toSnakeCase(pageName)}.dart';
    return DartFileBean(
      fileName: fileName,
      filePath: '$projectPath/lib/pages/$fileName',
      fileType: DartFileType.page,
      displayName: fileName,
      icon: Icons.pageview,
      isDefault: false,
      metadata: {
        'isEntryPoint': false,
        'containsApp': false,
        'pageName': pageName,
      },
    );
  }

  // Factory constructor for service
  factory DartFileBean.service(String projectPath, String serviceName) {
    final fileName = '${_toSnakeCase(serviceName)}_service.dart';
    return DartFileBean(
      fileName: fileName,
      filePath: '$projectPath/lib/services/$fileName',
      fileType: DartFileType.service,
      displayName: fileName,
      icon: Icons.build,
      isDefault: false,
      metadata: {
        'isEntryPoint': false,
        'containsApp': false,
        'serviceName': serviceName,
      },
    );
  }

  // Factory constructor for model
  factory DartFileBean.model(String projectPath, String modelName) {
    final fileName = '${_toSnakeCase(modelName)}.dart';
    return DartFileBean(
      fileName: fileName,
      filePath: '$projectPath/lib/models/$fileName',
      fileType: DartFileType.model,
      displayName: fileName,
      icon: Icons.data_object,
      isDefault: false,
      metadata: {
        'isEntryPoint': false,
        'containsApp': false,
        'modelName': modelName,
      },
    );
  }

  // Factory constructor for widget
  factory DartFileBean.widget(String projectPath, String widgetName) {
    final fileName = '${_toSnakeCase(widgetName)}_widget.dart';
    return DartFileBean(
      fileName: fileName,
      filePath: '$projectPath/lib/widgets/$fileName',
      fileType: DartFileType.widget,
      displayName: fileName,
      icon: Icons.widgets,
      isDefault: false,
      metadata: {
        'isEntryPoint': false,
        'containsApp': false,
        'widgetName': widgetName,
      },
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType.index,
      'displayName': displayName,
      'isDefault': isDefault,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory DartFileBean.fromJson(Map<String, dynamic> json) {
    return DartFileBean(
      fileName: json['fileName'],
      filePath: json['filePath'],
      fileType: DartFileType.values[json['fileType']],
      displayName: json['displayName'],
      icon: _getIconForType(DartFileType.values[json['fileType']]),
      isDefault: json['isDefault'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // Copy with modifications
  DartFileBean copyWith({
    String? fileName,
    String? filePath,
    DartFileType? fileType,
    String? displayName,
    IconData? icon,
    bool? isDefault,
    Map<String, dynamic>? metadata,
  }) {
    return DartFileBean(
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get the class name from the file
  String get className {
    switch (fileType) {
      case DartFileType.main:
        return 'MyApp';
      case DartFileType.page:
        return metadata['pageName'] ?? 'Page';
      case DartFileType.service:
        return '${metadata['serviceName'] ?? 'Service'}Service';
      case DartFileType.model:
        return metadata['modelName'] ?? 'Model';
      case DartFileType.widget:
        return '${metadata['widgetName'] ?? 'Widget'}Widget';
    }
  }

  // Get the import path for this file
  String get importPath {
    final relativePath = filePath.split('lib/').last;
    return relativePath.replaceAll('.dart', '');
  }

  // Check if this file can contain widgets
  bool get canContainWidgets {
    return fileType == DartFileType.main || fileType == DartFileType.page || fileType == DartFileType.widget;
  }

  // Check if this is the main entry point
  bool get isEntryPoint {
    return fileType == DartFileType.main;
  }

  // Helper method to convert camelCase to snake_case
  static String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}')
        .replaceFirst(RegExp(r'^_'), '');
  }

  // Helper method to get icon for file type
  static IconData _getIconForType(DartFileType type) {
    switch (type) {
      case DartFileType.main:
        return Icons.home;
      case DartFileType.page:
        return Icons.dashboard;
      case DartFileType.service:
        return Icons.build;
      case DartFileType.model:
        return Icons.data_object;
      case DartFileType.widget:
        return Icons.widgets;
    }
  }

  @override
  String toString() {
    return 'DartFileBean(fileName: $fileName, fileType: $fileType, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DartFileBean &&
        other.fileName == fileName &&
        other.filePath == filePath &&
        other.fileType == fileType;
  }

  @override
  int get hashCode {
    return fileName.hashCode ^ filePath.hashCode ^ fileType.hashCode;
  }
}

enum DartFileType {
  main,    // main.dart - app entry point
  page,    // page files - screens/pages
  service, // service files - business logic
  model,   // model files - data models
  widget,  // widget files - reusable widgets
}

extension DartFileTypeExtension on DartFileType {
  String get displayName {
    switch (this) {
      case DartFileType.main:
        return 'Main';
      case DartFileType.page:
        return 'Page';
      case DartFileType.service:
        return 'Service';
      case DartFileType.model:
        return 'Model';
      case DartFileType.widget:
        return 'Widget';
    }
  }

  String get folderName {
    switch (this) {
      case DartFileType.main:
        return 'lib';
      case DartFileType.page:
        return 'lib/pages';
      case DartFileType.service:
        return 'lib/services';
      case DartFileType.model:
        return 'lib/models';
      case DartFileType.widget:
        return 'lib/widgets';
    }
  }
} 