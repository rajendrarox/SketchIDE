import 'package:flutter/material.dart';
import 'dart:math' as math;

class DraggableWidgetPalette extends StatefulWidget {
  final Function(WidgetData) onWidgetDragStarted;
  final Function(WidgetData) onWidgetSelected;

  const DraggableWidgetPalette({
    super.key,
    required this.onWidgetDragStarted,
    required this.onWidgetSelected,
  });

  @override
  State<DraggableWidgetPalette> createState() => _DraggableWidgetPaletteState();
}

class _DraggableWidgetPaletteState extends State<DraggableWidgetPalette> {
  final List<WidgetCategory> _categories = [
    WidgetCategory(
      name: 'Layouts',
      icon: Icons.view_column,
      widgets: [
        WidgetData(
          id: 'column',
          name: 'Column',
          icon: Icons.view_column,
          description: 'Vertical layout',
          type: 'column',
          defaultProperties: {
            'mainAxisAlignment': 'MainAxisAlignment.start',
            'crossAxisAlignment': 'CrossAxisAlignment.center',
            'children': [],
          },
        ),
        WidgetData(
          id: 'row',
          name: 'Row',
          icon: Icons.view_agenda,
          description: 'Horizontal layout',
          type: 'row',
          defaultProperties: {
            'mainAxisAlignment': 'MainAxisAlignment.start',
            'crossAxisAlignment': 'CrossAxisAlignment.center',
            'children': [],
          },
        ),
        WidgetData(
          id: 'stack',
          name: 'Stack',
          icon: Icons.layers,
          description: 'Overlapping widgets',
          type: 'stack',
          defaultProperties: {
            'alignment': 'Alignment.topLeft',
            'children': [],
          },
        ),
        WidgetData(
          id: 'center',
          name: 'Center',
          icon: Icons.center_focus_strong,
          description: 'Center its child',
          type: 'center',
          defaultProperties: {
            'child': null,
          },
        ),
      ],
    ),
    WidgetCategory(
      name: 'Widgets',
      icon: Icons.widgets,
      widgets: [
        WidgetData(
          id: 'text',
          name: 'TextView',
          icon: Icons.text_fields,
          description: 'Display text',
          type: 'text',
          defaultProperties: {
            'text': 'Hello World',
            'fontSize': 16.0,
            'color': '#000000',
            'fontWeight': 'FontWeight.normal',
            'textAlign': 'TextAlign.left',
          },
        ),
        WidgetData(
          id: 'button',
          name: 'Button',
          icon: Icons.smart_button,
          description: 'Clickable button',
          type: 'button',
          defaultProperties: {
            'text': 'Button',
            'onPressed': '() {}',
            'backgroundColor': '#2196F3',
            'foregroundColor': '#FFFFFF',
          },
        ),
        WidgetData(
          id: 'edit_text',
          name: 'EditText',
          icon: Icons.edit,
          description: 'Text input field',
          type: 'edit_text',
          defaultProperties: {
            'hintText': 'Enter text...',
            'controller': null,
            'decoration': true,
            'border': true,
          },
        ),
        WidgetData(
          id: 'image_view',
          name: 'ImageView',
          icon: Icons.image,
          description: 'Display image',
          type: 'image_view',
          defaultProperties: {
            'src': 'assets/image.png',
            'width': 100.0,
            'height': 100.0,
            'fit': 'BoxFit.cover',
          },
        ),
        WidgetData(
          id: 'checkbox',
          name: 'CheckBox',
          icon: Icons.check_box,
          description: 'Checkbox input',
          type: 'checkbox',
          defaultProperties: {
            'value': false,
            'onChanged': '(value) {}',
            'title': 'Checkbox',
          },
        ),
        WidgetData(
          id: 'switch',
          name: 'Switch',
          icon: Icons.toggle_on,
          description: 'Toggle switch',
          type: 'switch',
          defaultProperties: {
            'value': false,
            'onChanged': '(value) {}',
            'title': 'Switch',
          },
        ),
        WidgetData(
          id: 'progress_bar',
          name: 'ProgressBar',
          icon: Icons.linear_scale,
          description: 'Progress indicator',
          type: 'progress_bar',
          defaultProperties: {
            'value': 0.5,
            'backgroundColor': '#E0E0E0',
            'valueColor': '#2196F3',
          },
        ),
        WidgetData(
          id: 'appbar',
          name: 'AppBar',
          icon: Icons.apps,
          description: 'Top app bar',
          type: 'appbar',
          defaultProperties: {
            'title': 'App Title',
            'backgroundColor': 'Theme.of(context).colorScheme.inversePrimary',
            'elevation': 4.0,
          },
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return _buildCategory(_categories[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: const Text(
        'Widgets',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildCategory(WidgetCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            category.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ),
        ...category.widgets.map((widget) => _buildDraggableWidget(widget)).toList(),
      ],
    );
  }

  Widget _buildDraggableWidget(WidgetData widget) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Draggable<WidgetData>(
        data: widget,
        feedback: _buildDragFeedback(widget),
        childWhenDragging: _buildWidgetItem(widget, isDragging: true),
        onDragStarted: () {
          this.widget.onWidgetDragStarted(widget);
        },
        child: _buildWidgetItem(widget, isDragging: false),
      ),
    );
  }

  Widget _buildWidgetItem(WidgetData widget, {required bool isDragging}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => this.widget.onWidgetSelected(widget),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
              color: isDragging ? Colors.grey.shade100 : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 14,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragFeedback(WidgetData widget) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade300, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 16,
              color: Colors.blue.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              widget.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetCategory {
  final String name;
  final IconData icon;
  final List<WidgetData> widgets;

  WidgetCategory({
    required this.name,
    required this.icon,
    required this.widgets,
  });
}

class WidgetData {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final String type;
  final Map<String, dynamic> defaultProperties;

  WidgetData({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.type,
    required this.defaultProperties,
  });

  WidgetData copyWith({
    String? id,
    String? name,
    IconData? icon,
    String? description,
    String? type,
    Map<String, dynamic>? defaultProperties,
  }) {
    return WidgetData(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      type: type ?? this.type,
      defaultProperties: defaultProperties ?? this.defaultProperties,
    );
  }
} 