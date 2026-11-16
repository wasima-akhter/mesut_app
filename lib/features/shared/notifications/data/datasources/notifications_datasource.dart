import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationsDataSource {
  Future<NotificationsFeedPage> getNotifications({
    int page = 1,
    int limit = 20,
  });
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> clearAll();
}

class NotificationsRemoteDataSourceImpl implements NotificationsDataSource {
  NotificationsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<NotificationsFeedPage> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileNotifications,
      queryParameters: {'page': page, 'limit': limit},
    );

    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    final meta = body['meta'] is Map
        ? Map<String, dynamic>.from(body['meta'] as Map)
        : const <String, dynamic>{};

    final rawItems = data['items'] is List
        ? data['items'] as List
        : (body['data'] is List ? body['data'] as List : const []);

    final items = rawItems
        .whereType<Map>()
        .map((m) => AppNotification.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    final rawUnread = data['unreadCount'];
    final unreadCount = rawUnread is int
        ? rawUnread
        : (int.tryParse(rawUnread?.toString() ?? '') ??
              items.where((n) => !n.isRead).length);

    final currentPage = _parseInt(meta['page'], fallback: page);
    final totalPages = _parseInt(meta['totalPages'], fallback: 1);
    final hasMore = meta.containsKey('totalPages')
        ? currentPage < totalPages
        : items.length >= limit;

    return NotificationsFeedPage(
      items: items,
      unreadCount: unreadCount,
      page: currentPage,
      totalPages: totalPages,
      hasMore: hasMore,
    );
  }

  @override
  Future<void> markAsRead(String id) async {
    if (id.trim().isEmpty) return;
    await apiClient.patch<Map<String, dynamic>>(
      ApiConstants.mobileNotificationRead(id),
    );
  }

  @override
  Future<void> markAllAsRead() async {
    await apiClient.patch<Map<String, dynamic>>(
      ApiConstants.mobileNotificationsReadAll,
    );
  }

  @override
  Future<void> deleteNotification(String id) async {
    // No delete endpoint in /mobile/notifications; locally hidden if dismissed.
  }

  @override
  Future<void> clearAll() async {
    await markAllAsRead();
  }

  static int _parseInt(dynamic val, {required int fallback}) {
    if (val is int) return val;
    if (val == null) return fallback;
    return int.tryParse(val.toString()) ?? fallback;
  }
}
