import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';

/// WidgetSizingService - EXACTLY matches Sketchware Pro's widget sizing logic
/// Handles proper sizing, density conversion, and exact frame scaling for dropped widgets
class WidgetSizingService {
  // SKETCHWARE PRO STYLE: Default widget dimensions (like ViewEditor.java:90-91)
  static const int DEFAULT_WIDGET_WIDTH = 50; // I = 50
  static const int DEFAULT_WIDGET_HEIGHT = 30; // J = 30

  // SKETCHWARE PRO STYLE: Layout constants (like ViewGroup.LayoutParams)
  static const int MATCH_PARENT = -1;
  static const int WRAP_CONTENT = -2;

  // ====================================================================
  // EXACT SKETCHIDE DENSITY CONVERSION (matches Sketchware Pro wB.a())
  // ====================================================================

  /// EXACT equivalent of wB.a(context, 1.0f) from Sketchware Pro
  /// Implements TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value, displayMetrics)
  static double convertDpToPixels(BuildContext context, double dp) {
    final mediaQuery = MediaQuery.of(context);

    // EXACT Android equivalent of TypedValue.applyDimension with COMPLEX_UNIT_DIP
    // Android formula: dp * density + 0.5f (for rounding)
    final density = mediaQuery.devicePixelRatio;
    return (dp * density + 0.5);
  }

  /// EXACT equivalent of wB.a(context, 1.0f) - get density factor
  static double getDensityFactor(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// EXACT equivalent of getResources().getDisplayMetrics().widthPixels
  static double getDisplayWidthPixels(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width * mediaQuery.devicePixelRatio;
  }

  /// EXACT equivalent of getResources().getDisplayMetrics().heightPixels
  static double getDisplayHeightPixels(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height * mediaQuery.devicePixelRatio;
  }

  /// EXACT equivalent of GB.f(getContext()) - status bar height
  static double getStatusBarHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.padding.top;
  }

  /// EXACT equivalent of GB.a(getContext()) - toolbar height
  static double getToolbarHeight(BuildContext context) {
    // Standard Android toolbar height is 56dp
    return convertDpToPixels(context, 56.0);
  }

  /// EXACT equivalent of Sketchware Pro's scaling calculation from ViewEditor.java:870-890
  /// This is the EXACT formula used by Sketchware Pro for frame scaling
  static SketchIDEScaling calculateExactFrameScaling(
    BuildContext context, {
    bool hasAds = false,
    int screenType = 0,
  }) {
    final mediaQuery = MediaQuery.of(context);

    // EXACT: Get device dimensions like Sketchware Pro
    final displayWidth = mediaQuery.size.width * mediaQuery.devicePixelRatio;
    final displayHeight = mediaQuery.size.height * mediaQuery.devicePixelRatio;

    // EXACT: Get density factor (f = wB.a(context, 1.0f))
    final f = getDensityFactor(context);

    // EXACT: Calculate orientation-based margins
    final isLandscapeMode = displayWidth > displayHeight;
    final var4 =
        (f * (!isLandscapeMode ? 12.0 : 24.0)).toInt(); // horizontal margin
    final var5 =
        (f * (!isLandscapeMode ? 20.0 : 10.0)).toInt(); // vertical margin

    // EXACT: Get system UI heights
    final statusBarHeight = getStatusBarHeight(context);
    final toolBarHeight = getToolbarHeight(context);

    // EXACT: Calculate available space (subtract palette width 120dp)
    final var9 = displayWidth - (120.0 * f).toInt();
    var var8 = displayHeight -
        statusBarHeight -
        toolBarHeight -
        (f * 48.0).toInt() -
        (f * 48.0).toInt();

    // EXACT: Subtract ad banner height if ads are enabled
    if (screenType == 0 && hasAds) {
      var8 -= (f * 56.0).toInt();
    }

    // EXACT: Calculate scaling factors (two different calculations)
    final var11 = (var9 / displayWidth < var8 / displayHeight)
        ? var9 / displayWidth
        : var8 / displayHeight;

    final var3 =
        ((var9 - var4 * 2) / displayWidth < (var8 - var5 * 2) / displayHeight)
            ? (var9 - var4 * 2) / displayWidth
            : (var8 - var5 * 2) / displayHeight;

    // EXACT: Calculate positioning offsets
    final offsetX = -((displayWidth - displayWidth * var11) / 2.0);
    final offsetY = -((displayHeight - displayHeight * var11) / 2.0);

    return SketchIDEScaling(
      displayWidth: displayWidth,
      displayHeight: displayHeight,
      scaleX: var11,
      scaleY: var11,
      offsetX: offsetX,
      offsetY: offsetY,
      availableWidth: var9.toDouble(),
      availableHeight: var8.toDouble(),
      marginHorizontal: var4.toDouble(),
      marginVertical: var5.toDouble(),
      densityFactor: f,
      isLandscape: isLandscapeMode,
    );
  }

