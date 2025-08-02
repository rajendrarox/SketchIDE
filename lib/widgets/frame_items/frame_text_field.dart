import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';
import '../../services/color_utils.dart';
import '../../services/widget_sizing_service.dart'; // Added import for WidgetSizingService
import 'base_frame_item.dart';

class FrameTextField extends BaseFrameItem {
  const FrameTextField({
    super.key,
    required super.widgetBean,
    super.touchController,
    super.selectionService,
    super.scale,
  });

  @override
  Widget buildContent(BuildContext context) {
    return _FrameTextFieldContent(
      widgetBean: widgetBean,
      touchController: touchController,
      selectionService: selectionService,
      scale: scale,
    );
  }
}

class _FrameTextFieldContent extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final MobileFrameTouchController? touchController;
  final SelectionService? selectionService;
  final double scale;

  const _FrameTextFieldContent({
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
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('🎯 FRAME TEXT FIELD TAP: ${widgetBean.id}');
        if (selectionService != null) {
          selectionService!.selectWidget(widgetBean);
          print('🎯 SELECTION SERVICE: Widget ${widgetBean.id} selected');
        }
        _notifyWidgetSelected();
      },
      onTapDown: (details) {
        print('🎯 FRAME TEXT FIELD TAP DOWN: ${widgetBean.id}');
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
          minWidth: 32 * scale, // SKETCHWARE PRO STYLE: Simple scaling
          minHeight: 32 * scale, // SKETCHWARE PRO STYLE: Simple scaling
        ),
        child: _buildTextFieldContent(context),
      ),
    );
  }

  Widget _buildTextFieldContent(BuildContext context) {
    final isSelected = selectionService?.selectedWidget?.id == widgetBean.id;
    final backgroundColor = _getBackgroundColor();
    final cornerRadius = _getCornerRadius();

    return Container(
      // SKETCHWARE PRO STYLE: Use background fill for selection like ItemEditText
      color: isSelected ? const Color(0x9599d5d0) : Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(cornerRadius * scale),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 1 * scale,
          ),
        ),
        child: TextField(
          enabled: false, // Disabled like Sketchware Pro
          controller: TextEditingController(text: _getText()),
          style: _getTextStyle(context),
          decoration: InputDecoration(
            hintText: _getHint(),
            hintStyle: _getHintStyle(context),
            contentPadding: _getContentPadding(context),
            border: InputBorder.none,
            // SKETCHWARE PRO STYLE: Remove default padding
            isDense: true,
          ),
        ),
      ),
    );
  }

  String _getHint() {
    final hint = widgetBean.properties['hint']?.toString() ?? '';

    // SKETCHWARE PRO STYLE: Default hint text like EditText
    if (hint.isEmpty) {
      return 'Enter text';
    }

    return hint;
  }

  String _getText() {
    final text = widgetBean.properties['text']?.toString() ?? '';

    // SKETCHWARE PRO STYLE: Default text like EditText
    if (text.isEmpty) {
      return 'Edit Text';
    }

    return text;
  }

  TextStyle _getTextStyle(BuildContext context) {
    final fontSize = _parseDouble(widgetBean.properties['textSize']) ?? 14.0;
    final textColor = ColorUtils.parseColor(
            widgetBean.properties['textColor'] ?? '#000000') ??
        Colors.black;

    // SKETCHWARE PRO STYLE: Use raw font size without density scaling
    final scaledFontSize = fontSize * scale; // Remove density scaling!

    return TextStyle(
      fontSize: scaledFontSize,
      color: textColor,
    );
  }

  TextStyle _getHintStyle(BuildContext context) {
    final hintColor = ColorUtils.parseColor(
            widgetBean.properties['hintColor'] ?? '#757575') ??
        Colors.grey;

    // SKETCHWARE PRO STYLE: Use raw font size without density scaling
    final fontSize = _parseDouble(widgetBean.properties['textSize']) ?? 14.0;
    final scaledFontSize = fontSize * scale; // Remove density scaling!

    return TextStyle(
      fontSize: scaledFontSize,
      color: hintColor,
    );
  }

  Color _getBackgroundColor() {
    final backgroundColor =
        widgetBean.properties['backgroundColor']?.toString() ?? '#FFFFFF';

    // SKETCHWARE PRO STYLE: Handle white background like ItemEditText
    if (backgroundColor == '#FFFFFF' || backgroundColor == '#ffffff') {
      return Colors.transparent; 
    }

    return ColorUtils.parseColor(backgroundColor) ?? Colors.transparent;
  }

  double _getCornerRadius() {
    final radius = widgetBean.properties['cornerRadius'];
    if (radius is num) {
      return radius.toDouble();
    }
    return 4.0; // SKETCHWARE PRO STYLE: Default corner radius
  }

  EdgeInsets _getContentPadding(BuildContext context) {
    // SKETCHWARE PRO STYLE: Use raw padding without density scaling
    final padding = 8.0 * scale; // Remove density scaling!

    return EdgeInsets.all(padding);
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
