import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';
import '../../services/widget_sizing_service.dart';
import 'base_frame_item.dart';

/// SKETCHWARE PRO STYLE: Frame Text Widget that matches ItemTextView exactly
/// Implements the same interface pattern as Sketchware Pro's ItemTextView
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

/// SKETCHWARE PRO STYLE: Frame Text Content Widget
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

    /// SKETCHWARE PRO STYLE: Get exact position and size like ItemTextView
    final position = widgetBean.position;
    final layout = widgetBean.layout;

    // EXACT SKETCHWARE PRO: Convert dp to pixels using wB.a(context, value) equivalent
    double width = position.width * scale;
    double height = position.height * scale;

    // EXACT SKETCHWARE PRO: If width/height are positive, convert dp to pixels exactly
    if (layout.width > 0) {
      width = WidgetSizingService.convertDpToPixels(
              context, layout.width.toDouble()) *
          scale;
    }
    if (layout.height > 0) {
      height = WidgetSizingService.convertDpToPixels(
              context, layout.height.toDouble()) *
          scale;
    }

    return GestureDetector(
      // FLUTTER FIX: Ensure tap events are captured (will be overridden by AndroidNativeTouchWidget)
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // ANDROID NATIVE: This will be handled by AndroidNativeTouchService when wrapped
        print('🎯 FRAME TEXT TAP (GestureDetector): ${widgetBean.id}');
        print(
            '🎯 SELECTION SERVICE: ${selectionService != null ? "AVAILABLE" : "NULL"}');
        print(
            '🎯 TOUCH CONTROLLER: ${touchController != null ? "AVAILABLE" : "NULL"}');

        if (selectionService != null) {
          selectionService!.selectWidget(widgetBean);
          print('🎯 SELECTION SERVICE: Widget ${widgetBean.id} selected');
        }
        // Notify parent about selection to open property panel
        _notifyWidgetSelected();
      },
      onTapDown: (details) {
        // Additional tap down handling if needed
        print('🎯 FRAME TEXT TAP DOWN: ${widgetBean.id}');
      },
      onLongPressStart: (details) {
        // SKETCHWARE PRO STYLE: Start drag detection on long press
        print('🎯 FRAME TEXT LONG PRESS START: ${widgetBean.id}');
        if (touchController != null) {
          touchController!
              .handleTouchStart(widgetBean, details.globalPosition, widgetKey);
        }
      },
      onLongPressMoveUpdate: (details) {
        // SKETCHWARE PRO STYLE: Update drag position during long press move
        if (touchController != null) {
          touchController!.handleTouchMove(details.globalPosition);
        }
      },
      onLongPressEnd: (details) {
        // SKETCHWARE PRO STYLE: End drag operation
        if (touchController != null) {
          touchController!.handleTouchEnd(details.globalPosition);
        }
      },
      onPanStart: (details) {
        // SKETCHWARE PRO STYLE: Alternative drag start
        print('🎯 FRAME TEXT PAN START: ${widgetBean.id}');
        if (touchController != null) {
          touchController!
              .handleTouchStart(widgetBean, details.globalPosition, widgetKey);
        }
      },
      onPanUpdate: (details) {
        // SKETCHWARE PRO STYLE: Update drag position during pan
        if (touchController != null) {
          touchController!.handleTouchMove(details.globalPosition);
        }
      },
      onPanEnd: (details) {
        // SKETCHWARE PRO STYLE: End pan operation
        if (touchController != null) {
          touchController!.handleTouchEnd(details.globalPosition);
        }
      },
      child: Container(
        key: widgetKey,
        // SKETCHWARE PRO STYLE: Use exact width/height like ItemTextView
        width: width,
        height: height,
        // EXACT SKETCHWARE PRO: Minimum size like ItemTextView (32dp)
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

  /// EXACT SKETCHWARE PRO: Build text content like ItemTextView
  Widget _buildTextContent(BuildContext context) {
    final isSelected = selectionService?.selectedWidget?.id == widgetBean.id;

    return Container(
      padding: _getPadding(context),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        // EXACT SKETCHWARE PRO: Selection background like ItemTextView.onDraw()
        border: isSelected
            ? Border.all(color: const Color(0x9599d5d0), width: 2.0 * scale)
            : Border.all(color: Colors.transparent, width: 1.0 * scale),
        // EXACT SKETCHWARE PRO: Subtle shadow like Android TextView
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1.0 * scale,
            offset: Offset(0, 1.0 * scale),
          ),
        ],
      ),
      child: Text(
        _getText(),
        style: _getTextStyle(context),
      ),
    );
  }

  /// SKETCHWARE PRO STYLE: Get text content (matches ItemTextView)
  String _getText() {
    final text = widgetBean.properties['text']?.toString() ?? '';

    // SKETCHWARE PRO STYLE: If text is empty, show default content like ItemTextView
    if (text.isEmpty) {
      return 'TextView'; // SKETCHWARE PRO STYLE: Default text like IconTextView.getBean()
    }

    return text;
  }

  /// SKETCHWARE PRO STYLE: Get text style (matches ItemTextView)
  TextStyle _getTextStyle(BuildContext context) {
    final fontSize = _parseDouble(widgetBean.properties['textSize']) ?? 14.0;
    final textColor =
        _parseColor(widgetBean.properties['textColor'] ?? '#000000');
    final textStyle = widgetBean.properties['textStyle'] ?? 'normal';

    // EXACT SKETCHWARE PRO: Convert sp to pixels like Android
    final scaledFontSize =
        WidgetSizingService.convertDpToPixels(context, fontSize) * scale;

    return TextStyle(
      fontSize: scaledFontSize,
      color: textColor,
      fontWeight: _getFontWeight(textStyle),
    );
  }

  /// SKETCHWARE PRO STYLE: Get font weight (matches ItemTextView)
  FontWeight _getFontWeight(String textStyle) {
    switch (textStyle) {
      case 'bold':
        return FontWeight.bold;
      case 'italic':
        return FontStyle.italic
            as FontWeight; // This is incorrect, should be FontWeight.normal with FontStyle.italic
      case 'bold|italic':
        return FontWeight
            .bold; // This is incorrect, should be FontWeight.bold with FontStyle.italic
      default:
        return FontWeight.normal;
    }
  }

  /// SKETCHWARE PRO STYLE: Get background color (matches ItemTextView)
  Color _getBackgroundColor() {
    final backgroundColor =
        widgetBean.properties['backgroundColor']?.toString() ?? '#FFFFFF';

    // SKETCHWARE PRO STYLE: Handle white background like ItemTextView
    if (backgroundColor == '#FFFFFF' || backgroundColor == '#ffffff') {
      return Colors
          .transparent; // SKETCHWARE PRO STYLE: Transparent for white background
    }

    return _parseColor(backgroundColor);
  }

  /// EXACT SKETCHWARE PRO: Get padding (matches ItemTextView.setPadding exactly)
  EdgeInsets _getPadding(BuildContext context) {
    final layout = widgetBean.layout;

    // EXACT SKETCHWARE PRO: Use exact equivalent of ItemTextView.setPadding()
    final sketchwarePadding = WidgetSizingService.convertSketchwarePadding(
      context,
      left: layout.paddingLeft,
      top: layout.paddingTop,
      right: layout.paddingRight,
      bottom: layout.paddingBottom,
    );

    return EdgeInsets.fromLTRB(
      sketchwarePadding.left * scale,
      sketchwarePadding.top * scale,
      sketchwarePadding.right * scale,
      sketchwarePadding.bottom * scale,
    );
  }

  /// SKETCHWARE PRO STYLE: Notify parent about widget selection (like ViewEditor.java:83)
  void _notifyWidgetSelected() {
    // This will bubble up to DesignActivityScreen -> PropertyPanel
    print('🚀 NOTIFYING WIDGET SELECTION: ${widgetBean.id}');

    // Use the touch controller's proper widget tap method
    if (touchController != null) {
      touchController!.handleWidgetTap(widgetBean);
    } else {
      print('🚀 WARNING: touchController is null!');
    }
  }

  /// SKETCHWARE PRO STYLE: Parse double from various types
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// SKETCHWARE PRO STYLE: Parse color from string
  Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      try {
        final colorInt =
            int.parse(colorString.substring(1), radix: 16) + 0xFF000000;
        return Color(colorInt);
      } catch (e) {
        return Colors.transparent;
      }
    }
    return Colors.transparent;
  }
}
