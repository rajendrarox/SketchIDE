import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

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
      height: 80 * scale,
      decoration: BoxDecoration(
        color: Colors.purple[50],
        border: Border.all(color: Colors.purple[200]!, width: 2 * scale),
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8 * scale,
            left: 8 * scale,
            child: Container(
              width: 20 * scale,
              height: 20 * scale,
              decoration: BoxDecoration(
                color: Colors.purple[300],
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
          ),
          Positioned(
            top: 20 * scale,
            left: 20 * scale,
            child: Container(
              width: 20 * scale,
              height: 20 * scale,
              decoration: BoxDecoration(
                color: Colors.purple[400],
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
          ),
          Positioned(
            top: 32 * scale,
            left: 32 * scale,
            child: Container(
              width: 20 * scale,
              height: 20 * scale,
              decoration: BoxDecoration(
                color: Colors.purple[500],
                borderRadius: BorderRadius.circular(4 * scale),
              ),
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
      type: 'Stack',
      properties: {
        'alignment': 'topLeft',
        'fit': 'loose',
        'clipBehavior': 'hardEdge',
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 200,
        height: 200,
      ),
      events: {},
      layout: LayoutBean(
        width: -2,
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
