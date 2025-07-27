import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';
import '../models/text_properties.dart';
import '../models/container_properties.dart';
import '../models/text_field_properties.dart';
import '../models/icon_properties.dart';
import '../models/layout_properties.dart';
import '../models/stack_properties.dart';
import '../widgets/items/widget_text.dart';
import '../widgets/items/widget_container.dart';
import '../widgets/items/widget_text_field.dart';
import '../widgets/items/widget_icon.dart';
import '../widgets/items/widget_row.dart';
import '../widgets/items/widget_column.dart';
import '../widgets/items/widget_stack.dart';

/// WidgetFactoryService - EXACTLY matches Sketchware Pro's ViewPane.createItemView()
/// Factory service for creating widget instances based on FlutterWidgetBean type
class WidgetFactoryService {
  static const String _tag = 'WidgetFactoryService';

  /// Create a widget instance based on the FlutterWidgetBean type
  /// This follows Sketchware Pro's ViewPane.createItemView() pattern
  static Widget createWidget(
    FlutterWidgetBean widgetBean, {
    bool isSelected = false,
    double scale = 1.0,
    VoidCallback? onTap,
  }) {
    switch (widgetBean.type) {
      case 'Text':
        return WidgetText(
          widgetBean: widgetBean,
          isSelected: isSelected,
          scale: scale,
          onTap: onTap,
        );

      case 'Container':
        return WidgetContainer(
          widgetBean: widgetBean,
          isSelected: isSelected,
          scale: scale,
          onTap: onTap,
        );

      case 'TextField':
        return WidgetTextField(
          widgetBean: widgetBean,
          isSelected: isSelected,
          scale: scale,
          onTap: onTap,
        );

      case 'Icon':
        return WidgetIcon(
          widgetBean: widgetBean,
          isSelected: isSelected,
          scale: scale,
          onTap: onTap,
        );

      case 'Row':
        return WidgetRow(
          widgetBean: widgetBean,
          isSelected: isSelected,
          scale: scale,
          onTap: onTap,
        );

      case 'Column':
        return WidgetColumn(
          widgetBean: widgetBean,
          isSelected: isSelected,
          scale: scale,
          onTap: onTap,
        );

      case 'Stack':
        return WidgetStack(
          widgetBean: widgetBean,
          isSelected: isSelected,
          scale: scale,
          onTap: onTap,
        );

      default:
        // Fallback to Container for unknown types (like Sketchware Pro's getUnknownItemView)
        print(
            '$_tag: Unknown widget type "${widgetBean.type}", falling back to Container');
        return WidgetContainer(
          widgetBean: widgetBean.copyWith(type: 'Container'),
          isSelected: isSelected,
          scale: scale,
          onTap: onTap,
        );
    }
  }

