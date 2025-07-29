import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetColumn - Simple palette widget for Column (matches Sketchware Pro's Icon*)
/// Display-only widget for palette, no interactive features
class WidgetColumn extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;

  const WidgetColumn({
    super.key,
    required this.widgetBean,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60 * scale,
      height: 80 * scale,
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[300]!, width: 1 * scale),
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSampleItem('1'),
          _buildSampleItem('2'),
          _buildSampleItem('3'),
        ],
      ),
    );
  }

  Widget _buildSampleItem(String text) {
    return Container(
      width: 16 * scale,
      height: 16 * scale,
      decoration: BoxDecoration(
        color: Colors.green[200],
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

  /// Create a FlutterWidgetBean for Column (matches Sketchware Pro's getBean())
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateSimpleId(),
      type: 'Column',
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
        width: 80,
        height: 120,
      ),
      events: {},
      layout: LayoutBean(
        width: -2, // WRAP_CONTENT
        height: -1, // MATCH_PARENT
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
