import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';
import '../../services/child_widget_service.dart';
import '../../services/layout_property_service.dart';

/// FrameStack - Mobile frame version of Stack widget (matches Sketchware Pro's ItemRelativeLayout)
/// Enhanced touch handling, selection visual feedback, and drag capabilities
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

  /// SKETCHWARE PRO STYLE: Setup touch controller callbacks
  void _setupTouchController() {
    widget.touchController?.setCallbacks(
      onWidgetSelected: widget.onWidgetSelected,
      onWidgetDragStart: widget.onWidgetDragStart,
      onWidgetDragUpdate: widget.onWidgetDragUpdate,
      onWidgetDragEnd: widget.onWidgetDragEnd,
      onWidgetLongPress: (widget) {
        print('🎯 FRAME STACK LONG PRESS: ${widget.id}');
        // Handle long press feedback
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

    // SKETCHWARE PRO STYLE: Get exact position and size like ItemCardView
    final position = widget.widgetBean.position;
    final layout = widget.widgetBean.layout;

    // SKETCHWARE PRO STYLE: Convert dp to pixels like wB.a(context, value)
    final density = MediaQuery.of(context).devicePixelRatio;

    // SKETCHWARE PRO STYLE: Handle width/height like ViewPane.updateLayout()
    double width = position.width * widget.scale;
    double height = position.height * widget.scale;

    // SKETCHWARE PRO STYLE: If width/height are positive, convert dp to pixels
    if (layout.width > 0) {
      width = layout.width * density * widget.scale;
    }
    if (layout.height > 0) {
      height = layout.height * density * widget.scale;
    }

    return GestureDetector(
      // FLUTTER FIX: Ensure tap events are captured
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // SKETCHWARE PRO STYLE: Handle widget selection on tap
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
          // SKETCHWARE PRO STYLE: Use exact width/height like ItemCardView
          width: width > 0 ? width : null,
          height: height > 0 ? height : null,
          // SKETCHWARE PRO STYLE: Minimum size like ItemCardView (32dp)
          constraints: BoxConstraints(
            minWidth: 32 * density * widget.scale,
            minHeight: 32 * density * widget.scale,
          ),
          child: _buildStackContent(),
        ),
      ),
    );
  }

  /// SKETCHWARE PRO STYLE: Build stack content with properties
  Widget _buildStackContent() {
    final backgroundColor = _getBackgroundColor();
    final alignment = _getAlignment();
    final fit = _getFit();
    final childWidgets = _buildChildWidgets();

    // SKETCHWARE PRO STYLE: Convert dp to pixels like Android
    final density = MediaQuery.of(context).devicePixelRatio;

    return Container(
      // SKETCHWARE PRO STYLE: Minimum size like ItemCardView
      constraints: BoxConstraints(
        minWidth: 32 * density * widget.scale,
        minHeight: 32 * density * widget.scale,
      ),
      // SKETCHWARE PRO STYLE: Background color handling like ItemCardView
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

  /// SKETCHWARE PRO STYLE: Build child widgets using enhanced service
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

  /// SKETCHWARE PRO STYLE: Build sample items for preview
  List<Widget> _buildSampleItems() {
    return [
      _buildSampleItem('Item 1', Alignment.topLeft),
      _buildSampleItem('Item 2', Alignment.center),
      _buildSampleItem('Item 3', Alignment.bottomRight),
    ];
  }

  /// SKETCHWARE PRO STYLE: Build sample item
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

  /// SKETCHWARE PRO STYLE: Get alignment using LayoutPropertyService
  Alignment _getAlignment() {
    final alignment = widget.widgetBean.properties['alignment'];
    return _layoutPropertyService.parseAlignment(alignment);
  }

  /// SKETCHWARE PRO STYLE: Get fit using LayoutPropertyService
  StackFit _getFit() {
    final fit = widget.widgetBean.properties['fit'];
    return _layoutPropertyService.parseStackFit(fit);
  }

  /// SKETCHWARE PRO STYLE: Get clip behavior using LayoutPropertyService
  Clip _getClipBehavior() {
    final clipBehavior = widget.widgetBean.properties['clipBehavior'];
    return _layoutPropertyService.parseClipBehavior(clipBehavior);
  }

  /// SKETCHWARE PRO STYLE: Get background color (matches ItemCardView)
  Color _getBackgroundColor() {
    final color = widget.widgetBean.properties['backgroundColor'];
    if (color != null) {
      if (color is int) {
        // SKETCHWARE PRO STYLE: Handle 0xffffff as white
        if (color == 0xffffff) {
          return Colors.white;
        }
        return Color(color);
      } else if (color is String && color.startsWith('#')) {
        try {
          final colorInt =
              int.parse(color.substring(1), radix: 16) + 0xFF000000;
          // SKETCHWARE PRO STYLE: Handle #FFFFFF as white
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

  /// SKETCHWARE PRO STYLE: Handle touch start
  void _handleTouchStart(Offset position) {
    print('🎯 FRAME STACK TOUCH START: ${widget.widgetBean.id}');
    widget.touchController
        ?.handleTouchStart(widget.widgetBean, position, _widgetKey);
  }

  /// SKETCHWARE PRO STYLE: Handle touch move
  void _handleTouchMove(Offset position) {
    widget.touchController?.handleTouchMove(position);
  }

  /// SKETCHWARE PRO STYLE: Handle touch end
  void _handleTouchEnd(Offset position) {
    print('🎯 FRAME STACK TOUCH END: ${widget.widgetBean.id}');
    widget.touchController?.handleTouchEnd(position);
  }

  /// SKETCHWARE PRO STYLE: Handle touch cancel
  void _handleTouchCancel() {
    print('🎯 FRAME STACK TOUCH CANCEL: ${widget.widgetBean.id}');
    widget.touchController?.handleTouchCancel();
  }

  /// SKETCHWARE PRO STYLE: Notify parent about widget selection
  void _notifyWidgetSelected() {
    print('🚀 NOTIFYING WIDGET SELECTION: ${widget.widgetBean.id}');
    if (widget.touchController != null) {
      widget.touchController!.handleWidgetTap(widget.widgetBean);
    } else {
      print('🚀 WARNING: touchController is null!');
    }
  }
}

/// SKETCHWARE PRO STYLE: Custom painter for selection visual feedback (matches ItemRelativeLayout.onDraw)
class _SelectionPainter extends CustomPainter {
  final bool isSelected;

  _SelectionPainter(this.isSelected);

  @override
  void paint(Canvas canvas, Size size) {
    if (isSelected) {
      // SKETCHWARE PRO STYLE: Use exact same color as ItemRelativeLayout (0x9599d5d0)
      final paint = Paint()
        ..color = const Color(0x9599d5d0)
        ..style = PaintingStyle.fill;

      // Draw selection rectangle (matches ItemRelativeLayout.onDraw)
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _SelectionPainter &&
        oldDelegate.isSelected != isSelected;
  }
}
