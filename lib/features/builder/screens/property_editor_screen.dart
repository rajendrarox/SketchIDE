import 'package:flutter/material.dart';
import '../models/widget_data.dart';
import '../models/dart_file_bean.dart';
import '../../../domain/models/project.dart';

class PropertyEditorScreen extends StatefulWidget {
  final WidgetData widget;
  final Project project;
  final DartFileBean file;
  final Function(WidgetData) onPropertyChanged;

  const PropertyEditorScreen({
    super.key,
    required this.widget,
    required this.project,
    required this.file,
    required this.onPropertyChanged,
  });

  @override
  State<PropertyEditorScreen> createState() => _PropertyEditorScreenState();
}

class _PropertyEditorScreenState extends State<PropertyEditorScreen> {
  late WidgetData editedWidget;
  final Map<String, TextEditingController> controllers = {};
  final Map<String, dynamic> originalProperties = {};

  @override
  void initState() {
    super.initState();
    editedWidget = widget.widget.copyWith();
    originalProperties.addAll(widget.widget.properties);
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize controllers for all properties
    for (final entry in editedWidget.properties.entries) {
      controllers[entry.key] = TextEditingController(text: entry.value?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${_getWidgetDisplayName(editedWidget.type)}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: 'Save Changes',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteWidget,
            tooltip: 'Delete Widget',
          ),
        ],
      ),
      body: Column(
        children: [
          // Widget ID Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Widget ID: ${editedWidget.id}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'File: ${widget.file.fileName}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Property Groups
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLayoutProperties(),
                const SizedBox(height: 16),
                _buildContentProperties(),
                const SizedBox(height: 16),
                _buildStyleProperties(),
                const SizedBox(height: 16),
                _buildBehaviorProperties(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutProperties() {
    return _buildPropertyGroup(
      title: 'Layout',
      icon: Icons.view_column,
      children: [
        _buildPropertyField(
          label: 'Width',
          property: 'width',
          hint: 'e.g., 100, match_parent, wrap_content',
          inputType: TextInputType.text,
        ),
        _buildPropertyField(
          label: 'Height',
          property: 'height',
          hint: 'e.g., 100, match_parent, wrap_content',
          inputType: TextInputType.text,
        ),
        _buildPropertyField(
          label: 'Margin',
          property: 'margin',
          hint: 'e.g., 8, 8, 8, 8',
          inputType: TextInputType.text,
        ),
        _buildPropertyField(
          label: 'Padding',
          property: 'padding',
          hint: 'e.g., 8, 8, 8, 8',
          inputType: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildContentProperties() {
    final contentProperties = <Widget>[];

    // Text-specific properties
    if (editedWidget.type == WidgetData.TYPE_TEXT || 
        editedWidget.type == WidgetData.TYPE_BUTTON ||
        editedWidget.type == WidgetData.TYPE_EDITTEXT) {
      contentProperties.add(
        _buildPropertyField(
          label: 'Text',
          property: 'text',
          hint: 'Enter text content',
          inputType: TextInputType.text,
          maxLines: 3,
        ),
      );
    }

    // EditText-specific properties
    if (editedWidget.type == WidgetData.TYPE_EDITTEXT) {
      contentProperties.add(
        _buildPropertyField(
          label: 'Hint Text',
          property: 'hintText',
          hint: 'Enter hint text',
          inputType: TextInputType.text,
        ),
      );
    }

    // Image-specific properties
    if (editedWidget.type == WidgetData.TYPE_IMAGE) {
      contentProperties.add(
        _buildPropertyField(
          label: 'Image Source',
          property: 'src',
          hint: 'e.g., assets/image.png',
          inputType: TextInputType.text,
        ),
      );
    }

    // AppBar-specific properties
    if (editedWidget.type == WidgetData.TYPE_APPBAR) {
      contentProperties.add(
        _buildPropertyField(
          label: 'Title',
          property: 'title',
          hint: 'Enter app bar title',
          inputType: TextInputType.text,
        ),
      );
    }

    if (contentProperties.isEmpty) {
      contentProperties.add(
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No content properties available for this widget type.',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return _buildPropertyGroup(
      title: 'Content',
      icon: Icons.text_fields,
      children: contentProperties,
    );
  }

  Widget _buildStyleProperties() {
    final styleProperties = <Widget>[];

    // Text styling
    if (editedWidget.type == WidgetData.TYPE_TEXT || 
        editedWidget.type == WidgetData.TYPE_BUTTON ||
        editedWidget.type == WidgetData.TYPE_EDITTEXT) {
      styleProperties.addAll([
        _buildPropertyField(
          label: 'Font Size',
          property: 'fontSize',
          hint: 'e.g., 16.0',
          inputType: TextInputType.number,
        ),
        _buildPropertyField(
          label: 'Text Color',
          property: 'color',
          hint: 'e.g., #FF0000, Colors.red',
          inputType: TextInputType.text,
        ),
        _buildPropertyField(
          label: 'Font Weight',
          property: 'fontWeight',
          hint: 'e.g., FontWeight.bold',
          inputType: TextInputType.text,
        ),
      ]);
    }

    // Background color for most widgets
    styleProperties.add(
      _buildPropertyField(
        label: 'Background Color',
        property: 'backgroundColor',
        hint: 'e.g., #FFFFFF, Colors.white',
        inputType: TextInputType.text,
      ),
    );

    // AppBar-specific styling
    if (editedWidget.type == WidgetData.TYPE_APPBAR) {
      styleProperties.add(
        _buildPropertyField(
          label: 'Background Color',
          property: 'backgroundColor',
          hint: 'e.g., Theme.of(context).colorScheme.inversePrimary',
          inputType: TextInputType.text,
        ),
      );
      styleProperties.add(
        _buildPropertyField(
          label: 'Elevation',
          property: 'elevation',
          hint: 'e.g., 4.0',
          inputType: TextInputType.number,
        ),
      );
    }

    return _buildPropertyGroup(
      title: 'Style',
      icon: Icons.palette,
      children: styleProperties,
    );
  }

  Widget _buildBehaviorProperties() {
    final behaviorProperties = <Widget>[];

    // Button-specific properties
    if (editedWidget.type == WidgetData.TYPE_BUTTON) {
      behaviorProperties.add(
        _buildPropertyField(
          label: 'On Pressed',
          property: 'onPressed',
          hint: 'e.g., () {}',
          inputType: TextInputType.text,
        ),
      );
    }

    // Checkbox/Switch properties
    if (editedWidget.type == WidgetData.TYPE_CHECKBOX || 
        editedWidget.type == WidgetData.TYPE_SWITCH) {
      behaviorProperties.add(
        _buildPropertyField(
          label: 'On Changed',
          property: 'onChanged',
          hint: 'e.g., (value) {}',
          inputType: TextInputType.text,
        ),
      );
    }

    // Progress bar properties
    if (editedWidget.type == WidgetData.TYPE_PROGRESSBAR) {
      behaviorProperties.add(
        _buildPropertyField(
          label: 'Value',
          property: 'value',
          hint: 'e.g., 0.5',
          inputType: TextInputType.number,
        ),
      );
    }

    if (behaviorProperties.isEmpty) {
      behaviorProperties.add(
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No behavior properties available for this widget type.',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return _buildPropertyGroup(
      title: 'Behavior',
      icon: Icons.touch_app,
      children: behaviorProperties,
    );
  }

  Widget _buildPropertyGroup({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyField({
    required String label,
    required String property,
    required String hint,
    required TextInputType inputType,
    int maxLines = 1,
  }) {
    final controller = controllers[property] ?? TextEditingController();
    controllers[property] = controller;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: inputType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
            ),
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  editedWidget.properties.remove(property);
                } else {
                  // Try to parse as number if it's a numeric field
                  if (inputType == TextInputType.number) {
                    final numValue = double.tryParse(value);
                    if (numValue != null) {
                      editedWidget.properties[property] = numValue;
                    } else {
                      editedWidget.properties[property] = value;
                    }
                  } else {
                    editedWidget.properties[property] = value;
                  }
                }
              });
            },
          ),
        ],
      ),
    );
  }

  String _getWidgetDisplayName(String type) {
    switch (type) {
      case WidgetData.TYPE_TEXT:
        return 'Text';
      case WidgetData.TYPE_BUTTON:
        return 'Button';
      case WidgetData.TYPE_EDITTEXT:
        return 'EditText';
      case WidgetData.TYPE_IMAGE:
        return 'Image';
      case WidgetData.TYPE_CHECKBOX:
        return 'CheckBox';
      case WidgetData.TYPE_SWITCH:
        return 'Switch';
      case WidgetData.TYPE_PROGRESSBAR:
        return 'ProgressBar';
      case WidgetData.TYPE_APPBAR:
        return 'AppBar';
      case WidgetData.TYPE_CENTER:
        return 'Center';
      case WidgetData.TYPE_COLUMN:
        return 'Column';
      case WidgetData.TYPE_ROW:
        return 'Row';
      case WidgetData.TYPE_STACK:
        return 'Stack';
      default:
        return 'Widget';
    }
  }

  void _saveChanges() {
    // Check if any properties have changed
    bool hasChanges = false;
    for (final entry in editedWidget.properties.entries) {
      if (originalProperties[entry.key] != entry.value) {
        hasChanges = true;
        break;
      }
    }

    if (hasChanges) {
      widget.onPropertyChanged(editedWidget);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Properties saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }

    Navigator.pop(context);
  }

  void _deleteWidget() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Widget'),
        content: Text('Are you sure you want to delete this ${_getWidgetDisplayName(editedWidget.type)} widget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close property editor
              // TODO: Implement delete callback
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 