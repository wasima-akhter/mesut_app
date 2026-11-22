import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/connectivity/connectivity_provider.dart';
import '../../../../core/connectivity/network_status.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../../media/presentation/providers/media_providers.dart';
import '../models/employee_sync_action.dart';
import '../services/employee_cache_service.dart';
import '../services/employee_sync_queue.dart';
import '../services/employee_sync_service.dart';

final employeeCacheServiceProvider = Provider<EmployeeCacheService>((ref) {
  return EmployeeCacheService(ref.watch(localStorageProvider));
});

final employeeSyncQueueProvider = Provider<EmployeeSyncQueue>((ref) {
  return EmployeeSyncQueueImpl(ref.watch(localStorageProvider));
});

final employeeSyncServiceProvider = Provider<EmployeeSyncService>((ref) {
  return EmployeeSyncService(
    queue: ref.watch(employeeSyncQueueProvider),
    apiClient: ref.watch(apiClientProvider),
    storageService: ref.watch(storageServiceProvider),
    mediaRepository: ref.watch(mediaRepositoryProvider),
  );
});

class EmployeeSyncState {
  const EmployeeSyncState({
    this.isOnline = true,
    this.isSyncing = false,
    this.pendingActions = const [],
    this.lastSyncedAt,
    this.lastSyncMessage,
  });

  final bool isOnline;
  final bool isSyncing;
  final List<EmployeeSyncAction> pendingActions;
  final DateTime? lastSyncedAt;
  final String? lastSyncMessage;

  List<EmployeeSyncAction> get visiblePendingActions =>
      pendingActions.where((action) {
        final isTimer = action.actionType == EmployeeSyncActionType.startTimer ||
            action.actionType == EmployeeSyncActionType.stopTimer ||
            action.actionType == EmployeeSyncActionType.manualTimeLog ||
            action.endpoint.contains('/timer/');
        return !isTimer;
      }).toList();

  int get totalPendingCount => visiblePendingActions.length;
  bool get hasPending => totalPendingCount > 0;

  EmployeeSyncState copyWith({
    bool? isOnline,
    bool? isSyncing,
    List<EmployeeSyncAction>? pendingActions,
    DateTime? lastSyncedAt,
    String? lastSyncMessage,
    bool clearMessage = false,
  }) {
    return EmployeeSyncState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingActions: pendingActions ?? this.pendingActions,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastSyncMessage: clearMessage
          ? null
          : (lastSyncMessage ?? this.lastSyncMessage),
    );
  }
}

class EmployeeSyncNotifier extends Notifier<EmployeeSyncState> {
  NetworkStatus? _lastObservedNetworkStatus;

  @override
  EmployeeSyncState build() {
    final queue = ref.watch(employeeSyncQueueProvider);
    final storage = ref.watch(storageServiceProvider);

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
    for (final action in initialQueue) {
      final isTimer = action.actionType == EmployeeSyncActionType.startTimer ||
          action.actionType == EmployeeSyncActionType.stopTimer ||
          action.actionType == EmployeeSyncActionType.manualTimeLog ||
          action.endpoint.contains('/timer/');
      if (isTimer) {
        queue.remove(action.id);
      }
    }
    final cleanedQueue = queue.loadQueue();
    final lastSync = storage.getLastSyncTime();

    return EmployeeSyncState(
      pendingActions: cleanedQueue,
      lastSyncedAt: lastSync,
    );
  }

  Future<void> enqueue(EmployeeSyncAction action) async {
    final queue = ref.read(employeeSyncQueueProvider);
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
      final service = ref.read(employeeSyncServiceProvider);
      final result = await service.processQueue();

      final queue = ref.read(employeeSyncQueueProvider);
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
      final friendlyError =
          ref.read(employeeSyncServiceProvider).toFriendlyError(e);
      state = state.copyWith(isSyncing: false, lastSyncMessage: friendlyError);
    }
  }
}

final employeeSyncProvider =
    NotifierProvider<EmployeeSyncNotifier, EmployeeSyncState>(
      EmployeeSyncNotifier.new,
    );
