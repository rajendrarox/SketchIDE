import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/flutter_widget_bean.dart';
import 'package:flutter/foundation.dart';

class DragController extends ChangeNotifier {
  bool _isDragging = false;
  bool _isLongPressDetected = false;
  FlutterWidgetBean? _draggedWidget;
  Offset? _dragStartPosition;
  Offset? _currentDragPosition;
  GlobalKey? _draggedWidgetKey;

  bool _t = false;
  double _u = 0;
  double _v = 0;
  double _scaledTouchSlop = 8.0;

  static const Duration _longPressTimeout = Duration(milliseconds: 400);
  Timer? _longPressTimer;
  bool _isLongPressScheduled = false;

  bool _isOverDeleteZone = false;
  bool _isOverViewPane = false;
  bool _isOverValidDropZone = false;

  Function(FlutterWidgetBean)? onWidgetMoved;
  Function(FlutterWidgetBean)? onWidgetDeleted;
  Function(FlutterWidgetBean, {Size? containerSize})? onWidgetAdded;
  Function(bool)? onDragStateChanged;
  Function(bool)? onDeleteZoneActive;
  Function(bool)? onViewPaneActive;

  bool get isDragging => _isDragging;
  bool get isLongPressDetected => _isLongPressDetected;
  FlutterWidgetBean? get draggedWidget => _draggedWidget;
  Offset? get dragStartPosition => _dragStartPosition;
  Offset? get currentDragPosition => _currentDragPosition;
  GlobalKey? get draggedWidgetKey => _draggedWidgetKey;
  bool get isOverDeleteZone => _isOverDeleteZone;
  bool get isOverViewPane => _isOverViewPane;
  bool get isOverValidDropZone => _isOverValidDropZone;

  void startDragDetection(
      FlutterWidgetBean widget, Offset position, GlobalKey widgetKey) {
    _t = false;
    _u = position.dx;
    _v = position.dy;
    _draggedWidget = widget;
    _draggedWidgetKey = widgetKey;
    _isLongPressDetected = false;
    _isDragging = false;

    if (widget.isFixed) {
      return;
    }

    _scheduleLongPressDetection(widget);

    notifyListeners();
  }

  void _scheduleLongPressDetection(FlutterWidgetBean widget) {
    _cancelLongPressDetection();
    _isLongPressScheduled = true;

    _longPressTimer = Timer(_longPressTimeout, () {
      if (_draggedWidget == widget && !_isDragging && _isLongPressScheduled) {
        _detectLongPress();
      }
    });
  }

