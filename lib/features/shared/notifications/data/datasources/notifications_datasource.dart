import '../../domain/entities/notification_entity.dart';

abstract class NotificationsDataSource {
  Future<List<AppNotification>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> clearAll();
}

class NotificationsMockDataSourceImpl implements NotificationsDataSource {
  final List<AppNotification> _notifications = [
    const AppNotification(
      id: '1',
      title: 'New Assignment Assigned',
      message: 'You have been assigned to Scaffold Erection at Goltsteins.Complex for tomorrow morning.',
      time: '10:30 AM',
      dateGroup: 'today',
      projectTag: 'Goltsteins.Complex',
      type: NotificationCategory.schedule,
      isRead: false,
    ),
    const AppNotification(
      id: '2',
      title: 'Safety Inspection Due',
      message: 'Routine safety audit required for Front Scaffold #3 at Lindenthal Business Center.',
      time: '08:15 AM',
      dateGroup: 'today',
      projectTag: 'Lindenthal Center',
      type: NotificationCategory.safety,
      isRead: false,
    ),
    const AppNotification(
      id: '3',
      title: 'Time Entry Approved',
      message: 'Your time log of 8.5 hours for Oct 6 has been reviewed and synced successfully.',
      time: 'Yesterday, 05:45 PM',
      dateGroup: 'yesterday',
      projectTag: 'Prj-0842',
      type: NotificationCategory.timeTracking,
      isRead: true,
    ),
    const AppNotification(
      id: '4',
      title: 'Phase Transition',
      message: 'Project "Goldstein Complex" moved from Erection to Standing Scaffold phase.',
      time: 'Yesterday, 02:10 PM',
      dateGroup: 'yesterday',
      projectTag: 'Goltsteins.Complex',
      type: NotificationCategory.task,
      isRead: true,
    ),
    const AppNotification(
      id: '5',
      title: 'Weather Advisory',
      message: 'High wind advisory (45 km/h) forecasted in Cologne region. Secure all loose scaffold planks.',
      time: 'Oct 4, 09:00 AM',
      dateGroup: 'earlier',
      type: NotificationCategory.system,
      isRead: true,
    ),
    const AppNotification(
      id: '6',
      title: 'Inspection Survey Completed',
      message: 'Technical field survey report submitted for Severinstraße 44.',
      time: 'Oct 3, 04:30 PM',
      dateGroup: 'earlier',
      projectTag: 'Severinstraße 44',
      type: NotificationCategory.inspection,
      isRead: true,
    ),
  ];

  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_notifications);
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> clearAll() async {
    _notifications.clear();
  }
}
