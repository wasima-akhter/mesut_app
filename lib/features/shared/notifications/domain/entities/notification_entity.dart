import 'package:construction_app/core/extensions/date_time_extensions.dart';

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
  final DateTime? timestamp;
  final String dateGroup; // 'today', 'yesterday', 'earlier'
  final String? projectTag;
  final NotificationCategory type;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.time = '',
    this.timestamp,
    required this.dateGroup,
    this.projectTag,
    required this.type,
    this.isRead = false,
  });

  String get displayTime {
    if (timestamp != null) {
      return timestamp!.formatRelative();
    }
    return time;
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    DateTime? timestamp,
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
      timestamp: timestamp ?? this.timestamp,
      dateGroup: dateGroup ?? this.dateGroup,
      projectTag: projectTag ?? this.projectTag,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
