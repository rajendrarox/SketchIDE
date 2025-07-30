import 'package:flutter/material.dart';

class ColorUtils {
  static Color? parseColor(dynamic colorValue) {
    if (colorValue == null) return null;

    if (colorValue is Color) return colorValue;

    if (colorValue is String) {
      if (colorValue.startsWith('#')) {
        try {
          return Color(int.parse(colorValue.replaceFirst('#', '0xFF')));
        } catch (e) {
          return null;
        }
      }

      return parseNamedColor(colorValue);
    }

    if (colorValue is int) {
      return Color(colorValue);
    }

    return null;
  }

  static Color? parseHexColor(String hexString) {
    if (hexString.isEmpty) return null;

    if (hexString.startsWith('#')) {
      try {
        return Color(int.parse(hexString.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        return null;
      }
    }

    try {
      return Color(int.parse(hexString, radix: 16) + 0xFF000000);
    } catch (e) {
      return null;
    }
  }

  static Color? parseNamedColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'transparent':
        return Colors.transparent;
      default:
        return null;
    }
  }

  static bool isValidColor(dynamic value) {
    return parseColor(value) != null;
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }
}
