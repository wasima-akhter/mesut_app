import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/connectivity/connectivity_provider.dart';
import '../../../../core/connectivity/network_status.dart';
import '../../../../core/enums/backend_enums.dart';
import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../data/datasources/mobile_timer_remote_datasource.dart';
import '../../data/datasources/offline_sync_local_datasource.dart';
import '../../domain/entities/offline_time_log.dart';

final offlineSyncLocalDataSourceProvider =
    Provider<OfflineSyncLocalDataSource>((ref) {
      return OfflineSyncLocalDataSourceImpl(
        storageService: ref.watch(storageServiceProvider),
      );
    });

final mobileTimerRemoteDataSourceProvider =
    Provider<MobileTimerRemoteDataSource>((ref) {
      return MobileTimerRemoteDataSourceImpl(
        apiClient: ref.watch(apiClientProvider),
      );
    });

class OfflineSyncState {
  const OfflineSyncState({
    this.pendingLogs = const [],
    this.isSyncing = false,
    this.lastSyncedAt,
    this.lastCreatedCount = 0,
    this.lastSkippedCount = 0,
    this.errorMessage,
  });

  final List<OfflineTimeLog> pendingLogs;
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final int lastCreatedCount;
  final int lastSkippedCount;
  final String? errorMessage;

  int get pendingCount => pendingLogs.length;
  bool get hasPending => pendingLogs.isNotEmpty;

  OfflineSyncState copyWith({
    List<OfflineTimeLog>? pendingLogs,
    bool? isSyncing,
    DateTime? lastSyncedAt,
    int? lastCreatedCount,
    int? lastSkippedCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OfflineSyncState(
      pendingLogs: pendingLogs ?? this.pendingLogs,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastCreatedCount: lastCreatedCount ?? this.lastCreatedCount,
      lastSkippedCount: lastSkippedCount ?? this.lastSkippedCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OfflineSyncNotifier extends Notifier<OfflineSyncState> {
  NetworkStatus? _lastObservedNetworkStatus;

  @override
  OfflineSyncState build() {
    final localDs = ref.watch(offlineSyncLocalDataSourceProvider);
    final storage = ref.read(storageServiceProvider);
    final initialQueue = localDs.loadQueue();
    final lastSynced = storage.getLastSyncTime();

    ref.listen<AsyncValue<NetworkStatus>>(networkStatusProvider, (_, next) {
      final status = next.asData?.value;
      if (status == null) return;
      final transitionedToOnline =
          _lastObservedNetworkStatus != NetworkStatus.online &&
          status == NetworkStatus.online;
      _lastObservedNetworkStatus = status;

      if (transitionedToOnline && state.hasPending && !state.isSyncing) {
        syncPendingLogs();
      }
    });

    return OfflineSyncState(
      pendingLogs: initialQueue,
      lastSyncedAt: lastSynced,
    );
  }

  /// Queues a completed timer segment with an immutable v4 `clientSyncId` and
  /// immediately attempts to sync if connectivity is available.
  Future<void> enqueueCompletedSegment({
    required String phaseId,
    required BackendActivityType activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
    String? projectName,
    bool attemptImmediateSync = true,
  }) async {
    final log = OfflineTimeLog.create(
      phaseId: phaseId,
      activityType: activityType,
      startTime: startTime,
      endTime: endTime,
      breakMinutes: breakMinutes,
      projectName: projectName,
    );

    final localDs = ref.read(offlineSyncLocalDataSourceProvider);
    await localDs.enqueue(log);

    state = state.copyWith(
      pendingLogs: localDs.loadQueue(),
      clearError: true,
    );

    if (attemptImmediateSync) {
      final isOnline = await ref.read(isOnlineProvider.future);
      if (isOnline && ref.mounted) {
        await syncPendingLogs();
      }
    }
  }

  /// Submits queued logs to `POST /mobile/sync` without modifying any `clientSyncId`.
  Future<MobileSyncResult?> syncPendingLogs() async {
    if (state.isSyncing) return null;
    final localDs = ref.read(offlineSyncLocalDataSourceProvider);
    final queue = localDs.loadQueue();
    if (queue.isEmpty) {
      final now = DateTime.now();
      await ref.read(storageServiceProvider).saveLastSyncTime(now);
      state = state.copyWith(
        pendingLogs: const [],
        lastSyncedAt: now,
        clearError: true,
      );
      return const MobileSyncResult(created: 0, skipped: 0);
    }

    final storage = ref.read(storageServiceProvider);
    final hasValidToken = await storage.hasValidAccessToken();
    if (!hasValidToken) return null;

    state = state.copyWith(isSyncing: true, clearError: true);

    try {
      final remoteDs = ref.read(mobileTimerRemoteDataSourceProvider);
      final result = await remoteDs.syncOfflineLogs(queue);
      if (!ref.mounted) return result;

      final acknowledgedIds = <String>{};
      if (result.acknowledgedCount >= queue.length) {
        acknowledgedIds.addAll(queue.map((e) => e.clientSyncId));
      } else {
        for (final row in result.logs) {
          final syncId = row['clientSyncId']?.toString().trim();
          if (syncId != null && syncId.isNotEmpty) {
            acknowledgedIds.add(syncId);
          }
        }
      }

      if (acknowledgedIds.isNotEmpty) {
        await localDs.removeBySyncIds(acknowledgedIds);
      }

      final now = DateTime.now();
      await storage.saveLastSyncTime(now);

      state = state.copyWith(
        pendingLogs: localDs.loadQueue(),
        isSyncing: false,
        lastSyncedAt: now,
        lastCreatedCount: result.created,
        lastSkippedCount: result.skipped,
        clearError: true,
      );
      return result;
    } catch (e) {
      if (!ref.mounted) return null;
      final langCode = ref.read(appLanguageProvider).code;
      final resolved = AppErrorResolver.resolve(e, languageCode: langCode);
      // Preserve pending queue intact with identical clientSyncIds for safe retry.
      state = state.copyWith(
        isSyncing: false,
        errorMessage: resolved.displayMessage,
      );
      return null;
    }
  }
}

final offlineSyncProvider =
    NotifierProvider<OfflineSyncNotifier, OfflineSyncState>(
      OfflineSyncNotifier.new,
    );
