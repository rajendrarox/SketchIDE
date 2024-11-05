import 'package:flutter/material.dart';
import 'linear_h_widget.dart';
import 'linear_v_widget.dart';

class WidgetFactory {
  static List<Draggable<String>> getDraggableWidgets() {
    return [
      Draggable<String>(
        data: 'LinearH',
        feedback: LinearHWidget(),
        childWhenDragging: Container(),
        child: LinearHWidget(),
      ),
      Draggable<String>(
        data: 'LinearV',
        feedback: LinearVWidget(),
        childWhenDragging: Container(),
        child: LinearVWidget(),
      ),
      // Add more draggable widgets here
    ];
  }
}
