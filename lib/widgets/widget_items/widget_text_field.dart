import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetTextField - Simple palette widget for TextField (matches Sketchware Pro's IconEditText)
/// Display-only widget for palette, no interactive features
class WidgetTextField extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;

  const WidgetTextField({
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
        border: Border.all(color: Colors.grey[400]!, width: 1 * scale),
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Center(
        child: Text(
          _getHint(),
          style: TextStyle(
            fontSize: 12 * scale,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _getHint() {
    return widgetBean.properties['hint'] ?? 'Edit Text';
  }

  /// Create a FlutterWidgetBean for TextField (matches Sketchware Pro's getBean())
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateSimpleId(),
      type: 'TextField',
      properties: {
        'text': '',
        'hint': 'Edit Text',
        'textSize': 14.0,
        'textColor': 0xFF000000,
        'hintColor': 0xFF757575,
        'inputType': 1, // TEXT
        'imeOption': 0, // NORMAL
        'singleLine': 1, // TRUE
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
