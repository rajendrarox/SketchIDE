import 'package:flutter/material.dart';
import 'mobile_frame.dart';
import '../ui/widgets/widgets_view/widget_factory.dart';

class ViewScreen extends StatelessWidget {
  const ViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1, // Adjusted to a smaller fraction
            child: DraggableWidgets(),
          ),
          Expanded(
            flex: 3, // Increased proportion for MobileFrame for more space
            child: MobileFrame(),
          ),
        ],
      ),
    );
  }
}

class DraggableWidgets extends StatelessWidget {
  const DraggableWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          ...WidgetFactory.getDraggableWidgets(),
        ],
      ),
    );
  }
}
