import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/flutter_widget_bean.dart';
import '../services/widget_factory_service.dart';
import '../controllers/drag_controller.dart';

class WidgetPalette extends StatefulWidget {
  final Function(FlutterWidgetBean) onWidgetSelected;
  final Function(FlutterWidgetBean, Offset) onWidgetDragged;
  final DragController? dragController;
  final bool isVisible;

  const WidgetPalette({
    super.key,
    required this.onWidgetSelected,
    required this.onWidgetDragged,
    this.dragController,
    this.isVisible = true,
  });

  @override
  State<WidgetPalette> createState() => _WidgetPaletteState();
}

class _WidgetPaletteState extends State<WidgetPalette> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          _buildCreateNewWidgetCard(),
          Expanded(
            child: _buildWidgetList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewWidgetCard() {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () => _showCreateWidgetDialog(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 3),
                Text(
                  'Create New Widget',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetList() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Layout'),
          _buildLayoutWidgets(),
          _buildSectionHeader('Widget'),
          _buildWidgetItems(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildLayoutWidgets() {
    return Column(
      children: [
        _buildDraggableWidgetCard('Row', Icons.view_agenda, 'Row'),
        _buildDraggableWidgetCard('Column', Icons.view_column, 'Column'),
        _buildDraggableWidgetCard('Container', Icons.crop_square, 'Container'),
        _buildDraggableWidgetCard('Stack', Icons.layers, 'Stack'),
      ],
    );
  }

  Widget _buildWidgetItems() {
    return Column(
      children: [
        _buildDraggableWidgetCard('Text', Icons.text_fields, 'Text'),
        _buildDraggableWidgetCard('Button', Icons.smart_button, 'Button'),
        _buildDraggableWidgetCard('TextField', Icons.input, 'TextField'),
        _buildDraggableWidgetCard('Icon', Icons.star, 'Icon'),
      ],
    );
  }

  Widget _buildDraggableWidgetCard(String type, IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      child: Draggable<FlutterWidgetBean>(
        data: _createWidgetBean(type, icon, label),
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: Colors.blue.shade600),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
        onDragStarted: () {
          HapticFeedback.mediumImpact();
        },
        onDragEnd: (details) {
          HapticFeedback.lightImpact();
        },
        child: Container(
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  FlutterWidgetBean _createWidgetBean(
      String type, IconData icon, String label) {
    return WidgetFactoryService.createWidgetBean(type);
  }

  void _showCreateWidgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Widget'),
        content: const Text('This will open the widget creation dialog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _addWidget(String type) {
    final widgetBean = _createWidgetBean(type, Icons.widgets, type);
    widget.onWidgetSelected(widgetBean);
  }
}
