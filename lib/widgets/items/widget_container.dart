import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetContainer - Flutter Container widget with Sketchware Pro-style selection
/// Styling wrapper widget
class WidgetContainer extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final bool isSelected;
  final double scale;
  final VoidCallback? onTap;
  final Widget? child;

  const WidgetContainer({
    super.key,
    required this.widgetBean,
    this.isSelected = false,
    this.scale = 1.0,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _getWidth(),
        height: _getHeight(),
        margin: _getMargin(),
        padding: _getPadding(),
        decoration: _getDecoration(),
        child: child ?? _buildDefaultChild(),
      ),
    );
  }

  double? _getWidth() {
    final width = widgetBean.properties['width'];
    if (width == null) return null;
    if (width == -1) return double.infinity; // MATCH_PARENT
    if (width == -2) return null; // WRAP_CONTENT
    return (width as num).toDouble() * scale;
  }

  double? _getHeight() {
    final height = widgetBean.properties['height'];
    if (height == null) return null;
    if (height == -1) return double.infinity; // MATCH_PARENT
    if (height == -2) return null; // WRAP_CONTENT
    return (height as num).toDouble() * scale;
  }

  EdgeInsets _getMargin() {
    return EdgeInsets.fromLTRB(
      (widgetBean.layout.marginLeft * scale).toDouble(),
      (widgetBean.layout.marginTop * scale).toDouble(),
      (widgetBean.layout.marginRight * scale).toDouble(),
      (widgetBean.layout.marginBottom * scale).toDouble(),
    );
  }

  EdgeInsets _getPadding() {
    return EdgeInsets.fromLTRB(
      (widgetBean.layout.paddingLeft * scale).toDouble(),
      (widgetBean.layout.paddingTop * scale).toDouble(),
      (widgetBean.layout.paddingRight * scale).toDouble(),
      (widgetBean.layout.paddingBottom * scale).toDouble(),
    );
  }

  BoxDecoration _getDecoration() {
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');
    final borderColor = isSelected
        ? const Color(0x9599d5d0)
        : _parseColor(widgetBean.properties['borderColor'] ?? '#CCCCCC');
    final borderWidth =
        isSelected ? 2.0 : (widgetBean.properties['borderWidth'] ?? 1.0);
    final borderRadius = widgetBean.properties['borderRadius'] ?? 0.0;

    return BoxDecoration(
      color: isSelected ? backgroundColor.withOpacity(0.9) : backgroundColor,
      border: Border.all(
        color: borderColor,
        width: borderWidth * scale,
      ),
      borderRadius: BorderRadius.circular(borderRadius * scale),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: const Color(0x9599d5d0).withOpacity(0.3),
                blurRadius: 4 * scale,
                spreadRadius: 1 * scale,
              ),
            ]
          : null,
    );
  }

  Widget _buildDefaultChild() {
    return Center(
      child: Text(
        'Container',
        style: TextStyle(
          fontSize: 12 * scale,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
            int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }

  /// Create a FlutterWidgetBean for Container
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateId(),
      type: 'Container',
      properties: {
        'width': -2, // WRAP_CONTENT
        'height': -2, // WRAP_CONTENT
        'backgroundColor': '#FFFFFF',
        'borderColor': '#CCCCCC',
        'borderWidth': 1.0,
        'borderRadius': 0.0,
        'alignment': 'center',
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 150,
        height: 80,
      ),
      events: {},
      layout: LayoutBean(
        width: -2, // WRAP_CONTENT
        height: -2, // WRAP_CONTENT
        marginLeft: 0,
        marginTop: 0,
        marginRight: 0,
        marginBottom: 0,
        paddingLeft: 16,
        paddingTop: 16,
        paddingRight: 16,
        paddingBottom: 16,
      ),
    );
  }
}
