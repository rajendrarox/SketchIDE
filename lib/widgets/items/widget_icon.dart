import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetIcon - Flutter Icon widget with Sketchware Pro-style selection
/// Display icon with styling
class WidgetIcon extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final bool isSelected;
  final double scale;
  final VoidCallback? onTap;

  const WidgetIcon({
    super.key,
    required this.widgetBean,
    this.isSelected = false,
    this.scale = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: const Color(0x9599d5d0), width: 2 * scale)
              : Border.all(
                  color: Colors.grey.withOpacity(0.3), width: 1 * scale),
          color: isSelected
              ? const Color(0x9599d5d0).withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.all(8 * scale),
          child: Icon(
            _getIconData(),
            size: _getIconSize(),
            color: _getIconColor(),
            semanticLabel: _getSemanticLabel(),
          ),
        ),
      ),
    );
  }

  IconData _getIconData() {
    final iconName = widgetBean.properties['iconName'] ?? 'home';
    return _getIconFromName(iconName);
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'search':
        return Icons.search;
      case 'settings':
        return Icons.settings;
      case 'person':
        return Icons.person;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'add':
        return Icons.add;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'close':
        return Icons.close;
      case 'check':
        return Icons.check;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'menu':
        return Icons.menu;
      case 'more_vert':
        return Icons.more_vert;
      case 'notifications':
        return Icons.notifications;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'location_on':
        return Icons.location_on;
      case 'camera':
        return Icons.camera;
      case 'image':
        return Icons.image;
      case 'video_library':
        return Icons.video_library;
      case 'music_note':
        return Icons.music_note;
      case 'file_download':
        return Icons.file_download;
      case 'file_upload':
        return Icons.file_upload;
      case 'share':
        return Icons.share;
      case 'link':
        return Icons.link;
      case 'info':
        return Icons.info;
      case 'help':
        return Icons.help;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'visibility':
        return Icons.visibility;
      case 'visibility_off':
        return Icons.visibility_off;
      case 'lock':
        return Icons.lock;
      case 'unlock':
        return Icons.lock_open;
      case 'refresh':
        return Icons.refresh;
      case 'sync':
        return Icons.sync;
      case 'cloud':
        return Icons.cloud;
      case 'wifi':
        return Icons.wifi;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'battery_full':
        return Icons.battery_full;
      case 'signal_cellular_4_bar':
        return Icons.signal_cellular_4_bar;
      case 'gps_fixed':
        return Icons.gps_fixed;
      case 'access_time':
        return Icons.access_time;
      case 'date_range':
        return Icons.date_range;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'event':
        return Icons.event;
      case 'schedule':
        return Icons.schedule;
      case 'timer':
        return Icons.timer;
      case 'alarm':
        return Icons.alarm;
      case 'volume_up':
        return Icons.volume_up;
      case 'volume_down':
        return Icons.volume_down;
      case 'volume_off':
        return Icons.volume_off;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'pause':
        return Icons.pause;
      case 'stop':
        return Icons.stop;
      case 'skip_next':
        return Icons.skip_next;
      case 'skip_previous':
        return Icons.skip_previous;
      case 'fast_forward':
        return Icons.fast_forward;
      case 'fast_rewind':
        return Icons.fast_rewind;
      case 'shuffle':
        return Icons.shuffle;
      case 'repeat':
        return Icons.repeat;
      case 'thumb_up':
        return Icons.thumb_up;
      case 'thumb_down':
        return Icons.thumb_down;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'star_border':
        return Icons.star_border;
      case 'bookmark':
        return Icons.bookmark;
      case 'bookmark_border':
        return Icons.bookmark_border;
      case 'print':
        return Icons.print;
      case 'save':
        return Icons.save;
      case 'open_in_new':
        return Icons.open_in_new;
      case 'launch':
        return Icons.launch;
      case 'code':
        return Icons.code;
      case 'bug_report':
        return Icons.bug_report;
      case 'build':
        return Icons.build;
      case 'construction':
        return Icons.construction;
      case 'engineering':
        return Icons.engineering;
      case 'science':
        return Icons.science;
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
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'trending_up':
        return Icons.trending_up;
      case 'trending_down':
        return Icons.trending_down;
      case 'analytics':
        return Icons.analytics;
      case 'insights':
        return Icons.insights;
      case 'dashboard':
        return Icons.dashboard;
      case 'assessment':
        return Icons.assessment;
      case 'bar_chart':
        return Icons.bar_chart;
      case 'pie_chart':
        return Icons.pie_chart;
      case 'show_chart':
        return Icons.show_chart;
      case 'timeline':
        return Icons.timeline;
      case 'functions':
        return Icons.functions;
      case 'calculate':
        return Icons.calculate;
      case 'functions':
        return Icons.functions;
      case 'functions':
        return Icons.functions;
      default:
        return Icons.home;
    }
  }

  double _getIconSize() {
    final iconSize = widgetBean.properties['iconSize'];
    if (iconSize is double) {
      return iconSize * scale;
    } else if (iconSize is String) {
      return (double.tryParse(iconSize) ?? 24.0) * scale;
    } else if (iconSize is int) {
      return (iconSize.toDouble()) * scale;
    }
    return 24.0 * scale; // Default fallback
  }

  Color _getIconColor() {
    return _parseColor(widgetBean.properties['iconColor'] ?? '#000000');
  }

  String? _getSemanticLabel() {
    return widgetBean.properties['semanticLabel'];
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
            int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return Colors.black;
    } catch (e) {
      return Colors.black;
    }
  }

  /// Create a FlutterWidgetBean for Icon
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateId(),
      type: 'Icon',
      properties: {
        'iconName': 'home',
        'iconSize': 24.0,
        'iconColor': '#000000',
        'semanticLabel': null,
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 40,
        height: 40,
      ),
      events: {},
      layout: LayoutBean(
        width: -2, // WRAP_CONTENT
        height: -2, // WRAP_CONTENT
        marginLeft: 0,
        marginTop: 0,
        marginRight: 0,
        marginBottom: 0,
        paddingLeft: 8,
        paddingTop: 8,
        paddingRight: 8,
        paddingBottom: 8,
      ),
    );
  }
}
