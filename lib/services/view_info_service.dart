import 'package:flutter/material.dart';
import '../models/view_info.dart';
import '../models/flutter_widget_bean.dart';
import 'widget_factory_service.dart';

/// Enhanced ViewInfoService - Matches Sketchware Pro's coordinate system
///
/// FEATURES:
/// - Coordinate transformation (raw to scaled)
/// - Scale-aware positioning
/// - Depth-based drop zone priority
/// - Margin/padding awareness
/// - Gravity-based positioning
/// - Real-time widget updates
class ViewInfoService extends ChangeNotifier {
  // SKETCHWARE PRO STYLE: Singleton instance for shared access
  static final ViewInfoService _instance = ViewInfoService._internal();
  factory ViewInfoService() => _instance;
  ViewInfoService._internal();

  // SKETCHWARE PRO STYLE: Track disposal state
  bool _disposed = false;
  bool get disposed => _disposed;
  // SKETCHWARE PRO STYLE: Scale factors
  double _outerScale = 1.0; // var11 in Sketchware Pro
  double _innerScale = 1.0; // var3 in Sketchware Pro
  double _widgetScale = 1.0; // Individual widget scale

  // SKETCHWARE PRO STYLE: Container dimensions
  Size _containerSize = Size.zero;
  Offset _containerOffset = Offset.zero;

  // SKETCHWARE PRO STYLE: Sophisticated view information tracking (like ViewPane.java)
  final List<ViewInfo> _viewInfos = [];
  ViewInfo? _currentViewInfo;
  DropZoneInfo? _currentDropZone;

  // SKETCHWARE PRO STYLE: Depth-based priority system (like ViewPane.java:782)
  final Map<int, List<ViewInfo>> _depthMap = {};
  int _maxDepth = 0;

  // SKETCHWARE PRO STYLE: Drop zone validation (like ViewEditor.java:327)
  bool _isValidDropZone = false;
  String? _dropZoneParent;
  int _dropZoneIndex = -1;
  Size _dropZoneSize = Size.zero;

  // SKETCHWARE PRO STYLE: Enhanced highlight state
  bool _isHighlighted = false;
  Rect? _highlightRect;
  Color _highlightColor = const Color(0x9599d5d0); // Sketchware Pro green

  // SKETCHWARE PRO STYLE: Widget registration for real-time updates
  final Map<String, Widget> _registeredWidgets = {};
  final Map<String, FlutterWidgetBean> _registeredWidgetBeans = {};

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
    if (_disposed)
      return; // SKETCHWARE PRO STYLE: Prevent disposed service usage
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
    if (_disposed)
      return; // SKETCHWARE PRO STYLE: Prevent disposed service usage
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

