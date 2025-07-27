import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/flutter_widget_bean.dart';
import '../models/view_info.dart';
import '../services/view_info_service.dart' as view_service;
import '../services/widget_factory_service.dart';
import 'view_dummy.dart';

/// Flutter Device Frame (Center) - EXACTLY matches Sketchware Pro's ViewPane
///
/// SIMPLIFIED DESIGN:
/// - Pure white background (matches Sketchware Pro)
/// - Simple border (no device simulation)
/// - Red highlight colors (matches Sketchware Pro)
/// - Optional ViewDummy for enhanced feedback
/// - Maintains sophisticated ViewInfo system
///
/// FEATURES:
/// - Coordinate-based drop zone detection
/// - Scale-aware widget positioning
/// - Enhanced drag feedback (optional)
/// - Grid background for alignment
class FlutterDeviceFrame extends StatefulWidget {
  final List<FlutterWidgetBean> widgets;
  final FlutterWidgetBean? selectedWidget;
  final Function(FlutterWidgetBean) onWidgetSelected;
  final Function(FlutterWidgetBean) onWidgetMoved;
  final Function(FlutterWidgetBean) onWidgetAdded;

  const FlutterDeviceFrame({
    super.key,
    required this.widgets,
    this.selectedWidget,
    required this.onWidgetSelected,
    required this.onWidgetMoved,
    required this.onWidgetAdded,
  });

  @override
  State<FlutterDeviceFrame> createState() => _FlutterDeviceFrameState();
}

class _FlutterDeviceFrameState extends State<FlutterDeviceFrame> {
  late view_service.ViewInfoService _viewInfoService;
  double _scale = 1.0;
  bool _showViewDummy = true; // Optional ViewDummy toggle

  // SKETCHWARE PRO STYLE: ViewDummy state management
  bool _isViewDummyVisible = false;
  bool _isViewDummyAllowed = false;
  Offset _viewDummyPosition = Offset.zero;
  FlutterWidgetBean? _viewDummyWidget;

  @override
  void initState() {
    super.initState();
    _viewInfoService = view_service.ViewInfoService();
  }

  @override
  void dispose() {
    _viewInfoService.dispose();
    super.dispose();
  }

  // SKETCHWARE PRO STYLE: Drop zone detection is now handled directly by ViewInfoService

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Stack(
        children: [
          Column(
            children: [
              // Device Frame Header (like Sketchware Pro)
              _buildDeviceHeader(),

              // Device Frame Content with Phone Simulation
              Expanded(
                child: _buildPhoneSimulation(),
              ),
            ],
          ),

          // Delete Zone (overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const SizedBox.shrink(), // Removed DeleteZone
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone_android,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sketchware Pro Style Preview',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // ViewDummy Toggle (optional enhanced feedback)
          IconButton(
            icon: Icon(
              _showViewDummy ? Icons.visibility : Icons.visibility_off,
              size: 18,
            ),
            onPressed: () => setState(() => _showViewDummy = !_showViewDummy),
            tooltip: 'Toggle Enhanced Drag Feedback',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          // Zoom Controls
          IconButton(
            icon: const Icon(Icons.zoom_in, size: 18),
            onPressed: () =>
                setState(() => _scale = (_scale + 0.1).clamp(0.5, 2.0)),
            tooltip: 'Zoom In',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, size: 18),
            onPressed: () =>
                setState(() => _scale = (_scale - 0.1).clamp(0.5, 2.0)),
            tooltip: 'Zoom Out',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneSimulation() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available space like Sketchware Pro
          final availableWidth = constraints.maxWidth - 40;
          final availableHeight = constraints.maxHeight - 40;

          // Calculate scale factors like Sketchware Pro
          final scaleX =
              availableWidth / 360.0; // 360dp is Sketchware Pro's base width
          final scaleY =
              availableHeight / 640.0; // 640dp is Sketchware Pro's base height

          // Use the smaller scale to maintain aspect ratio (like Sketchware Pro)
          final calculatedScale = _scale * (scaleX < scaleY ? scaleX : scaleY);

          // Calculate final content dimensions
          final contentWidth = 360 * calculatedScale;
          final contentHeight = 640 * calculatedScale;

          // SKETCHWARE PRO STYLE: Simple white container with border
          return Container(
            width: contentWidth,
            height: contentHeight,
            decoration: BoxDecoration(
              color: Colors.white, // Pure white like Sketchware Pro
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: _buildContentArea(calculatedScale),
          );
        },
      ),
    );
  }

