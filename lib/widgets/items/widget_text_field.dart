import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../models/text_field_properties.dart';
import '../../services/widget_factory_service.dart';

/// WidgetTextField - Flutter TextField widget with Sketchware Pro-style selection
/// Text input field
class WidgetTextField extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final bool isSelected;
  final double scale;
  final VoidCallback? onTap;

  const WidgetTextField({
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
          child: TextField(
            controller: TextEditingController(text: _getText()),
            enabled: false, // Read-only in preview
            style: _getTextStyle(),
            decoration: _getInputDecoration(),
            maxLines: _getMaxLines(),
            obscureText: _getObscureText(),
            textAlign: _getTextAlign(),
            keyboardType: _getKeyboardType(),
            textCapitalization: _getTextCapitalization(),
          ),
        ),
      ),
    );
  }

  String _getText() {
    final textFieldProps = WidgetFactoryService.getTypedProperties(widgetBean)
        as TextFieldProperties;
    return textFieldProps.text;
  }

  TextStyle _getTextStyle() {
    final textFieldProps = WidgetFactoryService.getTypedProperties(widgetBean)
        as TextFieldProperties;
    final fontSize = textFieldProps.textSize * scale;
    final fontWeight = _getFontWeightFromType(textFieldProps.textType);
    final color = Color(textFieldProps.textColor);

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

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

  InputDecoration _getInputDecoration() {
    final textFieldProps = WidgetFactoryService.getTypedProperties(widgetBean)
        as TextFieldProperties;
    final hint = textFieldProps.hint;
    final borderColor = Color(0xffCCCCCC); // Default border color
    final focusedBorderColor = Color(0xff2196F3); // Default focused color
    final borderRadius = 4.0 * scale; // Default border radius

    return InputDecoration(
      hintText: hint,
      border: _getBorder('outline', borderColor, borderRadius),
      enabledBorder: _getBorder('outline', borderColor, borderRadius),
      focusedBorder: _getBorder('outline', focusedBorderColor, borderRadius),
      filled: false,
      fillColor: Color(0xffF5F5F5),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 8 * scale,
      ),
    );
  }

  OutlineInputBorder _getBorder(String type, Color color, double radius) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: color,
        width: type == 'none' ? 0 : 1 * scale,
      ),
    );
  }

  int? _getMaxLines() {
    final textFieldProps = WidgetFactoryService.getTypedProperties(widgetBean)
        as TextFieldProperties;
    return textFieldProps.line > 0 ? textFieldProps.line : 1;
  }

  bool _getObscureText() {
    final textFieldProps = WidgetFactoryService.getTypedProperties(widgetBean)
        as TextFieldProperties;
    return textFieldProps.inputType == 129; // INPUT_TYPE_PASSWORD
  }

  TextAlign _getTextAlign() {
    return TextAlign.left; // Default for Sketchware Pro
  }

  TextInputType _getKeyboardType() {
    final textFieldProps = WidgetFactoryService.getTypedProperties(widgetBean)
        as TextFieldProperties;
    switch (textFieldProps.inputType) {
      case 1: // INPUT_TYPE_TEXT
        return TextInputType.text;
      case 3: // INPUT_TYPE_PHONE
        return TextInputType.phone;
      case 129: // INPUT_TYPE_PASSWORD
        return TextInputType.text;
      case 4098: // INPUT_TYPE_NUMBER_SIGNED
        return TextInputType.number;
      case 8194: // INPUT_TYPE_NUMBER_DECIMAL
        return TextInputType.numberWithOptions(decimal: true);
      default:
        return TextInputType.text;
    }
  }

  TextCapitalization _getTextCapitalization() {
    return TextCapitalization.sentences; // Default for Sketchware Pro
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
            int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }

  /// Create a FlutterWidgetBean for TextField using Factory Service
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return WidgetFactoryService.createWidgetBean('TextField',
        id: id, customProperties: properties);
  }
}
