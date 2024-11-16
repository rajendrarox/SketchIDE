import 'package:flutter/material.dart';
import 'linear_h_widget.dart';
import 'linear_v_widget.dart';

class WidgetFactory {
  static List<Draggable<String>> getDraggableWidgets() {
    return [
      Draggable<String>(
        data: 'LinearH',
        feedback: const LinearHWidget(),
        childWhenDragging: Container(),
        child: const LinearHWidget(),
      ),
      Draggable<String>(
        data: 'LinearV',
        feedback: const LinearVWidget(),
        childWhenDragging: Container(),
        child: const LinearVWidget(),
      ),
      // Add more draggable widgets here
    ];
  }
}
