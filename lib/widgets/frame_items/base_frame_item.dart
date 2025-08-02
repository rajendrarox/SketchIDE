import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../models/sketchide_item_interface.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';

abstract class BaseFrameItem extends StatefulWidget
    implements SketchideItemInterface {
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
  }

  @override
  bool getFixed() => widgetBean.isFixed;

  @override
  void setFixed(bool fixed) {
  }

  @override
  bool getSelection() {
    return selectionService?.isWidgetSelected(widgetBean) ?? false;
  }

  @override
  void setSelection(bool selection) {
    if (selection) {
      selectionService?.selectWidget(widgetBean);
    } else {
      selectionService?.clearSelection();
    }
  }

  Color getSelectionColor() => const Color(0x9599d5d0);

  double getDensityFactor(BuildContext context) =>
      MediaQuery.of(context).devicePixelRatio;

  CustomPainter buildSelectionPainter() {
    return SelectionPainter(
      isSelected: getSelection(),
      selectionColor: getSelectionColor(),
    );
  }

  Widget buildContent(BuildContext context);
}
  
class _BaseFrameItemState extends State<BaseFrameItem> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: widget.buildSelectionPainter(),
      child: widget.buildContent(context),
    );
  }
}

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
      final paint = Paint()
        ..color = selectionColor
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );

      final borderPaint = Paint()
        ..color = selectionColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SelectionPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.selectionColor != selectionColor;
  }
}
