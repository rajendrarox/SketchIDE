import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/flutter_widget_bean.dart';
import '../services/widget_factory_service.dart';
import '../controllers/drag_controller.dart';

/// Widget Palette (Left Sidebar) - EXACTLY matches Sketchware Pro's PaletteWidget
class WidgetPalette extends StatefulWidget {
  final Function(FlutterWidgetBean) onWidgetSelected;
  final Function(FlutterWidgetBean, Offset)
      onWidgetDragged; // Add drag callback
  final DragController? dragController; // Add drag controller
  final bool isVisible;

  const WidgetPalette({
    super.key,
    required this.onWidgetSelected,
    required this.onWidgetDragged, // Add drag callback
    this.dragController, // Add drag controller
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
      width: 120, // EXACTLY 120dp like Sketchware Pro
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
          // Create New Widget Card (like Sketchware Pro)
          _buildCreateNewWidgetCard(),

          // Widget List with Sections
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
          // Layout Section
          _buildSectionHeader('Layout'),
          _buildLayoutWidgets(),

          // Widget Section
          _buildSectionHeader('Widget'),
          _buildWidgetItems(),

          // Bottom padding
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
      margin:
          const EdgeInsets.fromLTRB(4, 2, 4, 2), // SKETCHWARE PRO: 4dp H, 2dp V
      child: Draggable<FlutterWidgetBean>(
        // SKETCHWARE PRO STYLE: Create drag data
        data: _createWidgetBean(type, icon, label),

        // SKETCHWARE PRO STYLE: Drag feedback (shadow/parchayi) - RESTORED
        // This blue feedback follows the finger during drag (like Sketchware Pro)
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(4), // SKETCHWARE PRO: 4dp radius
          child: Container(
            width: 120,
            height: 20, // SKETCHWARE PRO: 20dp height
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
                Icon(icon,
                    size: 14,
                    color: Colors.blue.shade600), // SKETCHWARE PRO: 14dp
                const SizedBox(width: 4), // SKETCHWARE PRO: 4dp spacing
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11, // SKETCHWARE PRO: 11sp
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),

        // SKETCHWARE PRO STYLE: Drag start feedback
        onDragStarted: () {
          print('🎯 DRAG STARTED: $type'); // Debug output
          HapticFeedback.mediumImpact();
        },

        // SKETCHWARE PRO STYLE: Drag end feedback
        onDragEnd: (details) {
          print('🎯 DRAG ENDED: $type at ${details.offset}'); // Debug output
          HapticFeedback.lightImpact();
        },

        // SKETCHWARE PRO STYLE: Child widget - EXACT MATCH (NO TAP BEHAVIOR)
        child: Container(
          height: 20, // SKETCHWARE PRO: Fixed 20dp height
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHigh, // SKETCHWARE PRO: colorSurfaceContainerHigh
            borderRadius:
                BorderRadius.circular(4), // SKETCHWARE PRO: 4dp radius
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                  width:
                      8), // INCREASED: 8dp left margin (shifted right, no overlap)
              Icon(
                icon,
                size: 14, // SKETCHWARE PRO: 14dp icon
                color: Theme.of(context)
                    .colorScheme
                    .onSurface, // SKETCHWARE PRO: colorOnSurface
              ),
              const SizedBox(width: 3), // SKETCHWARE PRO: 3dp marginStart
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11, // SKETCHWARE PRO: 11sp
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface, // SKETCHWARE PRO: colorOnSurface
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(width: 4), // SKETCHWARE PRO: 4dp marginEnd
            ],
          ),
        ),
      ),
    );
  }

  // SKETCHWARE PRO STYLE: Create widget bean for drag using factory service
  FlutterWidgetBean _createWidgetBean(
      String type, IconData icon, String label) {
    // SKETCHWARE PRO STYLE: Use type-based ID generation with existing widgets
    // For now, we'll use the simple ID since we don't have access to existing widgets here
    // The proper ID will be generated when the widget is actually added to the design
    return WidgetFactoryService.createWidgetBean(type);
  }

  // SKETCHWARE PRO STYLE: Get default properties for widget type
  // DEPRECATED: Now using WidgetFactoryService.createWidgetBean() for strongly typed properties
  Map<String, dynamic> _getDefaultProperties(String type) {
    // This method is deprecated - use WidgetFactoryService.createWidgetBean() instead
    return {};
  }

  // SKETCHWARE PRO STYLE: Get default layout for widget type
  // DEPRECATED: Now using WidgetFactoryService.createWidgetBean() for strongly typed properties
  LayoutBean _getDefaultLayout(String type) {
    // This method is deprecated - use WidgetFactoryService.createWidgetBean() instead
    return LayoutBean();
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
              // TODO: Implement custom widget creation
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // SKETCHWARE PRO STYLE: Add widget on tap (restored for potential use)
  void _addWidget(String type) {
    final widgetBean = _createWidgetBean(type, Icons.widgets, type);
    widget.onWidgetSelected(widgetBean);
  }
}
