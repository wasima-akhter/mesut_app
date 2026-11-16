import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsDataSource _dataSource;

  const NotificationsRepositoryImpl(this._dataSource);

  @override
  Future<NotificationsFeedPage> getNotifications({
    int page = 1,
    int limit = 20,
  }) {
    return _dataSource.getNotifications(page: page, limit: limit);
  }

  @override
  Future<void> markAsRead(String id) {
    return _dataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() {
    return _dataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(String id) {
    return _dataSource.deleteNotification(id);
  }

  @override
  Future<void> clearAll() {
    return _dataSource.clearAll();
  }
}
