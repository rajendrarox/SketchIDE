import 'package:flutter/material.dart';

class WidgetPalette extends StatefulWidget {
  const WidgetPalette({super.key});

  @override
  State<WidgetPalette> createState() => _WidgetPaletteState();
}

class _WidgetPaletteState extends State<WidgetPalette> {
  final List<WidgetCategory> _categories = [
    WidgetCategory(
      name: 'Layout',
      icon: Icons.view_column,
      widgets: [
        WidgetItem(
          name: 'Scaffold',
          icon: Icons.view_agenda,
          description: 'Basic app structure',
          widgetType: 'scaffold',
        ),
        WidgetItem(
          name: 'Container',
          icon: Icons.crop_square,
          description: 'Box with padding and margin',
          widgetType: 'container',
        ),
        WidgetItem(
          name: 'Column',
          icon: Icons.view_column,
          description: 'Vertical layout',
          widgetType: 'column',
        ),
        WidgetItem(
          name: 'Row',
          icon: Icons.view_agenda,
          description: 'Horizontal layout',
          widgetType: 'row',
        ),
        WidgetItem(
          name: 'Stack',
          icon: Icons.layers,
          description: 'Overlapping widgets',
          widgetType: 'stack',
        ),
      ],
    ),
    WidgetCategory(
      name: 'Basic',
      icon: Icons.widgets,
      widgets: [
        WidgetItem(
          name: 'Text',
          icon: Icons.text_fields,
          description: 'Display text',
          widgetType: 'text',
        ),
        WidgetItem(
          name: 'Button',
          icon: Icons.smart_button,
          description: 'Clickable button',
          widgetType: 'elevated_button',
        ),
        WidgetItem(
          name: 'Image',
          icon: Icons.image,
          description: 'Display image',
          widgetType: 'image',
        ),
        WidgetItem(
          name: 'Icon',
          icon: Icons.emoji_emotions,
          description: 'Display icon',
          widgetType: 'icon',
        ),
      ],
    ),
    WidgetCategory(
      name: 'Input',
      icon: Icons.input,
      widgets: [
        WidgetItem(
          name: 'Text Field',
          icon: Icons.text_fields,
          description: 'Text input field',
          widgetType: 'text_field',
        ),
        WidgetItem(
          name: 'Checkbox',
          icon: Icons.check_box,
          description: 'Checkbox input',
          widgetType: 'checkbox',
        ),
        WidgetItem(
          name: 'Switch',
          icon: Icons.toggle_on,
          description: 'Toggle switch',
          widgetType: 'switch',
        ),
      ],
    ),
    WidgetCategory(
      name: 'Navigation',
      icon: Icons.navigation,
      widgets: [
        WidgetItem(
          name: 'App Bar',
          icon: Icons.app_registration,
          description: 'Top app bar',
          widgetType: 'app_bar',
        ),
        WidgetItem(
          name: 'Bottom Navigation',
          icon: Icons.navigation,
          description: 'Bottom navigation bar',
          widgetType: 'bottom_navigation_bar',
        ),
        WidgetItem(
          name: 'Drawer',
          icon: Icons.menu,
          description: 'Side navigation drawer',
          widgetType: 'drawer',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.widgets, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          const Text(
            'Widget Palette',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(WidgetCategory category) {
    return ExpansionTile(
      leading: Icon(category.icon, color: Colors.blue.shade700),
      title: Text(
        category.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      children: category.widgets.map((widget) => _buildWidgetItem(widget)).toList(),
    );
  }

  Widget _buildWidgetItem(WidgetItem widget) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onWidgetSelected(widget),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.drag_handle,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onWidgetSelected(WidgetItem widget) {
    // TODO: Implement widget selection and drag functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${widget.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class WidgetCategory {
  final String name;
  final IconData icon;
  final List<WidgetItem> widgets;

  WidgetCategory({
    required this.name,
    required this.icon,
    required this.widgets,
  });
}

class WidgetItem {
  final String name;
  final IconData icon;
  final String description;
  final String widgetType;

  WidgetItem({
    required this.name,
    required this.icon,
    required this.description,
    required this.widgetType,
  });
} 