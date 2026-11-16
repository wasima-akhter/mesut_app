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
  final String? link;
  final String? rawType;
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
    this.link,
    this.rawType,
    required this.type,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final createdAtRaw =
        (json['createdAt'] ?? json['timestamp'] ?? json['updatedAt'])
            ?.toString();
    final parsedDate = createdAtRaw != null
        ? DateTime.tryParse(createdAtRaw)?.toLocal()
        : null;
    final rawType = json['type']?.toString();

    return AppNotification(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? json['body'] ?? '').toString(),
      timestamp: parsedDate,
      dateGroup: computeDateGroup(parsedDate),
      projectTag: json['projectTag']?.toString() ?? json['projectName']?.toString(),
      link: json['link']?.toString(),
      rawType: rawType,
      type: categoryFromType(rawType),
      isRead: json['isRead'] == true,
    );
  }

  static String computeDateGroup(DateTime? dt) {
    if (dt == null) return 'today';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(dt.year, dt.month, dt.day);

    if (dateOnly == today || dateOnly.isAfter(today)) return 'today';
    if (dateOnly == yesterday) return 'yesterday';
    return 'earlier';
  }

  static NotificationCategory categoryFromType(String? rawType) {
    final upper = (rawType ?? '').trim().toUpperCase();
    if (upper.contains('INSPECTION') || upper.contains('SURVEY')) {
      return NotificationCategory.inspection;
    }
    if (upper.contains('SCHEDULE') || upper.contains('ASSIGN')) {
      return NotificationCategory.schedule;
    }
    if (upper.contains('TIME') ||
        upper.contains('TIMER') ||
        upper.contains('SYNC') ||
        upper.contains('LOG')) {
      return NotificationCategory.timeTracking;
    }
    if (upper.contains('SAFETY') || upper.contains('WARN')) {
      return NotificationCategory.safety;
    }
    if (upper.contains('TASK') || upper.contains('PHASE') || upper.contains('PROJECT')) {
      return NotificationCategory.task;
    }
    return NotificationCategory.system;
  }

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
    String? link,
    String? rawType,
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
      link: link ?? this.link,
      rawType: rawType ?? this.rawType,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationsFeedPage {
  const NotificationsFeedPage({
    required this.items,
    required this.unreadCount,
    this.page = 1,
    this.totalPages = 1,
    this.hasMore = false,
  });

  final List<AppNotification> items;
  final int unreadCount;
  final int page;
  final int totalPages;
  final bool hasMore;
}
