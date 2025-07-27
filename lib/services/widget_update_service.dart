import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';

/// Widget Update Service - EXACTLY matches Sketchware Pro's updateItemView functionality
/// Handles widget-specific property updates for real-time changes
class WidgetUpdateService {
  /// Update widget based on its type (like Sketchware Pro's updateItemView)
  Widget updateWidget(Widget widget, FlutterWidgetBean widgetBean) {
    // First update layout properties
    Widget updatedWidget = updateLayout(widget, widgetBean);

    // Then update widget-specific properties based on type
    switch (widgetBean.type) {
      case 'Text':
        return updateTextWidget(updatedWidget, widgetBean);
      case 'TextField':
        return updateTextFieldWidget(updatedWidget, widgetBean);
      case 'Container':
        return updateContainerWidget(updatedWidget, widgetBean);
      case 'Icon':
        return updateIconWidget(updatedWidget, widgetBean);
      case 'Row':
      case 'Column':
        return updateLayoutWidget(updatedWidget, widgetBean);
      case 'Stack':
        return updateStackWidget(updatedWidget, widgetBean);
      default:
        return updatedWidget;
    }
  }

  /// Update layout properties (like Sketchware Pro's updateLayout method)
  Widget updateLayout(Widget widget, FlutterWidgetBean widgetBean) {
    final layout = widgetBean.layout;

    // Create container with layout properties
    return Container(
      width: _getWidth(layout.width),
      height: _getHeight(layout.height),
      margin: EdgeInsets.only(
        left: layout.marginLeft,
        top: layout.marginTop,
        right: layout.marginRight,
        bottom: layout.marginBottom,
      ),
      padding: EdgeInsets.only(
        left: layout.paddingLeft.toDouble(),
        top: layout.paddingTop.toDouble(),
        right: layout.paddingRight.toDouble(),
        bottom: layout.paddingBottom.toDouble(),
      ),
      color: Color(layout.backgroundColor),
      child: widget,
    );
  }

  /// Update text widget properties (like Sketchware Pro's updateTextView method)
  Widget updateTextWidget(Widget widget, FlutterWidgetBean widgetBean) {
    if (widget is! Text) return widget;

    final text = widgetBean.properties['text'] ?? 'Text';
    final textSize = widgetBean.properties['textSize'] ?? 14.0;
    final textColor = widgetBean.properties['textColor'] ?? Colors.black;
    final textType = widgetBean.properties['textType'] ?? 'normal';
    final lines = widgetBean.properties['lines'] ?? 1;
    final singleLine = widgetBean.properties['singleLine'] ?? false;

    return Text(
      text,
      style: TextStyle(
        fontSize: _parseDouble(textSize),
        color: _parseColor(textColor),
        fontWeight: _getFontWeight(textType),
      ),
      maxLines: singleLine ? 1 : _parseInt(lines),
      overflow: singleLine ? TextOverflow.ellipsis : null,
    );
  }