  /// SKETCHWARE PRO STYLE: Sophisticated drop zone detection (like ViewPane.java:782)
  void updateViewHighlight(Offset coordinates, Size widgetSize) {
    if (_disposed)
      return; // SKETCHWARE PRO STYLE: Prevent disposed service usage

    // SKETCHWARE PRO STYLE: Find the best drop zone with depth priority
    final dropZone = _findBestDropZoneWithDepth(coordinates, widgetSize);

    if (dropZone != null) {
      _currentDropZone = dropZone;
      _currentViewInfo = dropZone.viewInfo;
      _isHighlighted = true;
      _highlightRect = dropZone.viewInfo.rect;
      _isValidDropZone = true;
      _dropZoneParent = dropZone.viewInfo.parentId;
      _dropZoneIndex = dropZone.viewInfo.index;
      _dropZoneSize = widgetSize;

      // SKETCHWARE PRO STYLE: Set highlight color based on drop zone type
      _setHighlightColor(dropZone.viewInfo);
    } else {
      resetViewHighlight();
    }

    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Find best drop zone with depth priority (like ViewPane.java:782)
  DropZoneInfo? _findBestDropZoneWithDepth(Offset position, Size widgetSize) {
    ViewInfo? bestViewInfo;
    int highestDepth = -1;

    // SKETCHWARE PRO STYLE: Check from highest depth to lowest (like ViewPane.java)
    for (int depth = _maxDepth; depth >= 0; depth--) {
      final viewsAtDepth = _depthMap[depth] ?? [];

      for (final viewInfo in viewsAtDepth) {
        if (_isValidDropZoneForPosition(viewInfo, position, widgetSize)) {
          if (depth > highestDepth) {
            highestDepth = depth;
            bestViewInfo = viewInfo;
          }
        }
      }

      // SKETCHWARE PRO STYLE: If we found a valid drop zone at this depth, use it
      if (bestViewInfo != null) {
        break;
      }
    }

    if (bestViewInfo != null) {
      // SKETCHWARE PRO STYLE: Calculate hierarchical drop position instead of using cursor position
      final hierarchicalPosition =
          _calculateHierarchicalDropPosition(bestViewInfo, widgetSize);

      return DropZoneInfo(
        viewInfo: bestViewInfo,
        position: hierarchicalPosition,
        size: widgetSize,
        isValid: true,
      );
    }

    return null;
  }

  /// SKETCHWARE PRO STYLE: Calculate hierarchical drop position (like ViewPane.java:782)
  Offset _calculateHierarchicalDropPosition(
      ViewInfo viewInfo, Size widgetSize) {
    // SKETCHWARE PRO STYLE: For root container, drop at top-left with margins
    if (viewInfo.parentId == null || viewInfo.parentId == 'root') {
      return Offset(8.0, 8.0);
    }

    // SKETCHWARE PRO STYLE: For child widgets, drop at the exact hierarchical position
    // This should be the fixed drop target location, not relative to existing widgets
    final rect = viewInfo.rect;

    // SKETCHWARE PRO STYLE: Calculate the fixed drop position based on hierarchy
    // For containers, drop at top-left with margins
    if (viewInfo.viewType == 'Container' ||
        viewInfo.viewType == 'LinearLayout' ||
        viewInfo.viewType == 'RelativeLayout' ||
        viewInfo.viewType == 'FrameLayout') {
      return Offset(rect.left + 8.0, rect.top + 8.0);
    }

    // SKETCHWARE PRO STYLE: For other widgets, drop at their position
    return Offset(rect.left, rect.top);
  }

  /// SKETCHWARE PRO STYLE: Validate drop zone for position (like ViewEditor.java:327)
  bool _isValidDropZoneForPosition(
      ViewInfo viewInfo, Offset position, Size widgetSize) {
    final rect = viewInfo.rect;

    // SKETCHWARE PRO STYLE: Check if position is within the view bounds
    if (!rect.contains(position)) {
      return false;
    }

    // SKETCHWARE PRO STYLE: Check if widget size fits within the view
    final widgetRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      widgetSize.width,
      widgetSize.height,
    );

    if (!rect.contains(widgetRect.topLeft) ||
        !rect.contains(widgetRect.bottomRight)) {
      return false;
    }

    // SKETCHWARE PRO STYLE: Additional validation based on view type
    return _validateViewTypeForDrop(viewInfo, position, widgetSize);
  }

  /// SKETCHWARE PRO STYLE: Validate view type for drop (like ViewEditor.java)
  bool _validateViewTypeForDrop(
      ViewInfo viewInfo, Offset position, Size widgetSize) {
    final viewType = viewInfo.viewType;

    switch (viewType) {
      case 'LinearLayout':
        // SKETCHWARE PRO STYLE: Linear layouts accept all widgets
        return true;
      case 'RelativeLayout':
        // SKETCHWARE PRO STYLE: Relative layouts accept all widgets
        return true;
      case 'FrameLayout':
        // SKETCHWARE PRO STYLE: Frame layouts accept all widgets
        return true;
      case 'Container':
        // SKETCHWARE PRO STYLE: Containers accept all widgets
        return true;
      default:
        // SKETCHWARE PRO STYLE: Default validation
        return true;
    }
  }

  /// SKETCHWARE PRO STYLE: Set highlight color based on drop zone type
  void _setHighlightColor(ViewInfo viewInfo) {
    switch (viewInfo.viewType) {
      case 'LinearLayout':
        _highlightColor = const Color(0x9599d5d0); // Sketchware Pro green
        break;
      case 'RelativeLayout':
        _highlightColor = const Color(0x9599d5d0); // Sketchware Pro green
        break;
      case 'Container':
        _highlightColor =
            const Color(0x82ff5955); // Sketchware Pro semi-transparent red
        break;
      default:
        _highlightColor = const Color(0x9599d5d0); // Sketchware Pro green
        break;
    }
  }