  /// Convert SketchIDE measurements to Sketchware Pro exact equivalents
  static EdgeInsets convertSketchwarePadding(
    BuildContext context, {
    required int left,
    required int top,
    required int right,
    required int bottom,
  }) {
    // EXACT equivalent of ItemTextView.setPadding()
    final oneDp = getDensityFactor(context);

    return EdgeInsets.fromLTRB(
      left * oneDp,
      top * oneDp,
      right * oneDp,
      bottom * oneDp,
    );
  }

  /// SKETCHWARE PRO STYLE: Get proper widget size based on type (like ViewEditor.java:730-735)
  static Size getWidgetSize(String widgetType, Size availableSize) {
    switch (widgetType) {
      case 'Row':
      case 'HorizontalLayout':
        // SKETCHWARE PRO STYLE: Horizontal layouts use MATCH_PARENT width, WRAP_CONTENT height
        return Size(
            availableSize.width, 32.0); // ✅ EXACT: 32dp like ItemLinearLayout

      case 'Column':
      case 'VerticalLayout':
        // SKETCHWARE PRO STYLE: Vertical layouts use WRAP_CONTENT width, MATCH_PARENT height
        return Size(
            32.0, availableSize.height); // ✅ EXACT: 32dp like ItemLinearLayout

      case 'Container':
        // FLUTTER CONTAINER STYLE: Containers use MATCH_PARENT width, WRAP_CONTENT height like Row
        return Size(availableSize.width, 50.0); // Default height like Row

      case 'Text':
      case 'TextView':
        // SKETCHWARE PRO STYLE: Text widgets use WRAP_CONTENT
        return Size(50.0, 30.0); // EXACT Sketchware Pro default

      case 'Button':
        // SKETCHWARE PRO STYLE: Buttons use WRAP_CONTENT
        return Size(80.0, 40.0); // EXACT Sketchware Pro default

      case 'Icon':
      case 'IconButton':
        // SKETCHWARE PRO STYLE: Icons use fixed size
        return Size(48.0, 48.0); // Standard icon size

      case 'TextField':
      case 'EditText':
        // SKETCHWARE PRO STYLE: Text fields use MATCH_PARENT width
        return Size(availableSize.width, 50.0); // Full width, standard height

      case 'Stack':
      case 'RelativeLayout':
        // SKETCHWARE PRO STYLE: Stacks use MATCH_PARENT
        return Size(availableSize.width, availableSize.height);

      default:
        // SKETCHWARE PRO STYLE: Default size
        return Size(
            DEFAULT_WIDGET_WIDTH.toDouble(), DEFAULT_WIDGET_HEIGHT.toDouble());
    }
  }

  /// SKETCHWARE PRO STYLE: Get layout parameters for widget type (like ViewPane.java:680-688)
  static LayoutBean getLayoutBean(String widgetType, Size availableSize) {
    final size = getWidgetSize(widgetType, availableSize);

    int width;
    int height;

    switch (widgetType) {
      case 'Row':
      case 'HorizontalLayout':
        // SKETCHWARE PRO STYLE: MATCH_PARENT width, WRAP_CONTENT height
        width = MATCH_PARENT;
        height = WRAP_CONTENT;
        break;

      case 'Column':
      case 'VerticalLayout':
        // SKETCHWARE PRO STYLE: WRAP_CONTENT width, MATCH_PARENT height
        width = WRAP_CONTENT;
        height = MATCH_PARENT;
        break;

      case 'Container':
        // SKETCHWARE PRO STYLE: MATCH_PARENT width, WRAP_CONTENT height like CardView
        width = MATCH_PARENT;
        height = WRAP_CONTENT;
        break;

      case 'Text':
      case 'TextView':
        // SKETCHWARE PRO STYLE: WRAP_CONTENT
        width = WRAP_CONTENT;
        height = WRAP_CONTENT;
        break;

      case 'Button':
        // SKETCHWARE PRO STYLE: WRAP_CONTENT
        width = WRAP_CONTENT;
        height = WRAP_CONTENT;
        break;

      case 'Icon':
      case 'IconButton':
        // SKETCHWARE PRO STYLE: Fixed size
        width = 48;
        height = 48;
        break;

      case 'TextField':
      case 'EditText':
        // SKETCHWARE PRO STYLE: MATCH_PARENT width
        width = MATCH_PARENT;
        height = WRAP_CONTENT;
        break;

      case 'Image':
      case 'ImageView':
        // SKETCHWARE PRO STYLE: Default size
        width = 80;
        height = 80;
        break;

      case 'Stack':
        // SKETCHWARE PRO STYLE: MATCH_PARENT
        width = MATCH_PARENT;
        height = MATCH_PARENT;
        break;

      case 'ListView':
        // SKETCHWARE PRO STYLE: MATCH_PARENT
        width = MATCH_PARENT;
        height = MATCH_PARENT;
        break;

      default:
        // SKETCHWARE PRO STYLE: Default size
        width = DEFAULT_WIDGET_WIDTH;
        height = DEFAULT_WIDGET_HEIGHT;
        break;
    }

    return LayoutBean(
      width: width,
      height: height,
      marginLeft: 8.0, // SKETCHWARE PRO STYLE: Default margin
      marginTop: 8.0,
      marginRight: 8.0,
      marginBottom: 8.0,
      paddingLeft: 8, // SKETCHWARE PRO STYLE: Default padding
      paddingTop: 8,
      paddingRight: 8,
      paddingBottom: 8,
    );
  }

