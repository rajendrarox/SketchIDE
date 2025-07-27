/// StackProperties - EXACTLY matches Sketchware Pro's Stack pattern
/// Strongly typed properties for Stack widgets to avoid type conversion issues
class StackProperties {
  final String alignment;
  final String fit;
  final String clipBehavior;

  const StackProperties({
    this.alignment = 'topLeft',
    this.fit = 'loose',
    this.clipBehavior = 'hardEdge',
  });

  factory StackProperties.fromJson(Map<String, dynamic> json) {
    return StackProperties(
      alignment: json['alignment'] ?? 'topLeft',
      fit: json['fit'] ?? 'loose',
      clipBehavior: json['clipBehavior'] ?? 'hardEdge',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alignment': alignment,
      'fit': fit,
      'clipBehavior': clipBehavior,
    };
  }

  StackProperties copyWith({
    String? alignment,
    String? fit,
    String? clipBehavior,
  }) {
    return StackProperties(
      alignment: alignment ?? this.alignment,
      fit: fit ?? this.fit,
      clipBehavior: clipBehavior ?? this.clipBehavior,
    );
  }
}
