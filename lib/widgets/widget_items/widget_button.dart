import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetButton - Simple palette widget for Button (matches Sketchware Pro's IconButton)
/// Display-only widget for palette, no interactive features
class WidgetButton extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;

  const WidgetButton({
    super.key,
    required this.widgetBean,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80 * scale,
      height: 40 * scale,
      decoration: BoxDecoration(
        color: Colors.blue[600],
        border: Border.all(color: Colors.grey[300]!, width: 1 * scale),
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Center(
        child: Text(
          _getText(),
          style: TextStyle(
            fontSize: 12 * scale,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _getText() {
    return widgetBean.properties['text'] ?? 'Button';
  }

  /// Create a FlutterWidgetBean for Button (matches Sketchware Pro's getBean())
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateSimpleId(),
      type: 'Button',
      properties: {
        'text': 'Button',
        'textSize': 14.0,
        'textColor': 0xFFFFFFFF,
        'backgroundColor': 0xFF2196F3,
        'cornerRadius': 4.0,
        'enabled': true,
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 120,
        height: 40,
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
