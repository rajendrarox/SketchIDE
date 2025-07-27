import 'package:flutter/material.dart';
import 'base_property_box.dart';

/// Text Property Box - EXACTLY matches Sketchware Pro's PropertyInputItem
/// Handles text input properties with dialog interface
class PropertyTextBox extends BasePropertyBox {
  final Function(String) onChanged;
  final int maxLines;
  final bool isNumber;
  final double? minValue;
  final double? maxValue;

  const PropertyTextBox({
    super.key,
    required super.label,
    required super.value,
    required super.icon,
    required this.onChanged,
    this.maxLines = 1,
    this.isNumber = false,
    this.minValue,
    this.maxValue,
    super.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _getBoxWidth(),
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
          onTap: enabled ? () => _showTextDialog(context) : null,
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

  void _showTextDialog(BuildContext context) {
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
              maxLines: maxLines,
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Enter $label',
                border: const OutlineInputBorder(),
              ),
            ),
            if (isNumber && (minValue != null || maxValue != null))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Range: ${minValue ?? '∞'} - ${maxValue ?? '∞'}',
                  style: Theme.of(context).textTheme.bodySmall,
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
                if (isNumber) {
                  final number = double.tryParse(newValue);
                  if (number != null) {
                    if ((minValue == null || number >= minValue!) &&
                        (maxValue == null || number <= maxValue!)) {
                      onChanged(newValue);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Value must be between ${minValue ?? '∞'} and ${maxValue ?? '∞'}'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a valid number')),
                    );
                  }
                } else {
                  onChanged(newValue);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  double _getBoxWidth() => 120; // Default width like Sketchware Pro
}
