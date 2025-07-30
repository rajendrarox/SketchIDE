import 'package:flutter/material.dart';
import 'color_utils.dart';

class TextPropertyService {
  static const String _tag = 'TextPropertyService';

  static const String defaultText = 'Text';
  static const String defaultTextSize = '14.0';
  static const String defaultTextColor = '#000000';
  static const String defaultBackgroundColor = '#FFFFFF';
  static const String defaultTextType = 'normal';
  static const String defaultLines = '1';
  static const String defaultSingleLine = 'false';

  static Map<String, dynamic> getDefaultProperties() {
    return {
      'text': defaultText,
      'textSize': defaultTextSize,
      'textColor': defaultTextColor,
      'backgroundColor': defaultBackgroundColor,
      'textType': defaultTextType,
      'lines': defaultLines,
      'singleLine': defaultSingleLine,
    };
  }

  static String getText(Map<String, dynamic> properties) {
    final textValue = properties['text'];

    if (textValue == null) {
      return defaultText;
    }

    final text = textValue.toString();

    if (text.isEmpty || text == 'null') {
      return defaultText;
    }

    return text;
  }

  static TextStyle getTextStyle(
      BuildContext context, Map<String, dynamic> properties, double scale) {
    final fontSize = double.tryParse(
            properties['textSize']?.toString() ?? defaultTextSize) ??
        14.0;
    final textColor =
        ColorUtils.parseColor(properties['textColor'] ?? defaultTextColor) ??
            Colors.black;
    final textType = properties['textType'] ?? defaultTextType;

    return TextStyle(
      fontSize: fontSize * scale,
      color: textColor,
      fontWeight: _getFontWeight(textType),
    );
  }

  static FontWeight _getFontWeight(String textType) {
    switch (textType.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'italic':
        return FontWeight.normal;
      case 'bold_italic':
        return FontWeight.bold;
      default:
        return FontWeight.normal;
    }
  }
}
