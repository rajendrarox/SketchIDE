import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';
import '../../services/child_widget_service.dart';
import '../../services/layout_property_service.dart';

/// FrameContainer - Mobile frame version of Container widget (matches Sketchware Pro's ItemLinearLayout/ItemRelativeLayout)
/// Enhanced touch handling, selection visual feedback, and drag capabilities
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

  /// SKETCHWARE PRO STYLE: Setup touch controller callbacks
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

    // SKETCHWARE PRO STYLE: Get exact position and size like ItemCardView
    final position = widget.widgetBean.position;
    final layout = widget.widgetBean.layout;

    // SKETCHWARE PRO STYLE: Convert dp to pixels like wB.a(context, value)
    final density = MediaQuery.of(context).devicePixelRatio;

    // SKETCHWARE PRO STYLE: Handle width/height like ViewPane.updateLayout()
    double? width = position.width * widget.scale;
    double? height = position.height * widget.scale;

    // SKETCHWARE PRO STYLE: Handle MATCH_PARENT and positive values
    if (layout.width == -1) {
      // MATCH_PARENT - Mobile frame handles width via Positioned(right: 0)
      width = null; // ✅ Let parent constraints determine width
    } else if (layout.width > 0) {
      width = layout.width * density * widget.scale;
    }

    if (layout.height == -1) {
      // MATCH_PARENT - Let Container handle full height
      height = null; // ✅ Let parent constraints determine height
    } else if (layout.height > 0) {
      height = layout.height * density * widget.scale;
    }

    return GestureDetector(
      // FLUTTER FIX: Ensure tap events are captured
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // SKETCHWARE PRO STYLE: Handle widget selection on tap
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
          // SKETCHWARE PRO STYLE: Use exact width/height like ItemCardView
          width: width != null && width! > 0
              ? width
              : null, // ✅ Handle nullable width
          height: height != null && height! > 0
              ? height
              : null, // ✅ Handle nullable height
          // SKETCHWARE PRO STYLE: Minimum size like ItemCardView (32dp)
          constraints: BoxConstraints(
            minWidth: width == null
                ? 0
                : 32 *
                    density *
                    widget.scale, // ✅ No minWidth when using parent constraints
            minHeight:
                32 * density * widget.scale, // ✅ EXACT: 32dp like ItemCardView
          ),
          child: _buildContainerContent(),
        ),
      ),
    );
  }

  /// SKETCHWARE PRO STYLE: Build container content with properties
  Widget _buildContainerContent() {
    final backgroundColor = _getBackgroundColor();
    final borderColor = _getBorderColor();
    final borderWidth = _getBorderWidth();
    final borderRadius = _getBorderRadius();
    final childWidgets = _buildChildWidgets();

    // SKETCHWARE PRO STYLE: Convert dp to pixels like Android
    final density = MediaQuery.of(context).devicePixelRatio;
    final scaledBorderWidth = borderWidth *
        widget.scale; // Match Row widget - no density multiplication
    final scaledBorderRadius = borderRadius * density * widget.scale;
    final scaledFontSize = 12 * density * widget.scale;

    // SKETCHWARE PRO STYLE: Apply padding from layout bean like ItemRelativeLayout
    final padding = EdgeInsets.fromLTRB(
      widget.widgetBean.layout.paddingLeft * density * widget.scale,
      widget.widgetBean.layout.paddingTop * density * widget.scale,
      widget.widgetBean.layout.paddingRight * density * widget.scale,
      widget.widgetBean.layout.paddingBottom * density * widget.scale,
    );

    return Container(
      // FLUTTER CONTAINER STYLE: Basic container like Flutter Container
      width: double.infinity, // ✅ FORCE FULL WIDTH
      // FLUTTER CONTAINER STYLE: No height constraint - let content determine height
      padding: padding, // ✅ Apply padding
      decoration: BoxDecoration(
        color: backgroundColor,
        // FLUTTER CONTAINER STYLE: Basic border like Flutter Container
        border: Border.all(
          color: borderColor,
          width: scaledBorderWidth,
        ),
        borderRadius: BorderRadius.circular(scaledBorderRadius),
        // FLUTTER CONTAINER STYLE: Selection highlight only
        boxShadow: widget.selectionService?.selectedWidget?.id ==
                widget.widgetBean.id
            ? [
                BoxShadow(
                  color:
                      const Color(0x9599d5d0), // Sketchware Pro selection color
                  blurRadius: 0,
                  spreadRadius: 2.0 * widget.scale,
                ),
              ]
            : null,
      ),
      child: childWidgets.isNotEmpty
          ? Stack(children: childWidgets)
          : Container(), // Clean empty container - no placeholder text or icon
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

  /// SKETCHWARE PRO STYLE: Build placeholder content when no children
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

  /// EXACT SKETCHWARE PRO: Build empty container placeholder like ItemCardView
  Widget _buildEmptyContainerPlaceholder() {
    return Container(
      width: double.infinity, // ✅ ENSURE PLACEHOLDER ALSO TAKES FULL WIDTH
      padding: EdgeInsets.all(8 * widget.scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // EXACT SKETCHWARE PRO: Container icon like Sketchware Pro
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

  /// SKETCHWARE PRO STYLE: Get background color (matches Row widget)
  Color _getBackgroundColor() {
    final color = widget.widgetBean.properties['backgroundColor'];
    if (color != null) {
      if (color is int) {
        // SKETCHWARE PRO STYLE: Handle 0xffffff as transparent (matches Row widget)
        if (color == 0xffffff) {
          return Colors.transparent;
        }
        return Color(color);
      } else if (color is String && color.startsWith('#')) {
        try {
          final colorInt =
              int.parse(color.substring(1), radix: 16) + 0xFF000000;
          // SKETCHWARE PRO STYLE: Handle #FFFFFF as transparent (matches Row widget)
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

  /// SKETCHWARE PRO STYLE: Get border color (matches Row widget)
  Color _getBorderColor() {
    final color = widget.widgetBean.properties['borderColor'];
    if (color != null) {
      if (color is int) {
        return Color(color);
      } else if (color is String && color.startsWith('#')) {
        try {
          // Handle semi-transparent colors like #60000000 (matches Row widget)
          if (color.length == 9) {
            // 8-digit hex with alpha (e.g., #60000000)
            return Color(int.parse(color.substring(1), radix: 16));
          } else {
            // 6-digit hex without alpha (e.g., #CCCCCC)
            return Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
          }
        } catch (e) {
          return const Color(0x60000000); // Default to Row widget border color
        }
      }
    }
    return const Color(0x60000000); // Default to Row widget border color
  }

  /// SKETCHWARE PRO STYLE: Get border width
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

  /// FLUTTER CONTAINER STYLE: Get border radius
  double _getBorderRadius() {
    final borderRadius = widget.widgetBean.properties['borderRadius'];
    if (borderRadius != null) {
      if (borderRadius is int) {
        return borderRadius.toDouble();
      } else if (borderRadius is double) {
        return borderRadius;
      }
    }
    return 0.0; // Flutter Container default - no border radius
  }

  /// SKETCHWARE PRO STYLE: Get padding
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

  /// SKETCHWARE PRO STYLE: Get alignment using LayoutPropertyService
  Alignment _getAlignment() {
    final alignment = widget.widgetBean.properties['alignment'];
    return _layoutPropertyService.parseAlignment(alignment);
  }

  /// SKETCHWARE PRO STYLE: Handle touch start
  void _handleTouchStart(Offset position) {
    print('🎯 FRAME CONTAINER TOUCH START: ${widget.widgetBean.id}');
    widget.touchController
        ?.handleTouchStart(widget.widgetBean, position, _widgetKey);
  }

  /// SKETCHWARE PRO STYLE: Handle touch move
  void _handleTouchMove(Offset position) {
    widget.touchController?.handleTouchMove(position);
  }

  /// SKETCHWARE PRO STYLE: Handle touch end
  void _handleTouchEnd(Offset position) {
    print('🎯 FRAME CONTAINER TOUCH END: ${widget.widgetBean.id}');
    widget.touchController?.handleTouchEnd(position);
  }

  /// SKETCHWARE PRO STYLE: Handle touch cancel
  void _handleTouchCancel() {
    print('🎯 FRAME CONTAINER TOUCH CANCEL: ${widget.widgetBean.id}');
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

/// SKETCHWARE PRO STYLE: Custom painter for selection visual feedback (matches ItemLinearLayout.onDraw)
class _SelectionPainter extends CustomPainter {
  final bool isSelected;

  _SelectionPainter(this.isSelected);

  @override
  void paint(Canvas canvas, Size size) {
    if (isSelected) {
      // SKETCHWARE PRO STYLE: Use exact same color as ItemLinearLayout (0x9599d5d0)
      final paint = Paint()
        ..color = const Color(0x9599d5d0)
        ..style = PaintingStyle.fill;

      // Draw selection rectangle (matches ItemLinearLayout.onDraw)
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _SelectionPainter &&
        oldDelegate.isSelected != isSelected;
  }
}
