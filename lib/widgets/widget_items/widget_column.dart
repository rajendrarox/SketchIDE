import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

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
      width: 80 * scale,
      height: 120 * scale,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!, width: 2 * scale),
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_column,
            size: 24 * scale,
            color: Colors.blue[600],
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Column',
            style: TextStyle(
              fontSize: 12 * scale,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

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
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 200,
        height: 300,
      ),
      events: {},
      layout: LayoutBean(
        width: -2,
        height: -1,
        marginLeft: 0,
        marginTop: 0,
        marginRight: 0,
        marginBottom: 0,
        paddingLeft: 0,
        paddingTop: 0,
        paddingRight: 0,
        paddingBottom: 0,
      ),
    );
  }
}