  /// SKETCHWARE PRO STYLE: Reset view highlight
  void resetViewHighlight() {
    if (_disposed)
      return; // SKETCHWARE PRO STYLE: Prevent disposed service usage
    _currentViewInfo = null;
    _highlightRect = null;
    _isHighlighted = false;
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Add view info with depth mapping (matches ViewPane.java:984)
  void addViewInfo(
    Rect rect,
    Widget view,
    int index,
    int depth, {
    String? parentId,
    String viewType = 'Container',
  }) {
    if (_disposed)
      return; // SKETCHWARE PRO STYLE: Prevent disposed service usage

    final viewInfo = ViewInfo(
      rect: rect,
      view: view,
      index: index,
      depth: depth,
      parentId: parentId,
      viewType: viewType,
    );

    _viewInfos.add(viewInfo);

    // SKETCHWARE PRO STYLE: Add to depth map for priority-based drop zone detection
    if (!_depthMap.containsKey(depth)) {
      _depthMap[depth] = [];
    }
    _depthMap[depth]!.add(viewInfo);

    // Update max depth
    if (depth > _maxDepth) {
      _maxDepth = depth;
    }

    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Clear all view infos
  void clearViewInfos() {
    if (_disposed)
      return; // SKETCHWARE PRO STYLE: Prevent disposed service usage
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
    if (_disposed)
      return; // SKETCHWARE PRO STYLE: Prevent disposed service usage
    _currentDropZone = dropZone;
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Highlight view info
  void highlightViewInfo(ViewInfo? viewInfo) {
    if (_disposed)
      return; // SKETCHWARE PRO STYLE: Prevent disposed service usage
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

  /// SKETCHWARE PRO STYLE: Register widget for real-time updates
  void registerWidgetForUpdates(
      String widgetId, Widget widget, FlutterWidgetBean widgetBean) {
    if (_disposed)
      return; // SKETCHWARE PRO STYLE: Prevent disposed service usage
    _registeredWidgets[widgetId] = widget;
    _registeredWidgetBeans[widgetId] = widgetBean;
  }

  /// SKETCHWARE PRO STYLE: Unregister widget
  void unregisterWidget(String widgetId) {
    _registeredWidgets.remove(widgetId);
    _registeredWidgetBeans.remove(widgetId);
  }

  /// SKETCHWARE PRO STYLE: Get registered widget
  Widget? getRegisteredWidget(String widgetId) {
    return _registeredWidgets[widgetId];
  }

  /// SKETCHWARE PRO STYLE: Get registered widget bean
  FlutterWidgetBean? getRegisteredWidgetBean(String widgetId) {
    return _registeredWidgetBeans[widgetId];
  }

  /// SKETCHWARE PRO STYLE: Clear all registered widgets (for project navigation)
  void clearAllRegisteredWidgets() {
    if (_disposed)
      return; // SKETCHWARE PRO STYLE: Prevent disposed service usage
    _registeredWidgets.clear();
    _registeredWidgetBeans.clear();
    _viewInfos.clear();
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Reset service for tab switching
  void resetForTabSwitch() {
    _disposed = false;
    clearAllRegisteredWidgets();
  }

  /// SKETCHWARE PRO STYLE: Update widget in real-time
  Widget? updateWidget(String widgetId, FlutterWidgetBean updatedWidgetBean) {
    final widget = _registeredWidgets[widgetId];
    if (widget == null) return null;

    // Update the widget bean
    _registeredWidgetBeans[widgetId] = updatedWidgetBean;

    // Create updated widget using factory service
    return WidgetFactoryService.createWidget(
      updatedWidgetBean,
      scale: _widgetScale,
    );
  }

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      _viewInfos.clear();
      _registeredWidgets.clear();
      _registeredWidgetBeans.clear();
      super.dispose();
    }
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
