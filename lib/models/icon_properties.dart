/// IconProperties - EXACTLY matches Sketchware Pro's Icon pattern
/// Strongly typed properties for Icon widgets to avoid type conversion issues
class IconProperties {
  final String iconName;
  final double iconSize;
  final String iconColor;
  final String semanticLabel;

  const IconProperties({
    this.iconName = 'home',
    this.iconSize = 24.0,
    this.iconColor = '#000000',
    this.semanticLabel = '',
  });

  factory IconProperties.fromJson(Map<String, dynamic> json) {
    return IconProperties(
      iconName: json['iconName'] ?? 'home',
      iconSize: _parseDouble(json['iconSize']) ?? 24.0,
      iconColor: json['iconColor'] ?? '#000000',
      semanticLabel: json['semanticLabel'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iconName': iconName,
      'iconSize': iconSize,
      'iconColor': iconColor,
      'semanticLabel': semanticLabel,
    };
  }

  IconProperties copyWith({
    String? iconName,
    double? iconSize,
    String? iconColor,
    String? semanticLabel,
  }) {
    return IconProperties(
      iconName: iconName ?? this.iconName,
      iconSize: iconSize ?? this.iconSize,
      iconColor: iconColor ?? this.iconColor,
      semanticLabel: semanticLabel ?? this.semanticLabel,
    );
  }

  // Safe parsing methods
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
