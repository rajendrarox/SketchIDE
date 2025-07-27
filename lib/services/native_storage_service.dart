import 'package:flutter/services.dart';

class NativeStorageService {
  static const MethodChannel _channel =
      MethodChannel('com.sketchide.app/storage_permission');

  /// Check if storage permission is granted
  static Future<bool> checkStoragePermission() async {
    print('DEBUG: NativeStorageService.checkStoragePermission() called');
    try {
      final bool hasPermission =
          await _channel.invokeMethod('checkStoragePermission');
      print('DEBUG: checkStoragePermission result: $hasPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      print('ERROR: PlatformException in checkStoragePermission: $e');
      // Return false as fallback - user will need to grant permission
      return false;
    } catch (e) {
      print('ERROR: Unexpected error in checkStoragePermission: $e');
      return false;
    }
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    print('DEBUG: NativeStorageService.requestStoragePermission() called');
    try {
      final bool granted =
          await _channel.invokeMethod('requestStoragePermission');
      print('DEBUG: requestStoragePermission result: $granted');
      return granted;
    } on PlatformException catch (e) {
      print('ERROR: PlatformException in requestStoragePermission: $e');
      // Return false as fallback - user will need to grant permission manually
      return false;
    } catch (e) {
      print('ERROR: Unexpected error in requestStoragePermission: $e');
      return false;
    }
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    print('DEBUG: NativeStorageService.openAppSettings() called');
    try {
      await _channel.invokeMethod('openAppSettings');
      print('DEBUG: openAppSettings completed successfully');
    } on PlatformException catch (e) {
      print('ERROR: PlatformException in openAppSettings: $e');
      // Could implement fallback to open general settings
    } catch (e) {
      print('ERROR: Unexpected error in openAppSettings: $e');
    }
  }

  /// Get external storage path (like Sketchware Pro)
  static Future<String?> getExternalStoragePath() async {
    print('DEBUG: NativeStorageService.getExternalStoragePath() called');
    try {
      final String? path =
          await _channel.invokeMethod('getExternalStoragePath');
      print('DEBUG: getExternalStoragePath result: $path');
      return path;
    } on PlatformException catch (e) {
      print('ERROR: PlatformException in getExternalStoragePath: $e');
      // Return a fallback path
      return '/storage/emulated/0';
    } catch (e) {
      print('ERROR: Unexpected error in getExternalStoragePath: $e');
      return '/storage/emulated/0';
    }
  }
}
