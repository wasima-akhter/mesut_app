import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<List<AppNotification>> getNotifications();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String id);

  Future<void> clearAll();
}
