import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetContainer - Simple palette widget for Container (matches Sketchware Pro's Icon*)
/// Display-only widget for palette, no interactive features
class WidgetContainer extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;

  const WidgetContainer({
    super.key,
    required this.widgetBean,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80 * scale,
      height: 60 * scale,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(color: Colors.grey[400]!, width: 1 * scale),
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Center(
        child: Text(
          'Container',
          style: TextStyle(
            fontSize: 10 * scale,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    final color = widgetBean.properties['backgroundColor'];
    if (color != null) {
      if (color is int) {
        return Color(color);
      } else if (color is String && color.startsWith('#')) {
        try {
          return Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
        } catch (e) {
          return Colors.white;
        }
      }
    }
    return Colors.white;
  }

  /// Create a FlutterWidgetBean for Container (matches Sketchware Pro's getBean())
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateSimpleId(),
      type: 'Container',
      properties: {
        'backgroundColor': 0xFFFFFFFF,
        'borderColor': 0xFFCCCCCC,
        'borderRadius': 4.0,
        'borderWidth': 1.0,
        'padding': 8.0,
        'margin': 0.0,
        'alignment': 'center',
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 120,
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
        paddingLeft: 8,
        paddingTop: 8,
        paddingRight: 8,
        paddingBottom: 8,
      ),
    );
  }
}
