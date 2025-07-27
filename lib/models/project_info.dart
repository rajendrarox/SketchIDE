class ProjectInfo {
  final String appName;
  final String packageName;
  final String projectName;
  final String versionName;
  final int versionCode;
  final String? iconPath;
  final DateTime createdAt;
  final DateTime modifiedAt;

  ProjectInfo({
    required this.appName,
    required this.packageName,
    required this.projectName,
    this.versionName = '1.0',
    this.versionCode = 1,
    this.iconPath,
    required this.createdAt,
    required this.modifiedAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'package_name': packageName,
      'project_name': projectName,
      'version_name': versionName,
      'version_code': versionCode,
      'icon_path': iconPath,
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    return ProjectInfo(
      appName: json['app_name'],
      packageName: json['package_name'],
      projectName:
          json['project_name'] ?? json['app_name'], // Fallback to app_name
      versionName: json['version_name'] ?? '1.0',
      versionCode: json['version_code'] ?? 1,
      iconPath: json['icon_path'],
      createdAt: DateTime.parse(json['created_at']),
      modifiedAt: DateTime.parse(json['modified_at']),
    );
  }

  // Copy with updates
  ProjectInfo copyWith({
    String? appName,
    String? packageName,
    String? projectName,
    String? versionName,
    int? versionCode,
    String? iconPath,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return ProjectInfo(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      projectName: projectName ?? this.projectName,
      versionName: versionName ?? this.versionName,
      versionCode: versionCode ?? this.versionCode,
      iconPath: iconPath ?? this.iconPath,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  // Update modification time
  ProjectInfo updateModified() {
    return copyWith(modifiedAt: DateTime.now());
  }
}
