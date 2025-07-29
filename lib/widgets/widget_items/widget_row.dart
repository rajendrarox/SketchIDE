import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetRow - Simple palette widget for Row (matches Sketchware Pro's Icon*)
/// Display-only widget for palette, no interactive features
class WidgetRow extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;

  const WidgetRow({
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
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[300]!, width: 1 * scale),
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSampleItem('A'),
          _buildSampleItem('B'),
          _buildSampleItem('C'),
        ],
      ),
    );
  }

  Widget _buildSampleItem(String text) {
    return Container(
      width: 16 * scale,
      height: 16 * scale,
      decoration: BoxDecoration(
        color: Colors.blue[200],
        borderRadius: BorderRadius.circular(2 * scale),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 8 * scale,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Create a FlutterWidgetBean for Row (matches Sketchware Pro's getBean())
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateSimpleId(),
      type: 'Row',
      properties: {
        'mainAxisAlignment': 'start',
        'crossAxisAlignment': 'center',
        'mainAxisSize': 'max',
        'textDirection': 'ltr',
        'verticalDirection': 'down',
        'textBaseline': 'alphabetic',
        'children': [],
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
        width: -1, // MATCH_PARENT
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
