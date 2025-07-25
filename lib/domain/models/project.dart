import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String appName;

  @HiveField(3)
  final String packageName;

  @HiveField(4)
  final String? iconPath;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime modifiedAt;

  @HiveField(7)
  final String version;

  @HiveField(8)
  final int versionCode;

  @HiveField(9)
  final String description;

  @HiveField(10)
  final String projectPath;

  Project({
    required this.id,
    required this.name,
    required this.appName,
    required this.packageName,
    this.iconPath,
    required this.createdAt,
    required this.modifiedAt,
    this.version = '1.0.0',
    this.versionCode = 1,
    this.description = 'Default app created using SketchIDE',
    required this.projectPath,
  });

  Project copyWith({
    String? id,
    String? name,
    String? appName,
    String? packageName,
    String? iconPath,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? version,
    int? versionCode,
    String? description,
    String? projectPath,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      iconPath: iconPath ?? this.iconPath,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      version: version ?? this.version,
      versionCode: versionCode ?? this.versionCode,
      description: description ?? this.description,
      projectPath: projectPath ?? this.projectPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'appName': appName,
      'packageName': packageName,
      'iconPath': iconPath,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'version': version,
      'versionCode': versionCode,
      'description': description,
      'projectPath': projectPath,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      appName: json['appName'],
      packageName: json['packageName'],
      iconPath: json['iconPath'],
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
      version: json['version'] ?? '1.0.0',
      versionCode: json['versionCode'] ?? 1,
      description: json['description'] ?? 'Default app created using SketchIDE',
      projectPath: json['projectPath'],
    );
  }
} 