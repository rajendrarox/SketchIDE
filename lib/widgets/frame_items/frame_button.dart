import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';
import '../../services/color_utils.dart';
import '../../services/widget_sizing_service.dart'; // Added import for WidgetSizingService
import 'base_frame_item.dart';


class FrameButton extends BaseFrameItem {
  const FrameButton({
    super.key,
    required super.widgetBean,
    super.touchController,
    super.selectionService,
    super.scale,
  });

  @override
  Widget buildContent(BuildContext context) {
    return _FrameButtonContent(
      widgetBean: widgetBean,
      touchController: touchController,
      selectionService: selectionService,
      scale: scale,
    );
  }
}


class _FrameButtonContent extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final MobileFrameTouchController? touchController;
  final SelectionService? selectionService;
  final double scale;

  const _FrameButtonContent({
    required this.widgetBean,
    this.touchController,
    this.selectionService,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final widgetKey = GlobalKey();

    final position = widgetBean.position;
    final layout = widgetBean.layout;

    // SKETCHWARE PRO STYLE: Use wB.a() pattern - convert DP to pixels once
    double width = position.width * scale;
    double height = position.height * scale;

    if (layout.width > 0) {
      // SKETCHWARE PRO STYLE: wB.a(getContext(), (float) layout.width)
      width = WidgetSizingService.convertDpToPixels(context, layout.width.toDouble()) * scale;
    }
    if (layout.height > 0) {
      // SKETCHWARE PRO STYLE: wB.a(getContext(), (float) layout.height)
      height = WidgetSizingService.convertDpToPixels(context, layout.height.toDouble()) * scale;
    }

    return GestureDetector(
      // FLUTTER FIX: Ensure tap events are captured
      behavior: HitTestBehavior.opaque,
      onTap: () {
        
        print('🎯 FRAME BUTTON TAP: ${widgetBean.id}');
        print(
            '🎯 SELECTION SERVICE: ${selectionService != null ? "AVAILABLE" : "NULL"}');
        print(
            '🎯 TOUCH CONTROLLER: ${touchController != null ? "AVAILABLE" : "NULL"}');

        if (selectionService != null) {
          selectionService!.selectWidget(widgetBean);
          print('🎯 SELECTION SERVICE: Widget ${widgetBean.id} selected');
        }
        
        _notifyWidgetSelected();
      },
      onTapDown: (details) {
        print('🎯 FRAME BUTTON TAP DOWN: ${widgetBean.id}');
      },
      onLongPressStart: (details) {
        // Handle long press start
      },
      onLongPressMoveUpdate: (details) {
        // Handle long press move update
      },
      onLongPressEnd: (details) {
        // Handle long press end
      },
      onPanStart: (details) {
        // Handle pan start
      },
      onPanUpdate: (details) {
        // Handle pan update
      },
      onPanEnd: (details) {
        // Handle pan end
      },
      child: Container(
        key: widgetKey,
        width: width > 0 ? width : null,
        height: height > 0 ? height : null,
        constraints: BoxConstraints(
          minWidth: 32 * WidgetSizingService.convertDpToPixels(context, 1.0) * scale, // Use WidgetSizingService for density scaling
          minHeight: 32 * WidgetSizingService.convertDpToPixels(context, 1.0) * scale, // Use WidgetSizingService for density scaling
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

 
  Widget _buildButtonContent(BuildContext context) {
    final isSelected = selectionService?.selectedWidget?.id == widgetBean.id;

    return Container(
      decoration: BoxDecoration(
        // SKETCHWARE PRO STYLE: Use background fill for selection like ItemButton
        color: isSelected ? const Color(0x9599d5d0) : Colors.transparent,
      ),
      child: MaterialButton(
        onPressed: null, // Disabled button like Sketchware Pro
        // SKETCHWARE PRO STYLE: Use device default background, not custom color
        color: null, // Use device default background
        textColor: Colors.black, // SKETCHWARE PRO STYLE: Black text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getCornerRadius() * scale),
        ),
        // SKETCHWARE PRO STYLE: Remove minimum size constraints
        child: Text(
          _getText(),
          style: _getTextStyle(context),
          textAlign: TextAlign.center, // SKETCHWARE PRO STYLE: Center text
        ),
      ),
    );
  }

  String _getText() {
    final text = widgetBean.properties['text']?.toString() ?? '';
    
    // SKETCHWARE PRO STYLE: Default button text
    if (text.isEmpty) {
      return 'Button';
    }
    
    return text;
  }

  TextStyle _getTextStyle(BuildContext context) {
    final fontSize = _parseDouble(widgetBean.properties['textSize']) ?? 14.0;
    
    // SKETCHWARE PRO STYLE: Use raw font size without density scaling
    final scaledFontSize = fontSize * scale; // Remove density scaling!
    
    return TextStyle(
      fontSize: scaledFontSize,
      color: Colors.black, // SKETCHWARE PRO STYLE: Always black text
      fontWeight: _getFontWeight(widgetBean.properties['textStyle'] ?? 'normal'),
    );
  }

  FontWeight _getFontWeight(String textStyle) {
    switch (textStyle) {
      case 'bold':
        return FontWeight.bold;
      case 'italic':
        return FontWeight.normal;
      case 'bold|italic':
        return FontWeight.bold;
      default:
        return FontWeight.normal;
    }
  }

  double _getCornerRadius() {
    final radius = widgetBean.properties['cornerRadius'];
    if (radius is num) {
      return radius.toDouble();
    }
    return 4.0; // SKETCHWARE PRO STYLE: Default corner radius
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  void _notifyWidgetSelected() {
    print('🚀 NOTIFYING WIDGET SELECTION: ${widgetBean.id}');
    if (touchController != null) {
      touchController!.handleWidgetTap(widgetBean);
    } else {
      print('🚀 WARNING: touchController is null!');
    }
  }
}
