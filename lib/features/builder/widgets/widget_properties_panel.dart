import 'package:flutter/material.dart';
import 'droppable_mobile_frame.dart';

class WidgetPropertiesPanel extends StatefulWidget {
  final PlacedWidget? selectedWidget;
  final Function(PlacedWidget, Map<String, dynamic>) onPropertiesChanged;
  final VoidCallback onClose;

  const WidgetPropertiesPanel({
    super.key,
    this.selectedWidget,
    required this.onPropertiesChanged,
    required this.onClose,
  });

  @override
  State<WidgetPropertiesPanel> createState() => _WidgetPropertiesPanelState();
}

class _WidgetPropertiesPanelState extends State<WidgetPropertiesPanel> {
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _backgroundColorController = TextEditingController();
  final TextEditingController _textColorController = TextEditingController();
  final TextEditingController _fontSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateControllers();
  }

  @override
  void didUpdateWidget(WidgetPropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWidget != widget.selectedWidget) {
      _updateControllers();
    }
  }

  void _updateControllers() {
    if (widget.selectedWidget != null) {
      final properties = widget.selectedWidget!.properties;
      _widthController.text = properties['width']?.toString() ?? '100';
      _heightController.text = properties['height']?.toString() ?? '50';
      _textController.text = properties['text']?.toString() ?? '';
      _backgroundColorController.text = properties['backgroundColor']?.toString() ?? '#FFFFFF';
      _textColorController.text = properties['textColor']?.toString() ?? '#000000';
      _fontSizeController.text = properties['fontSize']?.toString() ?? '14';
    }
  }

  void _applyChanges() {
    if (widget.selectedWidget != null) {
      final newProperties = {
        'width': double.tryParse(_widthController.text) ?? 100.0,
        'height': double.tryParse(_heightController.text) ?? 50.0,
        'text': _textController.text,
        'backgroundColor': _backgroundColorController.text,
        'textColor': _textColorController.text,
        'fontSize': double.tryParse(_fontSizeController.text) ?? 14.0,
      };
      widget.onPropertiesChanged(widget.selectedWidget!, newProperties);
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _textController.dispose();
    _backgroundColorController.dispose();
    _textColorController.dispose();
    _fontSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedWidget == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 48, // Exact Sketchware Pro height
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          // Widget ID Spinner (like Sketchware Pro)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.widgets, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    widget.selectedWidget!.id,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
          // Properties Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: _showPropertiesDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
              ),
              child: const Text(
                'Properties',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          // Close Button
          Container(
            margin: const EdgeInsets.only(right: 4, top: 4),
            child: IconButton(
              onPressed: widget.onClose,
              icon: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _showPropertiesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.selectedWidget!.type} Properties'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPropertyField('Width', _widthController, 'dp'),
              _buildPropertyField('Height', _heightController, 'dp'),
              if (widget.selectedWidget!.type == 'text' || 
                  widget.selectedWidget!.type == 'button' ||
                  widget.selectedWidget!.type == 'edittext')
                _buildPropertyField('Text', _textController),
              _buildPropertyField('Background Color', _backgroundColorController, 'hex'),
              if (widget.selectedWidget!.type == 'text' || 
                  widget.selectedWidget!.type == 'button')
                _buildPropertyField('Text Color', _textColorController, 'hex'),
              if (widget.selectedWidget!.type == 'text' || 
                  widget.selectedWidget!.type == 'button')
                _buildPropertyField('Font Size', _fontSizeController, 'sp'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyChanges();
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyField(String label, TextEditingController controller, [String? unit]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                suffixText: unit,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 