import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetText - Simple palette widget for Text (matches Sketchware Pro's IconTextView)
/// Display-only widget for palette, no interactive features
class WidgetText extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;

  const WidgetText({
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
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1 * scale),
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Center(
        child: Text(
          _getText(),
          style: TextStyle(
            fontSize: 12 * scale,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _getText() {
    return widgetBean.properties['text'] ?? 'Text';
  }

  /// Create a FlutterWidgetBean for Text (matches Sketchware Pro's getBean())
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateSimpleId(),
      type: 'Text',
      properties: {
        'text': 'Text Widget',
        'textSize': 14.0,
        'textColor': 0xFF000000,
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 120,
        height: 30,
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
        paddingTop: 4,
        paddingRight: 8,
        paddingBottom: 4,
      ),
    );
  }
}
