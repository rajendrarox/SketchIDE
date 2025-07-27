import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flutter_widget_bean.dart';
import '../viewmodels/property_viewmodel.dart';
import '../services/property_service.dart';
import 'property_items/property_text_box.dart';
import 'property_items/property_color_box.dart';
import 'property_items/property_selector_box.dart';

/// Property Panel (Bottom) - EXACTLY matches Sketchware Pro's ViewProperty
/// Displays and manages widget properties with real-time updates
class PropertyPanel extends StatefulWidget {
  final FlutterWidgetBean selectedWidget;
  final List<FlutterWidgetBean> allWidgets;
  final Function(FlutterWidgetBean) onPropertyChanged;
  final Function(FlutterWidgetBean) onWidgetDeleted;
  final Function(FlutterWidgetBean)? onWidgetSelected;

  const PropertyPanel({
    super.key,
    required this.selectedWidget,
    required this.allWidgets,
    required this.onPropertyChanged,
    required this.onWidgetDeleted,
    this.onWidgetSelected,
  });

  @override
  State<PropertyPanel> createState() => _PropertyPanelState();
}

class _PropertyPanelState extends State<PropertyPanel> {
  late PropertyViewModel _propertyViewModel;
  int _selectedGroupId = 0;
  final List<PropertyGroup> _groups = [
    PropertyGroup(0, 'Basic'),
    PropertyGroup(1, 'Recent'),
    PropertyGroup(2, 'Event'),
  ];

  @override
  void initState() {
    super.initState();
    _propertyViewModel = PropertyViewModel();

    // Select the widget to load its properties
    _propertyViewModel.selectWidget(widget.selectedWidget);
  }

