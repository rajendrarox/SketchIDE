import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';

/// Selection Service - EXACTLY matches Sketchware Pro's selection system
/// Handles single widget selection with visual feedback (like ViewEditor.java:1047)
class SelectionService extends ChangeNotifier {
  // SKETCHWARE PRO STYLE SELECTION STATE (like ViewEditor.java:89)
  FlutterWidgetBean? _selectedWidget; // Like 'sy H' in Sketchware Pro

  // SKETCHWARE PRO STYLE SELECTION COLORS
  static const Color _selectionColor =
      Color(0x9599d5d0); // Sketchware Pro selection color
  static const Color _selectionBorderColor = Color(0x9599d5d0);
  static const double _selectionBorderWidth = 2.0;

  // Getters (like Sketchware Pro)
  FlutterWidgetBean? get selectedWidget => _selectedWidget;
  bool get hasSelection => _selectedWidget != null;

  /// SKETCHWARE PRO STYLE: Select single widget (like ViewEditor.java:1047)
  void selectWidget(FlutterWidgetBean widget) {
    print('🎯 SELECTION: Single widget ${widget.id}');

    // Clear previous selection (like Sketchware Pro)
    _clearSelection();

    // Set new selection (like Sketchware Pro)
    _selectedWidget = widget;

    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Clear selection (like ViewEditor.java:1047)
  void clearSelection() {
    _clearSelection();
    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Clear selection internally
  void _clearSelection() {
    _selectedWidget = null;
  }

  /// SKETCHWARE PRO STYLE: Get selection color for widget
  Color getSelectionColor(FlutterWidgetBean widget) {
    if (_selectedWidget == widget) {
      return _selectionColor;
    }
    return Colors.transparent;
  }

  /// SKETCHWARE PRO STYLE: Get selection border color for widget
  Color getSelectionBorderColor(FlutterWidgetBean widget) {
    if (_selectedWidget == widget) {
      return _selectionBorderColor;
    }
    return Colors.transparent;
  }

  /// SKETCHWARE PRO STYLE: Get selection border width for widget
  double getSelectionBorderWidth(FlutterWidgetBean widget) {
    if (_selectedWidget == widget) {
      return _selectionBorderWidth;
    }
    return 0.0;
  }

  /// SKETCHWARE PRO STYLE: Check if widget is selected (for backward compatibility)
  bool isWidgetSelected(FlutterWidgetBean widget) {
    return _selectedWidget == widget;
  }

  @override
  void dispose() {
    _clearSelection();
    super.dispose();
  }
}