  /// Create a FlutterWidgetBean with proper strongly typed properties
  /// This follows Sketchware Pro's pattern of creating ViewBean with proper properties
  static FlutterWidgetBean createWidgetBean(
    String type, {
    String? id,
    Map<String, dynamic>? customProperties,
  }) {
    final widgetId = id ?? FlutterWidgetBean.generateId();

    switch (type) {
      case 'Text':
        final textProps = TextProperties();
        return FlutterWidgetBean(
          id: widgetId,
          type: type,
          properties: textProps.toJson(),
          children: [],
          position: PositionBean(x: 0, y: 0, width: 120, height: 30),
          events: {},
          layout: LayoutBean(
            width: -2, // WRAP_CONTENT
            height: -2, // WRAP_CONTENT
            paddingLeft: 8,
            paddingTop: 4,
            paddingRight: 8,
            paddingBottom: 4,
          ),
        );

      case 'Container':
        final containerProps = ContainerProperties();
        return FlutterWidgetBean(
          id: widgetId,
          type: type,
          properties: containerProps.toJson(),
          children: [],
          position: PositionBean(x: 0, y: 0, width: 150, height: 80),
          events: {},
          layout: LayoutBean(
            width: -2, // WRAP_CONTENT
            height: -2, // WRAP_CONTENT
            paddingLeft: 16,
            paddingTop: 16,
            paddingRight: 16,
            paddingBottom: 16,
          ),
        );

      case 'TextField':
        final textFieldProps = TextFieldProperties();
        return FlutterWidgetBean(
          id: widgetId,
          type: type,
          properties: textFieldProps.toJson(),
          children: [],
          position: PositionBean(x: 0, y: 0, width: 200, height: 50),
          events: {},
          layout: LayoutBean(
            width: -1, // MATCH_PARENT
            height: -2, // WRAP_CONTENT
            paddingLeft: 8,
            paddingTop: 4,
            paddingRight: 8,
            paddingBottom: 4,
          ),
        );

      case 'Icon':
        final iconProps = IconProperties();
        return FlutterWidgetBean(
          id: widgetId,
          type: type,
          properties: iconProps.toJson(),
          children: [],
          position: PositionBean(x: 0, y: 0, width: 50, height: 50),
          events: {},
          layout: LayoutBean(
            width: -2, // WRAP_CONTENT
            height: -2, // WRAP_CONTENT
            paddingLeft: 8,
            paddingTop: 8,
            paddingRight: 8,
            paddingBottom: 8,
          ),
        );

      case 'Row':
        final layoutProps = LayoutProperties();
        return FlutterWidgetBean(
          id: widgetId,
          type: type,
          properties: layoutProps.toJson(),
          children: [],
          position: PositionBean(x: 0, y: 0, width: 200, height: 50),
          events: {},
          layout: LayoutBean(
            width: -1, // MATCH_PARENT
            height: -2, // WRAP_CONTENT
            paddingLeft: 8,
            paddingTop: 8,
            paddingRight: 8,
            paddingBottom: 8,
          ),
        );

      case 'Column':
        final layoutProps = LayoutProperties();
        return FlutterWidgetBean(
          id: widgetId,
          type: type,
          properties: layoutProps.toJson(),
          children: [],
          position: PositionBean(x: 0, y: 0, width: 200, height: 100),
          events: {},
          layout: LayoutBean(
            width: -2, // WRAP_CONTENT
            height: -1, // MATCH_PARENT
            paddingLeft: 8,
            paddingTop: 8,
            paddingRight: 8,
            paddingBottom: 8,
          ),
        );

      case 'Stack':
        final stackProps = StackProperties();
        return FlutterWidgetBean(
          id: widgetId,
          type: type,
          properties: stackProps.toJson(),
          children: [],
          position: PositionBean(x: 0, y: 0, width: 200, height: 100),
          events: {},
          layout: LayoutBean(
            width: -1, // MATCH_PARENT
            height: -1, // MATCH_PARENT
          ),
        );

      default:
        // Fallback to Container for unknown types
        print('$_tag: Unknown widget type "$type", falling back to Container');
        final containerProps = ContainerProperties();
        return FlutterWidgetBean(
          id: widgetId,
          type: 'Container',
          properties: containerProps.toJson(),
          children: [],
          position: PositionBean(x: 0, y: 0, width: 150, height: 80),
          events: {},
          layout: LayoutBean(
            width: -2, // WRAP_CONTENT
            height: -2, // WRAP_CONTENT
            paddingLeft: 16,
            paddingTop: 16,
            paddingRight: 16,
            paddingBottom: 16,
          ),
        );
    }
  }

  /// Get strongly typed properties from FlutterWidgetBean
  /// This provides type-safe access to widget properties
  static dynamic getTypedProperties(FlutterWidgetBean widgetBean) {
    switch (widgetBean.type) {
      case 'Text':
        return TextProperties.fromJson(widgetBean.properties);

      case 'Container':
        return ContainerProperties.fromJson(widgetBean.properties);

      case 'TextField':
        return TextFieldProperties.fromJson(widgetBean.properties);

      case 'Icon':
        return IconProperties.fromJson(widgetBean.properties);

      case 'Row':
      case 'Column':
        return LayoutProperties.fromJson(widgetBean.properties);

      case 'Stack':
        return StackProperties.fromJson(widgetBean.properties);

      default:
        return widgetBean.properties; // Fallback to dynamic map
    }
  }
}
