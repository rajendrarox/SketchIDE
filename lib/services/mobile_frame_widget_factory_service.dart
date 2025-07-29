import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';
import '../controllers/mobile_frame_touch_controller.dart';
import '../services/selection_service.dart';
import 'android_native_touch_service.dart';
import 'android_native_measurement_service.dart';
import '../widgets/frame_items/frame_text.dart';
import '../widgets/frame_items/frame_button.dart';
import '../widgets/frame_items/frame_container.dart';
import '../widgets/frame_items/frame_text_field.dart';
import '../widgets/frame_items/frame_icon.dart';
import '../widgets/frame_items/frame_row.dart';
import '../widgets/frame_items/frame_column.dart';
import '../widgets/frame_items/frame_stack.dart';

/// Mobile Frame Widget Factory Service - EXACTLY matches Sketchware Pro's ViewPane.createItemView
/// Creates appropriate mobile frame widget classes based on widget type
class MobileFrameWidgetFactoryService {
  /// ANDROID NATIVE: Create mobile frame widget with Android Native Touch System
  static Widget createFrameWidget({
    required FlutterWidgetBean widgetBean,
    required double scale,
    required List<FlutterWidgetBean> allWidgets,
    MobileFrameTouchController? touchController,
    SelectionService? selectionService,
    AndroidNativeTouchService? androidTouchService,
    required BuildContext context,
  }) {
    print(
        '🏭 ANDROID NATIVE FACTORY: Creating ${widgetBean.type} (${widgetBean.id})');

    // ANDROID NATIVE: Calculate exact measurements using Android's system
    final androidScale =
        AndroidNativeMeasurementService.calculateViewEditorScaling(context);
    final exactScale = scale * androidScale.contentScaleX;

    Widget frameWidget;
    switch (widgetBean.type) {
      case 'Text':
        frameWidget = FrameText(
          widgetBean: widgetBean,
          scale: exactScale,
          touchController: touchController,
          selectionService: selectionService,
        );
        break;

      case 'Button':
        frameWidget = FrameButton(
          widgetBean: widgetBean,
          scale: exactScale,
          touchController: touchController,
          selectionService: selectionService,
        );
        break;

      case 'Container':
        frameWidget = FrameContainer(
          widgetBean: widgetBean,
          scale: exactScale,
          touchController: touchController,
          selectionService: selectionService,
          allWidgets: allWidgets,
        );
        break;

      case 'TextField':
        frameWidget = FrameTextField(
          widgetBean: widgetBean,
          scale: exactScale,
          touchController: touchController,
          selectionService: selectionService,
        );
        break;

      case 'Icon':
        frameWidget = FrameIcon(
          widgetBean: widgetBean,
          scale: exactScale,
          touchController: touchController,
          selectionService: selectionService,
        );
        break;

      case 'Row':
        frameWidget = FrameRow(
          widgetBean: widgetBean,
          scale: exactScale,
          touchController: touchController,
          selectionService: selectionService,
          allWidgets: allWidgets,
        );
        break;

      case 'Column':
        frameWidget = FrameColumn(
          widgetBean: widgetBean,
          scale: exactScale,
          touchController: touchController,
          selectionService: selectionService,
          allWidgets: allWidgets,
        );
        break;

      case 'Stack':
        frameWidget = FrameStack(
          widgetBean: widgetBean,
          scale: exactScale,
          touchController: touchController,
          selectionService: selectionService,
          allWidgets: allWidgets,
        );
        break;

      default:
        print('⚠️ UNKNOWN WIDGET TYPE: ${widgetBean.type}');
        frameWidget = Container(
          width:
              AndroidNativeMeasurementService.convertDpToPixels(context, 100) *
                  exactScale,
          height:
              AndroidNativeMeasurementService.convertDpToPixels(context, 50) *
                  exactScale,
          color: Colors.red,
          child: Center(
            child: Text(
              'Unknown Widget: ${widgetBean.type}',
              style: TextStyle(
                  fontSize: AndroidNativeMeasurementService.convertDpToPixels(
                          context, 10) *
                      exactScale),
            ),
          ),
        );
    }

    // ANDROID NATIVE: Wrap with Android Native Touch System
    if (androidTouchService != null) {
      return AndroidNativeTouchWidget(
        widgetBean: widgetBean,
        touchService: androidTouchService,
        child: frameWidget,
      );
    }

    return frameWidget;
  }

  /// SKETCHWARE PRO STYLE: Create placeholder widget for unsupported types
  static Widget _createPlaceholderWidget(
      FlutterWidgetBean widgetBean, double scale, String type) {
    return Positioned(
      left: widgetBean.position.x * scale,
      top: widgetBean.position.y * scale,
      child: Container(
        width: widgetBean.position.width * scale,
        height: widgetBean.position.height * scale,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.grey[600]!),
          borderRadius: BorderRadius.circular(4 * scale),
        ),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
              fontSize: 10 * scale,
              color: Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  /// SKETCHWARE PRO STYLE: Check if widget type is supported
  static bool isWidgetTypeSupported(String widgetType) {
    const supportedTypes = [
      'Text',
      'Button',
      'Container',
      'TextField',
      'Icon',
      'Row',
      'Column',
      'Stack',
    ];
    return supportedTypes.contains(widgetType);
  }

  /// SKETCHWARE PRO STYLE: Get supported widget types
  static List<String> getSupportedWidgetTypes() {
    return [
      'Text',
      'Button',
      'Container',
      'TextField',
      'Icon',
      'Row',
      'Column',
      'Stack',
    ];
  }

  /// ANDROID NATIVE: Update existing frame widget with Android Native system
  static Widget updateFrameWidget({
    required Widget existingWidget,
    required FlutterWidgetBean updatedWidgetBean,
    required double scale,
    required List<FlutterWidgetBean> allWidgets,
    MobileFrameTouchController? touchController,
    SelectionService? selectionService,
    AndroidNativeTouchService? androidTouchService,
    required BuildContext context,
  }) {
    // ANDROID NATIVE: Recreate widget with updated properties using Android Native system
    return createFrameWidget(
      widgetBean: updatedWidgetBean,
      scale: scale,
      allWidgets: allWidgets,
      touchController: touchController,
      selectionService: selectionService,
      androidTouchService: androidTouchService,
      context: context,
    );
  }

  /// SKETCHWARE PRO STYLE: Get widget display name
  static String getWidgetDisplayName(String widgetType) {
    switch (widgetType) {
      case 'Text':
        return 'Text';
      case 'Button':
        return 'Button';
      case 'Container':
        return 'Container';
      case 'TextField':
        return 'Text Field';
      case 'Icon':
        return 'Icon';
      case 'Row':
        return 'Row';
      case 'Column':
        return 'Column';
      case 'Stack':
        return 'Stack';
      default:
        return widgetType;
    }
  }

  /// SKETCHWARE PRO STYLE: Get widget icon
  static IconData getWidgetIcon(String widgetType) {
    switch (widgetType) {
      case 'Text':
        return Icons.text_fields;
      case 'Button':
        return Icons.smart_button;
      case 'Container':
        return Icons.crop_square;
      case 'TextField':
        return Icons.input;
      case 'Icon':
        return Icons.star;
      case 'Row':
        return Icons.view_column;
      case 'Column':
        return Icons.view_list;
      case 'Stack':
        return Icons.layers;
      default:
        return Icons.widgets;
    }
  }
}
