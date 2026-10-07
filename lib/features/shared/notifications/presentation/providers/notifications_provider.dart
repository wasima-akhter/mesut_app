import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notifications_datasource.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';

// DI Providers
final notificationsDataSourceProvider = Provider<NotificationsDataSource>((ref) {
  return NotificationsMockDataSourceImpl();
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final dataSource = ref.watch(notificationsDataSourceProvider);
  return NotificationsRepositoryImpl(dataSource);
});

// Notifications List Notifier
class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() {
    return ref.watch(notificationsRepositoryProvider).getNotifications();
  }

  Future<void> markAsRead(String id) async {
    await ref.read(notificationsRepositoryProvider).markAsRead(id);
    state = await AsyncValue.guard(() => ref.read(notificationsRepositoryProvider).getNotifications());
  }

  Future<void> markAllAsRead() async {
    await ref.read(notificationsRepositoryProvider).markAllAsRead();
    state = await AsyncValue.guard(() => ref.read(notificationsRepositoryProvider).getNotifications());
  }

  Future<void> deleteNotification(String id) async {
    await ref.read(notificationsRepositoryProvider).deleteNotification(id);
    state = await AsyncValue.guard(() => ref.read(notificationsRepositoryProvider).getNotifications());
  }

  Future<void> clearAll() async {
    await ref.read(notificationsRepositoryProvider).clearAll();
    state = await AsyncValue.guard(() => ref.read(notificationsRepositoryProvider).getNotifications());
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final asyncNotifications = ref.watch(notificationsProvider);
  return asyncNotifications.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
