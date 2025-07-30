import 'package:flutter/material.dart';
import 'dart:async';
import '../models/flutter_widget_bean.dart';


class MobileFrameTouchController extends ChangeNotifier {

  bool _isLongPressDetected = false;
  bool _isDragging = false;
  bool _isTouchActive = false;
  FlutterWidgetBean? _touchedWidget;
  Offset? _touchStartPosition;
  Offset? _currentTouchPosition;
  GlobalKey? _touchedWidgetKey;


  bool _t = false; 
  double _u = 0; 
  double _v = 0; 
  double _scaledTouchSlop = 8.0; 

  static const Duration _longPressTimeout = Duration(
      milliseconds: 400); 
  Timer? _longPressTimer;
  bool _isLongPressScheduled = false;


  Function(FlutterWidgetBean)? onWidgetSelected;
  Function(FlutterWidgetBean, Offset)? onWidgetDragStart;
  Function(FlutterWidgetBean, Offset)? onWidgetDragUpdate;
  Function(FlutterWidgetBean, Offset)? onWidgetDragEnd;
  Function(FlutterWidgetBean)? onWidgetLongPress;
  Function(bool)? onDragStateChanged;


  bool get isLongPressDetected => _isLongPressDetected;
  bool get isDragging => _isDragging;
  bool get isTouchActive => _isTouchActive;
  FlutterWidgetBean? get touchedWidget => _touchedWidget;
  Offset? get touchStartPosition => _touchStartPosition;
  Offset? get currentTouchPosition => _currentTouchPosition;

  void handleTouchStart(
      FlutterWidgetBean widget, Offset position, GlobalKey? widgetKey) {
    print('🎯 MOBILE FRAME TOUCH START: ${widget.id} at $position');


    _t = false; 
    _u = position.dx; 
    _v = position.dy; 
    _touchedWidget = widget;
    _touchedWidgetKey = widgetKey;
    _touchStartPosition = position;
    _currentTouchPosition = position;
    _isTouchActive = true;
    _isLongPressDetected = false;
    _isDragging = false;

    if (widget.isFixed) {
      print('🎯 WIDGET IS FIXED: ${widget.id}');
      return;
    }

    _scheduleLongPressDetection(widget);

    notifyListeners();
  }

  void _scheduleLongPressDetection(FlutterWidgetBean widget) {
    _cancelLongPressDetection();
    _isLongPressScheduled = true;
    _longPressTimer = Timer(_longPressTimeout, () {
      if (_isLongPressScheduled && _touchedWidget == widget) {
        _detectLongPress();
      }
    });
  }

  void _cancelLongPressDetection() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _isLongPressScheduled = false;
  }


  void handleTouchMove(Offset position) {
    if (!_isTouchActive || _touchedWidget == null) return;

    _currentTouchPosition = position;

    if (!_t) {
      double deltaX = (position.dx - _u).abs();
      double deltaY = (position.dy - _v).abs();

      if (deltaX >= _scaledTouchSlop || deltaY >= _scaledTouchSlop) {
        print('🎯 DRAG START: ${_touchedWidget!.id}');
        _t = true; 
        _cancelLongPressDetection(); 


        if (onWidgetDragStart != null) {
          onWidgetDragStart!(_touchedWidget!, position);
        }
        if (onDragStateChanged != null) {
          onDragStateChanged!(true);
        }
      }
    }


    if (_t && _touchedWidget != null) {
      _isDragging = true;
      if (onWidgetDragUpdate != null) {
        onWidgetDragUpdate!(_touchedWidget!, position);
      }
    }

    notifyListeners();
  }


  void handleTouchEnd(Offset position) {
    if (!_isTouchActive || _touchedWidget == null) return;

    print('🎯 MOBILE FRAME TOUCH END: ${_touchedWidget!.id} at $position');


    if (_touchedWidget != null && !_isDragging) {
      _handleWidgetSelection();
    }


    if (_isDragging && _touchedWidget != null && onWidgetDragEnd != null) {
      onWidgetDragEnd!(_touchedWidget!, position);
    }


    _resetTouchState();

    notifyListeners();
  }


  void handleWidgetTap(FlutterWidgetBean widget) {
    print('🎯 MOBILE FRAME TOUCH: handleWidgetTap called for ${widget.id}');
    print(
        '🎯 MOBILE FRAME TOUCH: onWidgetSelected callback = ${onWidgetSelected != null ? "SET" : "NULL"}');

 
    _touchedWidget = widget;


    if (onWidgetSelected != null) {
      print('🎯 MOBILE FRAME TOUCH: Calling onWidgetSelected for ${widget.id}');
      onWidgetSelected!(widget);
      print('🎯 MOBILE FRAME TOUCH: onWidgetSelected callback completed');
    } else {
      print(
          '🎯 MOBILE FRAME TOUCH: WARNING - onWidgetSelected callback is NULL!');
    }


    _resetTouchState();
    notifyListeners();
  }


  void _handleWidgetSelection() {
    print('🎯 MOBILE FRAME TOUCH: _handleWidgetSelection called');
    print('🎯 MOBILE FRAME TOUCH: _touchedWidget = ${_touchedWidget?.id}');

    if (_touchedWidget == null) {
      print('🎯 MOBILE FRAME TOUCH: WARNING - _touchedWidget is null!');
      return;
    }

    print(
        '🎯 MOBILE FRAME TOUCH: onWidgetSelected callback = ${onWidgetSelected != null ? "SET" : "NULL"}');


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


  void _detectLongPress() {
    if (_touchedWidget == null) return;

    print('🎯 LONG PRESS DETECTED: ${_touchedWidget!.id}');
    _isLongPressDetected = true;


    if (onWidgetLongPress != null) {
      onWidgetLongPress!(_touchedWidget!);
    }

    notifyListeners();
  }


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
