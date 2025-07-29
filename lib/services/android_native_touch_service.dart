import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/flutter_widget_bean.dart';

/// ANDROID NATIVE TOUCH REPLICATION SERVICE
///
/// This service replicates Android's OnTouchListener behavior exactly
/// using Flutter's low-level Listener widget instead of GestureDetector
class AndroidNativeTouchService extends ChangeNotifier {
  // EXACT ANDROID CONSTANTS (from ViewConfiguration)
  static const double TOUCH_SLOP = 8.0; // Android's default touch slop
  static const int LONG_PRESS_TIMEOUT = 500; // Android's long press timeout
  static const int TAP_TIMEOUT = 300; // Android's tap timeout (increased for better detection)

  // ANDROID-STYLE TOUCH STATE VARIABLES (like ViewEditor.java)
  bool _isPressed = false;
  double _downX = 0;
  double _downY = 0;
  DateTime? _downTime;
  FlutterWidgetBean? _touchedWidget;

  // ANDROID-STYLE MOTION EVENT ACTIONS
  static const int ACTION_DOWN = 0;
  static const int ACTION_MOVE = 1;
  static const int ACTION_UP = 2;
  static const int ACTION_CANCEL = 3;

  /// EXACT ANDROID ONTOUCH REPLICATION
  /// This mimics Android's MotionEvent handling exactly
  bool handleMotionEvent(
      int action, double x, double y, FlutterWidgetBean? widget) {
    print('🎯 ANDROID TOUCH: Action=$action, X=$x, Y=$y, Widget=${widget?.id}');

    switch (action) {
      case ACTION_DOWN:
        return _handleActionDown(x, y, widget);

      case ACTION_MOVE:
        return _handleActionMove(x, y);

      case ACTION_UP:
        return _handleActionUp(x, y);

      case ACTION_CANCEL:
        return _handleActionCancel();

      default:
        return false;
    }
  }

  /// ANDROID ACTION_DOWN (exact replication of ViewEditor.java:290)
  bool _handleActionDown(double x, double y, FlutterWidgetBean? widget) {
    _isPressed = true;
    _downX = x;
    _downY = y;
    _downTime = DateTime.now();
    _touchedWidget = widget;

    // ANDROID STYLE: Haptic feedback on touch down
    HapticFeedback.lightImpact();

    print('🎯 ANDROID DOWN: Widget=${widget?.id}, Pos=($x, $y)');
    return true;
  }

  /// ANDROID ACTION_MOVE (exact replication of ViewEditor.java:327)
  bool _handleActionMove(double x, double y) {
    if (!_isPressed) return false;

    // ANDROID STYLE: Check touch slop like ViewEditor.java
    double deltaX = (x - _downX).abs();
    double deltaY = (y - _downY).abs();

    if (deltaX > TOUCH_SLOP || deltaY > TOUCH_SLOP) {
      print('🎯 ANDROID MOVE: Movement detected, canceling tap');
      return _handleActionCancel();
    }

    return true;
  }

  /// ANDROID ACTION_UP (exact replication of ViewEditor.java:350)
  bool _handleActionUp(double x, double y) {
    if (!_isPressed) return false;

    DateTime now = DateTime.now();
    int duration = now.difference(_downTime!).inMilliseconds;

    // ANDROID STYLE: Check touch slop and duration
    double deltaX = (x - _downX).abs();
    double deltaY = (y - _downY).abs();

    print(
        '🎯 ANDROID UP: Duration=${duration}ms, Delta=($deltaX, $deltaY), Widget=${_touchedWidget?.id}');

    if (duration >= LONG_PRESS_TIMEOUT) {
      print(
          '🎯 ANDROID LONG PRESS: Long press detected (${duration}ms) for ${_touchedWidget?.id}');
      _handleLongPress();
    } else if (deltaX < TOUCH_SLOP && deltaY < TOUCH_SLOP) {
      // ANDROID STYLE: Any UP within touch slop and before long press = TAP
      print(
          '🎯 ANDROID TAP: Valid tap detected (${duration}ms) for ${_touchedWidget?.id}');
      _handleTap();
    } else {
      print(
          '🎯 ANDROID: Movement too large, not a tap (Delta: $deltaX, $deltaY)');
    }

    return _handleActionCancel();
  }

