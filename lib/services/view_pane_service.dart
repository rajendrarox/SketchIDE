import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';
import 'widget_update_service.dart';

/// ViewPane Service - EXACTLY matches Sketchware Pro's ViewPane functionality
/// Handles real-time widget updates in the mobile frame
class ViewPaneService {
  final WidgetUpdateService _widgetUpdateService = WidgetUpdateService();

  // Widget registry for real-time updates
  final Map<String, Widget> _widgetRegistry = {};
  final Map<String, FlutterWidgetBean> _widgetBeans = {};

  /// Register a widget for real-time updates
  void registerWidget(
      String widgetId, Widget widget, FlutterWidgetBean widgetBean) {
    _widgetRegistry[widgetId] = widget;
    _widgetBeans[widgetId] = widgetBean;
  }

  /// Unregister a widget
  void unregisterWidget(String widgetId) {
    _widgetRegistry.remove(widgetId);
    _widgetBeans.remove(widgetId);
  }

  /// Update widget in real-time (like Sketchware Pro's g(ViewBean) method)
  Widget? updateWidget(String widgetId, FlutterWidgetBean updatedWidgetBean) {
    final widget = _widgetRegistry[widgetId];
    if (widget == null) return null;

    // Update the widget bean
    _widgetBeans[widgetId] = updatedWidgetBean;

    // Update the widget based on its type
    return _widgetUpdateService.updateWidget(widget, updatedWidgetBean);
  }

  /// Update widget layout properties (like Sketchware Pro's updateLayout method)
  Widget? updateWidgetLayout(
      String widgetId, FlutterWidgetBean updatedWidgetBean) {
    final widget = _widgetRegistry[widgetId];
    if (widget == null) return null;

    return _widgetUpdateService.updateLayout(widget, updatedWidgetBean);
  }

  /// Update text widget properties (like Sketchware Pro's updateTextView method)
  Widget? updateTextWidget(
      String widgetId, FlutterWidgetBean updatedWidgetBean) {
    final widget = _widgetRegistry[widgetId];
    if (widget == null) return null;

    return _widgetUpdateService.updateTextWidget(widget, updatedWidgetBean);
  }

  /// Update container widget properties
  Widget? updateContainerWidget(
      String widgetId, FlutterWidgetBean updatedWidgetBean) {
    final widget = _widgetRegistry[widgetId];
    if (widget == null) return null;

    return _widgetUpdateService.updateContainerWidget(
        widget, updatedWidgetBean);
  }

  /// Update icon widget properties
  Widget? updateIconWidget(
      String widgetId, FlutterWidgetBean updatedWidgetBean) {
    final widget = _widgetRegistry[widgetId];
    if (widget == null) return null;

    return _widgetUpdateService.updateIconWidget(widget, updatedWidgetBean);
  }

  /// Get current widget bean
  FlutterWidgetBean? getWidgetBean(String widgetId) {
    return _widgetBeans[widgetId];
  }

  /// Clear all registered widgets
  void clearWidgets() {
    _widgetRegistry.clear();
    _widgetBeans.clear();
  }

  /// Get all registered widget IDs
  List<String> getRegisteredWidgetIds() {
    return _widgetRegistry.keys.toList();
  }
}
