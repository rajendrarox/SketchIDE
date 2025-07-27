/// TextProperties - EXACTLY matches Sketchware Pro's TextBean
/// Strongly typed properties for Text widgets to avoid type conversion issues
class TextProperties {
  final String text;
  final int textSize;
  final int textColor;
  final int textType;
  final String textFont;
  final int line;

  const TextProperties({
    this.text = 'Text Widget',
    this.textSize = 12,
    this.textColor = 0xff000000,
    this.textType = 0, // TEXT_TYPE_NORMAL
    this.textFont = 'default_font',
    this.line = 0,
  });

  factory TextProperties.fromJson(Map<String, dynamic> json) {
    return TextProperties(
      text: json['text'] ?? 'Text Widget',
      textSize: _parseInt(json['textSize']) ?? 12,
      textColor: _parseInt(json['textColor']) ?? 0xff000000,
      textType: _parseInt(json['textType']) ?? 0,
      textFont: json['textFont'] ?? 'default_font',
      line: _parseInt(json['line']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'textSize': textSize,
      'textColor': textColor,
      'textType': textType,
      'textFont': textFont,
      'line': line,
    };
  }

  TextProperties copyWith({
    String? text,
    int? textSize,
    int? textColor,
    int? textType,
    String? textFont,
    int? line,
  }) {
    return TextProperties(
      text: text ?? this.text,
      textSize: textSize ?? this.textSize,
      textColor: textColor ?? this.textColor,
      textType: textType ?? this.textType,
      textFont: textFont ?? this.textFont,
      line: line ?? this.line,
    );
  }

  // Safe parsing methods
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