  /// ANDROID ACTION_CANCEL
  bool _handleActionCancel() {
    _isPressed = false;
    _downX = 0;
    _downY = 0;
    _downTime = null;
    _touchedWidget = null;

    notifyListeners();
    return true;
  }

  /// ANDROID STYLE TAP HANDLING
  void _handleTap() {
    if (_touchedWidget != null) {
      print('🎯 ANDROID TAP CONFIRMED: ${_touchedWidget!.id}');
      print('🎯 CALLBACK CHECK: onWidgetTapped = ${onWidgetTapped != null ? "SET" : "NULL"}');
      
      // Trigger selection callback exactly like Android
      if (onWidgetTapped != null) {
        print('🎯 CALLING CALLBACK: onWidgetTapped for ${_touchedWidget!.id}');
        onWidgetTapped!.call(_touchedWidget!);
        print('🎯 CALLBACK CALLED: onWidgetTapped completed');
      } else {
        print('🎯 ERROR: onWidgetTapped callback is NULL - widget tap will not work!');
      }
    } else {
      print('🎯 ERROR: _touchedWidget is NULL - no widget to tap!');
    }
  }

  /// ANDROID STYLE LONG PRESS HANDLING
  void _handleLongPress() {
    if (_touchedWidget != null) {
      print('🎯 ANDROID LONG PRESS CONFIRMED: ${_touchedWidget!.id}');
      // Trigger drag start exactly like Android
      onWidgetLongPressed?.call(_touchedWidget!);
    }
  }

  // CALLBACKS (like Android listeners)
  Function(FlutterWidgetBean)? onWidgetTapped;
  Function(FlutterWidgetBean)? onWidgetLongPressed;
}

/// ANDROID NATIVE TOUCH WIDGET
///
/// This widget uses Listener instead of GestureDetector to get raw touch events
/// exactly like Android's onTouchListener
class AndroidNativeTouchWidget extends StatefulWidget {
  final FlutterWidgetBean widgetBean;
  final Widget child;
  final AndroidNativeTouchService touchService;

  const AndroidNativeTouchWidget({
    super.key,
    required this.widgetBean,
    required this.child,
    required this.touchService,
  });

  @override
  State<AndroidNativeTouchWidget> createState() =>
      _AndroidNativeTouchWidgetState();
}

class _AndroidNativeTouchWidgetState extends State<AndroidNativeTouchWidget> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      // ANDROID STYLE: Raw pointer events (lower level than GestureDetector)
      onPointerDown: (PointerDownEvent event) {
        widget.touchService.handleMotionEvent(
          AndroidNativeTouchService.ACTION_DOWN,
          event.localPosition.dx,
          event.localPosition.dy,
          widget.widgetBean,
        );
      },

      onPointerMove: (PointerMoveEvent event) {
        widget.touchService.handleMotionEvent(
          AndroidNativeTouchService.ACTION_MOVE,
          event.localPosition.dx,
          event.localPosition.dy,
          widget.widgetBean,
        );
      },

      onPointerUp: (PointerUpEvent event) {
        widget.touchService.handleMotionEvent(
          AndroidNativeTouchService.ACTION_UP,
          event.localPosition.dx,
          event.localPosition.dy,
          widget.widgetBean,
        );
      },

      onPointerCancel: (PointerCancelEvent event) {
        widget.touchService.handleMotionEvent(
          AndroidNativeTouchService.ACTION_CANCEL,
          event.localPosition.dx,
          event.localPosition.dy,
          widget.widgetBean,
        );
      },

      child: widget.child,
    );
  }
}