  /// Update text field widget properties
  Widget updateTextFieldWidget(Widget widget, FlutterWidgetBean widgetBean) {
    if (widget is! TextField) return widget;

    final hint = widgetBean.properties['hint'] ?? '';
    final hintColor = widgetBean.properties['hintColor'] ?? Colors.grey;
    final text = widgetBean.properties['text'] ?? '';

    return TextField(
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _parseColor(hintColor)),
      ),
    );
  }

  /// Update container widget properties
  Widget updateContainerWidget(Widget widget, FlutterWidgetBean widgetBean) {
    if (widget is! Container) return widget;

    final backgroundColor =
        widgetBean.properties['backgroundColor'] ?? Colors.transparent;
    final borderColor =
        widgetBean.properties['borderColor'] ?? Colors.transparent;
    final borderWidth = widgetBean.properties['borderWidth'] ?? 0.0;
    final borderRadius = widgetBean.properties['borderRadius'] ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: _parseColor(backgroundColor),
        border: Border.all(
          color: _parseColor(borderColor),
          width: _parseDouble(borderWidth),
        ),
        borderRadius: BorderRadius.circular(_parseDouble(borderRadius)),
      ),
      child: widget,
    );
  }

  /// Update icon widget properties
  Widget updateIconWidget(Widget widget, FlutterWidgetBean widgetBean) {
    if (widget is! Icon) return widget;

    final iconName = widgetBean.properties['iconName'] ?? Icons.star;
    final iconSize = widgetBean.properties['iconSize'] ?? 24.0;
    final iconColor = widgetBean.properties['iconColor'] ?? Colors.black;

    return Icon(
      _parseIconData(iconName),
      size: _parseDouble(iconSize),
      color: _parseColor(iconColor),
    );
  }

  /// Update layout widget properties (Row/Column)
  Widget updateLayoutWidget(Widget widget, FlutterWidgetBean widgetBean) {
    final mainAxisAlignment =
        widgetBean.properties['mainAxisAlignment'] ?? 'start';
    final crossAxisAlignment =
        widgetBean.properties['crossAxisAlignment'] ?? 'start';
    final mainAxisSize = widgetBean.properties['mainAxisSize'] ?? 'max';

    if (widgetBean.type == 'Row') {
      return Row(
        mainAxisAlignment: _parseMainAxisAlignment(mainAxisAlignment),
        crossAxisAlignment: _parseCrossAxisAlignment(crossAxisAlignment),
        mainAxisSize: _parseMainAxisSize(mainAxisSize),
        children: widget is Row ? widget.children : [widget],
      );
    } else if (widgetBean.type == 'Column') {
      return Column(
        mainAxisAlignment: _parseMainAxisAlignment(mainAxisAlignment),
        crossAxisAlignment: _parseCrossAxisAlignment(crossAxisAlignment),
        mainAxisSize: _parseMainAxisSize(mainAxisSize),
        children: widget is Column ? widget.children : [widget],
      );
    }

    return widget;
  }

  /// Update stack widget properties
  Widget updateStackWidget(Widget widget, FlutterWidgetBean widgetBean) {
    final alignment = widgetBean.properties['alignment'] ?? 'topLeft';
    final fit = widgetBean.properties['fit'] ?? 'loose';

    return Stack(
      alignment: _parseAlignment(alignment),
      fit: _parseStackFit(fit),
      children: widget is Stack ? widget.children : [widget],
    );
  }

  // Helper methods for parsing values
  double? _getWidth(int width) {
    if (width == LayoutBean.MATCH_PARENT) return double.infinity;
    if (width == LayoutBean.WRAP_CONTENT) return null;
    return width.toDouble();
  }

  double? _getHeight(int height) {
    if (height == LayoutBean.MATCH_PARENT) return double.infinity;
    if (height == LayoutBean.WRAP_CONTENT) return null;
    return height.toDouble();
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  Color _parseColor(dynamic value) {
    if (value is Color) return value;
    if (value is int) return Color(value);
    if (value is String) {
      if (value.startsWith('0x')) {
        try {
          return Color(int.parse(value));
        } catch (e) {
          return Colors.black;
        }
      }
      // Handle color names
      switch (value.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'green':
          return Colors.green;
        case 'blue':
          return Colors.blue;
        case 'black':
          return Colors.black;
        case 'white':
          return Colors.white;
        case 'grey':
        case 'gray':
          return Colors.grey;
        default:
          return Colors.black;
      }
    }
    return Colors.black;
  }

  FontWeight _getFontWeight(String textType) {
    switch (textType.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'normal':
        return FontWeight.normal;
      case 'light':
        return FontWeight.w300;
      default:
        return FontWeight.normal;
    }
  }

  IconData _parseIconData(dynamic value) {
    if (value is IconData) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'star':
          return Icons.star;
        case 'home':
          return Icons.home;
        case 'settings':
          return Icons.settings;
        case 'person':
          return Icons.person;
        case 'favorite':
          return Icons.favorite;
        default:
          return Icons.star;
      }
    }
    return Icons.star;
  }

  MainAxisAlignment _parseMainAxisAlignment(String value) {
    switch (value.toLowerCase()) {
      case 'start':
        return MainAxisAlignment.start;
      case 'center':
        return MainAxisAlignment.center;
      case 'end':
        return MainAxisAlignment.end;
      case 'spacebetween':
        return MainAxisAlignment.spaceBetween;
      case 'spacearound':
        return MainAxisAlignment.spaceAround;
      case 'spaceevenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _parseCrossAxisAlignment(String value) {
    switch (value.toLowerCase()) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'center':
        return CrossAxisAlignment.center;
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.start;
    }
  }

  MainAxisSize _parseMainAxisSize(String value) {
    switch (value.toLowerCase()) {
      case 'min':
        return MainAxisSize.min;
      case 'max':
        return MainAxisSize.max;
      default:
        return MainAxisSize.max;
    }
  }

  Alignment _parseAlignment(String value) {
    switch (value.toLowerCase()) {
      case 'topleft':
        return Alignment.topLeft;
      case 'topcenter':
        return Alignment.topCenter;
      case 'topright':
        return Alignment.topRight;
      case 'centerleft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerright':
        return Alignment.centerRight;
      case 'bottomleft':
        return Alignment.bottomLeft;
      case 'bottomcenter':
        return Alignment.bottomCenter;
      case 'bottomright':
        return Alignment.bottomRight;
      default:
        return Alignment.topLeft;
    }
  }

  StackFit _parseStackFit(String value) {
    switch (value.toLowerCase()) {
      case 'loose':
        return StackFit.loose;
      case 'expand':
        return StackFit.expand;
      case 'passthrough':
        return StackFit.passthrough;
      default:
        return StackFit.loose;
    }
  }
}
