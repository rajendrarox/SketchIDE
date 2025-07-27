import 'package:flutter/material.dart';

/// Base Property Box - EXACTLY matches Sketchware Pro's property item design
/// All property boxes have the same 60dp height and consistent layout
abstract class BasePropertyBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool enabled;

  const BasePropertyBox({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.trailing,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _getBoxWidth(),
      height: 60, // EXACTLY like Sketchware Pro
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          // NO rounded corners - flat design like Sketchware Pro
          child: Stack(
            children: [
              // Icon - positioned absolutely like Sketchware Pro
              Positioned(
                left: 8,
                top: 18, // Center vertically in 60dp height
                child: Icon(
                  icon,
                  size: 24, // EXACTLY like Sketchware Pro
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              // Label - positioned absolutely like Sketchware Pro
              Positioned(
                left: 40, // 24dp icon + 8dp margin + 8dp spacing
                top: 10, // 10dp from top like Sketchware Pro
                right:
                    trailing != null ? 60 : 16, // Account for trailing widget
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16, // EXACTLY like Sketchware Pro
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Value - positioned absolutely like Sketchware Pro
              Positioned(
                left: 40, // Same left margin as label
                top: 32, // Below label
                right:
                    trailing != null ? 60 : 16, // Account for trailing widget
                child: Text(
                  value.isEmpty ? 'Enter value' : value,
                  style: TextStyle(
                    fontSize: 14, // EXACTLY like Sketchware Pro
                    color: value.isEmpty
                        ? Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.6)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Trailing widget (like color preview) - positioned absolutely like Sketchware Pro
              if (trailing != null)
                Positioned(
                  right: 16,
                  top: 16, // Center vertically
                  child: trailing!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Override this to customize box width
  double _getBoxWidth() => 120; // Default width like Sketchware Pro

  /// Override this to customize content area
  Widget _buildCustomContent(BuildContext context) {
    return const SizedBox.shrink(); // Not used with absolute positioning
  }
}
