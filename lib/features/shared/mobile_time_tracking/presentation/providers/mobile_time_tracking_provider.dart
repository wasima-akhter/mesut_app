import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/enums/backend_enums.dart';
import '../../../../../core/helpers/device_location_helper.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../../../core/storage/storage_provider.dart';
import '../../../../site_manager/offline_sync/models/site_manager_sync_action.dart';
import '../../../../site_manager/offline_sync/providers/site_manager_sync_provider.dart';
import '../../data/datasources/mobile_time_tracking_datasource.dart';
import '../../data/repositories/mobile_time_tracking_repository_impl.dart';
import '../../domain/entities/mobile_time_log_entity.dart';
import '../../domain/repositories/mobile_time_tracking_repository.dart';

export 'mobile_crew_time_provider.dart';

final mobileTimeTrackingDataSourceProvider =
    Provider<MobileTimeTrackingRemoteDataSource>((ref) {
      return MobileTimeTrackingRemoteDataSourceImpl(
        apiClient: ref.watch(apiClientProvider),
        cacheService: ref.watch(siteManagerCacheServiceProvider),
      );
    });

final mobileTimeTrackingRepositoryProvider =
    Provider<MobileTimeTrackingRepository>((ref) {
      return MobileTimeTrackingRepositoryImpl(
        ref.watch(mobileTimeTrackingDataSourceProvider),
      );
    });

class MobileTimeLogsNotifier extends AsyncNotifier<List<MobileTimeLogEntity>> {
  String _period = 'TODAY';
  String? _activeTimeLogId;

  String get period => _period;
  String? get activeTimeLogId => _activeTimeLogId;

  @override
  Future<List<MobileTimeLogEntity>> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    if (!hasToken) return const [];
    final logs = await ref
        .watch(mobileTimeTrackingRepositoryProvider)
        .getTimeLogs(period: _period);
    _syncActiveLogId(logs);
    return logs;
  }

  void _syncActiveLogId(List<MobileTimeLogEntity> logs) {
    final openLog = logs.where((l) => l.endTime == null).firstOrNull;
    _activeTimeLogId = openLog?.id;
  }

  Future<void> setPeriod(String period) async {
    final normalized = period.trim().toUpperCase();
    if (normalized == _period) return;
    _period = normalized;
    await refresh();
  }

  Future<void> refresh() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    if (!hasToken) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final logs = await ref
          .read(mobileTimeTrackingRepositoryProvider)
          .getTimeLogs(period: _period);
      _syncActiveLogId(logs);
      return logs;
    });
  }

  Future<MobileTimerStartResultEntity> startTimer({
    required String phaseId,
    required BackendActivityType activityType,
  }) async {
    final coords = await DeviceLocationHelper.tryGetCoordinates();
    try {
      final result = await ref
          .read(mobileTimeTrackingRepositoryProvider)
          .startTimer(
            phaseId: phaseId,
            activityType: activityType,
            gpsStartLat: coords?.lat,
            gpsStartLng: coords?.lng,
          );
      _activeTimeLogId = result.timeLog.id;
      await refresh();
      return result;
    } catch (_) {
      final localId = 'offline_timer_${DateTime.now().millisecondsSinceEpoch}';
      final localLog = MobileTimeLogEntity(
        id: localId,
        phaseId: phaseId,
        activityType: activityType,
        startTime: DateTime.now(),
        isManual: false,
      );
      _activeTimeLogId = localId;

      final action = SiteManagerSyncAction(
        id: localId,
        actionType: SiteManagerSyncActionType.startTimer,
        endpoint: ApiConstants.mobileTimerStart,
        httpMethod: 'POST',
        displayTitle: 'Start Timer: ${activityType.name}',
        createdAt: DateTime.now(),
        payload: {
          'phaseId': phaseId,
          'activityType': activityType.serializedName,
          'gpsStartLat': coords?.lat,
          'gpsStartLng': coords?.lng,
        },
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);

      final current = state.asData?.value ?? const <MobileTimeLogEntity>[];
      state = AsyncValue.data([localLog, ...current]);
      return MobileTimerStartResultEntity(timeLog: localLog);
    }
  }

  Future<MobileTimeLogEntity?> stopActiveTimer() async {
    final id = _activeTimeLogId;
    if (id == null || id.isEmpty) return null;
    final coords = await DeviceLocationHelper.tryGetCoordinates();

    try {
      final stopped = await ref
          .read(mobileTimeTrackingRepositoryProvider)
          .stopTimer(
            timeLogId: id,
            gpsEndLat: coords?.lat,
            gpsEndLng: coords?.lng,
          );
      _activeTimeLogId = null;
      await refresh();
      return stopped;
    } catch (_) {
      final current = state.asData?.value ?? const <MobileTimeLogEntity>[];
      final target = current.firstWhere(
        (l) => l.id == id,
        orElse: () => current.first,
      );
      final now = DateTime.now();
      final startTime = target.startTime ?? now;
      final stopped = target.copyWith(
        endTime: now,
        netHours: now.difference(startTime).inMinutes / 60.0,
      );
      _activeTimeLogId = null;

      final action = SiteManagerSyncAction(
        id: 'stop_$id',
        actionType: SiteManagerSyncActionType.stopTimer,
        endpoint: ApiConstants.mobileTimerStop,
        httpMethod: 'POST',
        displayTitle: 'Stop Timer',
        createdAt: DateTime.now(),
        payload: {
          'timeLogId': id,
          'gpsEndLat': coords?.lat,
          'gpsEndLng': coords?.lng,
        },
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);

      final next = current.map((l) => l.id == id ? stopped : l).toList();
      state = AsyncValue.data(next);
      return stopped;
    }
  }

  Future<MobileTimeLogEntity> logManualTime({
    required String phaseId,
    required BackendActivityType activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
  }) async {
    final payload = {
      'phaseId': phaseId,
      'activityType': activityType.serializedName,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'breakMinutes': breakMinutes,
    };

    try {
      final created = await ref
          .read(mobileTimeTrackingRepositoryProvider)
          .logManualTime(
            phaseId: phaseId,
            activityType: activityType,
            startTime: startTime,
            endTime: endTime,
            breakMinutes: breakMinutes,
          );
      await refresh();
      return created;
    } catch (_) {
      final localId = 'offline_log_${DateTime.now().millisecondsSinceEpoch}';
      final offlineLog = MobileTimeLogEntity(
        id: localId,
        phaseId: phaseId,
        activityType: activityType,
        startTime: startTime,
        endTime: endTime,
        isManual: true,
        breakMinutes: breakMinutes,
        netHours:
            (endTime.difference(startTime).inMinutes - breakMinutes) / 60.0,
      );

      final action = SiteManagerSyncAction(
        id: localId,
        actionType: SiteManagerSyncActionType.manualTimeLog,
        endpoint: ApiConstants.mobileTimerManual,
        httpMethod: 'POST',
        displayTitle: 'Time Log: ${activityType.name}',
        createdAt: DateTime.now(),
        payload: payload,
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);

      final current = state.asData?.value ?? const <MobileTimeLogEntity>[];
      state = AsyncValue.data([offlineLog, ...current]);
      return offlineLog;
    }
  }
}

final mobileTimeLogsProvider =
    AsyncNotifierProvider<MobileTimeLogsNotifier, List<MobileTimeLogEntity>>(
      MobileTimeLogsNotifier.new,
    );
