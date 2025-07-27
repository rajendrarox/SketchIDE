import 'package:flutter/material.dart';
import '../models/view_info.dart';

/// Enhanced ViewInfoService - Matches Sketchware Pro's coordinate system
///
/// FEATURES:
/// - Coordinate transformation (raw to scaled)
/// - Scale-aware positioning
/// - Depth-based drop zone priority
/// - Margin/padding awareness
/// - Gravity-based positioning
class ViewInfoService extends ChangeNotifier {
  // SKETCHWARE PRO STYLE: Scale factors
  double _outerScale = 1.0; // var11 in Sketchware Pro
  double _innerScale = 1.0; // var3 in Sketchware Pro
  double _widgetScale = 1.0; // Individual widget scale

  // SKETCHWARE PRO STYLE: Container dimensions
  Size _containerSize = Size.zero;
  Offset _containerOffset = Offset.zero;

  // SKETCHWARE PRO STYLE: View information tracking
  final List<ViewInfo> _viewInfos = [];
  ViewInfo? _currentViewInfo;
  DropZoneInfo? _currentDropZone;

  // SKETCHWARE PRO STYLE: Highlight state
  bool _isHighlighted = false;
  Rect? _highlightRect;

  // Getters
  double get outerScale => _outerScale;
  double get innerScale => _innerScale;
  double get widgetScale => _widgetScale;
  Size get containerSize => _containerSize;
  Offset get containerOffset => _containerOffset;
  List<ViewInfo> get viewInfos => _viewInfos;
  ViewInfo? get currentViewInfo => _currentViewInfo;
  DropZoneInfo? get currentDropZone => _currentDropZone;
  bool get isHighlighted => _isHighlighted;
  Rect? get highlightRect => _highlightRect;

