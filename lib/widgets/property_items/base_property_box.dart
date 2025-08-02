import 'package:flutter/material.dart';

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
      height: 60, 
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Stack(
            children: [
              Positioned(
                left: 8,
                top: 18, 
                child: Icon(
                  icon,
                  size: 24, 
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              Positioned(
                left: 40, 
                top: 10, 
                right:
                    trailing != null ? 60 : 16, // Account for trailing widget
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Positioned(
                left: 40, 
                top: 32, 
                right:
                    trailing != null ? 60 : 16, // Account for trailing widget
                child: Text(
                  value.isEmpty ? 'Enter value' : value,
                  style: TextStyle(
                    fontSize: 14, 
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

  double _getBoxWidth() => 120; 

  Widget _buildCustomContent(BuildContext context) {
    return const SizedBox.shrink(); 
  }
}
