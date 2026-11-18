import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/connectivity/connectivity_provider.dart';
import '../../../../core/connectivity/network_status.dart';
import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../../employee/time_tracking/presentation/providers/offline_sync_provider.dart';
import '../../../media/presentation/providers/media_providers.dart';
import '../models/site_manager_sync_action.dart';
import '../services/site_manager_cache_service.dart';
import '../services/site_manager_sync_queue.dart';
import '../services/site_manager_sync_service.dart';

final siteManagerCacheServiceProvider = Provider<SiteManagerCacheService>((
  ref,
) {
  return SiteManagerCacheService(ref.watch(localStorageProvider));
});

final siteManagerSyncQueueProvider = Provider<SiteManagerSyncQueue>((ref) {
  return SiteManagerSyncQueueImpl(ref.watch(localStorageProvider));
});

final siteManagerSyncServiceProvider = Provider<SiteManagerSyncService>((ref) {
  return SiteManagerSyncService(
    queue: ref.watch(siteManagerSyncQueueProvider),
    apiClient: ref.watch(apiClientProvider),
    storageService: ref.watch(storageServiceProvider),
    mediaRepository: ref.watch(mediaRepositoryProvider),
  );
});

class SiteManagerSyncState {
  const SiteManagerSyncState({
    this.isOnline = true,
    this.isSyncing = false,
    this.pendingActions = const [],
    this.timeLogsPendingCount = 0,
    this.lastSyncedAt,
    this.lastSyncMessage,
  });

  final bool isOnline;
  final bool isSyncing;
  final List<SiteManagerSyncAction> pendingActions;
  final int timeLogsPendingCount;
  final DateTime? lastSyncedAt;
  final String? lastSyncMessage;

  int get totalPendingCount => pendingActions.length + timeLogsPendingCount;
  bool get hasPending => totalPendingCount > 0;

  SiteManagerSyncState copyWith({
    bool? isOnline,
    bool? isSyncing,
    List<SiteManagerSyncAction>? pendingActions,
    int? timeLogsPendingCount,
    DateTime? lastSyncedAt,
    String? lastSyncMessage,
    bool clearMessage = false,
  }) {
    return SiteManagerSyncState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingActions: pendingActions ?? this.pendingActions,
      timeLogsPendingCount: timeLogsPendingCount ?? this.timeLogsPendingCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastSyncMessage: clearMessage
          ? null
          : (lastSyncMessage ?? this.lastSyncMessage),
    );
  }
}

class SiteManagerSyncNotifier extends Notifier<SiteManagerSyncState> {
  NetworkStatus? _lastObservedNetworkStatus;

  @override
  SiteManagerSyncState build() {
    final queue = ref.watch(siteManagerSyncQueueProvider);
    final storage = ref.watch(storageServiceProvider);
    final employeeSync = ref.watch(offlineSyncProvider);

    ref.listen<AsyncValue<NetworkStatus>>(networkStatusProvider, (_, next) {
      final status = next.asData?.value;
      if (status == null) return;

      final transitionedToOnline =
          _lastObservedNetworkStatus != NetworkStatus.online &&
          status == NetworkStatus.online;
      _lastObservedNetworkStatus = status;

      final isOnline = status == NetworkStatus.online;
      state = state.copyWith(isOnline: isOnline);

      if (transitionedToOnline && state.hasPending && !state.isSyncing) {
        syncAll();
      }
    });

    final initialQueue = queue.loadQueue();
    final lastSync = storage.getLastSyncTime();

    return SiteManagerSyncState(
      pendingActions: initialQueue,
      timeLogsPendingCount: employeeSync.pendingCount,
      lastSyncedAt: lastSync,
    );
  }

  Future<void> enqueue(SiteManagerSyncAction action) async {
    final queue = ref.read(siteManagerSyncQueueProvider);
    await queue.enqueue(action);

    final updated = queue.loadQueue();
    state = state.copyWith(pendingActions: updated, clearMessage: true);

    final isOnline = await ref.read(isOnlineProvider.future);
    if (isOnline && !state.isSyncing) {
      unawaited(syncAll());
    }
  }

  Future<void> syncAll() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true, clearMessage: true);

    try {
      final service = ref.read(siteManagerSyncServiceProvider);
      final result = await service.processQueue();

      // Also trigger time log sync if any
      final employeeSyncNotifier = ref.read(offlineSyncProvider.notifier);
      await employeeSyncNotifier.syncPendingLogs();

      final queue = ref.read(siteManagerSyncQueueProvider);
      final remainingActions = queue.loadQueue();
      final now = DateTime.now();

      state = state.copyWith(
        isSyncing: false,
        pendingActions: remainingActions,
        lastSyncedAt: now,
        lastSyncMessage: result.syncedCount > 0
            ? 'Synced ${result.syncedCount} changes successfully'
            : null,
      );
    } catch (e) {
      final friendlyError = AppErrorResolver.resolve(e).displayMessage;
      state = state.copyWith(isSyncing: false, lastSyncMessage: friendlyError);
    }
  }
}

final siteManagerSyncProvider =
    NotifierProvider<SiteManagerSyncNotifier, SiteManagerSyncState>(
      SiteManagerSyncNotifier.new,
    );
