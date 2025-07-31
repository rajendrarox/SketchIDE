import 'flutter_widget_bean.dart';

abstract class SketchideItemInterface {
  FlutterWidgetBean getBean();

  void setBean(FlutterWidgetBean viewBean);

  bool getFixed();

  void setFixed(bool fixed);

  void setSelection(bool selection);

  bool getSelection();
}
