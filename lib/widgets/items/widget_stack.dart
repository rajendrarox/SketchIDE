import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetStack - Flutter Stack widget with Sketchware Pro-style selection
/// Overlapping/positioned widgets (replaces RelativeLayout)
class WidgetStack extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final bool isSelected;
  final double scale;
  final VoidCallback? onTap;
  final List<Widget> children;

  const WidgetStack({
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
        child: Stack(
          alignment: _getAlignment(),
          fit: _getFit(),
          clipBehavior: _getClipBehavior(),
          children: children.isEmpty ? _buildDefaultChildren() : children,
        ),
      ),
    );
  }

  Alignment _getAlignment() {
    final alignment = widgetBean.properties['alignment'] ?? 'topLeft';
    switch (alignment) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        return Alignment.topLeft;
    }
  }

  StackFit _getFit() {
    final fit = widgetBean.properties['fit'] ?? 'loose';
    switch (fit) {
      case 'loose':
        return StackFit.loose;
      case 'expand':
        return StackFit.expand;
      case 'passthrough':
        return StackFit.passthrough;
      default:
        return StackFit.loose;
    }
  }

  Clip _getClipBehavior() {
    final clip = widgetBean.properties['clipBehavior'] ?? 'hardEdge';
    switch (clip) {
      case 'none':
        return Clip.none;
      case 'hardEdge':
        return Clip.hardEdge;
      case 'antiAlias':
        return Clip.antiAlias;
      case 'antiAliasWithSaveLayer':
        return Clip.antiAliasWithSaveLayer;
      default:
        return Clip.hardEdge;
    }
  }

  List<Widget> _buildDefaultChildren() {
    // Default children for empty Stack
    return [
      Positioned(
        left: 10 * scale,
        top: 10 * scale,
        child: Container(
          width: 60 * scale,
          height: 30 * scale,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4 * scale),
            border: Border.all(color: Colors.red.withOpacity(0.6)),
          ),
          child: Center(
            child: Text(
              'Back',
              style: TextStyle(
                fontSize: 8 * scale,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        right: 10 * scale,
        bottom: 10 * scale,
        child: Container(
          width: 60 * scale,
          height: 30 * scale,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4 * scale),
            border: Border.all(color: Colors.blue.withOpacity(0.6)),
          ),
          child: Center(
            child: Text(
              'Front',
              style: TextStyle(
                fontSize: 8 * scale,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  /// Create a FlutterWidgetBean for Stack
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateId(),
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
        height: 150,
      ),
      events: {},
      layout: LayoutBean(
        width: -1, // MATCH_PARENT
        height: -1, // MATCH_PARENT
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
