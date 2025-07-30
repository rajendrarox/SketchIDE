import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

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
        borderRadius: BorderRadius.circular(8 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getText(),
          style: TextStyle(
            fontSize: 14 * scale,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getText() {
    return widgetBean.properties['text'] ?? 'Button';
  }

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
        'cornerRadius': 8.0,
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 120,
        height: 48,
      ),
      events: {},
      layout: LayoutBean(
        width: -2,
        height: -2,
        marginLeft: 0,
        marginTop: 0,
        marginRight: 0,
        marginBottom: 0,
        paddingLeft: 16,
        paddingTop: 12,
        paddingRight: 16,
        paddingBottom: 12,
      ),
    );
  }
}
