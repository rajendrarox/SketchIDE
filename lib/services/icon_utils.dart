import 'package:flutter/material.dart';

class IconUtils {
  static IconData getIconFromName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'star':
        return Icons.star;
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'person':
        return Icons.person;
      case 'favorite':
        return Icons.favorite;
      case 'search':
        return Icons.search;
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
      case 'share':
        return Icons.share;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'thumb_up':
        return Icons.thumb_up;
      case 'thumb_down':
        return Icons.thumb_down;
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
      case 'video':
        return Icons.video_camera_back;
      case 'music_note':
        return Icons.music_note;
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
      case 'volume_up':
        return Icons.volume_up;
      case 'volume_down':
        return Icons.volume_down;
      case 'volume_off':
        return Icons.volume_off;
      case 'brightness_high':
        return Icons.brightness_high;
      case 'brightness_low':
        return Icons.brightness_low;
      case 'wifi':
        return Icons.wifi;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'gps_fixed':
        return Icons.gps_fixed;
      case 'notifications':
        return Icons.notifications;
      case 'notifications_off':
        return Icons.notifications_off;
      case 'account_circle':
        return Icons.account_circle;
      case 'help':
        return Icons.help;
      case 'feedback':
        return Icons.feedback;
      case 'bug_report':
        return Icons.bug_report;
      case 'code':
        return Icons.code;
      case 'build':
        return Icons.build;
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
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
      case 'calendar_today':
        return Icons.calendar_today;
      case 'schedule':
        return Icons.schedule;
      case 'alarm':
        return Icons.alarm;
      case 'timer':
        return Icons.timer;
      case 'hourglass_empty':
        return Icons.hourglass_empty;
      case 'hourglass_full':
        return Icons.hourglass_full;
      default:
        return Icons.star;
    }
  }

  static List<String> getAvailableIcons() {
    return [
      'star',
      'home',
      'settings',
      'person',
      'favorite',
      'search',
      'add',
      'edit',
      'delete',
      'close',
      'menu',
      'more_vert',
      'arrow_back',
      'arrow_forward',
      'check',
      'info',
      'warning',
      'error',
      'share',
      'favorite_border',
      'thumb_up',
      'thumb_down',
      'visibility',
      'visibility_off',
      'lock',
      'unlock',
      'email',
      'phone',
      'location_on',
      'camera',
      'image',
      'video',
      'music_note',
      'play_arrow',
      'pause',
      'stop',
      'skip_next',
      'skip_previous',
      'volume_up',
      'volume_down',
      'volume_off',
      'brightness_high',
      'brightness_low',
      'wifi',
      'bluetooth',
      'gps_fixed',
      'notifications',
      'notifications_off',
      'account_circle',
      'help',
      'feedback',
      'bug_report',
      'code',
      'build',
      'school',
      'work',
      'shopping_cart',
      'payment',
      'credit_card',
      'account_balance',
      'trending_up',
      'trending_down',
      'analytics',
      'dashboard',
      'calendar_today',
      'schedule',
      'alarm',
      'timer',
      'hourglass_empty',
      'hourglass_full',
    ];
  }

  static bool isValidIcon(String iconName) {
    return getAvailableIcons().contains(iconName.toLowerCase());
  }
}
