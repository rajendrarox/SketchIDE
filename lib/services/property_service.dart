import 'package:flutter/material.dart';
import 'color_utils.dart';
import '../models/flutter_widget_bean.dart';
import '../models/text_properties.dart';
import '../models/container_properties.dart';
import '../models/layout_properties.dart';
import '../models/icon_properties.dart';
import '../models/text_field_properties.dart';
import '../models/stack_properties.dart';
import '../widgets/property_items/property_text_box.dart';
import '../widgets/property_items/property_color_box.dart';
import '../widgets/property_items/property_selector_box.dart';

/// Property Service - Handles property definitions and business logic
/// EXACTLY matches Sketchware Pro's ViewPropertyItems logic
class PropertyService {
  /// Get property definitions for a specific widget type
  List<PropertyDefinition> getPropertiesForWidget(FlutterWidgetBean widget) {
    switch (widget.type) {
      case 'Text':
        return _getTextProperties(widget);
      case 'TextField':
        return _getTextFieldProperties(widget);
      case 'Container':
        return _getContainerProperties(widget);
      case 'Icon':
        return _getIconProperties(widget);
      case 'Row':
      case 'Column':
        return _getLayoutProperties(widget);
      case 'Stack':
        return _getStackProperties(widget);
      default:
        return [];
    }
  }

  /// Extract property values from widget
  Map<String, dynamic> extractPropertyValues(FlutterWidgetBean widget) {
    final values = <String, dynamic>{};

    // Extract from existing property models
    if (widget.properties.containsKey('textProperties')) {
      final textProps =
          TextProperties.fromJson(widget.properties['textProperties']);
      values['text'] = textProps.text;
      values['textSize'] = textProps.textSize.toString();
      values['textColor'] = textProps.textColor;
      values['textType'] = textProps.textType.toString();
    }

    if (widget.properties.containsKey('containerProperties')) {
      final containerProps = ContainerProperties.fromJson(
          widget.properties['containerProperties']);
      values['width'] = containerProps.width.toString();
      values['height'] = containerProps.height.toString();
      values['backgroundColor'] = containerProps.backgroundColor;
      values['borderColor'] = containerProps.borderColor;
      values['borderWidth'] = containerProps.borderWidth.toString();
      values['borderRadius'] = containerProps.borderRadius.toString();
    }

    if (widget.properties.containsKey('layoutProperties')) {
      final layoutProps =
          LayoutProperties.fromJson(widget.properties['layoutProperties']);
      values['mainAxisAlignment'] = layoutProps.mainAxisAlignment;
      values['crossAxisAlignment'] = layoutProps.crossAxisAlignment;
      values['mainAxisSize'] = layoutProps.mainAxisSize;
    }

    return values;
  }

  /// Create property widgets based on definitions
  List<Widget> createPropertyWidgets(
    List<PropertyDefinition> definitions,
    Map<String, dynamic> values,
    Function(String, dynamic) onPropertyChanged,
  ) {
    return definitions.map((def) {
      return _createPropertyWidget(
          def, values[def.key] ?? '', onPropertyChanged);
    }).toList();
  }

  /// Create individual property widget
  Widget _createPropertyWidget(
    PropertyDefinition definition,
    String currentValue,
    Function(String, dynamic) onPropertyChanged,
  ) {
    switch (definition.type) {
      case PropertyType.text:
        return PropertyTextBox(
          label: definition.label,
          value: currentValue,
          icon: definition.icon,
          onChanged: (value) => onPropertyChanged(definition.key, value),
          maxLines: definition.maxLines ?? 1,
          isNumber: definition.isNumber ?? false,
          minValue: definition.minValue,
          maxValue: definition.maxValue,
        );

      case PropertyType.color:
        return PropertyColorBox(
          label: definition.label,
          value: currentValue,
          icon: definition.icon,
          currentColor: ColorUtils.parseColor(currentValue) ?? Colors.black,
          onChanged: (color) => onPropertyChanged(definition.key, color.value),
          allowTransparent: definition.allowTransparent ?? false,
          allowNone: definition.allowNone ?? false,
        );

      case PropertyType.selector:
        return PropertySelectorBox(
          label: definition.label,
          value: currentValue,
          icon: definition.icon,
          options: definition.options ?? [],
          currentValue: currentValue,
          onChanged: (value) => onPropertyChanged(definition.key, value),
        );

      default:
        return PropertyTextBox(
          label: definition.label,
          value: currentValue,
          icon: definition.icon,
          onChanged: (value) => onPropertyChanged(definition.key, value),
        );
    }
  }

