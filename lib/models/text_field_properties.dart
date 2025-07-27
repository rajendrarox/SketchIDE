/// TextFieldProperties - EXACTLY matches Sketchware Pro's TextBean pattern for EditText
/// Strongly typed properties for TextField widgets to avoid type conversion issues
class TextFieldProperties {
  final String text;
  final String hint;
  final int textSize;
  final int textColor;
  final int hintColor;
  final int inputType;
  final int imeOption;
  final int singleLine;
  final int line;
  final String textFont;
  final int textType;

  const TextFieldProperties({
    this.text = '',
    this.hint = 'Enter text',
    this.textSize = 12,
    this.textColor = 0xff000000,
    this.hintColor = 0xff607d8b,
    this.inputType = 1, // INPUT_TYPE_TEXT
    this.imeOption = 0, // IME_OPTION_NORMAL
    this.singleLine = 0,
    this.line = 0,
    this.textFont = 'default_font',
    this.textType = 0, // TEXT_TYPE_NORMAL
  });

  factory TextFieldProperties.fromJson(Map<String, dynamic> json) {
    return TextFieldProperties(
      text: json['text'] ?? '',
      hint: json['hint'] ?? 'Enter text',
      textSize: _parseInt(json['textSize']) ?? 12,
      textColor: _parseInt(json['textColor']) ?? 0xff000000,
      hintColor: _parseInt(json['hintColor']) ?? 0xff607d8b,
      inputType: _parseInt(json['inputType']) ?? 1,
      imeOption: _parseInt(json['imeOption']) ?? 0,
      singleLine: _parseInt(json['singleLine']) ?? 0,
      line: _parseInt(json['line']) ?? 0,
      textFont: json['textFont'] ?? 'default_font',
      textType: _parseInt(json['textType']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'hint': hint,
      'textSize': textSize,
      'textColor': textColor,
      'hintColor': hintColor,
      'inputType': inputType,
      'imeOption': imeOption,
      'singleLine': singleLine,
      'line': line,
      'textFont': textFont,
      'textType': textType,
    };
  }

  TextFieldProperties copyWith({
    String? text,
    String? hint,
    int? textSize,
    int? textColor,
    int? hintColor,
    int? inputType,
    int? imeOption,
    int? singleLine,
    int? line,
    String? textFont,
    int? textType,
  }) {
    return TextFieldProperties(
      text: text ?? this.text,
      hint: hint ?? this.hint,
      textSize: textSize ?? this.textSize,
      textColor: textColor ?? this.textColor,
      hintColor: hintColor ?? this.hintColor,
      inputType: inputType ?? this.inputType,
      imeOption: imeOption ?? this.imeOption,
      singleLine: singleLine ?? this.singleLine,
      line: line ?? this.line,
      textFont: textFont ?? this.textFont,
      textType: textType ?? this.textType,
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
