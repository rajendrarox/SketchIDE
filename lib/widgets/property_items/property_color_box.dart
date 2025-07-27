import 'package:flutter/material.dart';
import 'base_property_box.dart';

/// Color Property Box - EXACTLY matches Sketchware Pro's PropertyColorItem
/// Handles color selection with preview square
class PropertyColorBox extends BasePropertyBox {
  final Function(Color) onChanged;
  final Color currentColor;
  final bool allowTransparent;
  final bool allowNone;

  const PropertyColorBox({
    super.key,
    required super.label,
    required super.value,
    required super.icon,
    required this.onChanged,
    required this.currentColor,
    this.allowTransparent = false,
    this.allowNone = false,
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
          onTap: enabled ? () => _showColorPicker(context) : null,
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

  String _getColorDisplayText() {
    if (currentColor == Colors.transparent) {
      return 'TRANSPARENT';
    } else if (currentColor == Colors.white && allowNone) {
      return 'NONE';
    } else {
      return '#${currentColor.value.toRadixString(16).toUpperCase().padLeft(8, '0')}';
    }
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        icon: Icon(icon),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple color picker - can be enhanced with more sophisticated picker
            Container(
              height: 200,
              width: double.maxFinite,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _getColorOptions().length,
                itemBuilder: (context, index) {
                  final color = _getColorOptions()[index];
                  return GestureDetector(
                    onTap: () {
                      onChanged(color);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: currentColor == color
                          ? Icon(
                              Icons.check,
                              color: _getContrastColor(color),
                              size: 20,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            if (allowTransparent || allowNone)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    if (allowTransparent)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onChanged(Colors.transparent);
                            Navigator.pop(context);
                          },
                          child: const Text('Transparent'),
                        ),
                      ),
                    if (allowTransparent && allowNone) const SizedBox(width: 8),
                    if (allowNone)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onChanged(Colors.white);
                            Navigator.pop(context);
                          },
                          child: const Text('None'),
                        ),
                      ),
                  ],
                ),
              ),
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

  List<Color> _getColorOptions() {
    return [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
      Colors.white,
      Colors.red.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.yellow.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.pink.shade100,
      Colors.teal.shade100,
      Colors.indigo.shade100,
      Colors.cyan.shade100,
      Colors.lime.shade100,
      Colors.amber.shade100,
    ];
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  double _getBoxWidth() => 120; // Default width like Sketchware Pro
}
