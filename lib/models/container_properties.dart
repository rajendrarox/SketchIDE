/// ContainerProperties - EXACTLY matches Sketchware Pro's Container pattern
/// Strongly typed properties for Container widgets to avoid type conversion issues
class ContainerProperties {
  final int width;
  final int height;
  final String backgroundColor;
  final String borderColor;
  final double borderWidth;
  final double borderRadius;
  final String alignment;

  const ContainerProperties({
    this.width = -2, // WRAP_CONTENT
    this.height = -2, // WRAP_CONTENT
    this.backgroundColor = '#FFFFFF',
    this.borderColor = '#CCCCCC',
    this.borderWidth = 1.0,
    this.borderRadius = 0.0,
    this.alignment = 'center',
  });

  factory ContainerProperties.fromJson(Map<String, dynamic> json) {
    return ContainerProperties(
      width: _parseInt(json['width']) ?? -2,
      height: _parseInt(json['height']) ?? -2,
      backgroundColor: json['backgroundColor'] ?? '#FFFFFF',
      borderColor: json['borderColor'] ?? '#CCCCCC',
      borderWidth: _parseDouble(json['borderWidth']) ?? 1.0,
      borderRadius: _parseDouble(json['borderRadius']) ?? 0.0,
      alignment: json['alignment'] ?? 'center',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'backgroundColor': backgroundColor,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'alignment': alignment,
    };
  }

  ContainerProperties copyWith({
    int? width,
    int? height,
    String? backgroundColor,
    String? borderColor,
    double? borderWidth,
    double? borderRadius,
    String? alignment,
  }) {
    return ContainerProperties(
      width: width ?? this.width,
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      alignment: alignment ?? this.alignment,
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
