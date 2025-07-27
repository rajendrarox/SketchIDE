import 'package:flutter/material.dart';
import 'base_property_box.dart';

/// Selector Property Box - EXACTLY matches Sketchware Pro's PropertySelectorItem
/// Handles dropdown selection for properties like text style, orientation, etc.
class PropertySelectorBox extends BasePropertyBox {
  final Function(String) onChanged;
  final List<String> options;
  final String currentValue;

  const PropertySelectorBox({
    super.key,
    required super.label,
    required super.value,
    required super.icon,
    required this.onChanged,
    required this.options,
    required this.currentValue,
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
          onTap: enabled ? () => _showSelectorDialog(context) : null,
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

  void _showSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        icon: Icon(icon),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: currentValue,
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
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

  double _getBoxWidth() => 120; // Default width like Sketchware Pro
}