  /// SKETCHWARE PRO STYLE: Calculate proper position for dropped widget (like ViewPane.java:782)
  static Offset calculateDropPosition(
      Offset dropPosition, Size widgetSize, Size containerSize,
      {String? widgetType}) {
    if (widgetType == 'Row' || widgetType == 'Column') {
      return Offset(0.0, 0.0);
    }

    return Offset(0.0, 0.0);
  }

  static FlutterWidgetBean calculateHierarchicalPosition(
      FlutterWidgetBean widget,
      Offset dropPosition,
      List<FlutterWidgetBean> existingWidgets) {
    String? closestParent = _findClosestParent(dropPosition, existingWidgets);

    if (closestParent != null) {
      return widget.copyWith(
        parent: closestParent,
        parentType: 0,
        index: _getNextIndex(closestParent, existingWidgets),
      );
    } else {
      return widget.copyWith(
        parent: 'root',
        parentType: 0,
        index: -1,
      );
    }
  }

  static String? _findClosestParent(
      Offset dropPosition, List<FlutterWidgetBean> existingWidgets) {
    for (FlutterWidgetBean widget in existingWidgets) {
      if (widget.type == 'Row' ||
          widget.type == 'Column' ||
          widget.type == 'Container' ||
          widget.type == 'Stack') {
        final rect = Rect.fromLTWH(widget.position.x, widget.position.y,
            widget.position.width, widget.position.height);
        if (rect.contains(dropPosition)) {
          return widget.id;
        }
      }
    }
    return null;
  }

  static int _getNextIndex(
      String parentId, List<FlutterWidgetBean> existingWidgets) {
    int maxIndex = -1;
    for (FlutterWidgetBean widget in existingWidgets) {
      if (widget.parent == parentId && widget.index > maxIndex) {
        maxIndex = widget.index;
      }
    }
    return maxIndex + 1;
  }

  /// SKETCHWARE PRO STYLE: Get available container size (like ViewEditor.java:873)
  static Size getAvailableContainerSize(Size totalSize) {
    // SKETCHWARE PRO STYLE: Account for status bar and toolbar
    const double statusBarHeight = 25.0;
    const double toolbarHeight = 48.0;
    const double margin = 16.0;

    return Size(
      totalSize.width - (margin * 2),
      totalSize.height - statusBarHeight - toolbarHeight - (margin * 2),
    );
  }

  /// SKETCHWARE PRO STYLE: Validate widget placement (like ViewPane.java:782)
  static bool isValidPlacement(
      Offset position, Size widgetSize, Size containerSize) {
    // SKETCHWARE PRO STYLE: Check if widget fits within container
    if (position.dx < 0 || position.dy < 0) return false;
    if (position.dx + widgetSize.width > containerSize.width) return false;
    if (position.dy + widgetSize.height > containerSize.height) return false;

    return true;
  }
}

/// EXACT equivalent of Sketchware Pro's scaling result
class SketchIDEScaling {
  final double displayWidth;
  final double displayHeight;
  final double scaleX;
  final double scaleY;
  final double offsetX;
  final double offsetY;
  final double availableWidth;
  final double availableHeight;
  final double marginHorizontal;
  final double marginVertical;
  final double densityFactor;
  final bool isLandscape;

  const SketchIDEScaling({
    required this.displayWidth,
    required this.displayHeight,
    required this.scaleX,
    required this.scaleY,
    required this.offsetX,
    required this.offsetY,
    required this.availableWidth,
    required this.availableHeight,
    required this.marginHorizontal,
    required this.marginVertical,
    required this.densityFactor,
    required this.isLandscape,
  });
}
