import 'dart:convert';

class ManifestModel {
  final String packageName;
  final String versionName;
  final int versionCode;
  final String appName;
  final String appIcon;
  final String appTheme;
  final List<PermissionModel> permissions;
  final List<ActivityModel> activities;
  final List<ServiceModel> services;
  final List<ReceiverModel> receivers;
  final List<ProviderModel> providers;
  final List<MetaDataModel> metaData;
  final List<IntentFilterModel> intentFilters;
  final Map<String, dynamic> applicationAttributes;

  ManifestModel({
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.appName,
    this.appIcon = '@mipmap/ic_launcher',
    this.appTheme = '@style/LaunchTheme',
    this.permissions = const [],
    this.activities = const [],
    this.services = const [],
    this.receivers = const [],
    this.providers = const [],
    this.metaData = const [],
    this.intentFilters = const [],
    this.applicationAttributes = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'versionName': versionName,
      'versionCode': versionCode,
      'appName': appName,
      'appIcon': appIcon,
      'appTheme': appTheme,
      'permissions': permissions.map((p) => p.toJson()).toList(),
      'activities': activities.map((a) => a.toJson()).toList(),
      'services': services.map((s) => s.toJson()).toList(),
      'receivers': receivers.map((r) => r.toJson()).toList(),
      'providers': providers.map((p) => p.toJson()).toList(),
      'metaData': metaData.map((m) => m.toJson()).toList(),
      'intentFilters': intentFilters.map((i) => i.toJson()).toList(),
      'applicationAttributes': applicationAttributes,
    };
  }

  factory ManifestModel.fromJson(Map<String, dynamic> json) {
    return ManifestModel(
      packageName: json['packageName'] ?? '',
      versionName: json['versionName'] ?? '1.0',
      versionCode: json['versionCode'] ?? 1,
      appName: json['appName'] ?? '',
      appIcon: json['appIcon'] ?? '@mipmap/ic_launcher',
      appTheme: json['appTheme'] ?? '@style/LaunchTheme',
      permissions: (json['permissions'] as List?)
              ?.map((p) => PermissionModel.fromJson(p))
              .toList() ??
          [],
      activities: (json['activities'] as List?)
              ?.map((a) => ActivityModel.fromJson(a))
              .toList() ??
          [],
      services: (json['services'] as List?)
              ?.map((s) => ServiceModel.fromJson(s))
              .toList() ??
          [],
      receivers: (json['receivers'] as List?)
              ?.map((r) => ReceiverModel.fromJson(r))
              .toList() ??
          [],
      providers: (json['providers'] as List?)
              ?.map((p) => ProviderModel.fromJson(p))
              .toList() ??
          [],
      metaData: (json['metaData'] as List?)
              ?.map((m) => MetaDataModel.fromJson(m))
              .toList() ??
          [],
      intentFilters: (json['intentFilters'] as List?)
              ?.map((i) => IntentFilterModel.fromJson(i))
              .toList() ??
          [],
      applicationAttributes:
          Map<String, dynamic>.from(json['applicationAttributes'] ?? {}),
    );
  }

  ManifestModel copyWith({
    String? packageName,
    String? versionName,
    int? versionCode,
    String? appName,
    String? appIcon,
    String? appTheme,
    List<PermissionModel>? permissions,
    List<ActivityModel>? activities,
    List<ServiceModel>? services,
    List<ReceiverModel>? receivers,
    List<ProviderModel>? providers,
    List<MetaDataModel>? metaData,
    List<IntentFilterModel>? intentFilters,
    Map<String, dynamic>? applicationAttributes,
  }) {
    return ManifestModel(
      packageName: packageName ?? this.packageName,
      versionName: versionName ?? this.versionName,
      versionCode: versionCode ?? this.versionCode,
      appName: appName ?? this.appName,
      appIcon: appIcon ?? this.appIcon,
      appTheme: appTheme ?? this.appTheme,
      permissions: permissions ?? this.permissions,
      activities: activities ?? this.activities,
      services: services ?? this.services,
      receivers: receivers ?? this.receivers,
      providers: providers ?? this.providers,
      metaData: metaData ?? this.metaData,
      intentFilters: intentFilters ?? this.intentFilters,
      applicationAttributes:
          applicationAttributes ?? this.applicationAttributes,
    );
  }
}

