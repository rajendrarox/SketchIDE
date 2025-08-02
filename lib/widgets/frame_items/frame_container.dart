import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';
import '../../services/child_widget_service.dart';
import '../../services/layout_property_service.dart';

class FrameContainer extends StatefulWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;
  final MobileFrameTouchController? touchController;
  final SelectionService? selectionService;
  final Function(FlutterWidgetBean)? onWidgetSelected;
  final Function(FlutterWidgetBean, Offset)? onWidgetDragStart;
  final Function(FlutterWidgetBean, Offset)? onWidgetDragUpdate;
  final Function(FlutterWidgetBean, Offset)? onWidgetDragEnd;
  final List<FlutterWidgetBean> allWidgets;

  const FrameContainer({
    super.key,
    required this.widgetBean,
    this.scale = 1.0,
    this.touchController,
    this.selectionService,
    this.onWidgetSelected,
    this.onWidgetDragStart,
    this.onWidgetDragUpdate,
    this.onWidgetDragEnd,
    required this.allWidgets,
  });

  @override
  State<FrameContainer> createState() => _FrameContainerState();
}

class _FrameContainerState extends State<FrameContainer> {
  final GlobalKey _widgetKey = GlobalKey();
  bool _isPressed = false;
  late LayoutPropertyService _layoutPropertyService;

  @override
  void initState() {
    super.initState();
    _layoutPropertyService = LayoutPropertyService();
    _setupTouchController();
  }

