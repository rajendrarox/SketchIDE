import 'package:flutter/material.dart';

/// DeleteZone - EXACTLY matches Sketchware Pro's delete zone with animations
class DeleteZone extends StatefulWidget {
  final bool isVisible;
  final bool isActive;
  final bool isCustomWidget;
  final VoidCallback? onDelete;

  const DeleteZone({
    super.key,
    this.isVisible = false,
    this.isActive = false,
    this.isCustomWidget = false,
    this.onDelete,
  });

  @override
  State<DeleteZone> createState() => _DeleteZoneState();
}

class _DeleteZoneState extends State<DeleteZone> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(DeleteZone oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    if (widget.isActive != oldWidget.isActive && widget.isActive) {
      _shakeController.forward().then((_) => _shakeController.reverse());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _shakeController]),
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: _buildDeleteZone(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteZone() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: widget.onDelete,
            borderRadius: BorderRadius.circular(12),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.isActive) {
      return widget.isCustomWidget
          ? Colors.orange.withOpacity(0.1)
          : Colors.red.withOpacity(0.1);
    }
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  Color _getBorderColor() {
    if (widget.isActive) {
      return widget.isCustomWidget ? Colors.orange : Colors.red;
    }
    return Theme.of(context).colorScheme.outline.withOpacity(0.3);
  }

  Widget _buildContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon with shake animation
        Transform.translate(
          offset: Offset(
            _shakeAnimation.value * 4 * (_shakeAnimation.value - 0.5),
            0,
          ),
          child: Icon(
            widget.isCustomWidget ? Icons.edit : Icons.delete,
            size: 32,
            color: _getIconColor(),
          ),
        ),
        const SizedBox(width: 16),
        // Text
        Text(
          widget.isCustomWidget
              ? (widget.isActive
                  ? 'Release to see Actions'
                  : 'Drag here to see Actions')
              : (widget.isActive ? 'Release to Delete' : 'Drag here to Delete'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _getTextColor(),
          ),
        ),
      ],
    );
  }

  Color _getIconColor() {
    if (widget.isActive) {
      return widget.isCustomWidget ? Colors.orange : Colors.red;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Color _getTextColor() {
    if (widget.isActive) {
      return widget.isCustomWidget ? Colors.orange : Colors.red;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}
