import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/network_providers.dart';
import '../../../../../core/services/notification_socket_service.dart';
import '../../../../../core/storage/storage_provider.dart';
import '../../data/datasources/notifications_datasource.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';

final notificationsDataSourceProvider = Provider<NotificationsDataSource>((
  ref,
) {
  return NotificationsRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
  );
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final dataSource = ref.watch(notificationsDataSourceProvider);
  return NotificationsRepositoryImpl(dataSource);
});

class NotificationsFeedState {
  const NotificationsFeedState({
    this.items = const [],
    this.unreadCount = 0,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<AppNotification> items;
  final int unreadCount;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  NotificationsFeedState copyWith({
    List<AppNotification>? items,
    int? unreadCount,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationsFeedState(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class NotificationsNotifier extends AsyncNotifier<NotificationsFeedState> {
  static const int _pageSize = 20;

  @override
  Future<NotificationsFeedState> build() async {
    _bindSocketCallbacks();

    final storage = ref.read(storageServiceProvider);
    final hasToken = await storage.hasValidAccessToken();
    if (!hasToken) {
      return const NotificationsFeedState();
    }

    final pageResult = await ref
        .watch(notificationsRepositoryProvider)
        .getNotifications(page: 1, limit: _pageSize);
    return NotificationsFeedState(
      items: pageResult.items,
      unreadCount: pageResult.unreadCount,
      currentPage: pageResult.page,
      hasMore: pageResult.hasMore,
    );
  }

  void _bindSocketCallbacks() {
    final socketService = ref.read(notificationSocketServiceProvider);
    socketService.onUnreadCount = applySocketUnreadCount;
    socketService.onNewNotification = applySocketNewNotification;
    socketService.onNotificationRead = applySocketNotificationRead;
    socketService.onAllRead = applySocketAllRead;
  }

  Future<void> refresh() async {
    final storage = ref.read(storageServiceProvider);
    final hasToken = await storage.hasValidAccessToken();
    if (!hasToken) {
      state = const AsyncValue.data(NotificationsFeedState());
      return;
    }

    final result = await AsyncValue.guard(() async {
      final page = await ref
          .read(notificationsRepositoryProvider)
          .getNotifications(page: 1, limit: _pageSize);
      return NotificationsFeedState(
        items: page.items,
        unreadCount: page.unreadCount,
        currentPage: page.page,
        hasMore: page.hasMore,
      );
    });
    if (ref.mounted) {
      state = result;
    }
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = await ref
          .read(notificationsRepositoryProvider)
          .getNotifications(page: current.currentPage + 1, limit: _pageSize);
      if (!ref.mounted) return;

      final existingIds = current.items.map((e) => e.id).toSet();
      final appended = [
        ...current.items,
        ...nextPage.items.where((item) => !existingIds.contains(item.id)),
      ];

      state = AsyncValue.data(
        current.copyWith(
          items: appended,
          unreadCount: nextPage.unreadCount,
          currentPage: nextPage.page,
          hasMore: nextPage.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (ref.mounted) {
        state = AsyncValue.data(current.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> markAsRead(String id) async {
    final current = state.asData?.value;
    if (current != null) {
      var decremented = false;
      final updated = current.items.map((item) {
        if (item.id == id && !item.isRead) {
          decremented = true;
          return item.copyWith(isRead: true);
        }
        return item;
      }).toList();
      final nextUnread = decremented
          ? (current.unreadCount - 1).clamp(0, 999999)
          : current.unreadCount;
      state = AsyncValue.data(
        current.copyWith(items: updated, unreadCount: nextUnread),
      );
    }

    ref.read(notificationSocketServiceProvider).emitMarkRead(id);
    try {
      await ref.read(notificationsRepositoryProvider).markAsRead(id);
    } catch (_) {
      await refresh();
    }
  }

  Future<void> markAllAsRead() async {
    final current = state.asData?.value;
    if (current != null) {
      final updated = current.items
          .map((item) => item.copyWith(isRead: true))
          .toList();
      state = AsyncValue.data(current.copyWith(items: updated, unreadCount: 0));
    }

    ref.read(notificationSocketServiceProvider).emitMarkAllRead();
    try {
      await ref.read(notificationsRepositoryProvider).markAllAsRead();
    } catch (_) {
      await refresh();
    }
  }

  Future<void> deleteNotification(String id) async {
    final current = state.asData?.value;
    if (current != null) {
      final target = current.items.where((e) => e.id == id).firstOrNull;
      final wasUnread = target != null && !target.isRead;
      final updated = current.items.where((item) => item.id != id).toList();
      final nextUnread = wasUnread
          ? (current.unreadCount - 1).clamp(0, 999999)
          : current.unreadCount;
      state = AsyncValue.data(
        current.copyWith(items: updated, unreadCount: nextUnread),
      );
    }
    if (id.isNotEmpty) {
      try {
        await ref.read(notificationsRepositoryProvider).markAsRead(id);
      } catch (_) {}
    }
  }

  Future<void> clearAll() async {
    await markAllAsRead();
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(items: const [], unreadCount: 0),
      );
    }
  }

  // ==============================
  // Socket.IO realtime handlers
  // ==============================

  void applySocketUnreadCount(int count) {
    final current = state.asData?.value ?? const NotificationsFeedState();
    state = AsyncValue.data(
      current.copyWith(unreadCount: count.clamp(0, 999999)),
    );
  }

  void applySocketNewNotification(Map<String, dynamic> payload) {
    final notification = AppNotification.fromJson(payload);
    final current = state.asData?.value ?? const NotificationsFeedState();

    final alreadyExists =
        notification.id.isNotEmpty &&
        current.items.any((item) => item.id == notification.id);

    final updatedList = alreadyExists
        ? current.items
        : [notification, ...current.items];
    final nextUnread = (!notification.isRead && !alreadyExists)
        ? current.unreadCount + 1
        : current.unreadCount;

    state = AsyncValue.data(
      current.copyWith(items: updatedList, unreadCount: nextUnread),
    );
  }

  void applySocketNotificationRead(String? id) {
    if (id == null || id.isEmpty) return;
    final current = state.asData?.value;
    if (current == null) return;

    var decremented = false;
    final updated = current.items.map((item) {
      if (item.id == id && !item.isRead) {
        decremented = true;
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();

    final nextUnread = decremented
        ? (current.unreadCount - 1).clamp(0, 999999)
        : current.unreadCount;
    state = AsyncValue.data(
      current.copyWith(items: updated, unreadCount: nextUnread),
    );
  }

  void applySocketAllRead() {
    final current = state.asData?.value;
    if (current == null) return;
    final updated = current.items
        .map((item) => item.copyWith(isRead: true))
        .toList();
    state = AsyncValue.data(current.copyWith(items: updated, unreadCount: 0));
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, NotificationsFeedState>(
      NotificationsNotifier.new,
    );

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final asyncNotifications = ref.watch(notificationsProvider);
  return asyncNotifications.maybeWhen(
    data: (feed) => feed.unreadCount,
    orElse: () => 0,
  );
});
