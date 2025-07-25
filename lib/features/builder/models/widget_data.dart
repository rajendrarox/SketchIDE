import 'package:flutter/material.dart';

class WidgetData {
  final String id;
  final String type;
  final Map<String, dynamic> properties;
  final String? parentId;
  final int index;
  final List<WidgetData> children;

  WidgetData({
    required this.id,
    required this.type,
    required this.properties,
    this.parentId,
    this.index = 0,
    this.children = const [],
  });

  WidgetData copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? properties,
    String? parentId,
    int? index,
    List<WidgetData>? children,
  }) {
    return WidgetData(
      id: id ?? this.id,
      type: type ?? this.type,
      properties: properties ?? this.properties,
      parentId: parentId ?? this.parentId,
      index: index ?? this.index,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'properties': properties,
      'parentId': parentId,
      'index': index,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  factory WidgetData.fromJson(Map<String, dynamic> json) {
    return WidgetData(
      id: json['id'],
      type: json['type'],
      properties: Map<String, dynamic>.from(json['properties']),
      parentId: json['parentId'],
      index: json['index'] is int ? json['index'] : int.tryParse(json['index']?.toString() ?? '0') ?? 0,
      children: (json['children'] as List?)
          ?.map((child) => WidgetData.fromJson(child))
          .toList() ?? [],
    );
  }

  // Default properties for each widget type
  static Map<String, Map<String, dynamic>> get defaultProperties {
    return {
      'column': {
        'mainAxisAlignment': 'MainAxisAlignment.start',
        'crossAxisAlignment': 'CrossAxisAlignment.center',
        'mainAxisSize': 'MainAxisSize.max',
        'children': [],
      },
      'row': {
        'mainAxisAlignment': 'MainAxisAlignment.start',
        'crossAxisAlignment': 'CrossAxisAlignment.center',
        'mainAxisSize': 'MainAxisSize.max',
        'children': [],
      },
      'stack': {
        'alignment': 'Alignment.topLeft',
        'fit': 'StackFit.loose',
        'children': [],
      },
      'text': {
        'text': 'Text',
        'style': {
          'fontSize': 14.0,
          'color': '#000000',
          'fontWeight': 'FontWeight.normal',
        },
      },
      'button': {
        'text': 'Button',
        'onPressed': null,
        'style': {
          'backgroundColor': '#2196F3',
          'foregroundColor': '#FFFFFF',
        },
      },
      'edittext': {
        'hintText': 'Enter text...',
        'controller': null,
        'decoration': {
          'border': 'OutlineInputBorder()',
        },
      },
      'image': {
        'src': '',
        'width': 100.0,
        'height': 100.0,
        'fit': 'BoxFit.cover',
      },
      'checkbox': {
        'value': false,
        'onChanged': null,
        'text': 'Checkbox',
      },
      'switch': {
        'value': false,
        'onChanged': null,
        'text': 'Switch',
      },
      'progressbar': {
        'value': 0.5,
        'backgroundColor': '#E0E0E0',
        'valueColor': '#2196F3',
      },
      'appbar': {
        'title': 'App Title',
        'backgroundColor': 'Theme.of(context).colorScheme.inversePrimary',
        'elevation': 4.0,
      },
      'center': {
        'child': null,
      },
      'scaffold': {
        'appBar': null,
        'body': null,
        'backgroundColor': 'Colors.white',
      },
      'materialapp': {
        'title': 'Flutter App',
        'theme': 'ThemeData(primarySwatch: Colors.blue)',
        'home': null,
      },
    };
  }

  // Get default properties for a specific widget type
  static Map<String, dynamic> getDefaultPropertiesForType(String type) {
    return Map<String, dynamic>.from(defaultProperties[type] ?? {});
  }

  // Widget type constants
  static const String TYPE_COLUMN = 'column';
  static const String TYPE_ROW = 'row';
  static const String TYPE_STACK = 'stack';
  static const String TYPE_TEXT = 'text';
  static const String TYPE_BUTTON = 'button';
  static const String TYPE_EDITTEXT = 'edittext';
  static const String TYPE_IMAGE = 'image';
  static const String TYPE_CHECKBOX = 'checkbox';
  static const String TYPE_SWITCH = 'switch';
  static const String TYPE_PROGRESSBAR = 'progressbar';
  static const String TYPE_APPBAR = 'appbar';
  static const String TYPE_CENTER = 'center';
  static const String TYPE_SCAFFOLD = 'scaffold';
  static const String TYPE_MATERIALAPP = 'materialapp';

  // Get all available widget types
  static List<String> get availableTypes => [
    TYPE_COLUMN,
    TYPE_ROW,
    TYPE_STACK,
    TYPE_TEXT,
    TYPE_BUTTON,
    TYPE_EDITTEXT,
    TYPE_IMAGE,
    TYPE_CHECKBOX,
    TYPE_SWITCH,
    TYPE_PROGRESSBAR,
    TYPE_APPBAR,
    TYPE_CENTER,
    TYPE_SCAFFOLD,
    TYPE_MATERIALAPP,
  ];

  // Check if widget type supports children
  static bool supportsChildren(String type) {
    return ['column', 'row', 'stack', 'center', 'scaffold', 'materialapp'].contains(type);
  }

  // Get widget display name
  static String getDisplayName(String type) {
    switch (type) {
      case TYPE_COLUMN:
        return 'Column';
      case TYPE_ROW:
        return 'Row';
      case TYPE_STACK:
        return 'Stack';
      case TYPE_TEXT:
        return 'Text';
      case TYPE_BUTTON:
        return 'Button';
      case TYPE_EDITTEXT:
        return 'EditText';
      case TYPE_IMAGE:
        return 'Image';
      case TYPE_CHECKBOX:
        return 'CheckBox';
      case TYPE_SWITCH:
        return 'Switch';
      case TYPE_PROGRESSBAR:
        return 'ProgressBar';
      case TYPE_APPBAR:
        return 'AppBar';
      case TYPE_CENTER:
        return 'Center';
      case TYPE_SCAFFOLD:
        return 'Scaffold';
      case TYPE_MATERIALAPP:
        return 'MaterialApp';
      default:
        return type;
    }
  }

  // Get widget icon
  static IconData getIcon(String type) {
    switch (type) {
      case TYPE_COLUMN:
        return Icons.view_column;
      case TYPE_ROW:
        return Icons.view_agenda;
      case TYPE_STACK:
        return Icons.layers;
      case TYPE_TEXT:
        return Icons.text_fields;
      case TYPE_BUTTON:
        return Icons.smart_button;
      case TYPE_EDITTEXT:
        return Icons.edit;
      case TYPE_IMAGE:
        return Icons.image;
      case TYPE_CHECKBOX:
        return Icons.check_box;
      case TYPE_SWITCH:
        return Icons.toggle_on;
      case TYPE_PROGRESSBAR:
        return Icons.linear_scale;
      case TYPE_APPBAR:
        return Icons.apps;
      case TYPE_CENTER:
        return Icons.center_focus_strong;
      case TYPE_SCAFFOLD:
        return Icons.view_agenda;
      case TYPE_MATERIALAPP:
        return Icons.app_settings_alt;
      default:
        return Icons.widgets;
    }
  }
} 