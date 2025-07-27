import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetRow - Flutter Row widget with Sketchware Pro-style selection
/// Horizontal arrangement of widgets
class WidgetRow extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final bool isSelected;
  final double scale;
  final VoidCallback? onTap;
  final List<Widget> children;

  const WidgetRow({
    super.key,
    required this.widgetBean,
    this.isSelected = false,
    this.scale = 1.0,
    this.onTap,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: const Color(0x9599d5d0), width: 2 * scale)
              : Border.all(
                  color: Colors.grey.withOpacity(0.3), width: 1 * scale),
          color: isSelected
              ? const Color(0x9599d5d0).withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: _getMainAxisAlignment(),
          crossAxisAlignment: _getCrossAxisAlignment(),
          mainAxisSize: _getMainAxisSize(),
          children: children.isEmpty ? _buildDefaultChildren() : children,
        ),
      ),
    );
  }

  MainAxisAlignment _getMainAxisAlignment() {
    final alignment = widgetBean.properties['mainAxisAlignment'] ?? 'start';
    switch (alignment) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _getCrossAxisAlignment() {
    final alignment = widgetBean.properties['crossAxisAlignment'] ?? 'center';
    switch (alignment) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.center;
    }
  }

  MainAxisSize _getMainAxisSize() {
    final size = widgetBean.properties['mainAxisSize'] ?? 'max';
    return size == 'min' ? MainAxisSize.min : MainAxisSize.max;
  }

  List<Widget> _buildDefaultChildren() {
    // Default children for empty Row
    return [
      Container(
        width: 50 * scale,
        height: 30 * scale,
        margin: EdgeInsets.all(4 * scale),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4 * scale),
          border: Border.all(color: Colors.blue.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            'Item 1',
            style: TextStyle(
              fontSize: 10 * scale,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ),
      Container(
        width: 50 * scale,
        height: 30 * scale,
        margin: EdgeInsets.all(4 * scale),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4 * scale),
          border: Border.all(color: Colors.green.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            'Item 2',
            style: TextStyle(
              fontSize: 10 * scale,
              color: Colors.green.shade700,
            ),
          ),
        ),
      ),
    ];
  }

  /// Create a FlutterWidgetBean for Row
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateId(),
      type: 'Row',
      properties: {
        'mainAxisAlignment': 'start',
        'crossAxisAlignment': 'center',
        'mainAxisSize': 'max',
        'textDirection': 'ltr',
        'verticalDirection': 'down',
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 300,
        height: 50,
      ),
      events: {},
      layout: LayoutBean(
        width: -1, // MATCH_PARENT
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
