import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../models/text_properties.dart';
import '../../services/widget_factory_service.dart';

/// WidgetText - Flutter Text widget with Sketchware Pro-style selection
/// Display text with styling
class WidgetText extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final bool isSelected;
  final double scale;
  final VoidCallback? onTap;

  const WidgetText({
    super.key,
    required this.widgetBean,
    this.isSelected = false,
    this.scale = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: const Color(0x9599d5d0), width: 2 * scale)
              : Border.all(
                  color: Colors.grey.withOpacity(0.3), width: 1 * scale),
          color: isSelected
              ? const Color(0x9599d5d0).withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.all(4 * scale),
          child: Text(
            _getText(),
            style: _getTextStyle(),
            textAlign: _getTextAlignFromProps(),
            maxLines: _getMaxLinesFromProps(),
            overflow: _getTextOverflowFromProps(),
            softWrap: _getSoftWrapFromProps(),
          ),
        ),
      ),
    );
  }

  String _getText() {
    final textProps =
        WidgetFactoryService.getTypedProperties(widgetBean) as TextProperties;
    return textProps.text;
  }

  TextStyle _getTextStyle() {
    final textProps =
        WidgetFactoryService.getTypedProperties(widgetBean) as TextProperties;
    final fontSize = textProps.textSize * scale;
    final fontWeight = _getFontWeightFromType(textProps.textType);
    final fontStyle = _getFontStyleFromType(textProps.textType);
    final color = Color(textProps.textColor);

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
    );
  }

  FontWeight _getFontWeight(String weight) {
    switch (weight) {
      case 'bold':
        return FontWeight.bold;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  FontStyle _getFontStyle(String style) {
    switch (style) {
      case 'italic':
        return FontStyle.italic;
      default:
        return FontStyle.normal;
    }
  }

  TextDecoration _getTextDecoration(String decoration) {
    switch (decoration) {
      case 'underline':
        return TextDecoration.underline;
      case 'overline':
        return TextDecoration.overline;
      case 'lineThrough':
        return TextDecoration.lineThrough;
      default:
        return TextDecoration.none;
    }
  }

  TextAlign _getTextAlign(String align) {
    switch (align) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      case 'start':
        return TextAlign.start;
      case 'end':
        return TextAlign.end;
      default:
        return TextAlign.left;
    }
  }

  int? _getMaxLines(int maxLines) {
    return maxLines > 0 ? maxLines : null;
  }

  TextOverflow _getTextOverflow(String overflow) {
    switch (overflow) {
      case 'clip':
        return TextOverflow.clip;
      case 'fade':
        return TextOverflow.fade;
      case 'visible':
        return TextOverflow.visible;
      default:
        return TextOverflow.ellipsis;
    }
  }

  bool _getSoftWrap(bool softWrap) {
    return softWrap;
  }

  // Helper methods for Sketchware Pro-style text type handling
  FontWeight _getFontWeightFromType(int textType) {
    switch (textType) {
      case 1: // TEXT_TYPE_BOLD
        return FontWeight.bold;
      case 2: // TEXT_TYPE_ITALIC
        return FontWeight.normal;
      case 3: // TEXT_TYPE_BOLDITALIC
        return FontWeight.bold;
      default: // TEXT_TYPE_NORMAL
        return FontWeight.normal;
    }
  }

  FontStyle _getFontStyleFromType(int textType) {
    switch (textType) {
      case 2: // TEXT_TYPE_ITALIC
      case 3: // TEXT_TYPE_BOLDITALIC
        return FontStyle.italic;
      default: // TEXT_TYPE_NORMAL, TEXT_TYPE_BOLD
        return FontStyle.normal;
    }
  }

  // Helper methods to get properties and call parameterized methods
  TextAlign _getTextAlignFromProps() {
    return TextAlign.left; // Default alignment for Sketchware Pro
  }

  int? _getMaxLinesFromProps() {
    final textProps =
        WidgetFactoryService.getTypedProperties(widgetBean) as TextProperties;
    return textProps.line > 0 ? textProps.line : null;
  }

  TextOverflow _getTextOverflowFromProps() {
    return TextOverflow.ellipsis; // Default for Sketchware Pro
  }

  bool _getSoftWrapFromProps() {
    return true; // Default for Sketchware Pro
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
            int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return Colors.black;
    } catch (e) {
      return Colors.black;
    }
  }

  /// Create a FlutterWidgetBean for Text
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateId(),
      type: 'Text',
      properties: {
        'text': 'Text Widget',
        'fontSize': 14.0,
        'fontWeight': 'normal',
        'fontStyle': 'normal',
        'textColor': '#000000',
        'backgroundColor': '#FFFFFF',
        'textAlign': 'left',
        'maxLines': 1.0,
        'textOverflow': 'ellipsis',
        'softWrap': true,
        'textDecoration': 'none',
        'decorationColor': '#000000',
        'decorationThickness': 1.0,
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 120,
        height: 30,
      ),
      events: {},
      layout: LayoutBean(
        width: -2, // WRAP_CONTENT
        height: -2, // WRAP_CONTENT
        marginLeft: 0,
        marginTop: 0,
        marginRight: 0,
        marginBottom: 0,
        paddingLeft: 8,
        paddingTop: 4,
        paddingRight: 8,
        paddingBottom: 4,
      ),
    );
  }
}
