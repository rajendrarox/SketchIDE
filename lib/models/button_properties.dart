/// ButtonProperties - EXACTLY matches Sketchware Pro's IconButton properties
/// Handles Button widget properties with proper typing
class ButtonProperties {
  final String text;
  final double textSize;
  final String textColor;
  final String textStyle;
  final String textAlign;
  final String backgroundColor;
  final double cornerRadius;
  final bool enabled;

  ButtonProperties({
    required this.text,
    required this.textSize,
    required this.textColor,
    required this.textStyle,
    required this.textAlign,
    required this.backgroundColor,
    required this.cornerRadius,
    required this.enabled,
  });

  /// Create from JSON map (like Sketchware Pro's ViewBean properties)
  factory ButtonProperties.fromJson(Map<String, dynamic> json) {
    return ButtonProperties(
      text: json['text'] ?? 'Button',
      textSize: (json['textSize'] ?? 14.0).toDouble(),
      textColor: json['textColor'] ?? '#FFFFFF',
      textStyle: json['textStyle'] ?? 'normal',
      textAlign: json['textAlign'] ?? 'center',
      backgroundColor: json['backgroundColor'] ?? '#2196F3',
      cornerRadius: (json['cornerRadius'] ?? 4.0).toDouble(),
      enabled: json['enabled'] ?? true,
    );
  }

  /// Convert to JSON map (like Sketchware Pro's ViewBean properties)
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'textSize': textSize,
      'textColor': textColor,
      'textStyle': textStyle,
      'textAlign': textAlign,
      'backgroundColor': backgroundColor,
      'cornerRadius': cornerRadius,
      'enabled': enabled,
    };
  }

  /// Create a copy with updated values (like Sketchware Pro's ViewBean.copyWith)
  ButtonProperties copyWith({
    String? text,
    double? textSize,
    String? textColor,
    String? textStyle,
    String? textAlign,
    String? backgroundColor,
    double? cornerRadius,
    bool? enabled,
  }) {
    return ButtonProperties(
      text: text ?? this.text,
      textSize: textSize ?? this.textSize,
      textColor: textColor ?? this.textColor,
      textStyle: textStyle ?? this.textStyle,
      textAlign: textAlign ?? this.textAlign,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() {
    return 'ButtonProperties(text: $text, textSize: $textSize, textColor: $textColor, backgroundColor: $backgroundColor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ButtonProperties &&
        other.text == text &&
        other.textSize == textSize &&
        other.textColor == textColor &&
        other.textStyle == textStyle &&
        other.textAlign == textAlign &&
        other.backgroundColor == backgroundColor &&
        other.cornerRadius == cornerRadius &&
        other.enabled == enabled;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        textSize.hashCode ^
        textColor.hashCode ^
        textStyle.hashCode ^
        textAlign.hashCode ^
        backgroundColor.hashCode ^
        cornerRadius.hashCode ^
        enabled.hashCode;
  }
}
