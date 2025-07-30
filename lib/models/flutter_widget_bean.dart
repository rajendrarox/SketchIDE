
class FlutterWidgetBean {
  final String id;
  final String type; 
  final Map<String, dynamic> properties;
  final String? parentId;
  final List<String> children;
  final PositionBean position;
  final Map<String, String> events;
  final bool isSelected;
  final bool isVisible;
  final String? customCode;

  final LayoutBean layout;
  final int parentType;
  final int index;
  final String parent;
  final int preIndex;
  final String preParent;
  final int preParentType;
  final bool isFixed;

  FlutterWidgetBean({
    required this.id,
    required this.type,
    required this.properties,
    this.parentId,
    required this.children,
    required this.position,
    required this.events,
    this.isSelected = false,
    this.isVisible = true,
    this.customCode,
    required this.layout,
    this.parentType = 0, 
    this.index = -1,
    this.parent = 'root',
    this.preIndex = -1,
    this.preParent = '',
    this.preParentType = 0,
    this.isFixed = false,
  });

  factory FlutterWidgetBean.fromJson(Map<String, dynamic> json) {
    return FlutterWidgetBean(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      parentId: json['parentId'],
      children: List<String>.from(json['children'] ?? []),
      position: PositionBean.fromJson(json['position'] ?? {}),
      events: Map<String, String>.from(json['events'] ?? {}),
      isSelected: json['isSelected'] ?? false,
      isVisible: json['isVisible'] ?? true,
      customCode: json['customCode'],
      layout: LayoutBean.fromJson(json['layout'] ?? {}),
      parentType: json['parentType'] ?? 0,
      index: json['index'] ?? -1,
      parent: json['parent'] ?? 'root',
      preIndex: json['preIndex'] ?? -1,
      preParent: json['preParent'] ?? '',
      preParentType: json['preParentType'] ?? 0,
      isFixed: json['isFixed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'properties': properties,
      'parentId': parentId,
      'children': children,
      'position': position.toJson(),
      'events': events,
      'isSelected': isSelected,
      'isVisible': isVisible,
      'customCode': customCode,
      'layout': layout.toJson(),
      'parentType': parentType,
      'index': index,
      'parent': parent,
      'preIndex': preIndex,
      'preParent': preParent,
      'preParentType': preParentType,
      'isFixed': isFixed,
    };
  }

  FlutterWidgetBean copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? properties,
    String? parentId,
    List<String>? children,
    PositionBean? position,
    Map<String, String>? events,
    bool? isSelected,
    bool? isVisible,
    String? customCode,
    LayoutBean? layout,
    int? parentType,
    int? index,
    String? parent,
    int? preIndex,
    String? preParent,
    int? preParentType,
    bool? isFixed,
  }) {
    return FlutterWidgetBean(
      id: id ?? this.id,
      type: type ?? this.type,
      properties: properties ?? this.properties,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
      position: position ?? this.position,
      events: events ?? this.events,
      isSelected: isSelected ?? this.isSelected,
      isVisible: isVisible ?? this.isVisible,
      customCode: customCode ?? this.customCode,
      layout: layout ?? this.layout,
      parentType: parentType ?? this.parentType,
      index: index ?? this.index,
      parent: parent ?? this.parent,
      preIndex: preIndex ?? this.preIndex,
      preParent: preParent ?? this.preParent,
      preParentType: preParentType ?? this.preParentType,
      isFixed: isFixed ?? this.isFixed,
    );
  }


  static String generateId(
      String widgetType, List<FlutterWidgetBean> existingWidgets) {
    String prefix = _getTypePrefix(widgetType);


    int counter = 1;
    for (FlutterWidgetBean widget in existingWidgets) {
      if (widget.id.startsWith(prefix)) {
        try {
          String suffix = widget.id.substring(prefix.length);
          int existingCounter = int.parse(suffix);
          if (existingCounter >= counter) {
            counter = existingCounter + 1;
          }
        } catch (e) {
        }
      }
    }

    return '$prefix$counter';
  }

  static String _getTypePrefix(String widgetType) {
    switch (widgetType.toLowerCase()) {
      case 'text':
        return 'text';
      case 'textfield':
      case 'edittext':
        return 'textfield';
      case 'button':
        return 'button';
      case 'container':
        return 'container';
      case 'icon':
        return 'icon';
      case 'row':
      case 'linearlayout':
        return 'row';
      case 'column':
      case 'linearlayout':
        return 'column';
      case 'stack':
      case 'relativelayout':
        return 'stack';
      default:
        return widgetType.toLowerCase();
    }
  }

  static String generateSimpleId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000000).toString().padLeft(6, '0');
    return 'widget_$timestamp$random';
  }

  String get displayName {
    return properties['text'] ?? type;
  }

  static const int VIEW_TYPE_LAYOUT_ROW = 0;
  static const int VIEW_TYPE_LAYOUT_COLUMN = 1;
  static const int VIEW_TYPE_LAYOUT_CONTAINER = 2;
  static const int VIEW_TYPE_LAYOUT_CENTER = 3;

  static const int VIEW_TYPE_WIDGET_TEXT = 10;
  static const int VIEW_TYPE_WIDGET_TEXTFIELD = 11;
  static const int VIEW_TYPE_WIDGET_ICON = 12;


  static const int VIEW_TYPE_WIDGET_ELEVATEDBUTTON = 20;
  static const int VIEW_TYPE_WIDGET_ICONBUTTON = 21;
  static const int VIEW_TYPE_WIDGET_CHECKBOX = 22;


  static const int VIEW_TYPE_WIDGET_CARD = 30;
  static const int VIEW_TYPE_WIDGET_CHIP = 31;
  static const int VIEW_TYPE_WIDGET_DIVIDER = 32;


  static const int VIEW_TYPE_WIDGET_APPBAR = 40;
  static const int VIEW_TYPE_WIDGET_BOTTOMNAVIGATIONBAR = 41;
  static const int VIEW_TYPE_WIDGET_FLOATINGACTIONBUTTON = 42;
}


