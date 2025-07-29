import 'flutter_widget_bean.dart';

/// SKETCHWARE PRO STYLE: Interface that matches the 'sy' interface from Sketchware Pro
/// This interface is implemented by all Item* classes in Sketchware Pro
abstract class SketchwareItemInterface {
  /// SKETCHWARE PRO STYLE: Get the widget bean (matches sy.getBean())
  FlutterWidgetBean getBean();

  /// SKETCHWARE PRO STYLE: Set the widget bean (matches sy.setBean())
  void setBean(FlutterWidgetBean viewBean);

  /// SKETCHWARE PRO STYLE: Get fixed status (matches sy.getFixed())
  bool getFixed();

  /// SKETCHWARE PRO STYLE: Set fixed status (matches sy.setFixed())
  void setFixed(bool fixed);

  /// SKETCHWARE PRO STYLE: Set selection status (matches sy.setSelection())
  void setSelection(bool selection);

  /// SKETCHWARE PRO STYLE: Get selection status (matches Item*.getSelection())
  bool getSelection();
}
