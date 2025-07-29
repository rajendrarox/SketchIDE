import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';
import '../services/mobile_frame_widget_factory_service.dart';
import '../controllers/mobile_frame_touch_controller.dart';
import '../services/selection_service.dart';

/// Service for building child widgets with SKETCHWARE PRO STYLE layout-specific handling
/// This replicates ViewPane's child widget creation exactly
class ChildWidgetService {
  /// Get all child widgets for a parent widget (like Sketchware Pro's ViewPane)
  static List<FlutterWidgetBean> getChildWidgets(
      FlutterWidgetBean parentWidget, List<FlutterWidgetBean> allWidgets) {
    return allWidgets
        .where((widget) => widget.parent == parentWidget.id)
        .toList();
  }

  /// Build child widgets for a parent widget with layout-specific rendering
  List<Widget> buildChildWidgets(
    FlutterWidgetBean parentWidget,
    List<FlutterWidgetBean> allWidgets,
    double scale,
    MobileFrameTouchController? touchController,
    SelectionService? selectionService,
    BuildContext context,
  ) {
    final childWidgets = getChildWidgets(parentWidget, allWidgets);

    // SKETCHWARE PRO STYLE: Layout-specific child rendering
    switch (parentWidget.type) {
      case 'Row':
        return _buildRowChildren(
          childWidgets,
          allWidgets,
          scale,
          touchController,
          selectionService,
          context,
        );
      case 'Column':
        return _buildColumnChildren(
          childWidgets,
          allWidgets,
          scale,
          touchController,
          selectionService,
          context,
        );
      case 'Stack':
        return _buildStackChildren(
          childWidgets,
          allWidgets,
          scale,
          touchController,
          selectionService,
          context,
        );
      default:
        return _buildDefaultChildren(
          childWidgets,
          allWidgets,
          scale,
          touchController,
          selectionService,
          context,
        );
    }
  }

  /// Build child widgets for Row layout (like Sketchware Pro's LinearLayout horizontal)
  List<Widget> _buildRowChildren(
    List<FlutterWidgetBean> childWidgets,
    List<FlutterWidgetBean> allWidgets,
    double scale,
    MobileFrameTouchController? touchController,
    SelectionService? selectionService,
    BuildContext context,
  ) {
    final builtWidgets = <Widget>[];

    for (final childWidget in childWidgets) {
      // ANDROID NATIVE: Create frame widget for child
      final frameWidget = MobileFrameWidgetFactoryService.createFrameWidget(
        widgetBean: childWidget,
        scale: scale,
        allWidgets: allWidgets,
        touchController: touchController,
        selectionService: selectionService,
        androidTouchService: null,
        context: context,
      );

      // SKETCHWARE PRO STYLE: Wrap with Row-specific layout
      final weight = childWidget.layout.weight;
      final rowChild = Expanded(
        flex: weight > 0 ? weight.toInt() : 1,
        child: frameWidget,
      );
      builtWidgets.add(rowChild);
    }

    return builtWidgets;
  }

  /// Build child widgets for Column layout (like Sketchware Pro's LinearLayout vertical)
  List<Widget> _buildColumnChildren(
    List<FlutterWidgetBean> childWidgets,
    List<FlutterWidgetBean> allWidgets,
    double scale,
    MobileFrameTouchController? touchController,
    SelectionService? selectionService,
    BuildContext context,
  ) {
    final builtWidgets = <Widget>[];

    for (final childWidget in childWidgets) {
      // ANDROID NATIVE: Create frame widget for child
      final frameWidget = MobileFrameWidgetFactoryService.createFrameWidget(
        widgetBean: childWidget,
        scale: scale,
        allWidgets: allWidgets,
        touchController: touchController,
        selectionService: selectionService,
        androidTouchService: null,
        context: context,
      );

      // SKETCHWARE PRO STYLE: Wrap with Column-specific layout
      final weight = childWidget.layout.weight;
      final columnChild = Flexible(
        flex: weight > 0 ? weight.toInt() : 0,
        child: frameWidget,
      );
      builtWidgets.add(columnChild);
    }

    return builtWidgets;
  }

  /// Build child widgets for Stack layout (like Sketchware Pro's FrameLayout)
  List<Widget> _buildStackChildren(
    List<FlutterWidgetBean> childWidgets,
    List<FlutterWidgetBean> allWidgets,
    double scale,
    MobileFrameTouchController? touchController,
    SelectionService? selectionService,
    BuildContext context,
  ) {
    final builtWidgets = <Widget>[];

    for (final childWidget in childWidgets) {
      // ANDROID NATIVE: Create frame widget for child
      final frameWidget = MobileFrameWidgetFactoryService.createFrameWidget(
        widgetBean: childWidget,
        scale: scale,
        allWidgets: allWidgets,
        touchController: touchController,
        selectionService: selectionService,
        androidTouchService: null,
        context: context,
      );

      // SKETCHWARE PRO STYLE: Wrap with Stack-specific positioning
      final stackChild = Positioned(
        left: childWidget.position.x * scale,
        top: childWidget.position.y * scale,
        child: frameWidget,
      );
      builtWidgets.add(stackChild);
    }

    return builtWidgets;
  }

  /// Build child widgets for default layout (like Sketchware Pro's ViewGroup)
  List<Widget> _buildDefaultChildren(
    List<FlutterWidgetBean> childWidgets,
    List<FlutterWidgetBean> allWidgets,
    double scale,
    MobileFrameTouchController? touchController,
    SelectionService? selectionService,
    BuildContext context,
  ) {
    final builtWidgets = <Widget>[];

    for (final childWidget in childWidgets) {
      // ANDROID NATIVE: Create frame widget for child with Android Native system
      final frameWidget = MobileFrameWidgetFactoryService.createFrameWidget(
        widgetBean: childWidget,
        scale: scale,
        allWidgets: allWidgets,
        touchController: touchController,
        selectionService: selectionService,
        androidTouchService: null, // Will be set by parent
        context: context,
      );
      builtWidgets.add(frameWidget);
    }

    return builtWidgets;
  }
}
