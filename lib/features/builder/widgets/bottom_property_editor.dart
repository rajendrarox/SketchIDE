import 'package:flutter/material.dart';
import '../models/widget_data.dart';
import '../models/dart_file_bean.dart';
import '../../../domain/models/project.dart';
import '../screens/property_editor_screen.dart';

class BottomPropertyEditor extends StatefulWidget {
  final List<WidgetData> widgets;
  final Project project;
  final DartFileBean file;
  final WidgetData? selectedWidget;
  final Function(WidgetData) onWidgetSelected;
  final Function(WidgetData) onPropertyChanged;
  final Function(WidgetData) onWidgetDeleted;

  const BottomPropertyEditor({
    super.key,
    required this.widgets,
    required this.project,
    required this.file,
    this.selectedWidget,
    required this.onWidgetSelected,
    required this.onPropertyChanged,
    required this.onWidgetDeleted,
  });

  @override
  State<BottomPropertyEditor> createState() => _BottomPropertyEditorState();
}

class _BottomPropertyEditorState extends State<BottomPropertyEditor>
    with TickerProviderStateMixin {
  late AnimationController _showAllController;
  late Animation<double> _showAllAnimation;
  bool _showAllVisible = true;
  int _selectedGroupIndex = 0;
  final ScrollController _scrollController = ScrollController();

  final List<String> _propertyGroups = ['Basic', 'Recent', 'Event'];
  
  // Performance optimization
  final Map<String, List<Map<String, dynamic>>> _propertyCache = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _showAllController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _showAllAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _showAllController,
      curve: Curves.easeInOut,
    ));

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _showAllController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrollX = _scrollController.offset;
    final maxScrollX = _scrollController.position.maxScrollExtent;
    
    if (scrollX > 100 && scrollX < maxScrollX - 100) {
      if (scrollX > _scrollController.position.pixels) {
        // Scrolling right
        if (_showAllVisible) {
          setState(() {
            _showAllVisible = false;
          });
          _showAllController.forward();
        }
      } else {
        // Scrolling left
        if (!_showAllVisible) {
          setState(() {
            _showAllVisible = true;
          });
          _showAllController.reverse();
        }
      }
    } else if (scrollX >= maxScrollX - 100) {
      if (_showAllVisible) {
        setState(() {
          _showAllVisible = false;
        });
        _showAllController.forward();
      }
    } else {
      if (!_showAllVisible) {
        setState(() {
          _showAllVisible = true;
        });
        _showAllController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          // Top bar with widget selector and action buttons
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Widget selector spinner
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: DropdownButtonFormField<String>(
                      value: widget.selectedWidget?.id,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      items: widget.widgets.map((widget) {
                        return DropdownMenuItem<String>(
                          value: widget.id,
                          child: Row(
                            children: [
                              Icon(
                                _getWidgetIcon(widget.type),
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_getWidgetDisplayName(widget.type)} (${widget.id})',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (widgetId) {
                        if (widgetId != null) {
                          final selectedWidget = widget.widgets.firstWhere((w) => w.id == widgetId);
                          widget.onWidgetSelected(selectedWidget);
                        }
                      },
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                // Delete button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    onPressed: widget.selectedWidget != null
                        ? () => _deleteWidget(widget.selectedWidget!)
                        : null,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Widget',
                  ),
                ),
                // Save button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    onPressed: widget.selectedWidget != null
                        ? () => _saveWidget(widget.selectedWidget!)
                        : null,
                    icon: const Icon(Icons.save, color: Colors.green),
                    tooltip: 'Save Widget',
                  ),
                ),
              ],
            ),
          ),
          // Property groups
          Container(
            height: 32,
            padding: const EdgeInsets.only(left: 4, top: 2),
            child: Row(
              children: _propertyGroups.asMap().entries.map((entry) {
                final index = entry.key;
                final groupName = entry.value;
                final isSelected = index == _selectedGroupIndex;

                return Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGroupIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          groupName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Property content area
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 6),
              child: Stack(
                children: [
                  // Horizontal scrolling property boxes
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: _buildPropertyBoxes(),
                    ),
                  ),
                  // Floating "See All" button
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedBuilder(
                      animation: _showAllAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _showAllVisible ? 1.0 : 0.0,
                          child: Container(
                            width: 82,
                            alignment: Alignment.center,
                            child: _buildSeeAllButton(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveWidget(WidgetData widget) {
    // Save the widget changes
    this.widget.onPropertyChanged(widget);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getWidgetDisplayName(widget.type)} widget saved successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }



  List<Widget> _buildPropertyBoxes() {
    if (widget.selectedWidget == null) {
      return [
        Container(
          width: 200,
          height: 82,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              'No widget selected',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ];
    }

    final properties = _getPropertiesForGroup(widget.selectedWidget!, _selectedGroupIndex);
    
    return properties.map((property) {
      return Container(
        width: 120,
        height: 82,
        margin: const EdgeInsets.only(right: 8),
        child: _buildPropertyBox(property),
      );
    }).toList();
  }

  Widget _buildPropertyBox(Map<String, dynamic> property) {
    final label = property['label'] as String;
    final value = property['value'] as String;
    final type = property['type'] as String;
    final key = property['key'] as String;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _editProperty(property),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property label header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPropertyTypeColor(type),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPropertyTypeIcon(type),
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Property value
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  child: _buildPropertyValue(type, value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyValue(String type, String value) {
    switch (type) {
      case 'text':
        return Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case 'color':
        return Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _parseColor(value),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case 'number':
        return Row(
          children: [
            Icon(Icons.straighten, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        );
      case 'measure':
        return Row(
          children: [
            Icon(Icons.aspect_ratio, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        );
      case 'indent':
        return Row(
          children: [
            Icon(Icons.format_indent_increase, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        );
      case 'boolean':
        return Row(
          children: [
            Icon(
              value.toLowerCase() == 'true' ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 12,
              color: value.toLowerCase() == 'true' ? Colors.green : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        );
      case 'event':
        return Row(
          children: [
            Icon(
              value == 'Set' ? Icons.event_available : Icons.event_busy,
              size: 12,
              color: value == 'Set' ? Colors.green : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        );
      case 'selector':
        return Row(
          children: [
            Icon(Icons.arrow_drop_down, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      default:
        return Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
    }
  }

  Color _getPropertyTypeColor(String type) {
    switch (type) {
      case 'text':
        return Colors.blue.shade600;
      case 'color':
        return Colors.purple.shade600;
      case 'number':
        return Colors.orange.shade600;
      case 'measure':
        return Colors.green.shade600;
      case 'indent':
        return Colors.teal.shade600;
      case 'boolean':
        return Colors.red.shade600;
      case 'event':
        return Colors.indigo.shade600;
      case 'selector':
        return Colors.cyan.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getPropertyTypeIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields;
      case 'color':
        return Icons.palette;
      case 'number':
        return Icons.straighten;
      case 'measure':
        return Icons.aspect_ratio;
      case 'indent':
        return Icons.format_indent_increase;
      case 'boolean':
        return Icons.check_circle;
      case 'event':
        return Icons.event;
      case 'selector':
        return Icons.arrow_drop_down;
      default:
        return Icons.settings;
    }
  }

  void _editProperty(Map<String, dynamic> property) {
    final label = property['label'] as String;
    final value = property['value'] as String;
    final type = property['type'] as String;
    final key = property['key'] as String;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPropertyEditor(type, key, value),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _updateProperty(key, _getEditedValue(type, key));
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label updated successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyEditor(String type, String key, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    
    switch (type) {
      case 'text':
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Text',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => _setEditedValue(key, value),
        );
        
      case 'number':
        return TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Number',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => _setEditedValue(key, value),
        );
        
      case 'color':
        return Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Color (hex or Flutter color)',
                border: const OutlineInputBorder(),
                hintText: 'e.g., #FF0000 or Colors.red',
              ),
              onChanged: (value) => _setEditedValue(key, value),
            ),
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _parseColor(currentValue),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text('Preview', style: TextStyle(fontSize: 10)),
              ),
            ),
          ],
        );
        
      case 'boolean':
        return StatefulBuilder(
          builder: (context, setState) {
            bool value = currentValue.toLowerCase() == 'true';
            return SwitchListTile(
              title: Text('Value'),
              value: value,
              onChanged: (newValue) {
                setState(() {
                  value = newValue;
                  _setEditedValue(key, newValue.toString());
                });
              },
            );
          },
        );
        
      case 'selector':
        return DropdownButtonFormField<String>(
          value: currentValue,
          decoration: const InputDecoration(
            labelText: 'Select Option',
            border: OutlineInputBorder(),
          ),
          items: _getSelectorOptions(key).map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _setEditedValue(key, value);
            }
          },
        );
        
      case 'measure':
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Size',
            border: const OutlineInputBorder(),
            hintText: 'e.g., 100, match_parent, wrap_content',
          ),
          onChanged: (value) => _setEditedValue(key, value),
        );
        
      case 'indent':
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Indent (left, top, right, bottom)',
            border: const OutlineInputBorder(),
            hintText: 'e.g., 8, 8, 8, 8',
          ),
          onChanged: (value) => _setEditedValue(key, value),
        );
        
      default:
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Value',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => _setEditedValue(key, value),
        );
    }
  }

  List<String> _getSelectorOptions(String key) {
    switch (key) {
      case 'fontWeight':
        return [
          'FontWeight.normal',
          'FontWeight.bold',
          'FontWeight.w100',
          'FontWeight.w200',
          'FontWeight.w300',
          'FontWeight.w400',
          'FontWeight.w500',
          'FontWeight.w600',
          'FontWeight.w700',
          'FontWeight.w800',
          'FontWeight.w900',
        ];
      case 'mainAxisAlignment':
        return [
          'MainAxisAlignment.start',
          'MainAxisAlignment.center',
          'MainAxisAlignment.end',
          'MainAxisAlignment.spaceBetween',
          'MainAxisAlignment.spaceAround',
          'MainAxisAlignment.spaceEvenly',
        ];
      case 'crossAxisAlignment':
        return [
          'CrossAxisAlignment.start',
          'CrossAxisAlignment.center',
          'CrossAxisAlignment.end',
          'CrossAxisAlignment.stretch',
          'CrossAxisAlignment.baseline',
        ];
      case 'mainAxisSize':
        return [
          'MainAxisSize.min',
          'MainAxisSize.max',
        ];
      case 'alignment':
        return [
          'Alignment.topLeft',
          'Alignment.topCenter',
          'Alignment.topRight',
          'Alignment.centerLeft',
          'Alignment.center',
          'Alignment.centerRight',
          'Alignment.bottomLeft',
          'Alignment.bottomCenter',
          'Alignment.bottomRight',
        ];
      case 'fit':
        return [
          'BoxFit.cover',
          'BoxFit.contain',
          'BoxFit.fill',
          'BoxFit.fitWidth',
          'BoxFit.fitHeight',
          'BoxFit.none',
          'BoxFit.scaleDown',
        ];
      case 'inputType':
        return [
          'TextInputType.text',
          'TextInputType.number',
          'TextInputType.emailAddress',
          'TextInputType.phone',
          'TextInputType.url',
          'TextInputType.multiline',
        ];
      default:
        return [];
    }
  }

  final Map<String, String> _editedValues = {};

  void _setEditedValue(String key, String value) {
    _editedValues[key] = value;
  }

  String _getEditedValue(String type, String key) {
    return _editedValues[key] ?? '';
  }

  void _updateProperty(String key, String value) {
    if (widget.selectedWidget != null) {
      final updatedWidget = widget.selectedWidget!.copyWith(
        properties: {
          ...widget.selectedWidget!.properties,
          key: value,
        },
      );
      widget.onPropertyChanged(updatedWidget);
    }
  }

  Widget _buildSeeAllButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openFullPropertyEditor(),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.more_horiz,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                'See All',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getPropertiesForGroup(WidgetData widget, int groupIndex) {
    switch (groupIndex) {
      case 0: // Basic
        return _getBasicProperties(widget);
      case 1: // Recent
        return _getRecentProperties(widget);
      case 2: // Event
        return _getEventProperties(widget);
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _getBasicProperties(WidgetData widget) {
    // Check cache first
    final cacheKey = '${widget.type}_basic';
    if (_propertyCache.containsKey(cacheKey)) {
      return _propertyCache[cacheKey]!;
    }

    final properties = <Map<String, dynamic>>[];

    // Always show layout properties for all widgets
    properties.addAll([
      {
        'label': 'Width',
        'value': _getPropertyValue(widget, 'width', 'match_parent'),
        'type': 'measure',
        'key': 'width',
      },
      {
        'label': 'Height',
        'value': _getPropertyValue(widget, 'height', 'wrap_content'),
        'type': 'measure',
        'key': 'height',
      },
      {
        'label': 'Margin',
        'value': _getPropertyValue(widget, 'margin', '0, 0, 0, 0'),
        'type': 'indent',
        'key': 'margin',
      },
      {
        'label': 'Padding',
        'value': _getPropertyValue(widget, 'padding', '0, 0, 0, 0'),
        'type': 'indent',
        'key': 'padding',
      },
    ]);

    // Widget-specific properties
    switch (widget.type) {
      case WidgetData.TYPE_TEXT:
        properties.addAll([
          {
            'label': 'Text',
            'value': _getPropertyValue(widget, 'text', 'Text'),
            'type': 'text',
            'key': 'text',
          },
          {
            'label': 'Font Size',
            'value': _getPropertyValue(widget, 'fontSize', '14.0'),
            'type': 'number',
            'key': 'fontSize',
          },
          {
            'label': 'Text Color',
            'value': _getPropertyValue(widget, 'color', '#000000'),
            'type': 'color',
            'key': 'color',
          },
          {
            'label': 'Font Weight',
            'value': _getPropertyValue(widget, 'fontWeight', 'FontWeight.normal'),
            'type': 'selector',
            'key': 'fontWeight',
          },
        ]);
        break;

      case WidgetData.TYPE_BUTTON:
        properties.addAll([
          {
            'label': 'Text',
            'value': _getPropertyValue(widget, 'text', 'Button'),
            'type': 'text',
            'key': 'text',
          },
          {
            'label': 'On Pressed',
            'value': widget.properties.containsKey('onPressed') ? 'Set' : 'Not Set',
            'type': 'event',
            'key': 'onPressed',
          },
          {
            'label': 'Background Color',
            'value': _getPropertyValue(widget, 'backgroundColor', '#2196F3'),
            'type': 'color',
            'key': 'backgroundColor',
          },
          {
            'label': 'Text Color',
            'value': _getPropertyValue(widget, 'foregroundColor', '#FFFFFF'),
            'type': 'color',
            'key': 'foregroundColor',
          },
        ]);
        break;

      case WidgetData.TYPE_EDITTEXT:
        properties.addAll([
          {
            'label': 'Hint Text',
            'value': _getPropertyValue(widget, 'hintText', 'Enter text...'),
            'type': 'text',
            'key': 'hintText',
          },
          {
            'label': 'Text',
            'value': _getPropertyValue(widget, 'text', ''),
            'type': 'text',
            'key': 'text',
          },
          {
            'label': 'Font Size',
            'value': _getPropertyValue(widget, 'fontSize', '14.0'),
            'type': 'number',
            'key': 'fontSize',
          },
          {
            'label': 'Input Type',
            'value': _getPropertyValue(widget, 'inputType', 'TextInputType.text'),
            'type': 'selector',
            'key': 'inputType',
          },
        ]);
        break;

      case WidgetData.TYPE_IMAGE:
        properties.addAll([
          {
            'label': 'Image Source',
            'value': _getPropertyValue(widget, 'src', ''),
            'type': 'text',
            'key': 'src',
          },
          {
            'label': 'Width',
            'value': _getPropertyValue(widget, 'width', '100.0'),
            'type': 'number',
            'key': 'width',
          },
          {
            'label': 'Height',
            'value': _getPropertyValue(widget, 'height', '100.0'),
            'type': 'number',
            'key': 'height',
          },
          {
            'label': 'Fit',
            'value': _getPropertyValue(widget, 'fit', 'BoxFit.cover'),
            'type': 'selector',
            'key': 'fit',
          },
        ]);
        break;

      case WidgetData.TYPE_CHECKBOX:
        properties.addAll([
          {
            'label': 'Text',
            'value': _getPropertyValue(widget, 'text', 'Checkbox'),
            'type': 'text',
            'key': 'text',
          },
          {
            'label': 'Value',
            'value': _getPropertyValue(widget, 'value', 'false'),
            'type': 'boolean',
            'key': 'value',
          },
          {
            'label': 'On Changed',
            'value': widget.properties.containsKey('onChanged') ? 'Set' : 'Not Set',
            'type': 'event',
            'key': 'onChanged',
          },
        ]);
        break;

      case WidgetData.TYPE_SWITCH:
        properties.addAll([
          {
            'label': 'Text',
            'value': _getPropertyValue(widget, 'text', 'Switch'),
            'type': 'text',
            'key': 'text',
          },
          {
            'label': 'Value',
            'value': _getPropertyValue(widget, 'value', 'false'),
            'type': 'boolean',
            'key': 'value',
          },
          {
            'label': 'On Changed',
            'value': widget.properties.containsKey('onChanged') ? 'Set' : 'Not Set',
            'type': 'event',
            'key': 'onChanged',
          },
        ]);
        break;

      case WidgetData.TYPE_PROGRESSBAR:
        properties.addAll([
          {
            'label': 'Value',
            'value': _getPropertyValue(widget, 'value', '0.5'),
            'type': 'number',
            'key': 'value',
          },
          {
            'label': 'Background Color',
            'value': _getPropertyValue(widget, 'backgroundColor', '#E0E0E0'),
            'type': 'color',
            'key': 'backgroundColor',
          },
          {
            'label': 'Value Color',
            'value': _getPropertyValue(widget, 'valueColor', '#2196F3'),
            'type': 'color',
            'key': 'valueColor',
          },
        ]);
        break;

      case WidgetData.TYPE_APPBAR:
        properties.addAll([
          {
            'label': 'Title',
            'value': _getPropertyValue(widget, 'title', 'App Title'),
            'type': 'text',
            'key': 'title',
          },
          {
            'label': 'Background Color',
            'value': _getPropertyValue(widget, 'backgroundColor', 'Theme.of(context).colorScheme.inversePrimary'),
            'type': 'color',
            'key': 'backgroundColor',
          },
          {
            'label': 'Elevation',
            'value': _getPropertyValue(widget, 'elevation', '4.0'),
            'type': 'number',
            'key': 'elevation',
          },
        ]);
        break;

      case WidgetData.TYPE_COLUMN:
      case WidgetData.TYPE_ROW:
        properties.addAll([
          {
            'label': 'Main Axis Alignment',
            'value': _getPropertyValue(widget, 'mainAxisAlignment', 'MainAxisAlignment.start'),
            'type': 'selector',
            'key': 'mainAxisAlignment',
          },
          {
            'label': 'Cross Axis Alignment',
            'value': _getPropertyValue(widget, 'crossAxisAlignment', 'CrossAxisAlignment.center'),
            'type': 'selector',
            'key': 'crossAxisAlignment',
          },
          {
            'label': 'Main Axis Size',
            'value': _getPropertyValue(widget, 'mainAxisSize', 'MainAxisSize.max'),
            'type': 'selector',
            'key': 'mainAxisSize',
          },
        ]);
        break;

      case WidgetData.TYPE_STACK:
        properties.addAll([
          {
            'label': 'Alignment',
            'value': _getPropertyValue(widget, 'alignment', 'Alignment.topLeft'),
            'type': 'selector',
            'key': 'alignment',
          },
          {
            'label': 'Fit',
            'value': _getPropertyValue(widget, 'fit', 'StackFit.loose'),
            'type': 'selector',
            'key': 'fit',
          },
        ]);
        break;
    }

    // Cache the result
    _propertyCache[cacheKey] = properties;
    return properties;
  }

  List<Map<String, dynamic>> _getRecentProperties(WidgetData widget) {
    // Show recently modified properties
    final properties = <Map<String, dynamic>>[];
    
    // For now, show some common properties
    if (widget.properties.containsKey('margin')) {
      properties.add({
        'label': 'Margin',
        'value': widget.properties['margin'].toString(),
        'type': 'text',
      });
    }

    if (widget.properties.containsKey('padding')) {
      properties.add({
        'label': 'Padding',
        'value': widget.properties['padding'].toString(),
        'type': 'text',
      });
    }

    return properties;
  }

  List<Map<String, dynamic>> _getEventProperties(WidgetData widget) {
    final properties = <Map<String, dynamic>>[];

    switch (widget.type) {
      case WidgetData.TYPE_BUTTON:
        properties.add({
          'label': 'On Pressed',
          'value': widget.properties.containsKey('onPressed') ? 'Set' : 'Not Set',
          'type': 'text',
        });
        break;
      case WidgetData.TYPE_CHECKBOX:
      case WidgetData.TYPE_SWITCH:
        properties.add({
          'label': 'On Changed',
          'value': widget.properties.containsKey('onChanged') ? 'Set' : 'Not Set',
          'type': 'text',
        });
        break;
      case WidgetData.TYPE_EDITTEXT:
        properties.add({
          'label': 'On Changed',
          'value': widget.properties.containsKey('onChanged') ? 'Set' : 'Not Set',
          'type': 'text',
        });
        break;
    }

    return properties;
  }

  IconData _getWidgetIcon(String type) {
    switch (type) {
      case WidgetData.TYPE_TEXT:
        return Icons.text_fields;
      case WidgetData.TYPE_BUTTON:
        return Icons.smart_button;
      case WidgetData.TYPE_EDITTEXT:
        return Icons.edit;
      case WidgetData.TYPE_IMAGE:
        return Icons.image;
      case WidgetData.TYPE_CHECKBOX:
        return Icons.check_box;
      case WidgetData.TYPE_SWITCH:
        return Icons.switch_right;
      case WidgetData.TYPE_PROGRESSBAR:
        return Icons.linear_scale;
      case WidgetData.TYPE_APPBAR:
        return Icons.apps;
      case WidgetData.TYPE_CENTER:
        return Icons.center_focus_strong;
      case WidgetData.TYPE_COLUMN:
        return Icons.view_column;
      case WidgetData.TYPE_ROW:
        return Icons.view_agenda;
      case WidgetData.TYPE_STACK:
        return Icons.layers;
      default:
        return Icons.widgets;
    }
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;
    if (colorString.startsWith('#')) {
      try {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void _openFullPropertyEditor() {
    if (widget.selectedWidget != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyEditorScreen(
            widget: widget.selectedWidget!,
            project: widget.project,
            file: widget.file,
            onPropertyChanged: widget.onPropertyChanged,
          ),
        ),
      );
    }
  }

  void _deleteWidget(WidgetData widget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Widget'),
        content: Text('Are you sure you want to delete this ${_getWidgetDisplayName(widget.type)} widget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              this.widget.onWidgetDeleted(widget);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_getWidgetDisplayName(widget.type)} widget deleted successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
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



  String _getPropertyValue(WidgetData widget, String key, String defaultValue) {
    final value = widget.properties[key];
    if (value == null || value.toString().isEmpty) {
      return defaultValue;
    }
    return value.toString();
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
} 