import 'package:flutter/material.dart';
import 'dart:async';
import '../models/flutter_widget_bean.dart';

/// Mobile Frame Touch Controller - EXACTLY matches Sketchware Pro's ViewEditor touch handling
/// Handles simple touch interactions for mobile frame widgets (like ViewEditor.java:276)
class MobileFrameTouchController extends ChangeNotifier {
  // SKETCHWARE PRO STYLE STATE VARIABLES
  bool _isLongPressDetected = false;
  bool _isDragging = false;
  bool _isTouchActive = false;
  FlutterWidgetBean? _touchedWidget;
  Offset? _touchStartPosition;
  Offset? _currentTouchPosition;
  GlobalKey? _touchedWidgetKey;

  // SKETCHWARE PRO STYLE TOUCH VARIABLES (like ViewEditor.java:276)
  bool _t = false; // isDragging flag
  double _u = 0; // startX
  double _v = 0; // startY
  double _scaledTouchSlop = 8.0; // matches Android's scaledTouchSlop

  // SKETCHWARE PRO STYLE TIMING (like ViewEditor.java:304)
  static const Duration _longPressTimeout = Duration(
      milliseconds: 400); // ViewConfiguration.getLongPressTimeout() / 2
  Timer? _longPressTimer;
  bool _isLongPressScheduled = false;

  // SKETCHWARE PRO STYLE CALLBACKS
  Function(FlutterWidgetBean)? onWidgetSelected;
  Function(FlutterWidgetBean, Offset)? onWidgetDragStart;
  Function(FlutterWidgetBean, Offset)? onWidgetDragUpdate;
  Function(FlutterWidgetBean, Offset)? onWidgetDragEnd;
  Function(FlutterWidgetBean)? onWidgetLongPress;
  Function(bool)? onDragStateChanged;

  // Getters
  bool get isLongPressDetected => _isLongPressDetected;
  bool get isDragging => _isDragging;
  bool get isTouchActive => _isTouchActive;
  FlutterWidgetBean? get touchedWidget => _touchedWidget;
  Offset? get touchStartPosition => _touchStartPosition;
  Offset? get currentTouchPosition => _currentTouchPosition;

  /// SKETCHWARE PRO STYLE: Handle touch start (ACTION_DOWN) - like ViewEditor.java:304
  void handleTouchStart(
      FlutterWidgetBean widget, Offset position, GlobalKey? widgetKey) {
    print('🎯 MOBILE FRAME TOUCH START: ${widget.id} at $position');

    // EXACTLY like Sketchware Pro's ACTION_DOWN handling
    _t = false; // Reset dragging flag
    _u = position.dx; // Store start X
    _v = position.dy; // Store start Y
    _touchedWidget = widget;
    _touchedWidgetKey = widgetKey;
    _touchStartPosition = position;
    _currentTouchPosition = position;
    _isTouchActive = true;
    _isLongPressDetected = false;
    _isDragging = false;

    // Check if widget is fixed (like Sketchware Pro)
    if (widget.isFixed) {
      print('🎯 WIDGET IS FIXED: ${widget.id}');
      return;
    }

    // SKETCHWARE PRO STYLE: Schedule long press detection with proper timer management
    _scheduleLongPressDetection(widget);

    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Schedule long press detection (like ViewEditor.java:304)
  void _scheduleLongPressDetection(FlutterWidgetBean widget) {
    _cancelLongPressDetection();
    _isLongPressScheduled = true;
    _longPressTimer = Timer(_longPressTimeout, () {
      if (_isLongPressScheduled && _touchedWidget == widget) {
        _detectLongPress();
      }
    });
  }

  /// SKETCHWARE PRO STYLE: Cancel long press detection (like ViewEditor.java:327)
  void _cancelLongPressDetection() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _isLongPressScheduled = false;
  }

