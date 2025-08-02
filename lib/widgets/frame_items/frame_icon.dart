import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';
import '../../controllers/mobile_frame_touch_controller.dart';
import '../../services/selection_service.dart';
import '../../services/color_utils.dart';
import '../../services/widget_sizing_service.dart'; // Added import for WidgetSizingService
import 'base_frame_item.dart';

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

    final position = widgetBean.position;
    final layout = widgetBean.layout;

    // SKETCHWARE PRO STYLE: Use wB.a() pattern - convert DP to pixels once
    double width = position.width * scale;
    double height = position.height * scale;

    if (layout.width > 0) {
      // SKETCHWARE PRO STYLE: wB.a(getContext(), (float) layout.width)
      width = WidgetSizingService.convertDpToPixels(context, layout.width.toDouble()) * scale;
    }
    if (layout.height > 0) {
      // SKETCHWARE PRO STYLE: wB.a(getContext(), (float) layout.height)
      height = WidgetSizingService.convertDpToPixels(context, layout.height.toDouble()) * scale;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('🎯 FRAME ICON TAP: ${widgetBean.id}');
        if (selectionService != null) {
          selectionService!.selectWidget(widgetBean);
          print('🎯 SELECTION SERVICE: Widget ${widgetBean.id} selected');
        }
        _notifyWidgetSelected();
      },
      onTapDown: (details) {
        print('🎯 FRAME ICON TAP DOWN: ${widgetBean.id}');
      },
      onLongPressStart: (details) {
      },
      onLongPressMoveUpdate: (details) {
      },
      onLongPressEnd: (details) {
      },
      onPanStart: (details) {
      },
      onPanUpdate: (details) {
      },
      onPanEnd: (details) {
      },
      child: Container(
        key: widgetKey,
        width: width > 0 ? width : null,
        height: height > 0 ? height : null,
        constraints: BoxConstraints(
          minWidth: 32 * scale, // Removed density scaling
          minHeight: 32 * scale, // Removed density scaling
        ),
        child: _buildIconContent(context),
      ),
    );
  }

  Widget _buildIconContent(BuildContext context) {
    final isSelected = selectionService?.selectedWidget?.id == widgetBean.id;
    final iconSize = _getIconSize(context);

    return Container(
      // SKETCHWARE PRO STYLE: Use background fill for selection like ItemImageView
      color: isSelected ? const Color(0x9599d5d0) : Colors.transparent,
      // SKETCHWARE PRO STYLE: Center icon like ImageView
      child: Center(
        child: Padding(
          // SKETCHWARE PRO STYLE: Add proper padding like ImageView
          padding: EdgeInsets.all(4.0 * scale),
          child: Icon(
            _getIconData(),
            size: iconSize,
            color: _getIconColor(),
          ),
        ),
      ),
    );
  }

  IconData _getIconData() {
    final iconName = widgetBean.properties['icon']?.toString() ?? '';

    if (iconName.isEmpty) {
      return Icons.image; // SKETCHWARE PRO STYLE: Default icon
    }

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

  double _getIconSize(BuildContext context) {
    final iconSize = _parseDouble(widgetBean.properties['iconSize']) ?? 24.0;
    
    // SKETCHWARE PRO STYLE: Use raw icon size without density scaling
    return iconSize * scale; // Remove density scaling!
  }

  Color _getIconColor() {
    final iconColor = widgetBean.properties['iconColor']?.toString() ?? '#000000';
    return ColorUtils.parseColor(iconColor) ?? Colors.black;
  }

  Color _getBackgroundColor() {
    // SKETCHWARE PRO STYLE: No background for icons like ItemImageView
    return Colors.transparent;
  }

  void _notifyWidgetSelected() {
    print('🚀 NOTIFYING WIDGET SELECTION: ${widgetBean.id}');
    if (touchController != null) {
      touchController!.handleWidgetTap(widgetBean);
    } else {
      print('🚀 WARNING: touchController is null!');
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
