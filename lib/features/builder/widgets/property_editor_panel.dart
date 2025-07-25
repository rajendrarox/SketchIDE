import 'package:flutter/material.dart';
import '../models/widget_data.dart';

class PropertyEditorPanel extends StatelessWidget {
  final WidgetData? selectedWidget;
  final List<WidgetData> widgets;
  final Function(WidgetData) onWidgetSelected;
  final Function(WidgetData) onWidgetDeleted;
  final Function(WidgetData) onPropertyChanged;

  const PropertyEditorPanel({
    super.key,
    required this.selectedWidget,
    required this.widgets,
    required this.onWidgetSelected,
    required this.onWidgetDeleted,
    required this.onPropertyChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedWidget == null) return const SizedBox.shrink();

    return Container(
      height: 180,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          _buildTopBar(context),
          _buildPropertyGroups(context),
          Expanded(child: _buildPropertyContent(context)),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedWidget?.id,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                isDense: true,
              ),
              items: widgets.map((widget) {
                return DropdownMenuItem<String>(
                  value: widget.id,
                  child: Text(
                    '${_getWidgetDisplayName(widget.type)} (${widget.id})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (widgetId) {
                if (widgetId != null) {
                  final widget = widgets.firstWhere((w) => w.id == widgetId);
                  onWidgetSelected(widget);
                }
              },
            ),
          ),
          IconButton(
            onPressed: () => onWidgetDeleted(selectedWidget!),
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            onPressed: () => onPropertyChanged(selectedWidget!),
            icon: const Icon(Icons.save, color: Colors.green, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyGroups(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Basic',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildPropertyBoxes(),
              ),
            ),
          ),
          SizedBox(
            width: 82,
            child: _buildSeeAllButton(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPropertyBoxes() {
    final properties = _getBasicProperties(selectedWidget!.type);
    return properties.map((property) {
      final value = selectedWidget!.properties[property] ?? '';
      return Container(
        width: 100,
        height: 70,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // Property header with icon
            Container(
              width: double.infinity,
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getPropertyTypeColor(property),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPropertyTypeIcon(property),
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      property,
                      style: const TextStyle(
                        fontSize: 9,
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
                padding: const EdgeInsets.all(6),
                child: Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSeeAllButton(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.more_horiz,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(height: 2),
            Text(
              'See All',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getBasicProperties(String widgetType) {
    switch (widgetType) {
      case 'text':
        return ['text', 'fontSize', 'color'];
      case 'button':
        return ['text', 'width', 'height'];
      case 'edittext':
        return ['hintText', 'width', 'height'];
      case 'image':
        return ['src', 'width', 'height'];
      case 'checkbox':
        return ['text', 'checked'];
      case 'switch':
        return ['text', 'checked'];
      case 'progressbar':
        return ['value', 'width', 'height'];
      case 'appbar':
        return ['title', 'backgroundColor'];
      case 'center':
        return ['width', 'height'];
      default:
        return ['width', 'height'];
    }
  }

  String _getWidgetDisplayName(String type) {
    switch (type) {
      case 'text':
        return 'Text';
      case 'button':
        return 'Button';
      case 'edittext':
        return 'TextField';
      case 'image':
        return 'Image';
      case 'checkbox':
        return 'Checkbox';
      case 'switch':
        return 'Switch';
      case 'progressbar':
        return 'ProgressBar';
      case 'appbar':
        return 'AppBar';
      case 'center':
        return 'Center';
      case 'scaffold':
        return 'Scaffold';
      case 'materialapp':
        return 'MaterialApp';
      case 'column':
        return 'Column';
      case 'row':
        return 'Row';
      case 'stack':
        return 'Stack';
      default:
        return type;
    }
  }

  Color _getPropertyTypeColor(String property) {
    switch (property) {
      case 'text':
      case 'hintText':
      case 'title':
        return Colors.blue;
      case 'width':
      case 'height':
        return Colors.green;
      case 'color':
      case 'backgroundColor':
        return Colors.purple;
      case 'fontSize':
      case 'value':
        return Colors.orange;
      case 'margin':
      case 'padding':
        return Colors.teal;
      case 'checked':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getPropertyTypeIcon(String property) {
    switch (property) {
      case 'text':
      case 'hintText':
      case 'title':
        return Icons.text_fields;
      case 'width':
      case 'height':
        return Icons.straighten;
      case 'color':
      case 'backgroundColor':
        return Icons.palette;
      case 'fontSize':
        return Icons.format_size;
      case 'value':
        return Icons.tune;
      case 'margin':
      case 'padding':
        return Icons.space_bar;
      case 'checked':
        return Icons.check_box;
      default:
        return Icons.settings;
    }
  }
} 