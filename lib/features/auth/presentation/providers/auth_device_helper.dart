import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/helpers/device_location_helper.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/storage_provider.dart';

class AuthDeviceContext {
  final String deviceIdentifier;
  final String? fcmToken;
  final double? lat;
  final double? lng;

  const AuthDeviceContext({
    required this.deviceIdentifier,
    this.fcmToken,
    this.lat,
    this.lng,
  });

  static Future<AuthDeviceContext> resolve(
    Ref ref, {
    bool refreshFcmIfEmpty = true,
  }) async {
    final storageService = ref.read(storageServiceProvider);
    final deviceId = await storageService.getOrCreateDeviceIdentifier();
    var fcmToken = await storageService.getFcmToken();
    if (refreshFcmIfEmpty && (fcmToken == null || fcmToken.isEmpty)) {
      try {
        fcmToken = await ref
            .read(pushNotificationServiceProvider)
            .refreshAndPersistToken();
      } catch (_) {}
    }
    final coords = await DeviceLocationHelper.tryGetCoordinates();
    return AuthDeviceContext(
      deviceIdentifier: deviceId,
      fcmToken: fcmToken,
      lat: coords?.lat,
      lng: coords?.lng,
    );
  }
}
