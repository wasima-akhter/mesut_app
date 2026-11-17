import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/services/notification_service.dart';
import '../../../../../core/storage/storage_provider.dart';

class NotificationSettingsNotifier extends Notifier<bool> {
  @override
  bool build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.notificationsEnabled;
  }

  Future<void> toggle() async {
    final newValue = !state;
    state = newValue;
    final pushService = ref.read(pushNotificationServiceProvider);
    await pushService.setNotificationsEnabled(newValue);
  }

  Future<void> setEnabled(bool enabled) async {
    if (state == enabled) return;
    state = enabled;
    final pushService = ref.read(pushNotificationServiceProvider);
    await pushService.setNotificationsEnabled(enabled);
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, bool>(
      NotificationSettingsNotifier.new,
    );
