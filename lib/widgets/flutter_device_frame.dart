import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';
import '../models/view_info.dart';
import '../services/view_info_service.dart' as view_service;
import '../services/view_info_service.dart' show DropZoneInfo;
import '../services/widget_sizing_service.dart';
import '../services/mobile_frame_widget_factory_service.dart';
import '../services/android_native_touch_service.dart';
import '../services/android_native_measurement_service.dart';
import '../controllers/mobile_frame_touch_controller.dart';
import '../services/selection_service.dart';
import '../services/text_property_service.dart';
import '../services/color_utils.dart';
import '../services/icon_utils.dart';
import 'view_dummy.dart';
import 'dart:math' as math;

/// Flutter Device Frame (Center) - EXACTLY matches Sketchware Pro's ViewPane
///
/// SKETCHWARE PRO STYLE DESIGN:
/// - Rectangular vertical frame (no rounded phone frame)
/// - Blue status bar (0xff0084c2) with "main.dart" and system indicators
/// - Blue AppBar (0xff008dcd) with "AppBar" text (Flutter terminology)
/// - Pure white content area with grid
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
  final Function(FlutterWidgetBean)? onWidgetSelected;
  final Function(FlutterWidgetBean)? onWidgetMoved;
  final Function(FlutterWidgetBean, {Size? containerSize})? onWidgetAdded;
  final VoidCallback?
      onBackgroundTapped; // SKETCHWARE PRO: Clear selection on background tap

  const FlutterDeviceFrame({
    super.key,
    required this.widgets,
    this.selectedWidget,
    this.onWidgetSelected,
    this.onWidgetMoved,
    this.onWidgetAdded,
    this.onBackgroundTapped, // SKETCHWARE PRO: Callback for background taps
  });

  @override
  State<FlutterDeviceFrame> createState() => _FlutterDeviceFrameState();
}

class _FlutterDeviceFrameState extends State<FlutterDeviceFrame> {
  view_service.ViewInfoService? _viewInfoService;
  double _scale = 1.0;
  bool _showViewDummy = true; // Optional ViewDummy toggle

  // ANDROID NATIVE: Touch service for native-like touch handling
  late AndroidNativeTouchService _androidTouchService;

  // SKETCHWARE PRO STYLE: ViewDummy state management
  bool _isViewDummyVisible = false;
  bool _isViewDummyAllowed = false;
  Offset _viewDummyPosition = Offset.zero;
  FlutterWidgetBean? _viewDummyWidget;

  // SKETCHWARE PRO STYLE: Visual feedback state management (like ViewPane.java)
  bool _isVisualFeedbackVisible = false;
  FlutterWidgetBean? _draggedWidgetData;

  // SKETCHWARE PRO STYLE: Mobile frame touch and selection controllers
  late MobileFrameTouchController _touchController;
  late SelectionService _selectionService;