  void _cancelLongPressDetection() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _isLongPressScheduled = false;
  }

  void startDragFromPalette(FlutterWidgetBean widget, Offset position) {
    _draggedWidget = widget;
    _dragStartPosition = position;
    _currentDragPosition = position;
    _draggedWidgetKey = null;
    _isLongPressDetected = false;
    _isDragging = true;

    HapticFeedback.mediumImpact();

    onDragStateChanged?.call(true);
    notifyListeners();
  }

  void updateDragPosition(Offset position) {
    if (_draggedWidget == null) return;

    _currentDragPosition = position;

    if (!_t) {
      final deltaX = (position.dx - _u).abs();
      final deltaY = (position.dy - _v).abs();

      if (deltaX >= _scaledTouchSlop || deltaY >= _scaledTouchSlop) {
        _draggedWidget = null;
        _cancelLongPressDetection();
        _resetDragState();
        return;
      }
      return;
    }

    _updateDropZoneDetection(position);
    notifyListeners();
  }

  void updatePaletteDragPosition(Offset position) {
    if (_draggedWidget == null) return;

    _currentDragPosition = position;
    _updateDropZoneDetection(position);
    notifyListeners();
  }

  void endDrag() {
    if (_t) {
      _handleDrop();
    } else {
      _handleSelection();
    }

    _resetDragState();
    notifyListeners();
  }

  void cancelDrag() {
    _resetDragState();
    notifyListeners();
  }

  void _detectLongPress() {
    if (_draggedWidget == null) return;

    _isLongPressDetected = true;
    _t = true;
    _isDragging = true;

    HapticFeedback.mediumImpact();

    _startDragFeedback();

    onDragStateChanged?.call(true);
    notifyListeners();
  }

  void _startDragFeedback() {}

  void _cancelLongPress() {
    _draggedWidget = null;
    _isLongPressDetected = false;
    _t = false;
    _isDragging = false;
  }

  void _updateDropZoneDetection(Offset position) {
    final wasOverDeleteZone = _isOverDeleteZone;
    _isOverDeleteZone = _isPositionInDeleteZone(position);

    if (_isOverDeleteZone != wasOverDeleteZone) {
      onDeleteZoneActive?.call(_isOverDeleteZone);
    }

    final wasOverViewPane = _isOverViewPane;
    _isOverViewPane = _isPositionInViewPane(position);

    if (_isOverViewPane != wasOverViewPane) {
      onViewPaneActive?.call(_isOverViewPane);
    }

    _isOverValidDropZone = _isOverViewPane || _isOverDeleteZone;
  }

  void _handleDrop() {
    if (_draggedWidget == null || _currentDragPosition == null) return;

    if (_isOverDeleteZone) {
      onWidgetDeleted?.call(_draggedWidget!);
    } else if (_isOverViewPane) {
      final newPosition = _calculateDropPosition(_currentDragPosition!);
      final updatedWidget = _draggedWidget!.copyWith(
        position: _draggedWidget!.position.copyWith(
          x: newPosition.dx,
          y: newPosition.dy,
        ),
      );

      if (_isLongPressDetected) {
        onWidgetMoved?.call(updatedWidget);
      } else {
        onWidgetAdded?.call(updatedWidget);
      }
    }
  }

  void _handleSelection() {
    if (_draggedWidget != null) {}
  }

  void _resetDragState() {
    _isDragging = false;
    _isLongPressDetected = false;
    _draggedWidget = null;
    _dragStartPosition = null;
    _currentDragPosition = null;
    _draggedWidgetKey = null;
    _t = false;
    _u = 0;
    _v = 0;
    _isOverDeleteZone = false;
    _isOverViewPane = false;
    _isOverValidDropZone = false;

    onDragStateChanged?.call(false);
    onDeleteZoneActive?.call(false);
    onViewPaneActive?.call(false);
  }

  bool _isPositionInDeleteZone(Offset position) {
    final screenHeight =
        PlatformDispatcher.instance.views.first.physicalSize.height /
            PlatformDispatcher.instance.views.first.devicePixelRatio;
    return position.dy > screenHeight - 120;
  }

  bool _isPositionInViewPane(Offset position) {
    final screenHeight =
        PlatformDispatcher.instance.views.first.physicalSize.height /
            PlatformDispatcher.instance.views.first.devicePixelRatio;
    return position.dy < screenHeight - 120;
  }

  Offset _calculateDropPosition(Offset position) {
    return position;
  }

  /// Set callbacks
  void setCallbacks({
    Function(FlutterWidgetBean)? onWidgetMoved,
    Function(FlutterWidgetBean)? onWidgetDeleted,
    Function(FlutterWidgetBean, {Size? containerSize})? onWidgetAdded,
    Function(bool)? onDragStateChanged,
    Function(bool)? onDeleteZoneActive,
    Function(bool)? onViewPaneActive,
  }) {
    this.onWidgetMoved = onWidgetMoved;
    this.onWidgetDeleted = onWidgetDeleted;
    this.onWidgetAdded = onWidgetAdded;
    this.onDragStateChanged = onDragStateChanged;
    this.onDeleteZoneActive = onDeleteZoneActive;
    this.onViewPaneActive = onViewPaneActive;
  }

  void updateDeleteZoneBounds(Rect bounds) {}

  void updateViewPaneBounds(Rect bounds) {}
}