  // Removed status bar and toolbar methods - simplified to match Sketchware Pro

  // SKETCHWARE PRO STYLE CONTENT AREA
  Widget _buildContentArea(double scale) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerSize = Size(constraints.maxWidth, constraints.maxHeight);

        // SKETCHWARE PRO STYLE: Update ViewInfoService with container information
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final containerOffset = renderBox.localToGlobal(Offset.zero);
            _viewInfoService.updateContainer(
              size: containerSize,
              offset: containerOffset,
            );
            _viewInfoService.updateScales(
              outerScale: _scale,
              innerScale: scale,
            );
          }
        });

        return Container(
          color: Colors.white,
          child: Stack(
            children: [
              // Background grid (like Sketchware Pro)
              CustomPaint(
                painter: GridPainter(scale: scale),
                size: Size.infinite,
              ),

              // SKETCHWARE PRO STYLE: Render all placed widgets
              _buildSketchwareProWidgets(scale),

              // SKETCHWARE PRO STYLE: Drag target for palette widgets
              _buildDragTargetOverlay(),

              // Optional ViewDummy for enhanced drag feedback
              if (_showViewDummy) _buildViewDummyOverlay(),
            ],
          ),
        );
      },
    );
  }

  // SKETCHWARE PRO STYLE: Drag target overlay for palette widgets
  Widget _buildDragTargetOverlay() {
    return Positioned.fill(
      child: DragTarget<FlutterWidgetBean>(
        // SKETCHWARE PRO STYLE: Accept all widgets
        onWillAccept: (data) {
          print('🎯 DRAG TARGET: Will accept ${data?.type}'); // Debug output
          return data != null;
        },

        // SKETCHWARE PRO STYLE: Handle widget drop with coordinate transformation
        onAccept: (widgetData) {
          print('🎯 WIDGET DROPPED: ${widgetData.type}'); // Debug output
          _handleWidgetDrop(widgetData);
        },

        // SKETCHWARE PRO STYLE: Visual feedback during drag with coordinate transformation
        onMove: (details) {
          print(
              '🎯 DRAG MOVE: ${details.data.type} at ${details.offset}'); // Debug output
          _handleDragMove(details);
        },

        // SKETCHWARE PRO STYLE: Hide ViewDummy when drag leaves
        onLeave: (data) {
          print('🎯 DRAG LEAVE: ${data?.type}'); // Debug output
          _hideViewDummy();
        },

        // SKETCHWARE PRO STYLE: Build drag target with red highlight colors
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: candidateData.isNotEmpty
                    ? const Color(0xffff5955) // Sketchware Pro red
                    : Colors.transparent,
                width: candidateData.isNotEmpty ? 2 : 0,
              ),
              color: candidateData.isNotEmpty
                  ? const Color(
                      0x82ff5955) // Sketchware Pro semi-transparent red
                  : Colors.transparent,
            ),
            child: Center(
              child: candidateData.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Drop ${candidateData.first?.type ?? 'widget'} here',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// SKETCHWARE PRO STYLE: Handle drag move with coordinate transformation
  void _handleDragMove(DragTargetDetails<FlutterWidgetBean> details) {
    // SKETCHWARE PRO STYLE: Transform raw coordinates to scaled coordinates
    final transformedCoordinates =
        _viewInfoService.transformCoordinates(details.offset);

    // SKETCHWARE PRO STYLE: Check if coordinates are within container
    if (!_viewInfoService.isWithinContainer(details.offset)) {
      _viewInfoService.resetViewHighlight();
      _updateViewDummy(false, details.offset, details.data);
      return;
    }

    // SKETCHWARE PRO STYLE: Get widget size for positioning
    final widgetSize = _getWidgetSize(details.data);

    // SKETCHWARE PRO STYLE: Update view highlight with transformed coordinates
    _viewInfoService.updateViewHighlight(transformedCoordinates, widgetSize);

    // SKETCHWARE PRO STYLE: Store current drop position for precise positioning
    _viewInfoService.setCurrentDropZone(view_service.DropZoneInfo(
      viewInfo: ViewInfo(
        rect: Rect.fromLTWH(transformedCoordinates.dx,
            transformedCoordinates.dy, widgetSize.width, widgetSize.height),
        view: Container(),
        index: 0,
        depth: 0,
      ),
      position: transformedCoordinates,
      size: widgetSize,
      isValid: true,
    ));

    // SKETCHWARE PRO STYLE: Update ViewDummy for visual feedback
    _updateViewDummy(true, details.offset, details.data);
  }

  /// SKETCHWARE PRO STYLE: Handle widget drop with precise positioning
  void _handleWidgetDrop(FlutterWidgetBean widgetData) {
    // SKETCHWARE PRO STYLE: Get the actual drop position from the last drag move
    final dropPosition = _viewInfoService.currentDropZone?.position ??
        Offset(_viewInfoService.containerSize.width / 2,
            _viewInfoService.containerSize.height / 2);

    final widgetSize = _getWidgetSize(widgetData);

    // SKETCHWARE PRO STYLE: Calculate precise position with bounds checking
    final precisePosition =
        _calculatePreciseDropPosition(dropPosition, widgetSize);

    // SKETCHWARE PRO STYLE: Create widget with precise position and default properties
    final positionedWidget = _createPositionedWidgetWithDefaults(
      widgetData,
      precisePosition,
      widgetSize,
    );

    // SKETCHWARE PRO STYLE: Add widget through the view model for proper history management
    if (widget.onWidgetAdded != null) {
      widget.onWidgetAdded!(positionedWidget);
    }

    // SKETCHWARE PRO STYLE: Select the newly added widget
    if (widget.onWidgetSelected != null) {
      widget.onWidgetSelected!(positionedWidget);
    }

    // SKETCHWARE PRO STYLE: Hide ViewDummy after successful drop
    _hideViewDummy();

    print('🎯 WIDGET DROPPED: ${widgetData.type} at ${precisePosition}');
  }

  /// SKETCHWARE PRO STYLE: Calculate precise drop position with bounds checking
  Offset _calculatePreciseDropPosition(Offset dropPosition, Size widgetSize) {
    final containerSize = _viewInfoService.containerSize;

    // SKETCHWARE PRO STYLE: Ensure widget fits within container bounds
    double x = dropPosition.dx;
    double y = dropPosition.dy;

    // SKETCHWARE PRO STYLE: Adjust for widget size to prevent overflow
    if (x + widgetSize.width > containerSize.width) {
      x = containerSize.width - widgetSize.width;
    }
    if (y + widgetSize.height > containerSize.height) {
      y = containerSize.height - widgetSize.height;
    }

    // SKETCHWARE PRO STYLE: Ensure minimum position
    x = x.clamp(0.0, containerSize.width - widgetSize.width);
    y = y.clamp(0.0, containerSize.height - widgetSize.height);

    return Offset(x, y);
  }

  /// SKETCHWARE PRO STYLE: Create widget with default properties like Sketchware Pro
  FlutterWidgetBean _createPositionedWidgetWithDefaults(
    FlutterWidgetBean widgetData,
    Offset position,
    Size widgetSize,
  ) {
    // SKETCHWARE PRO STYLE: Create new layout with default properties based on widget type
    LayoutBean layout;

    // SKETCHWARE PRO STYLE: Set default size based on widget type
    switch (widgetData.type) {
      case 'Row':
      case 'Column':
        // SKETCHWARE PRO STYLE: Layout widgets get MATCH_PARENT by default
        layout = LayoutBean(
          marginLeft: position.dx.toDouble(),
          marginTop: position.dy.toDouble(),
          marginRight: 0.0,
          marginBottom: 0.0,
          width: -1, // MATCH_PARENT
          height: -2, // WRAP_CONTENT
          paddingLeft: 8,
          paddingTop: 8,
          paddingRight: 8,
          paddingBottom: 8,
          backgroundColor: 0xFFFFFFFF,
          layoutGravity: 0,
        );
        break;
      case 'Stack':
        // SKETCHWARE PRO STYLE: Stack gets MATCH_PARENT by default
        layout = LayoutBean(
          marginLeft: position.dx.toDouble(),
          marginTop: position.dy.toDouble(),
          marginRight: 0.0,
          marginBottom: 0.0,
          width: -1, // MATCH_PARENT
          height: -1, // MATCH_PARENT
          paddingLeft: 8,
          paddingTop: 8,
          paddingRight: 8,
          paddingBottom: 8,
          backgroundColor: 0xFFFFFFFF,
          layoutGravity: 0,
        );
        break;
      default:
        // SKETCHWARE PRO STYLE: Regular widgets get WRAP_CONTENT by default
        layout = LayoutBean(
          marginLeft: position.dx.toDouble(),
          marginTop: position.dy.toDouble(),
          marginRight: 0.0,
          marginBottom: 0.0,
          width: -2, // WRAP_CONTENT
          height: -2, // WRAP_CONTENT
          paddingLeft: 8,
          paddingTop: 8,
          paddingRight: 8,
          paddingBottom: 8,
          backgroundColor: 0xFFFFFFFF,
          layoutGravity: 0,
        );
        break;
    }

    // SKETCHWARE PRO STYLE: Create new widget with updated layout and default properties
    final updatedWidget = FlutterWidgetBean(
      id: widgetData.id,
      type: widgetData.type,
      properties: Map.from(widgetData.properties)
        ..addAll(_getDefaultProperties(widgetData.type)),
      children: List.from(widgetData.children),
      position: PositionBean(
        x: position.dx,
        y: position.dy,
        width: widgetSize.width,
        height: widgetSize.height,
      ),
      events: Map.from(widgetData.events),
      layout: layout,
    );

    return updatedWidget;
  }

  /// SKETCHWARE PRO STYLE: Get default properties for widget type
  Map<String, dynamic> _getDefaultProperties(String widgetType) {
    switch (widgetType) {
      case 'Text':
        return {
          'text': 'Text',
          'textSize': '14.0',
          'textColor': '#000000',
          'backgroundColor': '#FFFFFF',
          'textType': 'normal',
          'lines': '1',
          'singleLine': 'false',
        };
      case 'TextField':
        return {
          'text': '',
          'hint': 'Enter text',
          'inputType': 'text',
          'singleLine': 'true',
          'lines': '1',
          'textSize': '14.0',
          'textColor': '#000000',
          'hintColor': '#757575',
          'backgroundColor': '#FFFFFF',
        };
      case 'Container':
        return {
          'backgroundColor': '#FFFFFF',
          'borderColor': '#000000',
          'borderWidth': '1.0',
          'borderRadius': '0.0',
          'width': '150.0',
          'height': '80.0',
        };
      case 'Icon':
        return {
          'iconName': 'star',
          'iconSize': 24.0, // Fixed: Use double instead of string
          'iconColor': '#000000',
          'backgroundColor': '#FFFFFF',
        };
      case 'Row':
        return {
          'mainAxisAlignment': 'start',
          'crossAxisAlignment': 'center',
          'mainAxisSize': 'max',
          'backgroundColor': '#FFFFFF',
        };
      case 'Column':
        return {
          'mainAxisAlignment': 'start',
          'crossAxisAlignment': 'center',
          'mainAxisSize': 'max',
          'backgroundColor': '#FFFFFF',
        };
      case 'Stack':
        return {
          'alignment': 'topLeft',
          'fit': 'loose',
          'backgroundColor': '#FFFFFF',
        };
      default:
        return {
          'backgroundColor': '#FFFFFF',
        };
    }
  }

  /// SKETCHWARE PRO STYLE: Get default layout for widget type
  LayoutBean _getDefaultLayout(String widgetType) {
    switch (widgetType) {
      case 'Text':
      case 'TextField':
      case 'Icon':
        return LayoutBean(
          width: LayoutBean.WRAP_CONTENT,
          height: LayoutBean.WRAP_CONTENT,
          marginLeft: 8,
          marginTop: 8,
          marginRight: 8,
          marginBottom: 8,
          paddingLeft: 4,
          paddingTop: 4,
          paddingRight: 4,
          paddingBottom: 4,
        );
      case 'Container':
        return LayoutBean(
          width: LayoutBean.WRAP_CONTENT,
          height: LayoutBean.WRAP_CONTENT,
          marginLeft: 8,
          marginTop: 8,
          marginRight: 8,
          marginBottom: 8,
          paddingLeft: 8,
          paddingTop: 8,
          paddingRight: 8,
          paddingBottom: 8,
        );
      case 'Row':
      case 'Column':
      case 'Stack':
        return LayoutBean(
          width: LayoutBean.MATCH_PARENT,
          height: LayoutBean.WRAP_CONTENT,
          marginLeft: 8,
          marginTop: 8,
          marginRight: 8,
          marginBottom: 8,
          paddingLeft: 8,
          paddingTop: 8,
          paddingRight: 8,
          paddingBottom: 8,
        );
      default:
        return LayoutBean(
          width: LayoutBean.WRAP_CONTENT,
          height: LayoutBean.WRAP_CONTENT,
          marginLeft: 8,
          marginTop: 8,
          marginRight: 8,
          marginBottom: 8,
          paddingLeft: 4,
          paddingTop: 4,
          paddingRight: 4,
          paddingBottom: 4,
        );
    }
  }

  /// SKETCHWARE PRO STYLE: Update ViewDummy state for visual feedback
  void _updateViewDummy(
      bool isAllowed, Offset position, FlutterWidgetBean widget) {
    setState(() {
      _isViewDummyVisible = true;
      _isViewDummyAllowed = isAllowed;
      _viewDummyPosition = position;
      _viewDummyWidget = widget;
    });
  }

  /// SKETCHWARE PRO STYLE: Hide ViewDummy
  void _hideViewDummy() {
    setState(() {
      _isViewDummyVisible = false;
      _viewDummyWidget = null;
    });
  }

  /// SKETCHWARE PRO STYLE: Get widget size based on type
  Size _getWidgetSize(FlutterWidgetBean widget) {
    switch (widget.type) {
      case 'Row':
      case 'Column':
        return const Size(200, 100); // Layout widgets
      case 'Stack':
        return const Size(200, 150); // Stack widget with proper dimensions
      case 'Container':
        return const Size(150, 80); // Container widget
      case 'Text':
        return const Size(120, 30); // Text widget
      case 'TextField':
        return const Size(150, 40); // Text field widget
      case 'Icon':
        return const Size(40, 40); // Icon widget
      default:
        return const Size(100, 50); // Default size
    }
  }

  /// SKETCHWARE PRO STYLE: Generate unique widget ID
  String _generateWidgetId(String widgetType) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${widgetType.toLowerCase()}_$timestamp';
  }

  // SKETCHWARE PRO STYLE WIDGET RENDERING
  Widget _buildSketchwareProWidgets(double scale) {
    // Drop zones are now handled by ViewInfoService

    return Stack(
      children: widget.widgets
          .map((widgetBean) => _buildSketchwareProWidget(widgetBean))
          .toList(),
    );
  }

  /// SKETCHWARE PRO STYLE: Build widget with selection capability
  Widget _buildSketchwareProWidget(FlutterWidgetBean widgetBean) {
    final isSelected = widget.selectedWidget?.id == widgetBean.id;
    final widgetKey = GlobalKey();
    final scale = 1.0; // SKETCHWARE PRO STYLE: Use 1.0 scale for mobile frame

    // Calculate position like Sketchware Pro
    final position = _calculateWidgetPosition(widgetBean, scale);

    return Positioned(
      left: position.left,
      top: position.top,
      child: GestureDetector(
        onTap: () {
          // SKETCHWARE PRO STYLE: Select widget and show property panel
          print('🎯 WIDGET SELECTED: ${widgetBean.type} (${widgetBean.id})');
          if (widget.onWidgetSelected != null) {
            widget.onWidgetSelected!(widgetBean);
          }
        },
        child: Listener(
          onPointerDown: (details) {
            // SKETCHWARE PRO STYLE: Handle drag start for existing widgets
            _handleExistingWidgetDragStart(widgetBean, details);
          },
          child: Container(
            decoration: BoxDecoration(
              border:
                  isSelected ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: _buildRealWidgetWithScale(widgetBean, scale),
          ),
        ),
      ),
    );
  }

  /// SKETCHWARE PRO STYLE: Handle drag start for existing widgets
  void _handleExistingWidgetDragStart(
      FlutterWidgetBean widgetBean, PointerDownEvent details) {
    // SKETCHWARE PRO STYLE: Allow dragging existing widgets
    print(
        '🎯 EXISTING WIDGET DRAG START: ${widgetBean.type} (${widgetBean.id})');
    // TODO: Implement drag functionality for existing widgets
  }

  // SKETCHWARE PRO STYLE POSITION CALCULATION
  WidgetPosition _calculateWidgetPosition(
      FlutterWidgetBean widgetBean, double scale) {
    // Like Sketchware Pro's LayoutParams system
    double width = widgetBean.position.width * scale;
    double height = widgetBean.position.height * scale;

    // Handle MATCH_PARENT and WRAP_CONTENT like Sketchware Pro
    if (widgetBean.layout.width == LayoutBean.MATCH_PARENT) {
      width = 360 * scale; // Full width
    } else if (widgetBean.layout.width == LayoutBean.WRAP_CONTENT) {
      width = _calculateWrapContentWidth(widgetBean, scale);
    }

    if (widgetBean.layout.height == LayoutBean.MATCH_PARENT) {
      height = 640 * scale; // Full height
    } else if (widgetBean.layout.height == LayoutBean.WRAP_CONTENT) {
      height = _calculateWrapContentHeight(widgetBean, scale);
    }

    // SKETCHWARE PRO STYLE: Use position coordinates for positioning (reverted to previous behavior)
    return WidgetPosition(
      left: widgetBean.position.x * scale,
      top: widgetBean.position.y * scale,
      width: width,
      height: height,
    );
  }

  double _calculateWrapContentWidth(
      FlutterWidgetBean widgetBean, double scale) {
    // Calculate based on content like Sketchware Pro
    switch (widgetBean.type) {
      case 'TextView':
        final text = widgetBean.properties['text'] ?? 'Text';
        final fontSize =
            double.tryParse(widgetBean.properties['fontSize'] ?? '14') ?? 14.0;
        return (text.length * fontSize * 0.6 + 16) *
            scale; // Approximate text width
      case 'Button':
        final text = widgetBean.properties['text'] ?? 'Button';
        final fontSize =
            double.tryParse(widgetBean.properties['fontSize'] ?? '14') ?? 14.0;
        return (text.length * fontSize * 0.6 + 32) * scale; // Button padding
      default:
        return widgetBean.position.width * scale;
    }
  }

  double _calculateWrapContentHeight(
      FlutterWidgetBean widgetBean, double scale) {
    // Calculate based on content like Sketchware Pro
    switch (widgetBean.type) {
      case 'TextView':
        final fontSize =
            double.tryParse(widgetBean.properties['fontSize'] ?? '14') ?? 14.0;
        return (fontSize + 8) * scale; // Text height + padding
      case 'Button':
        final fontSize =
            double.tryParse(widgetBean.properties['fontSize'] ?? '14') ?? 14.0;
        return (fontSize + 16) * scale; // Button height
      default:
        return widgetBean.position.height * scale;
    }
  }

  // SKETCHWARE PRO STYLE: Drop zone detection is now handled by ViewInfoService

  // Build real widget with proper scale using Factory Service (like Sketchware Pro's createItemView)
  Widget _buildRealWidgetWithScale(FlutterWidgetBean widgetBean, double scale) {
    final isSelected = widget.selectedWidget?.id == widgetBean.id;

    // Use the factory service to create the widget (like Sketchware Pro's createItemView)
    return WidgetFactoryService.createWidget(
      widgetBean,
      isSelected: isSelected,
      scale: scale,
      onTap: () => widget.onWidgetSelected(widgetBean),
    );
  }

  Widget _buildTextWidgetWithScale(FlutterWidgetBean widgetBean, double scale) {
    final text = widgetBean.properties['text'] ?? 'Text View';
    final fontSize =
        double.tryParse(widgetBean.properties['fontSize'] ?? '14') ?? 14.0;
    final textColor =
        _parseColor(widgetBean.properties['textColor'] ?? '#000000');
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');
    final fontWeight =
        _parseFontWeight(widgetBean.properties['fontWeight'] ?? 'normal');
    final textAlign =
        _parseTextAlign(widgetBean.properties['gravity'] ?? 'left');

    return Container(
      color: backgroundColor,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize * scale,
            color: textColor,
            fontWeight: fontWeight,
          ),
          textAlign: textAlign,
          maxLines: int.tryParse(widgetBean.properties['lines'] ?? '1') ?? 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTextFieldWithScale(FlutterWidgetBean widgetBean, double scale) {
    final hint = widgetBean.properties['hint'] ?? 'Enter text';
    final text = widgetBean.properties['text'] ?? '';
    final fontSize =
        double.tryParse(widgetBean.properties['fontSize'] ?? '14') ?? 14.0;
    final textColor =
        _parseColor(widgetBean.properties['textColor'] ?? '#000000');
    final hintColor =
        _parseColor(widgetBean.properties['hintColor'] ?? '#757575');
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: TextField(
        controller: TextEditingController(text: text),
        enabled: false, // Read-only in preview
        style: TextStyle(
          fontSize: fontSize * scale,
          color: textColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: fontSize * scale,
            color: hintColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4 * scale),
          ),
          contentPadding: EdgeInsets.all(8 * scale),
        ),
      ),
    );
  }

  Widget _buildElevatedButtonWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    final text = widgetBean.properties['text'] ?? 'Button';
    final fontSize =
        double.tryParse(widgetBean.properties['fontSize'] ?? '14') ?? 14.0;
    final textColor =
        _parseColor(widgetBean.properties['textColor'] ?? '#FFFFFF');
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#2196F3');

    return Container(
      color: backgroundColor,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize * scale,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildImageViewWithScale(FlutterWidgetBean widgetBean, double scale) {
    final src = widgetBean.properties['src'] ?? 'default_image';
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#F5F5F5');

    return Container(
      color: backgroundColor,
      child: Center(
        child: Icon(
          Icons.image,
          size: 32 * scale,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildRowWidgetWithScale(FlutterWidgetBean widgetBean, double scale) {
    final orientation = widgetBean.properties['orientation'] ?? 'vertical';
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');
    final gravity =
        _parseMainAxisAlignment(widgetBean.properties['gravity'] ?? 'left');

    return Container(
      color: backgroundColor,
      child: orientation == 'vertical'
          ? Column(
              mainAxisAlignment: gravity,
              children: _buildChildWidgetsWithScale(widgetBean, scale),
            )
          : Row(
              mainAxisAlignment: gravity,
              children: _buildChildWidgetsWithScale(widgetBean, scale),
            ),
    );
  }

  Widget _buildRelativeLayoutWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: Stack(
        children: _buildChildWidgetsWithScale(widgetBean, scale),
      ),
    );
  }

  Widget _buildScrollViewWithScale(FlutterWidgetBean widgetBean, double scale) {
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: _buildChildWidgetsWithScale(widgetBean, scale),
        ),
      ),
    );
  }

  Widget _buildListViewWithScale(FlutterWidgetBean widgetBean, double scale) {
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');
    final itemCount =
        int.tryParse(widgetBean.properties['itemCount'] ?? '3') ?? 3;

    return Container(
      color: backgroundColor,
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item ${index + 1}'),
            leading: Icon(Icons.list),
          );
        },
      ),
    );
  }

  Widget _buildProgressBarWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    final progress =
        double.tryParse(widgetBean.properties['progress'] ?? '50') ?? 50.0;
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#F5F5F5');

    return Container(
      color: backgroundColor,
      child: Center(
        child: SizedBox(
          width: 200 * scale,
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeekBarWithScale(FlutterWidgetBean widgetBean, double scale) {
    final progress =
        double.tryParse(widgetBean.properties['progress'] ?? '50') ?? 50.0;
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#F5F5F5');

    return Container(
      color: backgroundColor,
      child: Center(
        child: SizedBox(
          width: 200 * scale,
          child: Slider(
            value: progress,
            min: 0,
            max: 100,
            onChanged: (value) {
              // Read-only in preview
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchWithScale(FlutterWidgetBean widgetBean, double scale) {
    final checked = widgetBean.properties['checked'] == 'true';
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: Center(
        child: Switch(
          value: checked,
          onChanged: (value) {
            // Read-only in preview
          },
        ),
      ),
    );
  }

  Widget _buildCheckBoxWithScale(FlutterWidgetBean widgetBean, double scale) {
    final text = widgetBean.properties['text'] ?? 'Check Box';
    final checked = widgetBean.properties['checked'] == 'true';
    final textColor =
        _parseColor(widgetBean.properties['textColor'] ?? '#000000');
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
            value: checked,
            onChanged: (value) {
              // Read-only in preview
            },
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 14 * scale,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioButtonWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    final text = widgetBean.properties['text'] ?? 'Radio Button';
    final checked = widgetBean.properties['checked'] == 'true';
    final textColor =
        _parseColor(widgetBean.properties['textColor'] ?? '#000000');
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Radio<bool>(
            value: true,
            groupValue: checked ? true : false,
            onChanged: (value) {
              // Read-only in preview
            },
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 14 * scale,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinnerWithScale(FlutterWidgetBean widgetBean, double scale) {
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: Center(
        child: DropdownButton<String>(
          value: 'Item 1',
          items: ['Item 1', 'Item 2', 'Item 3'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            // Read-only in preview
          },
        ),
      ),
    );
  }

  Widget _buildCalendarViewWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: Center(
        child: Icon(
          Icons.calendar_today,
          size: 32 * scale,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildWebViewWithScale(FlutterWidgetBean widgetBean, double scale) {
    final url = widgetBean.properties['url'] ?? 'https://example.com';
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.web,
              size: 32 * scale,
              color: Colors.grey[600],
            ),
            SizedBox(height: 8 * scale),
            Text(
              'WebView',
              style: TextStyle(
                fontSize: 12 * scale,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapViewWithScale(FlutterWidgetBean widgetBean, double scale) {
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: Center(
        child: Icon(
          Icons.map,
          size: 32 * scale,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildAdViewWithScale(FlutterWidgetBean widgetBean, double scale) {
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#F5F5F5');

    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ads_click,
              size: 24 * scale,
              color: Colors.grey[600],
            ),
            SizedBox(height: 4 * scale),
            Text(
              'Ad View',
              style: TextStyle(
                fontSize: 10 * scale,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtonWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    final icon = widgetBean.properties['icon'] ?? 'add';
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FF5722');

    return Container(
      color: backgroundColor,
      child: Center(
        child: Icon(
          _parseIcon(icon),
          size: 24 * scale,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUnknownWidgetWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Text(
          widgetBean.type,
          style: TextStyle(
            fontSize: 10 * scale,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildWidgetsWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    // For now, return empty list. In a real implementation, this would
    // build child widgets based on the widget's children property
    return [];
  }

  // Utility methods for parsing properties
  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return Colors.transparent;
    if (colorString.startsWith('#')) {
      try {
        return Color(
            int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        return Colors.transparent;
      }
    }
    return Colors.transparent;
  }

  FontWeight _parseFontWeight(String weight) {
    switch (weight.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  TextAlign _parseTextAlign(String gravity) {
    switch (gravity.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }

  MainAxisAlignment _parseMainAxisAlignment(String gravity) {
    switch (gravity.toLowerCase()) {
      case 'center':
        return MainAxisAlignment.center;
      case 'end':
        return MainAxisAlignment.end;
      case 'spacearound':
        return MainAxisAlignment.spaceAround;
      case 'spacebetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceevenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  IconData _parseIcon(String icon) {
    switch (icon.toLowerCase()) {
      case 'add':
        return Icons.add;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'search':
        return Icons.search;
      case 'share':
        return Icons.share;
      case 'favorite':
        return Icons.favorite;
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.add;
    }
  }

  // Optional ViewDummy overlay for enhanced drag feedback
  Widget _buildViewDummyOverlay() {
    // SKETCHWARE PRO STYLE: ViewDummy provides visual feedback during drag
    if (!_isViewDummyVisible || _viewDummyWidget == null) {
      return const SizedBox.shrink();
    }

    return ViewDummy(
      isVisible: _isViewDummyVisible,
      isAllowed: _isViewDummyAllowed,
      position: _viewDummyPosition,
      widgetBean: _viewDummyWidget,
      isCustomWidget: false,
    );
  }

  // Missing widget rendering methods
  Widget _buildIconWidgetWithScale(FlutterWidgetBean widgetBean, double scale) {
    final iconName = widgetBean.properties['icon'] ?? 'star';
    final size = double.tryParse(widgetBean.properties['size'] ?? '24') ?? 24.0;
    final color = _parseColor(widgetBean.properties['color'] ?? '#000000');
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: Center(
        child: Icon(
          _parseIcon(iconName),
          size: size * scale,
          color: color,
        ),
      ),
    );
  }

  Widget _buildColumnWidgetWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');
    final gravity =
        _parseMainAxisAlignment(widgetBean.properties['gravity'] ?? 'top');

    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: gravity,
        children: _buildChildWidgetsWithScale(widgetBean, scale),
      ),
    );
  }

  Widget _buildContainerWidgetWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');
    final borderColor =
        _parseColor(widgetBean.properties['borderColor'] ?? '#000000');
    final borderWidth =
        double.tryParse(widgetBean.properties['borderWidth'] ?? '1') ?? 1.0;
    final borderRadius =
        double.tryParse(widgetBean.properties['borderRadius'] ?? '0') ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: borderWidth * scale,
        ),
        borderRadius: BorderRadius.circular(borderRadius * scale),
      ),
      child: _buildChildWidgetsWithScale(widgetBean, scale).isNotEmpty
          ? _buildChildWidgetsWithScale(widgetBean, scale).first
          : Center(
              child: Text(
                'Container',
                style: TextStyle(
                  fontSize: 12 * scale,
                  color: Colors.grey[600],
                ),
              ),
            ),
    );
  }

  Widget _buildStackWidgetWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    final backgroundColor =
        _parseColor(widgetBean.properties['backgroundColor'] ?? '#FFFFFF');

    return Container(
      color: backgroundColor,
      child: Stack(
        children: _buildChildWidgetsWithScale(widgetBean, scale),
      ),
    );
  }
}

// SKETCHWARE PRO STYLE DATA STRUCTURES
class WidgetPosition {
  final double left;
  final double top;
  final double width;
  final double height;

  WidgetPosition({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class GridPainter extends CustomPainter {
  final double scale;

  GridPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1 * scale;

    final gridSize = 20 * scale;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