class PermissionModel {
  final String name;
  final String? maxSdkVersion;
  final String? protectionLevel;
  final String? group;
  final String? label;
  final String? description;

  PermissionModel({
    required this.name,
    this.maxSdkVersion,
    this.protectionLevel,
    this.group,
    this.label,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'maxSdkVersion': maxSdkVersion,
      'protectionLevel': protectionLevel,
      'group': group,
      'label': label,
      'description': description,
    };
  }

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      name: json['name'] ?? '',
      maxSdkVersion: json['maxSdkVersion'],
      protectionLevel: json['protectionLevel'],
      group: json['group'],
      label: json['label'],
      description: json['description'],
    );
  }
}

class ActivityModel {
  final String name;
  final String? label;
  final String? theme;
  final bool exported;
  final bool enabled;
  final String? launchMode;
  final String? screenOrientation;
  final String? configChanges;
  final List<IntentFilterModel> intentFilters;
  final List<MetaDataModel> metaData;

  ActivityModel({
    required this.name,
    this.label,
    this.theme,
    this.exported = false,
    this.enabled = true,
    this.launchMode,
    this.screenOrientation,
    this.configChanges,
    this.intentFilters = const [],
    this.metaData = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'theme': theme,
      'exported': exported,
      'enabled': enabled,
      'launchMode': launchMode,
      'screenOrientation': screenOrientation,
      'configChanges': configChanges,
      'intentFilters': intentFilters.map((i) => i.toJson()).toList(),
      'metaData': metaData.map((m) => m.toJson()).toList(),
    };
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      name: json['name'] ?? '',
      label: json['label'],
      theme: json['theme'],
      exported: json['exported'] ?? false,
      enabled: json['enabled'] ?? true,
      launchMode: json['launchMode'],
      screenOrientation: json['screenOrientation'],
      configChanges: json['configChanges'],
      intentFilters: (json['intentFilters'] as List?)
              ?.map((i) => IntentFilterModel.fromJson(i))
              .toList() ??
          [],
      metaData: (json['metaData'] as List?)
              ?.map((m) => MetaDataModel.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class ServiceModel {
  final String name;
  final String? label;
  final bool exported;
  final bool enabled;
  final String? permission;
  final List<IntentFilterModel> intentFilters;
  final List<MetaDataModel> metaData;

  ServiceModel({
    required this.name,
    this.label,
    this.exported = false,
    this.enabled = true,
    this.permission,
    this.intentFilters = const [],
    this.metaData = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'exported': exported,
      'enabled': enabled,
      'permission': permission,
      'intentFilters': intentFilters.map((i) => i.toJson()).toList(),
      'metaData': metaData.map((m) => m.toJson()).toList(),
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      name: json['name'] ?? '',
      label: json['label'],
      exported: json['exported'] ?? false,
      enabled: json['enabled'] ?? true,
      permission: json['permission'],
      intentFilters: (json['intentFilters'] as List?)
              ?.map((i) => IntentFilterModel.fromJson(i))
              .toList() ??
          [],
      metaData: (json['metaData'] as List?)
              ?.map((m) => MetaDataModel.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class ReceiverModel {
  final String name;
  final String? label;
  final bool exported;
  final bool enabled;
  final String? permission;
  final List<IntentFilterModel> intentFilters;
  final List<MetaDataModel> metaData;

  ReceiverModel({
    required this.name,
    this.label,
    this.exported = false,
    this.enabled = true,
    this.permission,
    this.intentFilters = const [],
    this.metaData = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'exported': exported,
      'enabled': enabled,
      'permission': permission,
      'intentFilters': intentFilters.map((i) => i.toJson()).toList(),
      'metaData': metaData.map((m) => m.toJson()).toList(),
    };
  }

  factory ReceiverModel.fromJson(Map<String, dynamic> json) {
    return ReceiverModel(
      name: json['name'] ?? '',
      label: json['label'],
      exported: json['exported'] ?? false,
      enabled: json['enabled'] ?? true,
      permission: json['permission'],
      intentFilters: (json['intentFilters'] as List?)
              ?.map((i) => IntentFilterModel.fromJson(i))
              .toList() ??
          [],
      metaData: (json['metaData'] as List?)
              ?.map((m) => MetaDataModel.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class ProviderModel {
  final String name;
  final String? label;
  final bool exported;
  final bool enabled;
  final String? permission;
  final String? authorities;
  final String? readPermission;
  final String? writePermission;
  final List<MetaDataModel> metaData;

  ProviderModel({
    required this.name,
    this.label,
    this.exported = false,
    this.enabled = true,
    this.permission,
    this.authorities,
    this.readPermission,
    this.writePermission,
    this.metaData = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'exported': exported,
      'enabled': enabled,
      'permission': permission,
      'authorities': authorities,
      'readPermission': readPermission,
      'writePermission': writePermission,
      'metaData': metaData.map((m) => m.toJson()).toList(),
    };
  }

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      name: json['name'] ?? '',
      label: json['label'],
      exported: json['exported'] ?? false,
      enabled: json['enabled'] ?? true,
      permission: json['permission'],
      authorities: json['authorities'],
      readPermission: json['readPermission'],
      writePermission: json['writePermission'],
      metaData: (json['metaData'] as List?)
              ?.map((m) => MetaDataModel.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class MetaDataModel {
  final String name;
  final String value;
  final String? resource;

  MetaDataModel({
    required this.name,
    this.value = '',
    this.resource,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'resource': resource,
    };
  }

  factory MetaDataModel.fromJson(Map<String, dynamic> json) {
    return MetaDataModel(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      resource: json['resource'],
    );
  }
}

class IntentFilterModel {
  final bool autoVerify;
  final List<ActionModel> actions;
  final List<CategoryModel> categories;
  final List<DataModel> data;

  IntentFilterModel({
    this.autoVerify = false,
    this.actions = const [],
    this.categories = const [],
    this.data = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'autoVerify': autoVerify,
      'actions': actions.map((a) => a.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'data': data.map((d) => d.toJson()).toList(),
    };
  }

  factory IntentFilterModel.fromJson(Map<String, dynamic> json) {
    return IntentFilterModel(
      autoVerify: json['autoVerify'] ?? false,
      actions: (json['actions'] as List?)
              ?.map((a) => ActionModel.fromJson(a))
              .toList() ??
          [],
      categories: (json['categories'] as List?)
              ?.map((c) => CategoryModel.fromJson(c))
              .toList() ??
          [],
      data:
          (json['data'] as List?)?.map((d) => DataModel.fromJson(d)).toList() ??
              [],
    );
  }
}

class ActionModel {
  final String name;

  ActionModel({required this.name});

  Map<String, dynamic> toJson() => {'name': name};

  factory ActionModel.fromJson(Map<String, dynamic> json) {
    return ActionModel(name: json['name'] ?? '');
  }
}

class CategoryModel {
  final String name;

  CategoryModel({required this.name});

  Map<String, dynamic> toJson() => {'name': name};

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(name: json['name'] ?? '');
  }
}

class DataModel {
  final String? scheme;
  final String? host;
  final String? port;
  final String? path;
  final String? pathPattern;
  final String? pathPrefix;
  final String? mimeType;

  DataModel({
    this.scheme,
    this.host,
    this.port,
    this.path,
    this.pathPattern,
    this.pathPrefix,
    this.mimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'scheme': scheme,
      'host': host,
      'port': port,
      'path': path,
      'pathPattern': pathPattern,
      'pathPrefix': pathPrefix,
      'mimeType': mimeType,
    };
  }

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      scheme: json['scheme'],
      host: json['host'],
      port: json['port'],
      path: json['path'],
      pathPattern: json['pathPattern'],
      pathPrefix: json['pathPrefix'],
      mimeType: json['mimeType'],
    );
  }
}
