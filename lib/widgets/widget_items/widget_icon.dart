import 'package:flutter/material.dart';
import '../../models/flutter_widget_bean.dart';

/// WidgetIcon - Simple palette widget for Icon (matches Sketchware Pro's IconImageView)
/// Display-only widget for palette, no interactive features
class WidgetIcon extends StatelessWidget {
  final FlutterWidgetBean widgetBean;
  final double scale;

  const WidgetIcon({
    super.key,
    required this.widgetBean,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80 * scale,
      height: 40 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1 * scale),
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Center(
        child: Icon(
          _getIconData(),
          size: 24 * scale,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  IconData _getIconData() {
    final iconName = widgetBean.properties['iconName'] ?? 'home';
    return _getIconFromName(iconName);
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'person':
        return Icons.person;
      case 'search':
        return Icons.search;
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
      case 'menu':
        return Icons.menu;
      case 'more_vert':
        return Icons.more_vert;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'check':
        return Icons.check;
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'help':
        return Icons.help;
      case 'visibility':
        return Icons.visibility;
      case 'visibility_off':
        return Icons.visibility_off;
      case 'lock':
        return Icons.lock;
      case 'unlock':
        return Icons.lock_open;
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
      case 'video_camera_back':
        return Icons.video_camera_back;
      case 'mic':
        return Icons.mic;
      case 'volume_up':
        return Icons.volume_up;
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
      case 'queue_music':
        return Icons.queue_music;
      case 'playlist_play':
        return Icons.playlist_play;
      case 'library_music':
        return Icons.library_music;
      case 'music_note':
        return Icons.music_note;
      case 'headphones':
        return Icons.headphones;
      case 'speaker':
        return Icons.speaker;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'wifi':
        return Icons.wifi;
      case 'signal_cellular_4_bar':
        return Icons.signal_cellular_4_bar;
      case 'signal_wifi_4_bar':
        return Icons.signal_wifi_4_bar;
      case 'battery_full':
        return Icons.battery_full;
      case 'battery_charging_full':
        return Icons.battery_charging_full;
      case 'brightness_high':
        return Icons.brightness_high;
      case 'brightness_low':
        return Icons.brightness_low;
      case 'brightness_auto':
        return Icons.brightness_auto;
      case 'contrast':
        return Icons.contrast;
      case 'color_lens':
        return Icons.color_lens;
      case 'palette':
        return Icons.palette;
      case 'brush':
        return Icons.brush;
      case 'format_paint':
        return Icons.format_paint;
      case 'crop':
        return Icons.crop;
      case 'filter':
        return Icons.filter;
      case 'blur_on':
        return Icons.blur_on;
      case 'blur_off':
        return Icons.blur_off;
      case 'auto_fix_high':
        return Icons.auto_fix_high;
      case 'auto_fix_normal':
        return Icons.auto_fix_normal;
      case 'auto_fix_off':
        return Icons.auto_fix_off;
      case 'transform':
        return Icons.transform;
      case 'rotate_left':
        return Icons.rotate_left;
      case 'rotate_right':
        return Icons.rotate_right;
      case 'flip':
        return Icons.flip;
      case 'flip_camera_ios':
        return Icons.flip_camera_ios;
      case 'flip_camera_android':
        return Icons.flip_camera_android;
      case 'timer':
        return Icons.timer;
      case 'timer_10':
        return Icons.timer_10;
      case 'timer_3':
        return Icons.timer_3;
      case 'timer_off':
        return Icons.timer_off;
      case 'flash_on':
        return Icons.flash_on;
      case 'flash_off':
        return Icons.flash_off;
      case 'flash_auto':
        return Icons.flash_auto;
      case 'grid_on':
        return Icons.grid_on;
      case 'grid_off':
        return Icons.grid_off;
      case 'view_module':
        return Icons.view_module;
      case 'view_list':
        return Icons.view_list;
      case 'view_agenda':
        return Icons.view_agenda;
      case 'view_day':
        return Icons.view_day;
      case 'view_week':
        return Icons.view_week;
      case 'view_headline':
        return Icons.view_headline;
      case 'view_quilt':
        return Icons.view_quilt;
      case 'view_carousel':
        return Icons.view_carousel;
      case 'view_column':
        return Icons.view_column;
      case 'view_stream':
        return Icons.view_stream;
      case 'view_timeline':
        return Icons.view_timeline;
      case 'view_sidebar':
        return Icons.view_sidebar;
      case 'view_compact':
        return Icons.view_compact;
      case 'view_compact_alt':
        return Icons.view_compact_alt;
      case 'view_cozy':
        return Icons.view_cozy;
      case 'view_comfortable':
        return Icons.view_comfortable;
      case 'view_in_ar':
        return Icons.view_in_ar;
      case 'view_kanban':
        return Icons.view_kanban;
      default:
        return Icons.home;
    }
  }

  /// Create a FlutterWidgetBean for Icon (matches Sketchware Pro's getBean())
  static FlutterWidgetBean createBean({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return FlutterWidgetBean(
      id: id ?? FlutterWidgetBean.generateSimpleId(),
      type: 'Icon',
      properties: {
        'iconName': 'home',
        'iconSize': 24.0,
        'iconColor': 0xFF000000,
        'semanticLabel': 'Icon',
        ...?properties,
      },
      children: [],
      position: PositionBean(
        x: 0,
        y: 0,
        width: 48,
        height: 48,
      ),
      events: {},
      layout: LayoutBean(
        width: -2, // WRAP_CONTENT
        height: -2, // WRAP_CONTENT
        marginLeft: 0,
        marginTop: 0,
        marginRight: 0,
        marginBottom: 0,
        paddingLeft: 4,
        paddingTop: 4,
        paddingRight: 4,
        paddingBottom: 4,
      ),
    );
  }
}
