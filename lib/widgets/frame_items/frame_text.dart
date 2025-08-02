import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';
import '../../services/widget_sizing_service.dart';
import '../../services/text_property_service.dart';
import '../../services/color_utils.dart';
import 'base_frame_item.dart';

class FrameText extends BaseFrameItem {
  const FrameText({
    super.key,
    required super.widgetBean,
    super.touchController,
    super.selectionService,
    super.scale,
  });

  @override
  Widget buildContent(BuildContext context) {
    return _FrameTextContent(
      widgetBean: widgetBean,
      touchController: touchController,
      selectionService: selectionService,
      scale: scale,
    );
  }
}

class _FrameTextContent extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final MobileFrameTouchController? touchController;
  final SelectionService? selectionService;
  final double scale;

  const _FrameTextContent({
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
        print('🎯 FRAME TEXT TAP (GestureDetector): ${widgetBean.id}');
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
        
        print('🎯 FRAME TEXT TAP DOWN: ${widgetBean.id}');
      },
      onLongPressStart: (details) {
        
        print('🎯 FRAME TEXT LONG PRESS START: ${widgetBean.id}');
        if (touchController != null) {
          touchController!
              .handleTouchStart(widgetBean, details.globalPosition, widgetKey);
        }
      },
      onLongPressMoveUpdate: (details) {
        
        if (touchController != null) {
          touchController!.handleTouchMove(details.globalPosition);
        }
      },
      onLongPressEnd: (details) {
        
        if (touchController != null) {
          touchController!.handleTouchEnd(details.globalPosition);
        }
      },
      onPanStart: (details) {
        
        print('🎯 FRAME TEXT PAN START: ${widgetBean.id}');
        if (touchController != null) {
          touchController!
              .handleTouchStart(widgetBean, details.globalPosition, widgetKey);
        }
      },
      onPanUpdate: (details) {
        
        if (touchController != null) {
          touchController!.handleTouchMove(details.globalPosition);
        }
      },
      onPanEnd: (details) {
        
        if (touchController != null) {
          touchController!.handleTouchEnd(details.globalPosition);
        }
      },
      child: Container(
        key: widgetKey,
        
        width: width,
        height: height,
        
        constraints: BoxConstraints(
          minWidth:
              WidgetSizingService.convertDpToPixels(context, 32.0) * scale,
          minHeight:
              WidgetSizingService.convertDpToPixels(context, 32.0) * scale,
        ),
        child: _buildTextContent(context),
      ),
    );
  }

  
  Widget _buildTextContent(BuildContext context) {
    final isSelected = selectionService?.selectedWidget?.id == widgetBean.id;

    return Container(
      // SKETCHWARE PRO STYLE: Use background fill for selection like ItemTextView
      color: isSelected ? const Color(0x9599d5d0) : Colors.transparent,
      // SKETCHWARE PRO STYLE: Use gravity for centering like TextView.setGravity()
      alignment: _getTextAlignment(),
      padding: _getPadding(context),
      child: Text(
        _getText(),
        style: _getTextStyle(context),
        textAlign: _parseTextAlign(widgetBean.properties['textAlign'] ?? 'left'),
      ),
    );
  }

  
  String _getText() {
    return TextPropertyService.getText(widgetBean.properties);
  }

  
  TextStyle _getTextStyle(BuildContext context) {
    final fontSize = _parseDouble(widgetBean.properties['textSize']) ?? 14.0;
    final textColor = ColorUtils.parseColor(
            widgetBean.properties['textColor'] ?? '#000000') ??
        Colors.black;
    final textStyle = widgetBean.properties['textStyle'] ?? 'normal';

    // SKETCHWARE PRO STYLE: Use raw font size without density scaling
    final scaledFontSize = fontSize * scale; // Remove density scaling!

    return TextStyle(
      fontSize: scaledFontSize,
      color: textColor,
      fontWeight: _getFontWeight(textStyle),
      fontStyle: _getFontStyle(textStyle),
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

  
  FontStyle _getFontStyle(String textStyle) {
    switch (textStyle) {
      case 'italic':
      case 'bold|italic':
        return FontStyle.italic;
      default:
        return FontStyle.normal;
    }
  }

  
  Color _getBackgroundColor() {
    final backgroundColor =
        widgetBean.properties['backgroundColor']?.toString() ?? '#FFFFFF';

    // SKETCHWARE PRO STYLE: Handle white background like ItemTextView
    if (backgroundColor == '#FFFFFF' || backgroundColor == '#ffffff') {
      return Colors.transparent; 
    }

    return ColorUtils.parseColor(backgroundColor) ?? Colors.transparent;
  }

  
  EdgeInsets _getPadding(BuildContext context) {
    final layout = widgetBean.layout;

    // SKETCHWARE PRO STYLE: Use raw padding without density scaling
    return EdgeInsets.fromLTRB(
      layout.paddingLeft * scale,
      layout.paddingTop * scale,
      layout.paddingRight * scale,
      layout.paddingBottom * scale,
    );
  }

  
  // SKETCHWARE PRO STYLE: Use gravity for centering like TextView.setGravity()
  Alignment _getTextAlignment() {
    final gravity = widgetBean.layout.gravity;
    
    // SKETCHWARE PRO STYLE: Map Android gravity to Flutter alignment
    switch (gravity) {
      case 1: // Gravity.CENTER
        return Alignment.center;
      case 3: // Gravity.CENTER_HORIZONTAL
        return Alignment.center;
      case 16: // Gravity.CENTER_VERTICAL
        return Alignment.center;
      case 17: // Gravity.CENTER_HORIZONTAL | Gravity.CENTER_VERTICAL
        return Alignment.center;
      case 8388611: // Gravity.START
        return Alignment.centerLeft;
      case 8388613: // Gravity.END
        return Alignment.centerRight;
      case 48: // Gravity.TOP
        return Alignment.topCenter;
      case 80: // Gravity.BOTTOM
        return Alignment.bottomCenter;
      default:
        return Alignment.centerLeft; // SKETCHWARE PRO STYLE: Default alignment
    }
  }

  
  void _notifyWidgetSelected() {
    
    print('🚀 NOTIFYING WIDGET SELECTION: ${widgetBean.id}');

    if (touchController != null) {
      touchController!.handleWidgetTap(widgetBean);
    } else {
      print('🚀 WARNING: touchController is null!');
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  TextAlign _parseTextAlign(String alignment) {
    switch (alignment.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }
}