  void _setupTouchController() {
    widget.touchController?.setCallbacks(
      onWidgetSelected: widget.onWidgetSelected,
      onWidgetDragStart: widget.onWidgetDragStart,
      onWidgetDragUpdate: widget.onWidgetDragUpdate,
      onWidgetDragEnd: widget.onWidgetDragEnd,
      onWidgetLongPress: (widget) {
        print('🎯 FRAME CONTAINER LONG PRESS: ${widget.id}');
        // Handle long press feedback
      },
      onDragStateChanged: (isDragging) {
        print(
            '🎯 FRAME CONTAINER DRAG STATE: ${widget.widgetBean.id} - $isDragging');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelected =
        widget.selectionService?.isWidgetSelected(widget.widgetBean) ?? false;

    final position = widget.widgetBean.position;
    final layout = widget.widgetBean.layout;

    final density = MediaQuery.of(context).devicePixelRatio;

    double? width = position.width * widget.scale;
    double? height = position.height * widget.scale;

    if (layout.width == -1) {
      width = null; 
    } else if (layout.width > 0) {
      width = layout.width * density * widget.scale;
    }

    if (layout.height == -1) {
      height = null; 
    } else if (layout.height > 0) {
      height = layout.height * density * widget.scale;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('🎯 FRAME CONTAINER TAP: ${widget.widgetBean.id}');
        if (widget.selectionService != null) {
          widget.selectionService!.selectWidget(widget.widgetBean);
          print(
              '🎯 SELECTION SERVICE: Widget ${widget.widgetBean.id} selected');
        }
        _notifyWidgetSelected();
      },
      onTapDown: (details) {
        setState(() => _isPressed = true);
        _handleTouchStart(details.globalPosition);
      },
      onTapUp: (details) {
        setState(() => _isPressed = false);
        _handleTouchEnd(details.globalPosition);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _handleTouchCancel();
      },
      onPanStart: (details) {
        _handleTouchStart(details.globalPosition);
      },
      onPanUpdate: (details) {
        _handleTouchMove(details.globalPosition);
      },
      onPanEnd: (details) {
        _handleTouchEnd(details.globalPosition);
      },
      child: CustomPaint(
        painter: _SelectionPainter(isSelected),
        child: Container(
          key: _widgetKey,
          width: width != null && width! > 0
              ? width
              : null, 
          height: height != null && height! > 0
              ? height
              : null, 
          constraints: BoxConstraints(
            minWidth: width == null
                ? 0
                : 32 *
                    density *
                    widget.scale, 
            minHeight:
                32 * density * widget.scale, 
          ),
          child: _buildContainerContent(),
        ),
      ),
    );
  }

  Widget _buildContainerContent() {
    final backgroundColor = _getBackgroundColor();
    final borderColor = _getBorderColor();
    final borderWidth = _getBorderWidth();
    final borderRadius = _getBorderRadius();
    final childWidgets = _buildChildWidgets();

    final density = MediaQuery.of(context).devicePixelRatio;
    final scaledBorderWidth = borderWidth *
        widget.scale; 
    final scaledBorderRadius = borderRadius * density * widget.scale;
    final scaledFontSize = 12 * density * widget.scale;

    final padding = EdgeInsets.fromLTRB(
      widget.widgetBean.layout.paddingLeft * density * widget.scale,
      widget.widgetBean.layout.paddingTop * density * widget.scale,
      widget.widgetBean.layout.paddingRight * density * widget.scale,
      widget.widgetBean.layout.paddingBottom * density * widget.scale,
    );

    return Container(
      width: double.infinity, 
      padding: padding, 
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: scaledBorderWidth,
        ),
        borderRadius: BorderRadius.circular(scaledBorderRadius),
        boxShadow: widget.selectionService?.selectedWidget?.id ==
                widget.widgetBean.id
            ? [
                BoxShadow(
                  color:
                      const Color(0x9599d5d0), 
                  blurRadius: 0,
                  spreadRadius: 2.0 * widget.scale,
                ),
              ]
            : null,
      ),
      child: childWidgets.isNotEmpty
          ? Stack(children: childWidgets)
          : Container(), 
    );
  }

  List<Widget> _buildChildWidgets() {
    return ChildWidgetService().buildChildWidgets(
      widget.widgetBean,
      widget.allWidgets,
      widget.scale,
      widget.touchController,
      widget.selectionService,
      context,
    );
  }

  Widget _buildPlaceholderContent() {
    return Center(
      child: Text(
        'Container',
        style: TextStyle(
          fontSize: 12 * widget.scale,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildEmptyContainerPlaceholder() {
    return Container(
      width: double.infinity, 
      padding: EdgeInsets.all(8 * widget.scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 20 * widget.scale,
            height: 12 * widget.scale,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF666666),
                width: 1 * widget.scale,
              ),
              borderRadius: BorderRadius.circular(2 * widget.scale),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(1 * widget.scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.circular(1 * widget.scale),
                    ),
                  ),
                ),
                SizedBox(width: 1 * widget.scale),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(1 * widget.scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.circular(1 * widget.scale),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6 * widget.scale),
          Text(
            'Container',
            style: TextStyle(
              fontSize: 11 * widget.scale,
              color: const Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    final color = widget.widgetBean.properties['backgroundColor'];
    if (color != null) {
      if (color is int) {
        if (color == 0xffffff) {
          return Colors.transparent;
        }
        return Color(color);
      } else if (color is String && color.startsWith('#')) {
        try {
          final colorInt =
              int.parse(color.substring(1), radix: 16) + 0xFF000000;
          if (colorInt == 0xFFFFFFFF) {
            return Colors.transparent;
          }
          return Color(colorInt);
        } catch (e) {
          return Colors.transparent;
        }
      }
    }
    return Colors.transparent;
  }

  Color _getBorderColor() {
    final color = widget.widgetBean.properties['borderColor'];
    if (color != null) {
      if (color is int) {
        return Color(color);
      } else if (color is String && color.startsWith('#')) {
        try {
          if (color.length == 9) {
            return Color(int.parse(color.substring(1), radix: 16));
          } else {
            return Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
          }
        } catch (e) {
          return const Color(0x60000000); 
        }
      }
    }
    return const Color(0x60000000); 
  }

  double _getBorderWidth() {
    final borderWidth = widget.widgetBean.properties['borderWidth'];
    if (borderWidth != null) {
      if (borderWidth is int) {
        return borderWidth.toDouble();
      } else if (borderWidth is double) {
        return borderWidth;
      }
    }
    return 1.0;
  }

  double _getBorderRadius() {
    final borderRadius = widget.widgetBean.properties['borderRadius'];
    if (borderRadius != null) {
      if (borderRadius is int) {
        return borderRadius.toDouble();
      } else if (borderRadius is double) {
        return borderRadius;
      }
    }
    return 0.0; 
  }

  EdgeInsets _getPadding() {
    final paddingLeft = widget.widgetBean.layout.paddingLeft;
    final paddingTop = widget.widgetBean.layout.paddingTop;
    final paddingRight = widget.widgetBean.layout.paddingRight;
    final paddingBottom = widget.widgetBean.layout.paddingBottom;

    return EdgeInsets.fromLTRB(
      paddingLeft * widget.scale,
      paddingTop * widget.scale,
      paddingRight * widget.scale,
      paddingBottom * widget.scale,
    );
  }

  Alignment _getAlignment() {
    final alignment = widget.widgetBean.properties['alignment'];
    return _layoutPropertyService.parseAlignment(alignment);
  }

  void _handleTouchStart(Offset position) {
    print('🎯 FRAME CONTAINER TOUCH START: ${widget.widgetBean.id}');
    widget.touchController
        ?.handleTouchStart(widget.widgetBean, position, _widgetKey);
  }

  void _handleTouchMove(Offset position) {
    widget.touchController?.handleTouchMove(position);
  }

  void _handleTouchEnd(Offset position) {
    print('🎯 FRAME CONTAINER TOUCH END: ${widget.widgetBean.id}');
    widget.touchController?.handleTouchEnd(position);
  }

  void _handleTouchCancel() {
    print('🎯 FRAME CONTAINER TOUCH CANCEL: ${widget.widgetBean.id}');
    widget.touchController?.handleTouchCancel();
  }

  void _notifyWidgetSelected() {
    print('🚀 NOTIFYING WIDGET SELECTION: ${widget.widgetBean.id}');
    if (widget.touchController != null) {
      widget.touchController!.handleWidgetTap(widget.widgetBean);
    } else {
      print('🚀 WARNING: touchController is null!');
    }
  }
}

class _SelectionPainter extends CustomPainter {
  final bool isSelected;

  _SelectionPainter(this.isSelected);

  @override
  void paint(Canvas canvas, Size size) {
    if (isSelected) {
      final paint = Paint()
        ..color = const Color(0x9599d5d0)
        ..style = PaintingStyle.fill;

      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _SelectionPainter &&
        oldDelegate.isSelected != isSelected;
  }
}