class PositionBean {
  final double x;
  final double y;
  final double width;
  final double height;

  PositionBean({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory PositionBean.fromJson(Map<String, dynamic> json) {
    return PositionBean(
      x: LayoutBean._parseDouble(json['x']) ?? 0.0,
      y: LayoutBean._parseDouble(json['y']) ?? 0.0,
      width: LayoutBean._parseDouble(json['width']) ?? 200.0,
      height: LayoutBean._parseDouble(json['height']) ?? 50.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  PositionBean copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return PositionBean(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

class LayoutBean {
  final int width;
  final int height;
  final double marginLeft;
  final double marginTop;
  final double marginRight;
  final double marginBottom;
  final int paddingLeft;
  final int paddingTop;
  final int paddingRight;
  final int paddingBottom;
  final int layoutGravity;
  final int gravity;
  final double weight;
  final int orientation;
  final double weightSum;
  final int backgroundColor;
  final String? backgroundResource;
  final String? backgroundResColor;

  LayoutBean({
    this.width = -2, 
    this.height = -2, 
    this.marginLeft = 0,
    this.marginTop = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.paddingLeft = 0,
    this.paddingTop = 0,
    this.paddingRight = 0,
    this.paddingBottom = 0,
    this.layoutGravity = 0,
    this.gravity = 0,
    this.weight = 0,
    this.orientation = 1, 
    this.weightSum = 0,
    this.backgroundColor = 0xFFFFFFFF,
    this.backgroundResource,
    this.backgroundResColor,
  });

  factory LayoutBean.fromJson(Map<String, dynamic> json) {
    return LayoutBean(
      width: _parseInt(json['width']) ?? -2,
      height: _parseInt(json['height']) ?? -2,
      marginLeft: _parseDouble(json['marginLeft']) ?? 0.0,
      marginTop: _parseDouble(json['marginTop']) ?? 0.0,
      marginRight: _parseDouble(json['marginRight']) ?? 0.0,
      marginBottom: _parseDouble(json['marginBottom']) ?? 0.0,
      paddingLeft: _parseInt(json['paddingLeft']) ?? 0,
      paddingTop: _parseInt(json['paddingTop']) ?? 0,
      paddingRight: _parseInt(json['paddingRight']) ?? 0,
      paddingBottom: _parseInt(json['paddingBottom']) ?? 0,
      layoutGravity: _parseInt(json['layoutGravity']) ?? 0,
      gravity: _parseInt(json['gravity']) ?? 0,
      weight: _parseDouble(json['weight']) ?? 0.0,
      orientation: _parseInt(json['orientation']) ?? 1,
      weightSum: _parseDouble(json['weightSum']) ?? 0.0,
      backgroundColor: _parseInt(json['backgroundColor']) ?? 0xFFFFFFFF,
      backgroundResource: json['backgroundResource'],
      backgroundResColor: json['backgroundResColor'],
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'marginLeft': marginLeft,
      'marginTop': marginTop,
      'marginRight': marginRight,
      'marginBottom': marginBottom,
      'paddingLeft': paddingLeft,
      'paddingTop': paddingTop,
      'paddingRight': paddingRight,
      'paddingBottom': paddingBottom,
      'layoutGravity': layoutGravity,
      'gravity': gravity,
      'weight': weight,
      'orientation': orientation,
      'weightSum': weightSum,
      'backgroundColor': backgroundColor,
      'backgroundResource': backgroundResource,
      'backgroundResColor': backgroundResColor,
    };
  }

  LayoutBean copyWith({
    int? width,
    int? height,
    double? marginLeft,
    double? marginTop,
    double? marginRight,
    double? marginBottom,
    int? paddingLeft,
    int? paddingTop,
    int? paddingRight,
    int? paddingBottom,
    int? layoutGravity,
    int? gravity,
    double? weight,
    int? orientation,
    double? weightSum,
    int? backgroundColor,
    String? backgroundResource,
    String? backgroundResColor,
  }) {
    return LayoutBean(
      width: width ?? this.width,
      height: height ?? this.height,
      marginLeft: marginLeft ?? this.marginLeft,
      marginTop: marginTop ?? this.marginTop,
      marginRight: marginRight ?? this.marginRight,
      marginBottom: marginBottom ?? this.marginBottom,
      paddingLeft: paddingLeft ?? this.paddingLeft,
      paddingTop: paddingTop ?? this.paddingTop,
      paddingRight: paddingRight ?? this.paddingRight,
      paddingBottom: paddingBottom ?? this.paddingBottom,
      layoutGravity: layoutGravity ?? this.layoutGravity,
      gravity: gravity ?? this.gravity,
      weight: weight ?? this.weight,
      orientation: orientation ?? this.orientation,
      weightSum: weightSum ?? this.weightSum,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundResource: backgroundResource ?? this.backgroundResource,
      backgroundResColor: backgroundResColor ?? this.backgroundResColor,
    );
  }

  static const int MATCH_PARENT = -1;
  static const int WRAP_CONTENT = -2;
  static const int GRAVITY_NONE = 0;
  static const int GRAVITY_LEFT = 3;
  static const int GRAVITY_TOP = 48;
  static const int GRAVITY_RIGHT = 5;
  static const int GRAVITY_BOTTOM = 80;
  static const int GRAVITY_CENTER_HORIZONTAL = 1;
  static const int GRAVITY_CENTER_VERTICAL = 16;
  static const int GRAVITY_CENTER = 17;
  static const int ORIENTATION_VERTICAL = 1;
  static const int ORIENTATION_HORIZONTAL = 0;
}
