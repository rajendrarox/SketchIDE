import 'package:flutter/material.dart';

/// ViewInfo - Matches Sketchware Pro's ViewInfo structure
///
/// SKETCHWARE PRO STYLE:
/// - rect: Bounding rectangle of the view
/// - view: The actual widget/view
/// - index: Position in parent
/// - depth: Hierarchy depth for priority
class ViewInfo {
  final Rect rect;
  final Widget view;
  final int index;
  final int depth;

  const ViewInfo({
    required this.rect,
    required this.view,
    required this.index,
    required this.depth,
  });

  /// Create a copy with updated properties
  ViewInfo copyWith({
    Rect? rect,
    Widget? view,
    int? index,
    int? depth,
  }) {
    return ViewInfo(
      rect: rect ?? this.rect,
      view: view ?? this.view,
      index: index ?? this.index,
      depth: depth ?? this.depth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ViewInfo &&
        other.rect == rect &&
        other.view == view &&
        other.index == index &&
        other.depth == depth;
  }

  @override
  int get hashCode {
    return Object.hash(rect, view, index, depth);
  }

  @override
  String toString() {
    return 'ViewInfo(rect: $rect, index: $index, depth: $depth)';
  }
}
