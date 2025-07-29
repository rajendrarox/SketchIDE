import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';

/// Layout Property Service - Manages layout-specific properties for widgets
/// Matches Sketchware Pro's layout property management system
class LayoutPropertyService {
  static final LayoutPropertyService _instance =
      LayoutPropertyService._internal();
  factory LayoutPropertyService() => _instance;
  LayoutPropertyService._internal();

  /// Get default properties for a widget type
  Map<String, dynamic> getDefaultProperties(String widgetType) {
    switch (widgetType) {
      case 'Row':
        return _getRowDefaultProperties();
      case 'Column':
        return _getColumnDefaultProperties();
      case 'Stack':
        return _getStackDefaultProperties();
      case 'Container':
        return _getContainerDefaultProperties();
      default:
        return {};
    }
  }

  /// Get Row default properties
  Map<String, dynamic> _getRowDefaultProperties() {
    return {
      'mainAxisAlignment': 'start',
      'crossAxisAlignment': 'center',
      'mainAxisSize': 'max',
      'textDirection': 'ltr',
      'verticalDirection': 'down',
      'textBaseline': 'alphabetic',
    };
  }

  /// Get Column default properties
  Map<String, dynamic> _getColumnDefaultProperties() {
    return {
      'mainAxisAlignment': 'start',
      'crossAxisAlignment': 'center',
      'mainAxisSize': 'max',
      'textDirection': 'ltr',
      'verticalDirection': 'down',
      'textBaseline': 'alphabetic',
    };
  }

  /// Get Stack default properties
  Map<String, dynamic> _getStackDefaultProperties() {
    return {
      'alignment': 'center',
      'fit': 'loose',
      'clipBehavior': 'hardEdge',
    };
  }

  /// Get Container default properties
  Map<String, dynamic> _getContainerDefaultProperties() {
    return {
      'alignment': 'center',
      'margin': 0.0,
      'padding': 0.0,
      'decoration': null,
      'constraints': null,
      'transform': null,
    };
  }

  /// Get child default properties
  Map<String, dynamic> getChildDefaultProperties(String parentType) {
    switch (parentType) {
      case 'Row':
      case 'Column':
        return {
          'margin': 0.0,
          'flex': 1,
          'fit': 'loose',
        };
      case 'Stack':
        return {
          'alignment': 'center',
          'left': null,
          'top': null,
          'right': null,
          'bottom': null,
        };
      case 'Container':
        return {
          'margin': 0.0,
        };
      default:
        return {};
    }
  }