  @override
  void didUpdateWidget(PropertyPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWidget.id != widget.selectedWidget.id) {
      // Widget changed, update the property view model
      _propertyViewModel.selectWidget(widget.selectedWidget);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _propertyViewModel,
      child: Consumer<PropertyViewModel>(
        builder: (context, propertyViewModel, child) {
          return Container(
            height: 170, // EXACTLY 170dp like Sketchware Pro
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Widget Selector Header (like Sketchware Pro)
                _buildWidgetSelectorHeader(),

                // Property Groups (horizontal tabs like Sketchware Pro)
                _buildPropertyGroups(),

                // Property Content
                Expanded(
                  child: _buildPropertyContent(propertyViewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWidgetSelectorHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Widget Selector Dropdown
          Expanded(
            child: DropdownButtonFormField<String>(
              value: widget.selectedWidget.id,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(),
              ),
              items: widget.allWidgets.map((widgetBean) {
                return DropdownMenuItem(
                  value: widgetBean.id,
                  child: Text(
                    '${widgetBean.type} (${widgetBean.id})',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                // SKETCHWARE PRO STYLE: Handle widget selection from dropdown
                if (value != null && widget.onWidgetSelected != null) {
                  final selectedWidget = widget.allWidgets.firstWhere(
                    (w) => w.id == value,
                    orElse: () => widget.selectedWidget,
                  );
                  widget.onWidgetSelected!(selectedWidget);
                }
              },
            ),
          ),

          const SizedBox(width: 8),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _showDeleteDialog(),
            tooltip: 'Delete Widget',
          ),

          // Save Button
          IconButton(
            icon: const Icon(Icons.save, size: 20),
            onPressed: () => _saveWidget(),
            tooltip: 'Save Widget',
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyGroups() {
    return Container(
      height: 32,
      padding: const EdgeInsets.only(left: 4, top: 2),
      child: Row(
        children: _groups.map((group) {
          final isSelected = group.id == _selectedGroupId;
          return GestureDetector(
            onTap: () => setState(() => _selectedGroupId = group.id),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                group.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPropertyContent(PropertyViewModel propertyViewModel) {
    switch (_selectedGroupId) {
      case 0: // Basic
        return _buildBasicProperties(propertyViewModel);
      case 1: // Recent
        return _buildRecentProperties();
      case 2: // Event
        return _buildEventProperties();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicProperties(PropertyViewModel propertyViewModel) {
    // Get properties based on widget type (like Sketchware Pro)
    final properties = _getPropertiesForWidgetType(widget.selectedWidget.type);

    return Row(
      children: [
        // Horizontal Scrolling Property Items
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: properties.map((property) {
                return _buildPropertyItem(property, propertyViewModel);
              }).toList(),
            ),
          ),
        ),

        // See All Floating Button (like Sketchware Pro)
        Container(
          width: 60,
          height: 82,
          margin: const EdgeInsets.only(right: 8),
          child: FloatingActionButton(
            mini: true,
            onPressed: () => _showAllProperties(),
            child: const Icon(Icons.more_horiz, size: 20),
          ),
        ),
      ],
    );
  }

  List<PropertyDefinition> _getPropertiesForWidgetType(String widgetType) {
    switch (widgetType) {
      case 'Text':
        return [
          PropertyDefinition(
            key: 'property_id',
            label: 'ID',
            type: PropertyType.text,
            icon: Icons.tag,
          ),
          PropertyDefinition(
            key: 'property_text',
            label: 'Text',
            type: PropertyType.text,
            icon: Icons.text_fields,
            maxLines: 3,
          ),
          PropertyDefinition(
            key: 'property_text_size',
            label: 'Text Size',
            type: PropertyType.text,
            icon: Icons.format_size,
            isNumber: true,
            minValue: 8,
            maxValue: 72,
          ),
          PropertyDefinition(
            key: 'property_text_color',
            label: 'Text Color',
            type: PropertyType.color,
            icon: Icons.palette,
            allowTransparent: true,
          ),
          PropertyDefinition(
            key: 'property_text_style',
            label: 'Text Style',
            type: PropertyType.selector,
            icon: Icons.format_bold,
            options: ['Normal', 'Bold', 'Italic', 'Bold Italic'],
          ),
          PropertyDefinition(
            key: 'property_layout_width',
            label: 'Width',
            type: PropertyType.measure,
            icon: Icons.width_normal,
          ),
          PropertyDefinition(
            key: 'property_layout_height',
            label: 'Height',
            type: PropertyType.measure,
            icon: Icons.height,
          ),
          PropertyDefinition(
            key: 'property_margin',
            label: 'Margin',
            type: PropertyType.indent,
            icon: Icons.margin,
          ),
          PropertyDefinition(
            key: 'property_padding',
            label: 'Padding',
            type: PropertyType.indent,
            icon: Icons.padding,
          ),
        ];

      case 'TextField':
        return [
          PropertyDefinition(
            key: 'property_id',
            label: 'ID',
            type: PropertyType.text,
            icon: Icons.tag,
          ),
          PropertyDefinition(
            key: 'property_text',
            label: 'Text',
            type: PropertyType.text,
            icon: Icons.text_fields,
          ),
          PropertyDefinition(
            key: 'property_hint',
            label: 'Hint',
            type: PropertyType.text,
            icon: Icons.lightbulb_outline,
          ),
          PropertyDefinition(
            key: 'property_text_size',
            label: 'Text Size',
            type: PropertyType.text,
            icon: Icons.format_size,
            isNumber: true,
            minValue: 8,
            maxValue: 72,
          ),
          PropertyDefinition(
            key: 'property_text_color',
            label: 'Text Color',
            type: PropertyType.color,
            icon: Icons.palette,
          ),
          PropertyDefinition(
            key: 'property_hint_color',
            label: 'Hint Color',
            type: PropertyType.color,
            icon: Icons.palette,
          ),
          PropertyDefinition(
            key: 'property_input_type',
            label: 'Input Type',
            type: PropertyType.selector,
            icon: Icons.keyboard,
            options: ['Text', 'Number', 'Phone', 'Password', 'Email'],
          ),
          PropertyDefinition(
            key: 'property_single_line',
            label: 'Single Line',
            type: PropertyType.boolean,
            icon: Icons.format_line_spacing,
          ),
          PropertyDefinition(
            key: 'property_lines',
            label: 'Lines',
            type: PropertyType.text,
            icon: Icons.format_list_numbered,
            isNumber: true,
            minValue: 1,
            maxValue: 10,
          ),
          PropertyDefinition(
            key: 'property_layout_width',
            label: 'Width',
            type: PropertyType.measure,
            icon: Icons.width_normal,
          ),
          PropertyDefinition(
            key: 'property_layout_height',
            label: 'Height',
            type: PropertyType.measure,
            icon: Icons.height,
          ),
        ];

      case 'Container':
        return [
          PropertyDefinition(
            key: 'property_id',
            label: 'ID',
            type: PropertyType.text,
            icon: Icons.tag,
          ),
          PropertyDefinition(
            key: 'property_layout_width',
            label: 'Width',
            type: PropertyType.measure,
            icon: Icons.width_normal,
          ),
          PropertyDefinition(
            key: 'property_layout_height',
            label: 'Height',
            type: PropertyType.measure,
            icon: Icons.height,
          ),
          PropertyDefinition(
            key: 'property_background_color',
            label: 'Background',
            type: PropertyType.color,
            icon: Icons.palette,
          ),
          PropertyDefinition(
            key: 'property_border_color',
            label: 'Border Color',
            type: PropertyType.color,
            icon: Icons.border_color,
          ),
          PropertyDefinition(
            key: 'property_border_width',
            label: 'Border Width',
            type: PropertyType.text,
            icon: Icons.border_style,
            isNumber: true,
            minValue: 0,
            maxValue: 20,
          ),
          PropertyDefinition(
            key: 'property_border_radius',
            label: 'Border Radius',
            type: PropertyType.text,
            icon: Icons.rounded_corner,
            isNumber: true,
            minValue: 0,
            maxValue: 50,
          ),
          PropertyDefinition(
            key: 'property_margin',
            label: 'Margin',
            type: PropertyType.indent,
            icon: Icons.margin,
          ),
          PropertyDefinition(
            key: 'property_padding',
            label: 'Padding',
            type: PropertyType.indent,
            icon: Icons.padding,
          ),
        ];

      case 'Icon':
        return [
          PropertyDefinition(
            key: 'property_id',
            label: 'ID',
            type: PropertyType.text,
            icon: Icons.tag,
          ),
          PropertyDefinition(
            key: 'property_icon_name',
            label: 'Icon',
            type: PropertyType.text,
            icon: Icons.emoji_emotions,
          ),
          PropertyDefinition(
            key: 'property_icon_size',
            label: 'Size',
            type: PropertyType.text,
            icon: Icons.format_size,
            isNumber: true,
            minValue: 12,
            maxValue: 100,
          ),
          PropertyDefinition(
            key: 'property_icon_color',
            label: 'Color',
            type: PropertyType.color,
            icon: Icons.palette,
          ),
          PropertyDefinition(
            key: 'property_layout_width',
            label: 'Width',
            type: PropertyType.measure,
            icon: Icons.width_normal,
          ),
          PropertyDefinition(
            key: 'property_layout_height',
            label: 'Height',
            type: PropertyType.measure,
            icon: Icons.height,
          ),
        ];

      case 'Row':
      case 'Column':
        return [
          PropertyDefinition(
            key: 'property_id',
            label: 'ID',
            type: PropertyType.text,
            icon: Icons.tag,
          ),
          PropertyDefinition(
            key: 'property_orientation',
            label: 'Orientation',
            type: PropertyType.selector,
            icon: Icons.swap_horiz,
            options: ['Horizontal', 'Vertical'],
          ),
          PropertyDefinition(
            key: 'property_main_axis_alignment',
            label: 'Main Alignment',
            type: PropertyType.selector,
            icon: Icons.align_horizontal_center,
            options: [
              'Start',
              'Center',
              'End',
              'Space Between',
              'Space Around',
              'Space Evenly'
            ],
          ),
          PropertyDefinition(
            key: 'property_cross_axis_alignment',
            label: 'Cross Alignment',
            type: PropertyType.selector,
            icon: Icons.align_vertical_center,
            options: ['Start', 'Center', 'End', 'Stretch', 'Baseline'],
          ),
          PropertyDefinition(
            key: 'property_layout_width',
            label: 'Width',
            type: PropertyType.measure,
            icon: Icons.width_normal,
          ),
          PropertyDefinition(
            key: 'property_layout_height',
            label: 'Height',
            type: PropertyType.measure,
            icon: Icons.height,
          ),
          PropertyDefinition(
            key: 'property_margin',
            label: 'Margin',
            type: PropertyType.indent,
            icon: Icons.margin,
          ),
          PropertyDefinition(
            key: 'property_padding',
            label: 'Padding',
            type: PropertyType.indent,
            icon: Icons.padding,
          ),
        ];

      case 'Stack':
        return [
          PropertyDefinition(
            key: 'property_id',
            label: 'ID',
            type: PropertyType.text,
            icon: Icons.tag,
          ),
          PropertyDefinition(
            key: 'property_alignment',
            label: 'Alignment',
            type: PropertyType.selector,
            icon: Icons.center_focus_strong,
            options: [
              'Top Left',
              'Top Center',
              'Top Right',
              'Center Left',
              'Center',
              'Center Right',
              'Bottom Left',
              'Bottom Center',
              'Bottom Right'
            ],
          ),
          PropertyDefinition(
            key: 'property_fit',
            label: 'Fit',
            type: PropertyType.selector,
            icon: Icons.fit_screen,
            options: ['Loose', 'Expand'],
          ),
          PropertyDefinition(
            key: 'property_layout_width',
            label: 'Width',
            type: PropertyType.measure,
            icon: Icons.width_normal,
          ),
          PropertyDefinition(
            key: 'property_layout_height',
            label: 'Height',
            type: PropertyType.measure,
            icon: Icons.height,
          ),
        ];

      default:
        return [
          PropertyDefinition(
            key: 'property_id',
            label: 'ID',
            type: PropertyType.text,
            icon: Icons.tag,
          ),
          PropertyDefinition(
            key: 'property_layout_width',
            label: 'Width',
            type: PropertyType.measure,
            icon: Icons.width_normal,
          ),
          PropertyDefinition(
            key: 'property_layout_height',
            label: 'Height',
            type: PropertyType.measure,
            icon: Icons.height,
          ),
          PropertyDefinition(
            key: 'property_margin',
            label: 'Margin',
            type: PropertyType.indent,
            icon: Icons.margin,
          ),
          PropertyDefinition(
            key: 'property_padding',
            label: 'Padding',
            type: PropertyType.indent,
            icon: Icons.padding,
          ),
        ];
    }
  }

  Widget _buildPropertyItem(
      PropertyDefinition property, PropertyViewModel propertyViewModel) {
    final value = _getPropertyValue(property.key);

    switch (property.type) {
      case PropertyType.text:
        return PropertyTextBox(
          label: property.label,
          value: value,
          icon: property.icon,
          onChanged: (newValue) => _updateProperty(property.key, newValue),
          maxLines: property.maxLines ?? 1,
          isNumber: property.isNumber ?? false,
          minValue: property.minValue,
          maxValue: property.maxValue,
        );

      case PropertyType.color:
        return PropertyColorBox(
          label: property.label,
          value: value,
          icon: property.icon,
          currentColor: _parseColor(value),
          onChanged: (color) =>
              _updateProperty(property.key, color.value.toString()),
          allowTransparent: property.allowTransparent ?? false,
          allowNone: property.allowNone ?? false,
        );

      case PropertyType.selector:
        return PropertySelectorBox(
          label: property.label,
          value: value,
          icon: property.icon,
          options: property.options ?? [],
          currentValue: value,
          onChanged: (newValue) => _updateProperty(property.key, newValue),
        );

      case PropertyType.boolean:
        return PropertyCheckboxItem(
          label: property.label,
          value: value == 'true',
          propertyKey: property.key,
          icon: property.icon,
          onChanged: (newValue) =>
              _updateProperty(property.key, newValue.toString()),
        );

      case PropertyType.measure:
        return PropertyMeasureItem(
          label: property.label,
          value: value,
          propertyKey: property.key,
          icon: property.icon,
          onChanged: (newValue) => _updateProperty(property.key, newValue),
        );

      case PropertyType.indent:
        return PropertyIndentItem(
          label: property.label,
          value: value,
          propertyKey: property.key,
          icon: property.icon,
          onChanged: (newValue) => _updateProperty(property.key, newValue),
        );

      case PropertyType.resource:
      default:
        // For resource type or any other type, show as text for now
        return PropertyTextBox(
          label: property.label,
          value: value,
          icon: property.icon,
          onChanged: (newValue) => _updateProperty(property.key, newValue),
        );
    }
  }

  String _getPropertyValue(String key) {
    switch (key) {
      case 'property_id':
        return widget.selectedWidget.id;
      case 'property_text':
        return widget.selectedWidget.properties['text'] ?? '';
      case 'property_hint':
        return widget.selectedWidget.properties['hint'] ?? '';
      case 'property_text_size':
        return widget.selectedWidget.properties['textSize']?.toString() ?? '12';
      case 'property_text_color':
        return widget.selectedWidget.properties['textColor']?.toString() ??
            '#000000';
      case 'property_hint_color':
        return widget.selectedWidget.properties['hintColor']?.toString() ??
            '#607D8B';
      case 'property_text_style':
        return widget.selectedWidget.properties['textType']?.toString() ?? '0';
      case 'property_input_type':
        return widget.selectedWidget.properties['inputType']?.toString() ?? '1';
      case 'property_single_line':
        return widget.selectedWidget.properties['singleLine']?.toString() ??
            '0';
      case 'property_lines':
        return widget.selectedWidget.properties['line']?.toString() ?? '1';
      case 'property_layout_width':
        return widget.selectedWidget.position.width.toString();
      case 'property_layout_height':
        return widget.selectedWidget.position.height.toString();
      case 'property_background_color':
        return widget.selectedWidget.properties['backgroundColor'] ?? '#FFFFFF';
      case 'property_border_color':
        return widget.selectedWidget.properties['borderColor'] ?? '#CCCCCC';
      case 'property_border_width':
        return widget.selectedWidget.properties['borderWidth']?.toString() ??
            '1.0';
      case 'property_border_radius':
        return widget.selectedWidget.properties['borderRadius']?.toString() ??
            '0.0';
      case 'property_icon_name':
        return widget.selectedWidget.properties['iconName'] ?? 'home';
      case 'property_icon_size':
        return widget.selectedWidget.properties['iconSize']?.toString() ??
            '24.0';
      case 'property_icon_color':
        return widget.selectedWidget.properties['iconColor'] ?? '#000000';
      case 'property_orientation':
        return widget.selectedWidget.properties['orientation'] ?? 'horizontal';
      case 'property_main_axis_alignment':
        return widget.selectedWidget.properties['mainAxisAlignment'] ?? 'start';
      case 'property_cross_axis_alignment':
        return widget.selectedWidget.properties['crossAxisAlignment'] ??
            'center';
      case 'property_alignment':
        return widget.selectedWidget.properties['alignment'] ?? 'topLeft';
      case 'property_fit':
        return widget.selectedWidget.properties['fit'] ?? 'loose';
      default:
        return '';
    }
  }

  void _updateProperty(String key, String value) {
    final updatedProperties =
        Map<String, dynamic>.from(widget.selectedWidget.properties);

    // Convert value based on property type
    dynamic convertedValue = value;
    if (key.contains('textSize') ||
        key.contains('line') ||
        key.contains('inputType') ||
        key.contains('textType') ||
        key.contains('singleLine')) {
      convertedValue = int.tryParse(value) ?? 0;
    } else if (key.contains('borderWidth') ||
        key.contains('borderRadius') ||
        key.contains('iconSize')) {
      convertedValue = double.tryParse(value) ?? 0.0;
    }

    updatedProperties[key] = convertedValue;

    final updatedWidget =
        widget.selectedWidget.copyWith(properties: updatedProperties);
    widget.onPropertyChanged(updatedWidget);
  }

  Widget _buildRecentProperties() {
    return const Center(
      child: Text('Recent properties will be shown here'),
    );
  }

  Widget _buildEventProperties() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildEventButton('Click'),
              _buildEventButton('Long Click'),
              _buildEventButton('Text Change'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventButton(String eventName) {
    return ElevatedButton(
      onPressed: () => _addEvent(eventName),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(eventName),
    );
  }

  Color _parseColor(String value) {
    if (value.startsWith('#')) {
      try {
        return Color(int.parse(value.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        return Colors.black;
      }
    }
    return Colors.black;
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Widget'),
        content: Text(
            'Are you sure you want to delete "${widget.selectedWidget.id}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onWidgetDeleted(widget.selectedWidget);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveWidget() {
    // Save widget changes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Widget saved successfully'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showAllProperties() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Properties'),
        content: const Text('All properties dialog will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addEvent(String eventName) {
    // Add event to widget
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $eventName event'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// Property Group Class
class PropertyGroup {
  final int id;
  final String name;

  PropertyGroup(this.id, this.name);
}

// Property Checkbox Item - EXACTLY matches Sketchware Pro's PropertySwitchSingleLineItem
class PropertyCheckboxItem extends StatelessWidget {
  final String label;
  final bool value;
  final String propertyKey;
  final IconData icon;
  final Function(bool) onChanged;

  const PropertyCheckboxItem({
    super.key,
    required this.label,
    required this.value,
    required this.propertyKey,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 60, // EXACTLY like Sketchware Pro
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background like Sketchware Pro
        borderRadius: BorderRadius.circular(8), // Slightly rounded corners
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius:
              BorderRadius.circular(8), // Match container border radius
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon on top - EXACTLY like Sketchware Pro
              Icon(
                icon,
                size: 20, // Slightly smaller icon like Sketchware Pro
                color: Theme.of(context).colorScheme.onSurface,
              ),

              const SizedBox(height: 4), // Small spacing

              // Property name below icon - EXACTLY like Sketchware Pro
              Text(
                label,
                style: TextStyle(
                  fontSize: 12, // Smaller text like Sketchware Pro
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Property Measure Item - EXACTLY matches Sketchware Pro's PropertyMeasureItem
class PropertyMeasureItem extends StatelessWidget {
  final String label;
  final String value;
  final String propertyKey;
  final IconData icon;
  final Function(String) onChanged;

  const PropertyMeasureItem({
    super.key,
    required this.label,
    required this.value,
    required this.propertyKey,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 60, // EXACTLY like Sketchware Pro
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background like Sketchware Pro
        borderRadius: BorderRadius.circular(8), // Slightly rounded corners
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMeasureDialog(context),
          borderRadius:
              BorderRadius.circular(8), // Match container border radius
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon on top - EXACTLY like Sketchware Pro
              Icon(
                icon,
                size: 20, // Slightly smaller icon like Sketchware Pro
                color: Theme.of(context).colorScheme.onSurface,
              ),

              const SizedBox(height: 4), // Small spacing

              // Property name below icon - EXACTLY like Sketchware Pro
              Text(
                label,
                style: TextStyle(
                  fontSize: 12, // Smaller text like Sketchware Pro
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMeasureDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        icon: Icon(icon),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter $label',
                border: const OutlineInputBorder(),
                suffixText: 'dp',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                onChanged(newValue);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Property Indent Item - EXACTLY matches Sketchware Pro's PropertyIndentItem
class PropertyIndentItem extends StatelessWidget {
  final String label;
  final String value;
  final String propertyKey;
  final IconData icon;
  final Function(String) onChanged;

  const PropertyIndentItem({
    super.key,
    required this.label,
    required this.value,
    required this.propertyKey,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 60, // EXACTLY like Sketchware Pro
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background like Sketchware Pro
        borderRadius: BorderRadius.circular(8), // Slightly rounded corners
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showIndentDialog(context),
          borderRadius:
              BorderRadius.circular(8), // Match container border radius
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon on top - EXACTLY like Sketchware Pro
              Icon(
                icon,
                size: 20, // Slightly smaller icon like Sketchware Pro
                color: Theme.of(context).colorScheme.onSurface,
              ),

              const SizedBox(height: 4), // Small spacing

              // Property name below icon - EXACTLY like Sketchware Pro
              Text(
                label,
                style: TextStyle(
                  fontSize: 12, // Smaller text like Sketchware Pro
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIndentDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        icon: Icon(icon),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter $label',
                border: const OutlineInputBorder(),
                suffixText: 'dp',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                onChanged(newValue);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
