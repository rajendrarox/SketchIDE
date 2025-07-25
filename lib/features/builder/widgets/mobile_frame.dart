import 'package:flutter/material.dart';

class MobileFrame extends StatefulWidget {
  const MobileFrame({super.key});

  @override
  State<MobileFrame> createState() => _MobileFrameState();
}

class _MobileFrameState extends State<MobileFrame> {
  final List<WidgetData> _widgets = [];
  WidgetData? _selectedWidget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        height: 640,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Status bar
              _buildStatusBar(),
              // Main content area
              _buildContentArea(),
              // Add widget button
              _buildAddWidgetButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 8),
            Text(
              '9:41',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 12),
                const SizedBox(width: 2),
                Icon(Icons.wifi, color: Colors.white, size: 12),
                const SizedBox(width: 2),
                Icon(Icons.battery_full, color: Colors.white, size: 12),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    return Positioned(
      top: 30,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.grey.shade50,
        child: _widgets.isEmpty ? _buildEmptyState() : _buildWidgetsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_android,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Drag widgets here',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select widgets from the palette\nand drag them to this area',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _widgets.length,
      itemBuilder: (context, index) {
        final widget = _widgets[index];
        return _buildWidgetItem(widget, index);
      },
    );
  }

  Widget _buildWidgetItem(WidgetData widget, int index) {
    final isSelected = _selectedWidget == widget;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectWidget(widget),
          onLongPress: () => _showWidgetOptions(widget, index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: _buildWidgetPreview(widget),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetPreview(WidgetData widget) {
    switch (widget.type) {
      case 'text':
        return Text(
          widget.properties['text'] ?? 'Text Widget',
          style: TextStyle(
            fontSize: widget.properties['fontSize']?.toDouble() ?? 16,
            fontWeight: widget.properties['bold'] == true 
                ? FontWeight.bold 
                : FontWeight.normal,
            color: _parseColor(widget.properties['color']),
          ),
        );
      case 'elevated_button':
        return ElevatedButton(
          onPressed: () {},
          child: Text(widget.properties['text'] ?? 'Button'),
        );
      case 'container':
        return Container(
          width: double.infinity,
          height: widget.properties['height']?.toDouble() ?? 50,
          decoration: BoxDecoration(
            color: _parseColor(widget.properties['color']) ?? Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.properties['text'] ?? 'Container',
              style: TextStyle(
                color: _parseColor(widget.properties['textColor']),
              ),
            ),
          ),
        );
      case 'image':
        return Container(
          width: double.infinity,
          height: widget.properties['height']?.toDouble() ?? 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.image,
            size: 32,
            color: Colors.grey.shade400,
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${widget.type} Widget',
            style: const TextStyle(fontSize: 14),
          ),
        );
    }
  }

  Widget _buildAddWidgetButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: _showAddWidgetDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _selectWidget(WidgetData widget) {
    setState(() {
      _selectedWidget = widget;
    });
  }

  void _showWidgetOptions(WidgetData widget, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Widget'),
              onTap: () {
                Navigator.pop(context);
                _editWidget(widget);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Widget', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteWidget(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWidgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Widget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuickAddOption('Text', 'text'),
            _buildQuickAddOption('Button', 'elevated_button'),
            _buildQuickAddOption('Container', 'container'),
            _buildQuickAddOption('Image', 'image'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddOption(String name, String type) {
    return ListTile(
      leading: Icon(_getIconForType(type)),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        _addWidget(type);
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields;
      case 'elevated_button':
        return Icons.smart_button;
      case 'container':
        return Icons.crop_square;
      case 'image':
        return Icons.image;
      default:
        return Icons.widgets;
    }
  }

  void _addWidget(String type) {
    final widget = WidgetData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      properties: _getDefaultProperties(type),
    );
    
    setState(() {
      _widgets.add(widget);
      _selectedWidget = widget;
    });
  }

  Map<String, dynamic> _getDefaultProperties(String type) {
    switch (type) {
      case 'text':
        return {
          'text': 'Hello World',
          'fontSize': 16,
          'color': '#000000',
          'bold': false,
        };
      case 'elevated_button':
        return {
          'text': 'Button',
        };
      case 'container':
        return {
          'text': 'Container',
          'height': 50,
          'color': '#E0E0E0',
          'textColor': '#000000',
        };
      case 'image':
        return {
          'height': 100,
        };
      default:
        return {};
    }
  }

  void _editWidget(WidgetData widget) {
    // TODO: Implement widget editing dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${widget.type} widget')),
    );
  }

  void _deleteWidget(int index) {
    setState(() {
      _widgets.removeAt(index);
      if (_selectedWidget == _widgets[index]) {
        _selectedWidget = null;
      }
    });
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
}

class WidgetData {
  final String id;
  final String type;
  final Map<String, dynamic> properties;

  WidgetData({
    required this.id,
    required this.type,
    required this.properties,
  });
} 