  /// SKETCHWARE PRO STYLE: Handle touch move (ACTION_MOVE) - like ViewEditor.java:315
  void handleTouchMove(Offset position) {
    if (!_isTouchActive || _touchedWidget == null) return;

    _currentTouchPosition = position;

    // SKETCHWARE PRO STYLE: Check if we should start dragging (like ViewEditor.java:315)
    if (!_t) {
      double deltaX = (position.dx - _u).abs();
      double deltaY = (position.dy - _v).abs();

      if (deltaX >= _scaledTouchSlop || deltaY >= _scaledTouchSlop) {
        print('🎯 DRAG START: ${_touchedWidget!.id}');
        _t = true; // Start dragging
        _cancelLongPressDetection(); // Cancel long press

        // SKETCHWARE PRO STYLE: Start drag feedback
        if (onWidgetDragStart != null) {
          onWidgetDragStart!(_touchedWidget!, position);
        }
        if (onDragStateChanged != null) {
          onDragStateChanged!(true);
        }
      }
    }

    // SKETCHWARE PRO STYLE: Handle drag update
    if (_t && _touchedWidget != null) {
      _isDragging = true;
      if (onWidgetDragUpdate != null) {
        onWidgetDragUpdate!(_touchedWidget!, position);
      }
    }

    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Handle touch end (ACTION_UP) - like ViewEditor.java:350
  void handleTouchEnd(Offset position) {
    if (!_isTouchActive || _touchedWidget == null) return;

    print('🎯 MOBILE FRAME TOUCH END: ${_touchedWidget!.id} at $position');

    // SKETCHWARE PRO STYLE: Handle widget selection
    if (_touchedWidget != null && !_isDragging) {
      _handleWidgetSelection();
    }

    // SKETCHWARE PRO STYLE: Handle drag end
    if (_isDragging && _touchedWidget != null && onWidgetDragEnd != null) {
      onWidgetDragEnd!(_touchedWidget!, position);
    }

    // SKETCHWARE PRO STYLE: Reset state
    _resetTouchState();

    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Handle widget tap selection (direct selection)
  void handleWidgetTap(FlutterWidgetBean widget) {
    print('🎯 MOBILE FRAME TOUCH: handleWidgetTap called for ${widget.id}');
    print(
        '🎯 MOBILE FRAME TOUCH: onWidgetSelected callback = ${onWidgetSelected != null ? "SET" : "NULL"}');

    // SKETCHWARE PRO STYLE: Set touched widget and trigger selection
    _touchedWidget = widget;

    // SKETCHWARE PRO STYLE: Simple single selection like Sketchware Pro
    if (onWidgetSelected != null) {
      print('🎯 MOBILE FRAME TOUCH: Calling onWidgetSelected for ${widget.id}');
      onWidgetSelected!(widget);
      print('🎯 MOBILE FRAME TOUCH: onWidgetSelected callback completed');
    } else {
      print(
          '🎯 MOBILE FRAME TOUCH: WARNING - onWidgetSelected callback is NULL!');
    }

    // Reset touch state
    _resetTouchState();
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Handle widget selection (simple single selection)
  void _handleWidgetSelection() {
    print('🎯 MOBILE FRAME TOUCH: _handleWidgetSelection called');
    print('🎯 MOBILE FRAME TOUCH: _touchedWidget = ${_touchedWidget?.id}');

    if (_touchedWidget == null) {
      print('🎯 MOBILE FRAME TOUCH: WARNING - _touchedWidget is null!');
      return;
    }

    print(
        '🎯 MOBILE FRAME TOUCH: onWidgetSelected callback = ${onWidgetSelected != null ? "SET" : "NULL"}');

    // SKETCHWARE PRO STYLE: Simple single selection like Sketchware Pro
    if (onWidgetSelected != null) {
      print(
          '🎯 MOBILE FRAME TOUCH: Calling onWidgetSelected for ${_touchedWidget!.id}');
      onWidgetSelected!(_touchedWidget!);
      print('🎯 MOBILE FRAME TOUCH: onWidgetSelected callback completed');
    } else {
      print(
          '🎯 MOBILE FRAME TOUCH: WARNING - onWidgetSelected callback is NULL!');
    }
  }

  /// SKETCHWARE PRO STYLE: Detect long press (like ViewEditor.java:327)
  void _detectLongPress() {
    if (_touchedWidget == null) return;

    print('🎯 LONG PRESS DETECTED: ${_touchedWidget!.id}');
    _isLongPressDetected = true;

    // SKETCHWARE PRO STYLE: Trigger long press callback
    if (onWidgetLongPress != null) {
      onWidgetLongPress!(_touchedWidget!);
    }

    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Reset touch state (like ViewEditor.java:327)
  void _resetTouchState() {
    _t = false;
    _u = 0;
    _v = 0;
    _touchedWidget = null;
    _touchedWidgetKey = null;
    _touchStartPosition = null;
    _currentTouchPosition = null;
    _isLongPressDetected = false;
    _isDragging = false;
    _cancelLongPressDetection();
  }

  /// SKETCHWARE PRO STYLE: Set callbacks (for backward compatibility)
  void setCallbacks({
    Function(FlutterWidgetBean)? onWidgetSelected,
    Function(FlutterWidgetBean, Offset)? onWidgetDragStart,
    Function(FlutterWidgetBean, Offset)? onWidgetDragUpdate,
    Function(FlutterWidgetBean, Offset)? onWidgetDragEnd,
    Function(FlutterWidgetBean)? onWidgetLongPress,
    Function(bool)? onDragStateChanged,
  }) {
    this.onWidgetSelected = onWidgetSelected;
    this.onWidgetDragStart = onWidgetDragStart;
    this.onWidgetDragUpdate = onWidgetDragUpdate;
    this.onWidgetDragEnd = onWidgetDragEnd;
    this.onWidgetLongPress = onWidgetLongPress;
    this.onDragStateChanged = onDragStateChanged;
  }

  /// SKETCHWARE PRO STYLE: Handle touch cancel (ACTION_CANCEL)
  void handleTouchCancel() {
    print('🎯 MOBILE FRAME TOUCH CANCEL: ${_touchedWidget?.id}');
    _resetTouchState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelLongPressDetection();
    super.dispose();
  }
}
