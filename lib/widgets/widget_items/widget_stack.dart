import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetStack - Simple palette widget for Stack (matches Sketchware Pro's Icon*)
/// Display-only widget for palette, no interactive features
class WidgetStack extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;

  const WidgetStack({
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
        color: Colors.purple[50],
        border: Border.all(color: Colors.purple[300]!, width: 1 * scale),
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Stack(
        children: [
          _buildSampleItem('1', Alignment.topLeft),
          _buildSampleItem('2', Alignment.center),
          _buildSampleItem('3', Alignment.bottomRight),
        ],
      ),
    );
  }

  Widget _buildSampleItem(String text, Alignment alignment) {
    return Positioned(
      left: alignment.x < 0 ? 4 * scale : null,
      right: alignment.x > 0 ? 4 * scale : null,
      top: alignment.y < 0 ? 4 * scale : null,
      bottom: alignment.y > 0 ? 4 * scale : null,
      child: Container(
        width: 20 * scale,
        height: 20 * scale,
        decoration: BoxDecoration(
          color: Colors.purple[200],
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10 * scale,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Create a FlutterWidgetBean for Stack (matches Sketchware Pro's getBean())
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateSimpleId(),
      type: 'Stack',
      properties: {
        'alignment': 'topLeft',
        'fit': 'loose',
        'clipBehavior': 'hardEdge',
        'children': [],
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
        paddingLeft: 4,
        paddingTop: 4,
        paddingRight: 4,
        paddingBottom: 4,
      ),
    );
  }
}
