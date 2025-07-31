import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';
import '../services/text_property_service.dart';
import '../services/color_utils.dart';
import '../services/icon_utils.dart';


class ViewDummy extends StatefulWidget {
  final bool isVisible;
  final bool isAllowed;
  final Offset position;
  final FlutterWidgetBean? widgetBean;
  final Widget? draggedWidget;
  final bool isCustomWidget;

  const ViewDummy({
    super.key,
    this.isVisible = false,
    this.isAllowed = false,
    this.position = Offset.zero,
    this.widgetBean,
    this.draggedWidget,
    this.isCustomWidget = false,
  });

  @override
  State<ViewDummy> createState() => _ViewDummyState();
}

class _ViewDummyState extends State<ViewDummy> {
  bool _isImageReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.draggedWidget != null) {
      _createWidgetBitmap();
    }
  }

  @override
  void didUpdateWidget(ViewDummy oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.draggedWidget != oldWidget.draggedWidget) {
      _createWidgetBitmap();
    }
  }

  Future<void> _createWidgetBitmap() async {
    if (widget.draggedWidget == null) return;

    try {
      setState(() {
        _isImageReady = true;
      });
    } catch (e) {
      print('ViewDummy: Error creating widget preview: $e');
      setState(() {
        _isImageReady = true;
      });
    }
  }

  Widget _buildTempWidget() {
    if (widget.widgetBean != null) {
      switch (widget.widgetBean!.type) {
        case 'Text':
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              TextPropertyService.getText(widget.widgetBean!.properties),
              style: TextPropertyService.getTextStyle(
                  context, widget.widgetBean!.properties, 1.0),
            ),
          );
        case 'Button':
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.widgetBean!.properties['text'] ?? 'Button',
              style: const TextStyle(color: Colors.white),
            ),
          );
        case 'Container':
          return Container(
            width: 100,
            height: 60,
            decoration: BoxDecoration(
              color: ColorUtils.parseColor(
                      widget.widgetBean!.properties['backgroundColor']) ??
                  Colors.transparent,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(child: Text('Container')),
          );
        default:
          return Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                widget.widgetBean!.type,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
      }
    }

    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(child: Text('Widget')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: _buildDummyContent(),
    );
  }

  Widget _buildDummyContent() {
    return Opacity(
      opacity: 0.5,
      child: Stack(
        children: [
          _buildWidgetPreview(),

          if (!widget.isAllowed)
            Positioned.fill(
              child: Container(
                color: Colors.red.withOpacity(0.3),
                child: const Center(
                  child: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWidgetPreview() {
    if (widget.widgetBean != null) {
      final widgetBean = widget.widgetBean!;
      return Container(
        width: widgetBean.position.width > 0 ? widgetBean.position.width : 100,
        height:
            widgetBean.position.height > 0 ? widgetBean.position.height : 50,
        child: _buildWidgetTypePreview(),
      );
    }

    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey),
      ),
      child: const Center(
        child: Icon(
          Icons.widgets,
          color: Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildWidgetTypePreview() {
    final type = widget.widgetBean!.type;
    final properties = widget.widgetBean!.properties;

    switch (type) {
      case 'Text':
        return Center(
          child: Text(
            TextPropertyService.getText(properties),
            style: TextPropertyService.getTextStyle(context, properties, 1.0)
                .copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: _parseTextAlign(properties['textAlign']),
          ),
        );
      case 'TextField':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Text(
            properties['hint'] ?? 'Text Field',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        );
      case 'Icon':
        return Center(
          child: Icon(
            IconUtils.getIconFromName(properties['icon'] ?? 'star'),
            color: Colors.white,
            size: double.tryParse(properties['size']?.toString() ?? '24') ?? 24,
          ),
        );
      case 'Row':
      case 'Column':
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(
              type,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      case 'Container':
        return Container(
          decoration: BoxDecoration(
            color: ColorUtils.parseColor(properties['backgroundColor']),
            borderRadius: BorderRadius.circular(
              double.tryParse(properties['borderRadius']?.toString() ?? '0') ??
                  0,
            ),
            border: Border.all(
              color: ColorUtils.parseColor(properties['borderColor']) ??
                  Colors.white.withOpacity(0.5),
              width: double.tryParse(
                      properties['borderWidth']?.toString() ?? '1') ??
                  1,
            ),
          ),
          child: Center(
            child: Text(
              'Container',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      default:
        return Center(
          child: Text(
            type,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
    }
  }

  TextAlign _parseTextAlign(dynamic textAlign) {
    if (textAlign == null) return TextAlign.start;
    switch (textAlign.toString().toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.start;
    }
  }

  Color? _parseColor(dynamic colorValue) {
    if (colorValue == null) return null;

    if (colorValue is Color) return colorValue;

    if (colorValue is String) {
      if (colorValue.startsWith('#')) {
        try {
          return Color(int.parse(colorValue.replaceFirst('#', '0xFF')));
        } catch (e) {
          return null;
        }
      }

      switch (colorValue.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'yellow':
          return Colors.yellow;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'pink':
          return Colors.pink;
        case 'brown':
          return Colors.brown;
        case 'grey':
        case 'gray':
          return Colors.grey;
        case 'black':
          return Colors.black;
        case 'white':
          return Colors.white;
        default:
          return null;
      }
    }

    return null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
