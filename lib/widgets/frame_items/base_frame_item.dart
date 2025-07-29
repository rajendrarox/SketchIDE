import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../models/sketchware_item_interface.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';

/// SKETCHWARE PRO STYLE: Base class for all frame items that matches Item* classes
/// This provides the common interface and functionality that all Sketchware Pro Item* classes have
abstract class BaseFrameItem extends StatefulWidget
    implements SketchwareItemInterface {
  final FlutterWidgetBean widgetBean;
  final MobileFrameTouchController? touchController;
  final SelectionService? selectionService;
  final double scale;

  const BaseFrameItem({
    super.key,
    required this.widgetBean,
    this.touchController,
    this.selectionService,
    this.scale = 1.0,
  });

  @override
  State<BaseFrameItem> createState() => _BaseFrameItemState();

  @override
  FlutterWidgetBean getBean() => widgetBean;

  @override
  void setBean(FlutterWidgetBean viewBean) {
    // In Flutter, we can't modify the widgetBean directly, but this matches the interface
    // The actual bean is managed by the parent widget
  }

  @override
  bool getFixed() => widgetBean.isFixed;

  @override
  void setFixed(bool fixed) {
    // In Flutter, we can't modify the widgetBean directly, but this matches the interface
    // The actual fixed status is managed by the parent widget
  }

  @override
  bool getSelection() {
    return selectionService?.isWidgetSelected(widgetBean) ?? false;
  }

  @override
  void setSelection(bool selection) {
    // In Flutter, selection is managed by the SelectionService
    // This matches the interface pattern from Sketchware Pro
    if (selection) {
      selectionService?.selectWidget(widgetBean);
    } else {
      selectionService?.clearSelection();
    }
  }

  /// SKETCHWARE PRO STYLE: Get the selection color (matches 0x9599d5d0)
  Color getSelectionColor() => const Color(0x9599d5d0);

  /// SKETCHWARE PRO STYLE: Get the density factor (matches wB.a(context, 1.0f))
  double getDensityFactor(BuildContext context) =>
      MediaQuery.of(context).devicePixelRatio;

  /// SKETCHWARE PRO STYLE: Build the selection painter (matches onDraw with canvas.drawRect)
  CustomPainter buildSelectionPainter() {
    return SelectionPainter(
      isSelected: getSelection(),
      selectionColor: getSelectionColor(),
    );
  }

  /// SKETCHWARE PRO STYLE: Build the main content (to be implemented by subclasses)
  Widget buildContent(BuildContext context);
}

/// SKETCHWARE PRO STYLE: Base state for frame items
class _BaseFrameItemState extends State<BaseFrameItem> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: widget.buildSelectionPainter(),
      child: widget.buildContent(context),
    );
  }
}

/// SKETCHWARE PRO STYLE: Selection painter that matches the onDraw pattern from Item* classes
class SelectionPainter extends CustomPainter {
  final bool isSelected;
  final Color selectionColor;

  SelectionPainter({
    required this.isSelected,
    required this.selectionColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isSelected) {
      // SKETCHWARE PRO STYLE: Draw selection rectangle like Item*.onDraw()
      final paint = Paint()
        ..color = selectionColor
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SelectionPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.selectionColor != selectionColor;
  }
}