  /// Text widget properties
  List<PropertyDefinition> _getTextProperties(FlutterWidgetBean widget) {
    return [
      PropertyDefinition(
        key: 'text',
        label: 'Text',
        type: PropertyType.text,
        icon: Icons.text_fields,
        maxLines: 3,
      ),
      PropertyDefinition(
        key: 'textSize',
        label: 'Text Size',
        type: PropertyType.text,
        icon: Icons.format_size,
        isNumber: true,
        minValue: 8,
        maxValue: 72,
      ),
      PropertyDefinition(
        key: 'textColor',
        label: 'Text Color',
        type: PropertyType.color,
        icon: Icons.palette,
      ),
      PropertyDefinition(
        key: 'textType',
        label: 'Text Style',
        type: PropertyType.selector,
        icon: Icons.format_bold,
        options: ['Normal', 'Bold', 'Italic', 'Bold Italic'],
      ),
    ];
  }

  /// TextField widget properties
  List<PropertyDefinition> _getTextFieldProperties(FlutterWidgetBean widget) {
    return [
      PropertyDefinition(
        key: 'text',
        label: 'Text',
        type: PropertyType.text,
        icon: Icons.text_fields,
        maxLines: 3,
      ),
      PropertyDefinition(
        key: 'hint',
        label: 'Hint',
        type: PropertyType.text,
        icon: Icons.lightbulb_outline,
        maxLines: 2,
      ),
      PropertyDefinition(
        key: 'textSize',
        label: 'Text Size',
        type: PropertyType.text,
        icon: Icons.format_size,
        isNumber: true,
        minValue: 8,
        maxValue: 72,
      ),
      PropertyDefinition(
        key: 'textColor',
        label: 'Text Color',
        type: PropertyType.color,
        icon: Icons.palette,
      ),
      PropertyDefinition(
        key: 'hintColor',
        label: 'Hint Color',
        type: PropertyType.color,
        icon: Icons.palette,
      ),
      PropertyDefinition(
        key: 'inputType',
        label: 'Input Type',
        type: PropertyType.selector,
        icon: Icons.keyboard,
        options: ['Text', 'Number', 'Phone', 'Password', 'Email'],
      ),
    ];
  }

  /// Container widget properties
  List<PropertyDefinition> _getContainerProperties(FlutterWidgetBean widget) {
    return [
      PropertyDefinition(
        key: 'width',
        label: 'Width',
        type: PropertyType.selector,
        icon: Icons.width_normal,
        options: ['Wrap Content', 'Match Parent', 'Custom'],
      ),
      PropertyDefinition(
        key: 'height',
        label: 'Height',
        type: PropertyType.selector,
        icon: Icons.height,
        options: ['Wrap Content', 'Match Parent', 'Custom'],
      ),
      PropertyDefinition(
        key: 'backgroundColor',
        label: 'Background',
        type: PropertyType.color,
        icon: Icons.palette,
        allowTransparent: true,
        allowNone: true,
      ),
      PropertyDefinition(
        key: 'borderColor',
        label: 'Border Color',
        type: PropertyType.color,
        icon: Icons.border_color,
        allowTransparent: true,
      ),
      PropertyDefinition(
        key: 'borderWidth',
        label: 'Border Width',
        type: PropertyType.text,
        icon: Icons.border_style,
        isNumber: true,
        minValue: 0,
        maxValue: 20,
      ),
      PropertyDefinition(
        key: 'borderRadius',
        label: 'Border Radius',
        type: PropertyType.text,
        icon: Icons.rounded_corner,
        isNumber: true,
        minValue: 0,
        maxValue: 50,
      ),
    ];
  }