  /// SKETCHWARE PRO STYLE: Update scale factors
  void updateScales({
    required double outerScale,
    required double innerScale,
    double? widgetScale,
  }) {
    _outerScale = outerScale;
    _innerScale = innerScale;
    if (widgetScale != null) _widgetScale = widgetScale;
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Update container information
  void updateContainer({
    required Size size,
    required Offset offset,
  }) {
    _containerSize = size;
    _containerOffset = offset;
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Coordinate transformation (matches ViewEditor.java:779)
  /// Converts raw screen coordinates to scaled ViewPane coordinates
  Offset transformCoordinates(Offset rawCoordinates) {
    // SKETCHWARE PRO STYLE: Get container location on screen
    final containerScreenLocation = _containerOffset;

    // SKETCHWARE PRO STYLE: Check if coordinates are within container bounds
    final containerScreenRect = Rect.fromLTWH(
      containerScreenLocation.dx,
      containerScreenLocation.dy,
      _containerSize.width * _innerScale,
      _containerSize.height * _innerScale,
    );

    if (!containerScreenRect.contains(rawCoordinates)) {
      return Offset.zero; // Outside container
    }

    // SKETCHWARE PRO STYLE: Transform to scaled coordinates
    final relativeX =
        (rawCoordinates.dx - containerScreenLocation.dx) / _innerScale;
    final relativeY =
        (rawCoordinates.dy - containerScreenLocation.dy) / _innerScale;

    return Offset(relativeX, relativeY);
  }

  /// SKETCHWARE PRO STYLE: Check if coordinates are within container (matches ViewEditor.java:779)
  bool isWithinContainer(Offset rawCoordinates) {
    final containerScreenLocation = _containerOffset;
    final containerScreenRect = Rect.fromLTWH(
      containerScreenLocation.dx,
      containerScreenLocation.dy,
      _containerSize.width * _innerScale,
      _containerSize.height * _innerScale,
    );

    return containerScreenRect.contains(rawCoordinates);
  }

  /// SKETCHWARE PRO STYLE: Get drop zone info (matches ViewPane.java:750)
  /// Returns the highest priority drop zone at the given coordinates
  ViewInfo? getViewInfo(Offset coordinates) {
    ViewInfo? result;
    int highestPriority = -1;

    for (ViewInfo viewInfo in _viewInfos) {
      if (viewInfo.rect.contains(coordinates) &&
          highestPriority < viewInfo.depth) {
        highestPriority = viewInfo.depth;
        result = viewInfo;
      }
    }

    return result;
  }

  /// SKETCHWARE PRO STYLE: Update view highlight (matches ViewPane.java:750)
  void updateViewHighlight(Offset coordinates, Size widgetSize) {
    final viewInfo = getViewInfo(coordinates);

    if (viewInfo == null) {
      resetViewHighlight();
    } else if (_currentViewInfo != viewInfo) {
      resetViewHighlight();
      _currentViewInfo = viewInfo;
      _highlightRect = Rect.fromLTWH(
        viewInfo.rect.left,
        viewInfo.rect.top,
        widgetSize.width,
        widgetSize.height,
      );
      _isHighlighted = true;
      notifyListeners();
    }
  }

  /// SKETCHWARE PRO STYLE: Reset view highlight
  void resetViewHighlight() {
    _currentViewInfo = null;
    _highlightRect = null;
    _isHighlighted = false;
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Add view info (matches ViewPane.java:984)
  void addViewInfo(Rect rect, Widget view, int index, int depth) {
    final viewInfo = ViewInfo(
      rect: rect,
      view: view,
      index: index,
      depth: depth,
    );
    _viewInfos.add(viewInfo);
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Clear all view infos
  void clearViewInfos() {
    _viewInfos.clear();
    resetViewHighlight();
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Calculate view depth (matches ViewPane.java:252)
  int calculateViewDepth(Widget view) {
    int depth = 0;
    Widget? current = view;

    while (current != null) {
      depth++;
      // In Flutter, we need to traverse the widget tree differently
      // This is a simplified version
      break;
    }

    return depth;
  }

  /// SKETCHWARE PRO STYLE: Set current drop zone
  void setCurrentDropZone(DropZoneInfo? dropZone) {
    _currentDropZone = dropZone;
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Highlight view info
  void highlightViewInfo(ViewInfo? viewInfo) {
    _currentViewInfo = viewInfo;
    _isHighlighted = viewInfo != null;
    if (viewInfo != null) {
      _highlightRect = viewInfo.rect;
    } else {
      _highlightRect = null;
    }
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Calculate widget position with margins and padding
  Offset calculateWidgetPosition({
    required Offset dropPosition,
    required Size widgetSize,
    required EdgeInsets margins,
    required EdgeInsets padding,
    required Alignment gravity,
  }) {
    // SKETCHWARE PRO STYLE: Account for margins and padding
    final adjustedPosition = Offset(
      dropPosition.dx + margins.left + padding.left,
      dropPosition.dy + margins.top + padding.top,
    );

    // SKETCHWARE PRO STYLE: Apply gravity-based positioning
    switch (gravity) {
      case Alignment.center:
        return Offset(
          adjustedPosition.dx - widgetSize.width / 2,
          adjustedPosition.dy - widgetSize.height / 2,
        );
      case Alignment.centerLeft:
        return Offset(
          adjustedPosition.dx,
          adjustedPosition.dy - widgetSize.height / 2,
        );
      case Alignment.centerRight:
        return Offset(
          adjustedPosition.dx - widgetSize.width,
          adjustedPosition.dy - widgetSize.height / 2,
        );
      case Alignment.topCenter:
        return Offset(
          adjustedPosition.dx - widgetSize.width / 2,
          adjustedPosition.dy,
        );
      case Alignment.bottomCenter:
        return Offset(
          adjustedPosition.dx - widgetSize.width / 2,
          adjustedPosition.dy - widgetSize.height,
        );
      default:
        return adjustedPosition;
    }
  }

  /// SKETCHWARE PRO STYLE: Get drop zone info for widget placement
  DropZoneInfo? getDropZoneInfo(Offset coordinates, Size widgetSize) {
    final viewInfo = getViewInfo(coordinates);

    if (viewInfo == null) return null;

    return DropZoneInfo(
      viewInfo: viewInfo,
      position: coordinates,
      size: widgetSize,
      isValid: true,
    );
  }

  @override
  void dispose() {
    _viewInfos.clear();
    super.dispose();
  }
}

/// SKETCHWARE PRO STYLE: Drop zone information
class DropZoneInfo {
  final ViewInfo viewInfo;
  final Offset position;
  final Size size;
  final bool isValid;

  DropZoneInfo({
    required this.viewInfo,
    required this.position,
    required this.size,
    required this.isValid,
  });
}