  @override
  void initState() {
    super.initState();
    _initializeViewInfoService();
    _initializeMobileFrameControllers();
    _androidTouchService = AndroidNativeTouchService();

    // ANDROID NATIVE: Set up touch service callbacks for property panel
    _androidTouchService.onWidgetTapped = (widget) {
      this.widget.onWidgetSelected?.call(widget);
    };

    _androidTouchService.onWidgetLongPressed = (widget) {
      // Handle long press for drag operations
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// SKETCHWARE PRO STYLE: Initialize ViewInfoService safely
  void _initializeViewInfoService() {
    if (_viewInfoService == null || _viewInfoService!.disposed) {
      _viewInfoService = view_service.ViewInfoService();
    } else {
      // SKETCHWARE PRO STYLE: Reset service for tab switching
      _viewInfoService!.resetForTabSwitch();
    }
  }

  /// SKETCHWARE PRO STYLE: Check if service is available
  bool get _isServiceAvailable =>
      _viewInfoService != null && !_viewInfoService!.disposed;

  /// SKETCHWARE PRO STYLE: Get ViewInfoService safely
  view_service.ViewInfoService get _safeViewInfoService {
    _initializeViewInfoService();
    return _viewInfoService!;
  }

  /// SKETCHWARE PRO STYLE: Initialize mobile frame controllers
  void _initializeMobileFrameControllers() {
    _touchController = MobileFrameTouchController();
    _selectionService = SelectionService();

    // Setup touch controller callbacks
    _touchController.setCallbacks(
      onWidgetSelected: (widget) {
        this.widget.onWidgetSelected?.call(widget);
      },
      onWidgetDragStart: (widget, position) {
        _handleWidgetDragStart(widget, position);
      },
      onWidgetDragUpdate: (widget, position) {
        _handleWidgetDragUpdate(widget, position);
      },
      onWidgetDragEnd: (widget, position) {
        _handleWidgetDragEnd(widget, position);
      },
      onWidgetLongPress: (widget) {
        // Handle long press feedback
      },
      onDragStateChanged: (isDragging) {
        // Handle drag state changes
      },
    );
  }

  /// SKETCHWARE PRO STYLE: Handle widget drag start
  void _handleWidgetDragStart(FlutterWidgetBean widget, Offset position) {
    // TODO: Implement drag start logic for existing widgets
  }

  /// SKETCHWARE PRO STYLE: Handle widget drag update
  void _handleWidgetDragUpdate(FlutterWidgetBean widget, Offset position) {
    // TODO: Implement drag update logic for existing widgets
    // Call the widget's onWidgetMoved callback
    this.widget.onWidgetMoved?.call(widget);
  }

  /// SKETCHWARE PRO STYLE: Handle widget drag end
  void _handleWidgetDragEnd(FlutterWidgetBean widget, Offset position) {
    // TODO: Implement drag end logic for existing widgets
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
              // SKETCHWARE PRO STYLE: No header - mobile frame starts from top
              Expanded(
                child: _buildRectangularMobileFrame(),
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

  // REMOVED: _buildDeviceHeader - User requested no blue header like Sketchware Pro

  // SKETCHWARE PRO STYLE: Fixed mobile frame exactly like Sketchware Pro (no center, no extra spacing)
  Widget _buildRectangularMobileFrame() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // EXACT SKETCHWARE PRO SCALING (from ViewEditor.java:870-890)
        final double f = MediaQuery.of(context)
            .devicePixelRatio; // EXACT: f = wB.a(context, 1.0f)
        final int displayWidth = (MediaQuery.of(context).size.width * f)
            .round(); // EXACT: getResources().getDisplayMetrics().widthPixels
        final int displayHeight = (MediaQuery.of(context).size.height * f)
            .round(); // EXACT: getResources().getDisplayMetrics().heightPixels

        // EXACT SKETCHWARE PRO: Orientation-based margins (like ViewEditor.java:870-871)
        final bool isLandscapeMode = displayWidth > displayHeight;
        final int var4 =
            (f * (!isLandscapeMode ? 12.0 : 24.0)).round(); // horizontal margin
        final int var5 =
            (f * (!isLandscapeMode ? 20.0 : 10.0)).round(); // vertical margin

        // EXACT SKETCHWARE PRO: System UI heights (like ViewEditor.java:872-873)
        final int statusBarHeight =
            (f * 25.0).round(); // EXACT: (int) (f * 25f)
        final int toolBarHeight = (f * 48.0).round(); // EXACT: (int) (f * 48f)

        // EXACT SKETCHWARE PRO: Calculate available space (like ViewEditor.java:874-875)
        final int var9 =
            displayWidth - (120.0 * f).round(); // subtract palette width
        final int var8 = displayHeight -
            statusBarHeight -
            toolBarHeight -
            (f * 48.0).round() -
            (f * 48.0).round();

        // EXACT SKETCHWARE PRO: Calculate scaling factors (like ViewEditor.java:877-878)
        final double var11 =
            math.min(var9 / displayWidth, var8 / displayHeight);
        final double var3 = math.min((var9 - var4 * 2) / displayWidth,
            (var8 - var5 * 2) / displayHeight);

        // EXACT SKETCHWARE PRO: Apply scaling (like ViewEditor.java:880-881)
        final double finalScale = var3 * _scale;

        // EXACT SKETCHWARE PRO: Final frame dimensions
        final double frameWidth = displayWidth * finalScale;
        final double frameHeight = displayHeight * finalScale;

        // SKETCHWARE PRO STYLE: Exact mobile frame like Sketchware Pro
        return Align(
          alignment: Alignment
              .topCenter, // SKETCHWARE PRO: Fixed at top, centered horizontally
          child: Container(
            width: frameWidth,
            height: frameHeight,
            decoration: BoxDecoration(
              // EXACT SKETCHWARE PRO: Clean rectangular border like ViewEditor
              border: Border.all(
                color: const Color(
                    0xFFDDDDDD), // Lighter border like Sketchware Pro
                width: 1 * finalScale,
              ),
              color: Colors.white, // Clean white background
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // Subtle shadow
                  blurRadius: 2 * finalScale,
                  offset: Offset(0, 1 * finalScale),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status Bar (like Sketchware Pro)
                _buildStatusBar(finalScale),

                // AppBar (like Sketchware Pro's Toolbar)
                _buildToolbar(finalScale),

                // Content Area (white background with grid)
                Expanded(
                  child: _buildContentArea(finalScale),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ANDROID NATIVE: Status Bar (exactly like Sketchware Pro)
  Widget _buildStatusBar(double scale) {
    return Container(
      height: 25.0 * scale, // EXACT: Fixed 25dp height like Sketchware Pro
      decoration: BoxDecoration(
        color: const Color(0xFF0084C2), // Sketchware Pro blue
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF006B9E),
            width: 1 * scale,
          ),
        ),
      ),
      child: Row(
        children: [
          // EXACT SKETCHWARE PRO: File name on left side (like ViewEditor.java:535)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8 * scale),
              child: Text(
                'main.dart', // FLUTTER: Show main.dart instead of main.xml
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // EXACT SKETCHWARE PRO: System indicators on right side
          Row(
            children: [
              // Network signal
              Icon(
                Icons.signal_cellular_4_bar,
                color: Colors.white,
                size: 14 * scale,
              ),
              SizedBox(width: 2 * scale),
              // WiFi
              Icon(
                Icons.wifi,
                color: Colors.white,
                size: 14 * scale,
              ),
              SizedBox(width: 2 * scale),
              // Battery
              Icon(
                Icons.battery_full,
                color: Colors.white,
                size: 14 * scale,
              ),
              SizedBox(width: 4 * scale),
              // Time (like Sketchware Pro)
              Text(
                '10:11', // EXACT SKETCHWARE PRO: Current time format
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8 * scale),
            ],
          ),
        ],
      ),
    );
  }

  // ANDROID NATIVE: AppBar (exactly like Sketchware Pro's Toolbar)
  Widget _buildToolbar(double scale) {
    return Container(
      height: 48.0 * scale, // EXACT: Fixed 48dp height like Sketchware Pro
      decoration: BoxDecoration(
        color: const Color(0xFF008DCD), // Sketchware Pro AppBar blue
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF006B9E),
            width: 1 * scale,
          ),
        ),
      ),
      child: Row(
        children: [
          // EXACT SKETCHWARE PRO: AppBar content (like ViewEditor.java:565)
          Padding(
            padding: EdgeInsets.only(left: 16 * scale),
            child: Text(
              'AppBar', // FLUTTER: Use AppBar instead of Toolbar
              style: TextStyle(
                color: Colors.white,
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold, // EXACT SKETCHWARE PRO: Bold text
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SKETCHWARE PRO STYLE CONTENT AREA
  Widget _buildContentArea(double scale) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // SKETCHWARE PRO EXACT: Fixed content area dimensions for target device
        // Based on 360x640dp target device minus status bar (25dp) and AppBar (48dp)
        const double targetContentWidth = 360.0; // Fixed content width in dp
        const double targetContentHeight = 640.0 -
            25.0 -
            48.0; // 567dp content height (exact Sketchware Pro calculation)

        // SKETCHWARE PRO STYLE: Convert to actual container size (like ViewEditor.java:894)
        final containerSize = Size(targetContentWidth, targetContentHeight);

        // SKETCHWARE PRO STYLE: Update ViewInfoService with container information
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isServiceAvailable)
            return; // SKETCHWARE PRO STYLE: Prevent disposed service usage

          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final containerOffset = renderBox.localToGlobal(Offset.zero);
            _safeViewInfoService.updateContainer(
              size:
                  containerSize, // SKETCHWARE PRO: Fixed target device content size
              offset: containerOffset,
            );
            _safeViewInfoService.updateScales(
              outerScale: _scale,
              innerScale: scale,
            );
          }
        });

        return GestureDetector(
          // SKETCHWARE PRO STYLE: Handle background taps to clear selection (like ViewEditor.java:285-289)
          onTap: () {
            widget.onBackgroundTapped?.call();
          },
          child: Container(
            color: Colors.white, // Pure white background (like Sketchware Pro)
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

                // SKETCHWARE PRO STYLE: Visual feedback overlay for drag target
                _buildVisualFeedbackOverlay(),

                // SKETCHWARE PRO STYLE: Removed cursor-following ViewDummy - keeping only fixed hierarchical feedback
              ],
            ),
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
          return data != null;
        },

        // SKETCHWARE PRO STYLE: Handle widget drop with coordinate transformation
        onAccept: (widgetData) {
          _handleWidgetDrop(widgetData);
        },

        // SKETCHWARE PRO STYLE: Visual feedback during drag with coordinate transformation
        onMove: (details) {
          _handleDragMove(details);
        },

        // SKETCHWARE PRO STYLE: Hide visual feedback when drag leaves
        onLeave: (data) {
          _hideVisualFeedback();
        },

        // SKETCHWARE PRO STYLE: Drag target builder (completely transparent)
        builder: (context, candidateData, rejectedData) {
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // SKETCHWARE PRO STYLE: Visual feedback overlay for drag target
  Widget _buildVisualFeedbackOverlay() {
    if (!_isVisualFeedbackVisible || _draggedWidgetData == null) {
      return const SizedBox.shrink();
    }

    final dropZone = _safeViewInfoService.currentDropZone;
    if (dropZone == null) {
      return const SizedBox.shrink();
    }

    final containerSize = _safeViewInfoService.containerSize;
    final defaultWidgetSize = WidgetSizingService.getWidgetSize(
        _draggedWidgetData!.type, containerSize);

    final dropPosition = dropZone.position;

    return Positioned(
      left: dropPosition.dx,
      top: dropPosition.dy,
      child: Opacity(
        opacity: 0.5,
        child: Container(
          width: defaultWidgetSize.width,
          height: defaultWidgetSize.height,
          child: _buildWidgetTypePreview(_draggedWidgetData!),
        ),
      ),
    );
  }

  Widget _buildWidgetTypePreview(FlutterWidgetBean widgetBean) {
    final type = widgetBean.type;
    final properties = widgetBean.properties;

    switch (type) {
      case 'Text':
        return Center(
          child: Text(
            TextPropertyService.getText(properties),
            style: TextPropertyService.getTextStyle(context, properties, 1.0),
            textAlign: _parseTextAlign(properties['textAlign'] ?? 'left'),
          ),
        );
      case 'TextField':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey),
          ),
          child: Text(
            properties['hint'] ?? 'Text Field',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        );
      case 'Icon':
        return Center(
          child: Icon(
            IconUtils.getIconFromName(properties['iconName'] ?? 'star'),
            color: Colors.black,
            size: double.tryParse(properties['iconSize']?.toString() ?? '24') ??
                24,
          ),
        );
      case 'Row':
      case 'Column':
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(2),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              type,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      case 'Container':
        return Container(
          decoration: BoxDecoration(
            color: ColorUtils.parseColor(properties['backgroundColor']) ??
                Colors.white,
            borderRadius: BorderRadius.circular(
              double.tryParse(properties['borderRadius']?.toString() ?? '0') ??
                  0,
            ),
            border: Border.all(
              color: ColorUtils.parseColor(properties['borderColor']) ??
                  Colors.grey,
              width: double.tryParse(
                      properties['borderWidth']?.toString() ?? '1') ??
                  1,
            ),
          ),
          child: const Center(
            child: Text(
              'Container',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      case 'Stack':
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(2),
            color: Colors.white,
          ),
          child: const Center(
            child: Text(
              'Stack',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
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
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
    }
  }

  /// SKETCHWARE PRO STYLE: Handle drag move with coordinate transformation
  void _handleDragMove(DragTargetDetails<FlutterWidgetBean> details) {
    final transformedCoordinates =
        _safeViewInfoService.transformCoordinates(details.offset);

    if (!_safeViewInfoService.isWithinContainer(details.offset)) {
      _safeViewInfoService.resetViewHighlight();
      _hideVisualFeedback();
      return;
    }

    final widgetSize = _getWidgetSize(details.data);

    _safeViewInfoService.updateViewHighlight(
        transformedCoordinates, widgetSize);

    _updateVisualFeedback(details.data, widgetSize);
  }

  /// SKETCHWARE PRO STYLE: Handle widget drop with proper sizing (like ViewEditor.java:327)
  void _handleWidgetDrop(FlutterWidgetBean widgetData) {
    final dropPosition = _safeViewInfoService.currentDropZone?.position ??
        Offset(_safeViewInfoService.containerSize.width / 2,
            _safeViewInfoService.containerSize.height / 2);

    final containerSize = WidgetSizingService.getAvailableContainerSize(
      Size(_safeViewInfoService.containerSize.width,
          _safeViewInfoService.containerSize.height),
    );

    final hierarchicalWidget =
        WidgetSizingService.calculateHierarchicalPosition(
      widgetData,
      dropPosition,
      widget.widgets,
    );

    final positionedWidget = _createPositionedWidgetWithDefaults(
      hierarchicalWidget,
      dropPosition,
      WidgetSizingService.getWidgetSize(widgetData.type, containerSize),
    );

    if (widget.onWidgetAdded != null) {
      widget.onWidgetAdded!(positionedWidget, containerSize: containerSize);
    }

    _hideVisualFeedback();
  }

  /// SKETCHWARE PRO STYLE: Calculate precise drop position with bounds checking
  Offset _calculatePreciseDropPosition(Offset dropPosition, Size widgetSize) {
    final containerSize = _safeViewInfoService.containerSize;

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
    LayoutBean layout;

    switch (widgetData.type) {
      case 'Row':
      case 'Column':
        layout = LayoutBean(
          marginLeft: 0.0,
          marginTop: 0.0,
          marginRight: 0.0,
          marginBottom: 0.0,
          width: -1,
          height: -2,
          paddingLeft: 8,
          paddingTop: 8,
          paddingRight: 8,
          paddingBottom: 8,
          backgroundColor: 0xFFFFFFFF,
          layoutGravity: 0,
        );
        break;
      case 'Container':
        layout = LayoutBean(
          marginLeft: 0.0,
          marginTop: 0.0,
          marginRight: 0.0,
          marginBottom: 0.0,
          width: -1,
          height: -1,
          paddingLeft: 8,
          paddingTop: 8,
          paddingRight: 8,
          paddingBottom: 8,
          backgroundColor: 0xFFFFFFFF,
          layoutGravity: 0,
        );
        break;
      case 'Stack':
        layout = LayoutBean(
          marginLeft: 0.0,
          marginTop: 0.0,
          marginRight: 0.0,
          marginBottom: 0.0,
          width: -1,
          height: -1,
          paddingLeft: 8,
          paddingTop: 8,
          paddingRight: 8,
          paddingBottom: 8,
          backgroundColor: 0xFFFFFFFF,
          layoutGravity: 0,
        );
        break;
      default:
        layout = LayoutBean(
          marginLeft: position.dx,
          marginTop: position.dy,
          marginRight: 0.0,
          marginBottom: 0.0,
          width: -2,
          height: -2,
          paddingLeft: 8,
          paddingTop: 8,
          paddingRight: 8,
          paddingBottom: 8,
          backgroundColor: 0xFFFFFFFF,
          layoutGravity: 0,
        );
        break;
    }

    // Apply default properties if they don't exist
    final defaultProperties = _getDefaultProperties(widgetData.type);
    final mergedProperties = Map<String, dynamic>.from(defaultProperties);
    mergedProperties.addAll(widgetData.properties);

    return widgetData.copyWith(
      properties: mergedProperties,
      layout: layout,
      position: PositionBean(
        x: position.dx,
        y: position.dy,
        width: widgetSize.width,
        height: widgetSize.height,
      ),
    );
  }

  /// SKETCHWARE PRO STYLE: Get default properties for widget type
  Map<String, dynamic> _getDefaultProperties(String widgetType) {
    switch (widgetType) {
      case 'Text':
        return TextPropertyService.getDefaultProperties();
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
          'backgroundColor': '#FFFFFF', // Match Row widget - white background
          'borderColor':
              '#60000000', // Match Row widget - semi-transparent black border
          'borderWidth': '1.0',
          'borderRadius': '0.0',
          'alignment': 'center',
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
    final shouldUpdate = _isViewDummyVisible != true ||
        _isViewDummyAllowed != isAllowed ||
        _viewDummyPosition != position ||
        _viewDummyWidget?.id != widget.id;

    if (shouldUpdate) {
      setState(() {
        _isViewDummyVisible = true;
        _isViewDummyAllowed = isAllowed;
        _viewDummyPosition = position;
        _viewDummyWidget = widget;
      });
    }
  }

  /// SKETCHWARE PRO STYLE: Hide ViewDummy
  void _hideViewDummy() {
    setState(() {
      _isViewDummyVisible = false;
      _viewDummyWidget = null;
    });
  }

  /// SKETCHWARE PRO STYLE: Update visual feedback (like ViewPane.java:747)
  void _updateVisualFeedback(FlutterWidgetBean widget, Size widgetSize) {
    final dropZone = _safeViewInfoService.currentDropZone;
    final shouldShow = dropZone != null;
    final shouldUpdate = _isVisualFeedbackVisible != shouldShow ||
        _draggedWidgetData?.id != widget.id;

    if (shouldUpdate) {
      setState(() {
        _isVisualFeedbackVisible = shouldShow;
        _draggedWidgetData = shouldShow ? widget : null;
      });
    }
  }

  /// SKETCHWARE PRO STYLE: Hide visual feedback
  void _hideVisualFeedback() {
    setState(() {
      _isVisualFeedbackVisible = false;
      _draggedWidgetData = null;
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
    _safeViewInfoService.clearViewInfos();

    _safeViewInfoService.addViewInfo(
      Rect.fromLTWH(0, 0, _safeViewInfoService.containerSize.width,
          _safeViewInfoService.containerSize.height),
      Container(),
      0,
      0,
      parentId: 'root',
      viewType: 'Container',
    );

    final rootWidgets = _getRootWidgets();

    return Stack(
      children: rootWidgets
          .map((widgetBean) => _buildSketchwareProWidget(widgetBean))
          .toList(),
    );
  }

  /// SKETCHWARE PRO STYLE: Get root widgets (widgets without parents)
  List<FlutterWidgetBean> _getRootWidgets() {
    return widget.widgets
        .where((widget) =>
            widget.parentId == null ||
            widget.parentId == 'root' ||
            widget.parent == 'root')
        .toList();
  }

  /// SKETCHWARE PRO STYLE: Build widget with selection capability
  Widget _buildSketchwareProWidget(FlutterWidgetBean widgetBean) {
    final isSelected = widget.selectedWidget?.id == widgetBean.id;
    final widgetKey = GlobalKey();
    final scale = 1.0;

    final position = _calculateWidgetPosition(widgetBean, scale);

    _safeViewInfoService.addViewInfo(
      Rect.fromLTWH(
          position.left, position.top, position.width, position.height),
      Container(),
      0,
      0,
      parentId: widgetBean.parent,
      viewType: widgetBean.type,
    );

    if ((widgetBean.type == 'Row' || widgetBean.type == 'Container') &&
        widgetBean.layout.width == LayoutBean.MATCH_PARENT) {
      return Positioned(
        left: 0,
        top: 0,
        right: 0,
        child: Container(
          height: position.height > 0 ? position.height : null,
          child: _buildRealWidgetWithScale(widgetBean, scale),
        ),
      );
    } else if (widgetBean.type == 'Column' &&
        widgetBean.layout.height == LayoutBean.MATCH_PARENT) {
      return Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        child: Container(
          width: position.width > 0 ? position.width : null,
          child: _buildRealWidgetWithScale(widgetBean, scale),
        ),
      );
    } else {
      return Positioned(
        left: position.left,
        top: position.top,
        child: Container(
          width: position.width,
          height: position.height,
          child: _buildRealWidgetWithScale(widgetBean, scale),
        ),
      );
    }
  }

  // SKETCHWARE PRO STYLE POSITION CALCULATION
  WidgetPosition _calculateWidgetPosition(
      FlutterWidgetBean widgetBean, double scale) {
    // SKETCHWARE PRO STYLE: Get available container size
    final containerSize = WidgetSizingService.getAvailableContainerSize(
      Size(_safeViewInfoService.containerSize.width,
          _safeViewInfoService.containerSize.height),
    );

    // Like Sketchware Pro's LayoutParams system
    double width = widgetBean.position.width * scale;
    double height = widgetBean.position.height * scale;

    // Handle MATCH_PARENT and WRAP_CONTENT like Sketchware Pro
    if (widgetBean.layout.width == LayoutBean.MATCH_PARENT) {
      width = containerSize.width * scale; // Available width
    } else if (widgetBean.layout.width == LayoutBean.WRAP_CONTENT) {
      width = _calculateWrapContentWidth(widgetBean, scale);
    }

    if (widgetBean.layout.height == LayoutBean.MATCH_PARENT) {
      height = containerSize.height * scale; // Available height
    } else if (widgetBean.layout.height == LayoutBean.WRAP_CONTENT) {
      height = _calculateWrapContentHeight(widgetBean, scale);
    }

    // SKETCHWARE PRO STYLE: Use position coordinates for positioning
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

  // Build real widget with proper scale using Android Native Factory Service
  Widget _buildRealWidgetWithScale(FlutterWidgetBean widgetBean, double scale) {
    // ANDROID NATIVE: Create frame widget with Android Native touch system integration
    Widget createdWidget = MobileFrameWidgetFactoryService.createFrameWidget(
      widgetBean: widgetBean,
      scale: scale,
      allWidgets: widget.widgets,
      touchController: _touchController,
      selectionService: _selectionService,
      androidTouchService: _androidTouchService,
      context: context,
    );

    // SKETCHWARE PRO STYLE: Return frame widget with touch capabilities
    return createdWidget;
  }

  List<Widget> _buildChildWidgetsWithScale(
      FlutterWidgetBean widgetBean, double scale) {
    // For now, return empty list. In a real implementation, this would
    // build child widgets based on the widget's children property
    return [];
  }

  // Utility methods for parsing properties

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

  // SKETCHWARE PRO STYLE: Enhanced ViewDummy overlay (EXACTLY like Sketchware Pro)
  Widget _buildViewDummyOverlay() {
    if (!_isViewDummyVisible || _viewDummyWidget == null) {
      return const SizedBox.shrink();
    }

    return ViewDummy(
      isVisible: _isViewDummyVisible,
      isAllowed: _isViewDummyAllowed,
      position: _viewDummyPosition,
      widgetBean: _viewDummyWidget,
      draggedWidget: _buildWidgetPreview(_viewDummyWidget!),
      isCustomWidget: false,
    );
  }

  /// SKETCHWARE PRO STYLE: Build widget preview for ViewDummy
  Widget _buildWidgetPreview(FlutterWidgetBean widget) {
    switch (widget.type) {
      case 'Text':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.properties['text'] ?? 'Text',
            style: TextStyle(
              fontSize: double.tryParse(
                      widget.properties['textSize']?.toString() ?? '14') ??
                  14.0,
              color: Colors.black,
            ),
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
            widget.properties['text'] ?? 'Button',
            style: const TextStyle(color: Colors.white),
          ),
        );
      case 'Container':
        return Container(
          width: 100,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
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
              widget.type,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
    }
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
