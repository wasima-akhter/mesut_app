import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<NotificationsFeedPage> getNotifications({int page = 1, int limit = 20});

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String id);

  Future<void> clearAll();
}
