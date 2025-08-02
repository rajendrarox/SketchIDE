import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';
import '../../services/child_widget_service.dart';
import '../../services/layout_property_service.dart';

class FrameStack extends StatefulWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;
  final MobileFrameTouchController? touchController;
  final SelectionService? selectionService;
  final Function(FlutterWidgetBean)? onWidgetSelected;
  final Function(FlutterWidgetBean, Offset)? onWidgetDragStart;
  final Function(FlutterWidgetBean, Offset)? onWidgetDragUpdate;
  final Function(FlutterWidgetBean, Offset)? onWidgetDragEnd;
  final List<FlutterWidgetBean> allWidgets;

  const FrameStack({
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
  State<FrameStack> createState() => _FrameStackState();
}

class _FrameStackState extends State<FrameStack> {
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
        print('🎯 FRAME STACK LONG PRESS: ${widget.id}');
      },
      onDragStateChanged: (isDragging) {
        print(
            '🎯 FRAME STACK DRAG STATE: ${widget.widgetBean.id} - $isDragging');
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

    double width = position.width * widget.scale;
    double height = position.height * widget.scale;

    if (layout.width > 0) {
      width = layout.width * density * widget.scale;
    }
    if (layout.height > 0) {
      height = layout.height * density * widget.scale;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('🎯 FRAME STACK TAP: ${widget.widgetBean.id}');
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
          width: width > 0 ? width : null,
          height: height > 0 ? height : null,
          constraints: BoxConstraints(
            minWidth: 32 * density * widget.scale,
            minHeight: 32 * density * widget.scale,
          ),
          child: _buildStackContent(),
        ),
      ),
    );
  }

  Widget _buildStackContent() {
    final backgroundColor = _getBackgroundColor();
    final alignment = _getAlignment();
    final fit = _getFit();
    final childWidgets = _buildChildWidgets();

    final density = MediaQuery.of(context).devicePixelRatio;

    return Container(
      constraints: BoxConstraints(
        minWidth: 32 * density * widget.scale,
        minHeight: 32 * density * widget.scale,
      ),
      color: backgroundColor,
      child: childWidgets.isNotEmpty
          ? Stack(
              alignment: alignment,
              fit: fit,
              children: childWidgets,
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 8 * density * widget.scale,
                  top: 8 * density * widget.scale,
                  child: Container(
                    width: 16 * density * widget.scale,
                    height: 16 * density * widget.scale,
                    color: Colors.grey[300],
                  ),
                ),
                Positioned(
                  right: 8 * density * widget.scale,
                  bottom: 8 * density * widget.scale,
                  child: Container(
                    width: 16 * density * widget.scale,
                    height: 16 * density * widget.scale,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
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

  List<Widget> _buildSampleItems() {
    return [
      _buildSampleItem('Item 1', Alignment.topLeft),
      _buildSampleItem('Item 2', Alignment.center),
      _buildSampleItem('Item 3', Alignment.bottomRight),
    ];
  }

 
  Widget _buildSampleItem(String text, Alignment alignment) {
    return Positioned(
      left: alignment.x * 20 * widget.scale,
      top: alignment.y * 20 * widget.scale,
      child: Container(
        padding: EdgeInsets.all(8 * widget.scale),
        decoration: BoxDecoration(
          color: Colors.purple[100],
          borderRadius: BorderRadius.circular(4 * widget.scale),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10 * widget.scale,
            color: Colors.purple[800],
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment() {
    final alignment = widget.widgetBean.properties['alignment'];
    return _layoutPropertyService.parseAlignment(alignment);
  }

  
  StackFit _getFit() {
    final fit = widget.widgetBean.properties['fit'];
    return _layoutPropertyService.parseStackFit(fit);
  }

  
  Clip _getClipBehavior() {
    final clipBehavior = widget.widgetBean.properties['clipBehavior'];
    return _layoutPropertyService.parseClipBehavior(clipBehavior);
  }

  
  Color _getBackgroundColor() {
    final color = widget.widgetBean.properties['backgroundColor'];
    if (color != null) {
      if (color is int) {
        if (color == 0xffffff) {
          return Colors.white;
        }
        return Color(color);
      } else if (color is String && color.startsWith('#')) {
        try {
          final colorInt =
              int.parse(color.substring(1), radix: 16) + 0xFF000000;
          
          if (colorInt == 0xFFFFFFFF) {
            return Colors.white;
          }
          return Color(colorInt);
        } catch (e) {
          return Colors.white;
        }
      }
    }
    return Colors.white;
  }

  
  void _handleTouchStart(Offset position) {
    print('🎯 FRAME STACK TOUCH START: ${widget.widgetBean.id}');
    widget.touchController
        ?.handleTouchStart(widget.widgetBean, position, _widgetKey);
  }

  
  void _handleTouchMove(Offset position) {
    widget.touchController?.handleTouchMove(position);
  }

  
  void _handleTouchEnd(Offset position) {
    print('🎯 FRAME STACK TOUCH END: ${widget.widgetBean.id}');
    widget.touchController?.handleTouchEnd(position);
  }

  
  void _handleTouchCancel() {
    print('🎯 FRAME STACK TOUCH CANCEL: ${widget.widgetBean.id}');
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
