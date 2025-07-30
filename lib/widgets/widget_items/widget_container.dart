import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

class WidgetContainer extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;

  const WidgetContainer({
    super.key,
    required this.widgetBean,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100 * scale,
      height: 60 * scale,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(
          color: _getBorderColor(),
          width: _getBorderWidth() * scale,
        ),
        borderRadius: BorderRadius.circular(_getCornerRadius() * scale),
      ),
      child: _hasChild() ? _buildChild() : null,
    );
  }

  Color _getBackgroundColor() {
    final color = widgetBean.properties['backgroundColor'];
    return color != null ? Color(color) : Colors.transparent;
  }

  Color _getBorderColor() {
    final color = widgetBean.properties['borderColor'];
    return color != null ? Color(color) : Colors.grey[300]!;
  }

  double _getBorderWidth() {
    return widgetBean.properties['borderWidth']?.toDouble() ?? 1.0;
  }

  double _getCornerRadius() {
    return widgetBean.properties['cornerRadius']?.toDouble() ?? 0.0;
  }

  bool _hasChild() {
    return widgetBean.children.isNotEmpty;
  }

  Widget _buildChild() {
    return Container(
      padding: EdgeInsets.all(8 * scale),
      child: Center(
        child: Text(
          'Container',
          style: TextStyle(
            fontSize: 12 * scale,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateSimpleId(),
      type: 'Container',
      properties: {
        'backgroundColor': 0xFFFFFFFF,
        'borderColor': 0xFFE0E0E0,
        'borderWidth': 1.0,
        'cornerRadius': 0.0,
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 200,
        height: 100,
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
