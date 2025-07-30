import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';
import '../../services/color_utils.dart';
import 'base_frame_item.dart';

/// SKETCHWARE PRO STYLE: Frame Icon Widget that matches ItemImageView exactly
/// Implements the same interface pattern as Sketchware Pro's ItemImageView
class FrameIcon extends BaseFrameItem {
  const FrameIcon({
    super.key,
    required super.widgetBean,
    super.touchController,
    super.selectionService,
    super.scale,
  });

  @override
  Widget buildContent(BuildContext context) {
    return _FrameIconContent(
      widgetBean: widgetBean,
      touchController: touchController,
      selectionService: selectionService,
      scale: scale,
    );
  }
}

/// SKETCHWARE PRO STYLE: Frame Icon Content Widget
class _FrameIconContent extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final MobileFrameTouchController? touchController;
  final SelectionService? selectionService;
  final double scale;

  const _FrameIconContent({
    required this.widgetBean,
    this.touchController,
    this.selectionService,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final widgetKey = GlobalKey();

    /// SKETCHWARE PRO STYLE: Get exact position and size like ItemImageView
    final position = widgetBean.position;
    final layout = widgetBean.layout;

    // SKETCHWARE PRO STYLE: Convert dp to pixels like wB.a(context, value)
    final density = MediaQuery.of(context).devicePixelRatio;

    // SKETCHWARE PRO STYLE: Handle width/height like ViewPane.updateLayout()
    double width = position.width * scale;
    double height = position.height * scale;

    // SKETCHWARE PRO STYLE: If width/height are positive, convert dp to pixels
    if (layout.width > 0) {
      width = layout.width * density * scale;
    }
    if (layout.height > 0) {
      height = layout.height * density * scale;
    }

    return GestureDetector(
      // FLUTTER FIX: Ensure tap events are captured
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // SKETCHWARE PRO STYLE: Handle widget selection on tap
        print('🎯 FRAME ICON TAP: ${widgetBean.id}');
        if (selectionService != null) {
          selectionService!.selectWidget(widgetBean);
          print('🎯 SELECTION SERVICE: Widget ${widgetBean.id} selected');
        }
        _notifyWidgetSelected();
      },
      onTapDown: (details) {
        // Additional tap down handling if needed
        print('🎯 FRAME ICON TAP DOWN: ${widgetBean.id}');
      },
      onLongPressStart: (details) {
        // Handle long press start
      },
      onLongPressMoveUpdate: (details) {
        // Handle long press move update
      },
      onLongPressEnd: (details) {
        // Handle long press end
      },
      onPanStart: (details) {
        // Handle pan start
      },
      onPanUpdate: (details) {
        // Handle pan update
      },
      onPanEnd: (details) {
        // Handle pan end
      },
      child: Container(
        key: widgetKey,
        // SKETCHWARE PRO STYLE: Use exact width/height like ItemImageView
        width: width > 0 ? width : null,
        height: height > 0 ? height : null,
        // SKETCHWARE PRO STYLE: Minimum size like ItemImageView (32dp)
        constraints: BoxConstraints(
          minWidth: 32 * density * scale,
          minHeight: 32 * density * scale,
        ),
        child: _buildIconContent(context),
      ),
    );
  }

  /// SKETCHWARE PRO STYLE: Build icon content (matches ItemImageView)
  Widget _buildIconContent(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final iconSize = _getIconSize(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Center(
        child: Icon(
          _getIconData(),
          size: iconSize,
          color: _getIconColor(),
        ),
      ),
    );
  }

  /// SKETCHWARE PRO STYLE: Get icon data (matches ItemImageView)
  IconData _getIconData() {
    final iconName = widgetBean.properties['icon']?.toString() ?? '';

    // SKETCHWARE PRO STYLE: If icon is empty, show default icon like ItemImageView
    if (iconName.isEmpty) {
      return Icons
          .image; // SKETCHWARE PRO STYLE: Default icon like IconImageView.getBean()
    }

    // Map icon names to IconData
    switch (iconName.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'search':
        return Icons.search;
      case 'menu':
        return Icons.menu;
      case 'add':
        return Icons.add;
      case 'delete':
        return Icons.delete;
      case 'edit':
        return Icons.edit;
      case 'share':
        return Icons.share;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'person':
        return Icons.person;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'location':
        return Icons.location_on;
      case 'camera':
        return Icons.camera_alt;
      case 'gallery':
        return Icons.photo_library;
      case 'download':
        return Icons.download;
      case 'upload':
        return Icons.upload;
      case 'refresh':
        return Icons.refresh;
      case 'close':
        return Icons.close;
      case 'check':
        return Icons.check;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
        return Icons.info;
      case 'help':
        return Icons.help;
      case 'back':
        return Icons.arrow_back;
      case 'forward':
        return Icons.arrow_forward;
      case 'up':
        return Icons.arrow_upward;
      case 'down':
        return Icons.arrow_downward;
      case 'play':
        return Icons.play_arrow;
      case 'pause':
        return Icons.pause;
      case 'stop':
        return Icons.stop;
      case 'next':
        return Icons.skip_next;
      case 'previous':
        return Icons.skip_previous;
      case 'volume':
        return Icons.volume_up;
      case 'mute':
        return Icons.volume_off;
      case 'fullscreen':
        return Icons.fullscreen;
      case 'exit_fullscreen':
        return Icons.fullscreen_exit;
      case 'zoom_in':
        return Icons.zoom_in;
      case 'zoom_out':
        return Icons.zoom_out;
      case 'rotate':
        return Icons.rotate_right;
      case 'flip':
        return Icons.flip;
      case 'crop':
        return Icons.crop;
      case 'filter':
        return Icons.filter;
      case 'sort':
        return Icons.sort;
      case 'list':
        return Icons.list;
      case 'grid':
        return Icons.grid_view;
      case 'calendar':
        return Icons.calendar_today;
      case 'clock':
        return Icons.access_time;
      case 'notifications':
        return Icons.notifications;
      case 'lock':
        return Icons.lock;
      case 'unlock':
        return Icons.lock_open;
      case 'visibility':
        return Icons.visibility;
      case 'visibility_off':
        return Icons.visibility_off;
      case 'keyboard':
        return Icons.keyboard;
      case 'language':
        return Icons.language;
      case 'translate':
        return Icons.translate;
      case 'code':
        return Icons.code;
      case 'bug':
        return Icons.bug_report;
      case 'build':
        return Icons.build;
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'store':
        return Icons.store;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'payment':
        return Icons.payment;
      case 'credit_card':
        return Icons.credit_card;
      case 'account_balance':
        return Icons.account_balance;
      case 'trending_up':
        return Icons.trending_up;
      case 'trending_down':
        return Icons.trending_down;
      case 'analytics':
        return Icons.analytics;
      case 'dashboard':
        return Icons.dashboard;
      case 'assessment':
        return Icons.assessment;
      case 'pie_chart':
        return Icons.pie_chart;
      case 'bar_chart':
        return Icons.bar_chart;
      case 'line_chart':
        return Icons.show_chart;
      case 'scatter_plot':
        return Icons.scatter_plot;
      case 'timeline':
        return Icons.timeline;
      case 'schedule':
        return Icons.schedule;
      case 'event':
        return Icons.event;
      case 'today':
        return Icons.today;
      case 'date_range':
        return Icons.date_range;
      case 'update':
        return Icons.update;
      case 'sync':
        return Icons.sync;
      case 'cloud':
        return Icons.cloud;
      case 'cloud_upload':
        return Icons.cloud_upload;
      case 'cloud_download':
        return Icons.cloud_download;
      case 'folder':
        return Icons.folder;
      case 'folder_open':
        return Icons.folder_open;
      case 'file':
        return Icons.insert_drive_file;
      case 'image':
      default:
        return Icons.image;
    }
  }

  /// SKETCHWARE PRO STYLE: Get icon size (matches ItemImageView)
  double _getIconSize(BuildContext context) {
    final iconSize = widgetBean.properties['iconSize'];
    if (iconSize is num) {
      // SKETCHWARE PRO STYLE: Convert dp to pixels like Android
      final density = MediaQuery.of(context).devicePixelRatio;
      return iconSize.toDouble() * density * scale;
    }
    // SKETCHWARE PRO STYLE: Default icon size like ItemImageView
    final density = MediaQuery.of(context).devicePixelRatio;
    return 24.0 * density * scale;
  }

  /// SKETCHWARE PRO STYLE: Get icon color (matches ItemImageView)
  Color _getIconColor() {
    final iconColor =
        widgetBean.properties['iconColor']?.toString() ?? '#000000';
    return ColorUtils.parseColor(iconColor) ?? Colors.black;
  }

  /// SKETCHWARE PRO STYLE: Get background color (matches ItemImageView)
  Color _getBackgroundColor() {
    final backgroundColor =
        widgetBean.properties['backgroundColor']?.toString() ?? '#FFFFFF';

    // SKETCHWARE PRO STYLE: Handle white background like ItemImageView
    if (backgroundColor == '#FFFFFF' || backgroundColor == '#ffffff') {
      return Colors
          .transparent; // SKETCHWARE PRO STYLE: Transparent for white background
    }

    return ColorUtils.parseColor(backgroundColor) ?? Colors.transparent;
  }

  /// SKETCHWARE PRO STYLE: Notify parent about widget selection
  void _notifyWidgetSelected() {
    print('🚀 NOTIFYING WIDGET SELECTION: ${widgetBean.id}');
    if (touchController != null) {
      touchController!.handleWidgetTap(widgetBean);
    } else {
      print('🚀 WARNING: touchController is null!');
    }
  }
}
