enum NotificationCategory {
  task,
  inspection,
  schedule,
  timeTracking,
  safety,
  system,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final String dateGroup; // 'today', 'yesterday', 'earlier'
  final String? projectTag;
  final NotificationCategory type;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.dateGroup,
    this.projectTag,
    required this.type,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    String? dateGroup,
    String? projectTag,
    NotificationCategory? type,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      dateGroup: dateGroup ?? this.dateGroup,
      projectTag: projectTag ?? this.projectTag,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
