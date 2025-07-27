/// LayoutProperties - EXACTLY matches Sketchware Pro's Layout pattern
/// Strongly typed properties for Row and Column layout widgets to avoid type conversion issues
class LayoutProperties {
  final String mainAxisAlignment;
  final String crossAxisAlignment;
  final String mainAxisSize;

  const LayoutProperties({
    this.mainAxisAlignment = 'start',
    this.crossAxisAlignment = 'center',
    this.mainAxisSize = 'max',
  });

  factory LayoutProperties.fromJson(Map<String, dynamic> json) {
    return LayoutProperties(
      mainAxisAlignment: json['mainAxisAlignment'] ?? 'start',
      crossAxisAlignment: json['crossAxisAlignment'] ?? 'center',
      mainAxisSize: json['mainAxisSize'] ?? 'max',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mainAxisAlignment': mainAxisAlignment,
      'crossAxisAlignment': crossAxisAlignment,
      'mainAxisSize': mainAxisSize,
    };
  }

  LayoutProperties copyWith({
    String? mainAxisAlignment,
    String? crossAxisAlignment,
    String? mainAxisSize,
  }) {
    return LayoutProperties(
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      mainAxisSize: mainAxisSize ?? this.mainAxisSize,
    );
  }
}
