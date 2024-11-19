import 'package:flutter/material.dart';
import 'package:sketchide/ui/widgets/widgets_view/my_widgets/item_widget_view.dart';

class BuildScreenLibrary extends StatelessWidget {
  const BuildScreenLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Management & Other'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ItemWidgetView(
              icon: Icons.toll_outlined,
              iconColor: Colors.blue,
              statusText: 'Off',
              title: 'StatefulWidget',
              subtitle: 'For dynamic, changeable UI that responds to events.',
              onTap: () {
                // Action for StatefulWidget
              },
            ),
          ],
        ),
      ),
    );
  }
}
