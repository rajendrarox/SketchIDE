import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';
import 'base_frame_item.dart';

/// SKETCHWARE PRO STYLE: Frame TextField Widget that matches ItemEditText exactly
/// Implements the same interface pattern as Sketchware Pro's ItemEditText
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

/// SKETCHWARE PRO STYLE: Frame TextField Content Widget
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

    /// SKETCHWARE PRO STYLE: Get exact position and size like ItemEditText
    final position = widgetBean.position;
    final layout = widgetBean.layout;

    // SKETCHWARE PRO STYLE: Convert dp to pixels like wB.a(context, value)
    final density = MediaQuery.of(context).devicePixelRatio;

    // SKETCHWARE PRO STYLE: Handle width/height like ViewPane.updateLayout()
    double width = position.width * scale;
    double height = position.height * scale;

    // SKETCHWARE PRO STYLE: If width/height are positive, convert dp to pixels
    if (layout.width > 0) {
      width = layout.width * density * scale;
    }
    if (layout.height > 0) {
      height = layout.height * density * scale;
    }

    return GestureDetector(
      // FLUTTER FIX: Ensure tap events are captured
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // SKETCHWARE PRO STYLE: Handle widget selection on tap
        print('🎯 FRAME TEXT FIELD TAP: ${widgetBean.id}');
        if (selectionService != null) {
          selectionService!.selectWidget(widgetBean);
          print('🎯 SELECTION SERVICE: Widget ${widgetBean.id} selected');
        }
        _notifyWidgetSelected();
      },
      onTapDown: (details) {
        // Additional tap down handling if needed
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
        // SKETCHWARE PRO STYLE: Use exact width/height like ItemEditText
        width: width > 0 ? width : null,
        height: height > 0 ? height : null,
        // SKETCHWARE PRO STYLE: Minimum size like ItemEditText (32dp)
        constraints: BoxConstraints(
          minWidth: 32 * density * scale,
          minHeight: 32 * density * scale,
        ),
        child: _buildTextFieldContent(context),
      ),
    );
  }

  /// SKETCHWARE PRO STYLE: Build text field content (matches ItemEditText)
  Widget _buildTextFieldContent(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final cornerRadius = _getCornerRadius();
    final contentPadding = _getContentPadding(context);

    // SKETCHWARE PRO STYLE: Convert dp to pixels like Android
    final density = MediaQuery.of(context).devicePixelRatio;
    final scaledCornerRadius = cornerRadius * density * scale;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(scaledCornerRadius),
        border: Border.all(
          color: Colors.grey[400]!,
          width: 1 * density * scale,
        ),
      ),
      child: TextField(
        enabled: false, // SKETCHWARE PRO STYLE: Read-only in design mode
        controller: TextEditingController(text: _getText()),
        style: _getTextStyle(context),
        decoration: InputDecoration(
          hintText: _getHint(),
          hintStyle: _getHintStyle(context),
          contentPadding: contentPadding,
          border: InputBorder.none,
        ),
      ),
    );
  }

  /// SKETCHWARE PRO STYLE: Get hint text (matches ItemEditText)
  String _getHint() {
    final hint = widgetBean.properties['hint']?.toString() ?? '';

    // SKETCHWARE PRO STYLE: If hint is empty, show default content like ItemEditText
    if (hint.isEmpty) {
      return 'Enter text'; // SKETCHWARE PRO STYLE: Default hint like IconEditText.getBean()
    }

    return hint;
  }

  /// SKETCHWARE PRO STYLE: Get text content (matches ItemEditText)
  String _getText() {
    final text = widgetBean.properties['text']?.toString() ?? '';

    // SKETCHWARE PRO STYLE: If text is empty, show default content like ItemEditText
    if (text.isEmpty) {
      return 'Edit Text'; // SKETCHWARE PRO STYLE: Default text like IconEditText.getBean()
    }

    return text;
  }

  /// SKETCHWARE PRO STYLE: Get text style (matches ItemEditText)
  TextStyle _getTextStyle(BuildContext context) {
    final fontSize = _parseDouble(widgetBean.properties['textSize']) ?? 14.0;
    final textColor =
        _parseColor(widgetBean.properties['textColor'] ?? '#000000');

    // SKETCHWARE PRO STYLE: Convert sp to pixels like Android
    final density = MediaQuery.of(context).devicePixelRatio;
    final scaledFontSize = fontSize * density * scale;

    return TextStyle(
      fontSize: scaledFontSize,
      color: textColor,
    );
  }

  /// SKETCHWARE PRO STYLE: Get hint style (matches ItemEditText)
  TextStyle _getHintStyle(BuildContext context) {
    final hintColor =
        _parseColor(widgetBean.properties['hintColor'] ?? '#757575');

    // SKETCHWARE PRO STYLE: Convert sp to pixels like Android
    final density = MediaQuery.of(context).devicePixelRatio;
    final fontSize = _parseDouble(widgetBean.properties['textSize']) ?? 14.0;
    final scaledFontSize = fontSize * density * scale;

    return TextStyle(
      fontSize: scaledFontSize,
      color: hintColor,
    );
  }

  /// SKETCHWARE PRO STYLE: Get background color (matches ItemEditText)
  Color _getBackgroundColor() {
    final backgroundColor =
        widgetBean.properties['backgroundColor']?.toString() ?? '#FFFFFF';

    // SKETCHWARE PRO STYLE: Handle white background like ItemEditText
    if (backgroundColor == '#FFFFFF' || backgroundColor == '#ffffff') {
      return Colors
          .transparent; // SKETCHWARE PRO STYLE: Transparent for white background
    }

    return _parseColor(backgroundColor);
  }

  /// SKETCHWARE PRO STYLE: Get corner radius (matches ItemEditText)
  double _getCornerRadius() {
    final radius = widgetBean.properties['cornerRadius'];
    if (radius is num) {
      return radius.toDouble();
    }
    return 4.0;
  }

  /// SKETCHWARE PRO STYLE: Get content padding (matches ItemEditText)
  EdgeInsets _getContentPadding(BuildContext context) {
    final density = MediaQuery.of(context).devicePixelRatio;
    final padding = 8.0 * density * scale;

    return EdgeInsets.all(padding);
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

  /// SKETCHWARE PRO STYLE: Notify parent about widget selection
  void _notifyWidgetSelected() {
    print('🚀 NOTIFYING WIDGET SELECTION: ${widgetBean.id}');
    if (touchController != null) {
      touchController!.handleWidgetTap(widgetBean);
    } else {
      print('🚀 WARNING: touchController is null!');
    }
  }
}
