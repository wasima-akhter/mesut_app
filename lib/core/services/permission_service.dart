import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  AppPermissions._();

  /// ============================================================
  /// CAMERA
  /// ============================================================

  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();

    return status.isGranted;
  }

  /// ============================================================
  /// PHOTOS / GALLERY
  /// ============================================================

  static Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();

    return status.isGranted || status.isLimited;
  }

  /// ============================================================
  /// LOCATION
  /// ============================================================

  static Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();

    return status.isGranted;
  }

  /// ============================================================
  /// CHECK CAMERA
  /// ============================================================

  static Future<bool> hasCameraPermission() async {
    return Permission.camera.isGranted;
  }

  /// ============================================================
  /// CHECK PHOTOS
  /// ============================================================

  static Future<bool> hasPhotosPermission() async {
    final status = await Permission.photos.status;

    return status.isGranted || status.isLimited;
  }

  /// ============================================================
  /// CHECK LOCATION
  /// ============================================================

  static Future<bool> hasLocationPermission() async {
    return Permission.locationWhenInUse.isGranted;
  }

  /// ============================================================
  /// OPEN SETTINGS
  /// ============================================================

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
