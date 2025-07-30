import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

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
      width: 120 * scale,
      height: 60 * scale,
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!, width: 2 * scale),
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_agenda,
            size: 24 * scale,
            color: Colors.green[600],
          ),
          SizedBox(width: 8 * scale),
          Text(
            'Row',
            style: TextStyle(
              fontSize: 12 * scale,
              color: Colors.green[700],
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
      type: 'Row',
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
        width: 300,
        height: 100,
      ),
      events: {},
      layout: LayoutBean(
        width: -1,
        height: -2,
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