  /// Parse MainAxisAlignment from string
  MainAxisAlignment parseMainAxisAlignment(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'start':
          return MainAxisAlignment.start;
        case 'end':
          return MainAxisAlignment.end;
        case 'center':
          return MainAxisAlignment.center;
        case 'space_between':
          return MainAxisAlignment.spaceBetween;
        case 'space_around':
          return MainAxisAlignment.spaceAround;
        case 'space_evenly':
          return MainAxisAlignment.spaceEvenly;
      }
    }
    return MainAxisAlignment.start;
  }

  /// Parse CrossAxisAlignment from string
  CrossAxisAlignment parseCrossAxisAlignment(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'start':
          return CrossAxisAlignment.start;
        case 'end':
          return CrossAxisAlignment.end;
        case 'center':
          return CrossAxisAlignment.center;
        case 'stretch':
          return CrossAxisAlignment.stretch;
        case 'baseline':
          return CrossAxisAlignment.baseline;
      }
    }
    return CrossAxisAlignment.center;
  }

  /// Parse MainAxisSize from string
  MainAxisSize parseMainAxisSize(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'min':
          return MainAxisSize.min;
        case 'max':
          return MainAxisSize.max;
      }
    }
    return MainAxisSize.max;
  }

  /// Parse Alignment from string
  Alignment parseAlignment(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'top_left':
          return Alignment.topLeft;
        case 'top_center':
          return Alignment.topCenter;
        case 'top_right':
          return Alignment.topRight;
        case 'center_left':
          return Alignment.centerLeft;
        case 'center':
          return Alignment.center;
        case 'center_right':
          return Alignment.centerRight;
        case 'bottom_left':
          return Alignment.bottomLeft;
        case 'bottom_center':
          return Alignment.bottomCenter;
        case 'bottom_right':
          return Alignment.bottomRight;
      }
    }
    return Alignment.center;
  }

  /// Parse StackFit from string
  StackFit parseStackFit(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'loose':
          return StackFit.loose;
        case 'expand':
          return StackFit.expand;
        case 'passthrough':
          return StackFit.passthrough;
      }
    }
    return StackFit.loose;
  }

  /// Parse ClipBehavior from string
  Clip parseClipBehavior(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'none':
          return Clip.none;
        case 'hard_edge':
          return Clip.hardEdge;
        case 'anti_alias':
          return Clip.antiAlias;
        case 'anti_alias_with_save_layer':
          return Clip.antiAliasWithSaveLayer;
      }
    }
    return Clip.hardEdge;
  }

  /// Get available MainAxisAlignment options
  List<String> getMainAxisAlignmentOptions() {
    return [
      'start',
      'end',
      'center',
      'space_between',
      'space_around',
      'space_evenly',
    ];
  }

  /// Get available CrossAxisAlignment options
  List<String> getCrossAxisAlignmentOptions() {
    return [
      'start',
      'end',
      'center',
      'stretch',
      'baseline',
    ];
  }

  /// Get available MainAxisSize options
  List<String> getMainAxisSizeOptions() {
    return [
      'min',
      'max',
    ];
  }

  /// Get available Alignment options
  List<String> getAlignmentOptions() {
    return [
      'top_left',
      'top_center',
      'top_right',
      'center_left',
      'center',
      'center_right',
      'bottom_left',
      'bottom_center',
      'bottom_right',
    ];
  }

  /// Get available StackFit options
  List<String> getStackFitOptions() {
    return [
      'loose',
      'expand',
      'passthrough',
    ];
  }

  /// Get available ClipBehavior options
  List<String> getClipBehaviorOptions() {
    return [
      'none',
      'hard_edge',
      'anti_alias',
      'anti_alias_with_save_layer',
    ];
  }

  /// Validate layout properties for a widget
  bool validateLayoutProperties(FlutterWidgetBean widget) {
    switch (widget.type) {
      case 'Row':
      case 'Column':
        return _validateFlexLayoutProperties(widget);
      case 'Stack':
        return _validateStackProperties(widget);
      case 'Container':
        return _validateContainerProperties(widget);
      default:
        return true;
    }
  }

  /// Validate flex layout properties (Row/Column)
  bool _validateFlexLayoutProperties(FlutterWidgetBean widget) {
    final mainAxisAlignment = widget.properties['mainAxisAlignment'];
    final crossAxisAlignment = widget.properties['crossAxisAlignment'];
    final mainAxisSize = widget.properties['mainAxisSize'];

    return getMainAxisAlignmentOptions().contains(mainAxisAlignment) &&
        getCrossAxisAlignmentOptions().contains(crossAxisAlignment) &&
        getMainAxisSizeOptions().contains(mainAxisSize);
  }

  /// Validate Stack properties
  bool _validateStackProperties(FlutterWidgetBean widget) {
    final alignment = widget.properties['alignment'];
    final fit = widget.properties['fit'];
    final clipBehavior = widget.properties['clipBehavior'];

    return getAlignmentOptions().contains(alignment) &&
        getStackFitOptions().contains(fit) &&
        getClipBehaviorOptions().contains(clipBehavior);
  }

  /// Validate Container properties
  bool _validateContainerProperties(FlutterWidgetBean widget) {
    final alignment = widget.properties['alignment'];
    final margin = widget.properties['margin'];
    final padding = widget.properties['padding'];

    return getAlignmentOptions().contains(alignment) &&
        (margin == null || margin is num) &&
        (padding == null || padding is num);
  }

  /// Apply layout properties to a widget
  void applyLayoutProperties(
      FlutterWidgetBean widget, Map<String, dynamic> properties) {
    final defaultProps = getDefaultProperties(widget.type);
    final updatedProps = Map<String, dynamic>.from(widget.properties);

    // Merge with defaults and new properties
    updatedProps.addAll(defaultProps);
    updatedProps.addAll(properties);

    // Update widget properties
    widget.properties.clear();
    widget.properties.addAll(updatedProps);
  }

  /// Get layout property display name
  String getLayoutPropertyDisplayName(String propertyName) {
    switch (propertyName) {
      case 'mainAxisAlignment':
        return 'Main Alignment';
      case 'crossAxisAlignment':
        return 'Cross Alignment';
      case 'mainAxisSize':
        return 'Main Axis Size';
      case 'alignment':
        return 'Alignment';
      case 'fit':
        return 'Fit';
      case 'clipBehavior':
        return 'Clip Behavior';
      case 'margin':
        return 'Margin';
      case 'padding':
        return 'Padding';
      default:
        return propertyName;
    }
  }

  /// Get layout-specific property groups for property panel organization
  Map<String, List<String>> getLayoutPropertyGroups(String widgetType) {
    switch (widgetType) {
      case 'Row':
      case 'Column':
        return {
          'Layout': ['mainAxisAlignment', 'crossAxisAlignment', 'mainAxisSize'],
          'Spacing': ['margin', 'padding'],
        };
      case 'Stack':
        return {
          'Layout': ['alignment', 'fit', 'clipBehavior'],
          'Spacing': ['margin', 'padding'],
        };
      case 'Container':
        return {
          'Layout': ['alignment'],
          'Spacing': ['margin', 'padding'],
          'Decoration': ['backgroundColor', 'borderRadius'],
        };
      default:
        return {
          'General': ['margin', 'padding'],
        };
    }
  }

  /// Get property type for UI rendering
  String getPropertyType(String propertyName) {
    switch (propertyName) {
      case 'mainAxisAlignment':
      case 'crossAxisAlignment':
      case 'alignment':
      case 'fit':
      case 'clipBehavior':
        return 'selector';
      case 'mainAxisSize':
        return 'selector';
      case 'margin':
      case 'padding':
      case 'backgroundColor':
      case 'borderRadius':
        return 'input';
      default:
        return 'input';
    }
  }
}
