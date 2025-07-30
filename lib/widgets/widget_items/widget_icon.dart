import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../services/icon_utils.dart';

/// WidgetIcon - Simple palette widget for Icon (matches Sketchware Pro's IconImageView)
/// Display-only widget for palette, no interactive features
class WidgetIcon extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;

  const WidgetIcon({
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
        child: Icon(
          _getIconData(),
          size: 24 * scale,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  IconData _getIconData() {
    final iconName = widgetBean.properties['iconName'] ?? 'home';
    return IconUtils.getIconFromName(iconName);
  }

  /// Create a FlutterWidgetBean for Icon (matches Sketchware Pro's getBean())
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateSimpleId(),
      type: 'Icon',
      properties: {
        'iconName': 'home',
        'iconSize': 24.0,
        'iconColor': 0xFF000000,
        'semanticLabel': 'Icon',
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 48,
        height: 48,
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