  /// Icon widget properties
  List<PropertyDefinition> _getIconProperties(FlutterWidgetBean widget) {
    return [
      PropertyDefinition(
        key: 'iconName',
        label: 'Icon',
        type: PropertyType.text,
        icon: Icons.emoji_emotions,
      ),
      PropertyDefinition(
        key: 'iconSize',
        label: 'Size',
        type: PropertyType.text,
        icon: Icons.format_size,
        isNumber: true,
        minValue: 12,
        maxValue: 100,
      ),
      PropertyDefinition(
        key: 'iconColor',
        label: 'Color',
        type: PropertyType.color,
        icon: Icons.palette,
      ),
    ];
  }

  /// Layout widget properties (Row/Column)
  List<PropertyDefinition> _getLayoutProperties(FlutterWidgetBean widget) {
    return [
      PropertyDefinition(
        key: 'mainAxisAlignment',
        label: 'Main Alignment',
        type: PropertyType.selector,
        icon: Icons.align_horizontal_center,
        options: [
          'Start',
          'Center',
          'End',
          'Space Between',
          'Space Around',
          'Space Evenly'
        ],
      ),
      PropertyDefinition(
        key: 'crossAxisAlignment',
        label: 'Cross Alignment',
        type: PropertyType.selector,
        icon: Icons.align_vertical_center,
        options: ['Start', 'Center', 'End', 'Stretch', 'Baseline'],
      ),
      PropertyDefinition(
        key: 'mainAxisSize',
        label: 'Main Axis Size',
        type: PropertyType.selector,
        icon: Icons.straighten,
        options: ['Min', 'Max'],
      ),
    ];
  }

  /// Stack widget properties
  List<PropertyDefinition> _getStackProperties(FlutterWidgetBean widget) {
    return [
      PropertyDefinition(
        key: 'alignment',
        label: 'Alignment',
        type: PropertyType.selector,
        icon: Icons.center_focus_strong,
        options: [
          'Top Left',
          'Top Center',
          'Top Right',
          'Center Left',
          'Center',
          'Center Right',
          'Bottom Left',
          'Bottom Center',
          'Bottom Right'
        ],
      ),
      PropertyDefinition(
        key: 'fit',
        label: 'Fit',
        type: PropertyType.selector,
        icon: Icons.fit_screen,
        options: ['Loose', 'Expand', 'Passthrough'],
      ),
      PropertyDefinition(
        key: 'clipBehavior',
        label: 'Clip Behavior',
        type: PropertyType.selector,
        icon: Icons.crop,
        options: [
          'None',
          'Hard Edge',
          'Anti Alias',
          'Anti Alias With Save Layer'
        ],
      ),
    ];
  }
}

/// Property Definition - Defines a property and its characteristics
class PropertyDefinition {
  final String key;
  final String label;
  final PropertyType type;
  final IconData icon;
  final int? maxLines;
  final bool? isNumber;
  final double? minValue;
  final double? maxValue;
  final List<String>? options;
  final bool? allowTransparent;
  final bool? allowNone;

  const PropertyDefinition({
    required this.key,
    required this.label,
    required this.type,
    required this.icon,
    this.maxLines,
    this.isNumber,
    this.minValue,
    this.maxValue,
    this.options,
    this.allowTransparent,
    this.allowNone,
  });
}

/// Property Types - Matches Sketchware Pro's property types
enum PropertyType {
  text,
  color,
  selector,
  boolean,
  measure,
  indent,
  resource,
}
