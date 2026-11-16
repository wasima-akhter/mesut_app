import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums/app_enum.dart';
import '../../../../../core/enums/backend_enums.dart';
import '../../../../../core/helpers/device_location_helper.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../../../core/providers/common_provider.dart';
import '../../../../../core/storage/storage_provider.dart';
import '../../data/datasources/mobile_time_tracking_datasource.dart';
import '../../data/repositories/mobile_time_tracking_repository_impl.dart';
import '../../domain/entities/mobile_time_log_entity.dart';
import '../../domain/repositories/mobile_time_tracking_repository.dart';

final mobileTimeTrackingDataSourceProvider =
    Provider<MobileTimeTrackingRemoteDataSource>((ref) {
      return MobileTimeTrackingRemoteDataSourceImpl(
        apiClient: ref.watch(apiClientProvider),
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
  }

  Future<MobileTimeLogEntity?> stopActiveTimer() async {
    final id = _activeTimeLogId;
    if (id == null || id.isEmpty) return null;
    final coords = await DeviceLocationHelper.tryGetCoordinates();
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
  }

  Future<MobileTimeLogEntity> logManualTime({
    required String phaseId,
    required BackendActivityType activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
  }) async {
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
  }
}

final mobileTimeLogsProvider =
    AsyncNotifierProvider<MobileTimeLogsNotifier, List<MobileTimeLogEntity>>(
      MobileTimeLogsNotifier.new,
    );

class MobileCrewTimeNotifier extends AsyncNotifier<MobileCrewTimeEntity?> {
  String? _projectId;
  DateTime? _date;

  String? get projectId => _projectId;
  DateTime? get date => _date;

  @override
  Future<MobileCrewTimeEntity?> build() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    final role = ref.watch(userRoleProvider);
    if (!hasToken || role != UserRole.siteManager || _projectId == null) {
      return null;
    }
    return ref
        .watch(mobileTimeTrackingRepositoryProvider)
        .getCrewTime(projectId: _projectId!, date: _date);
  }

  Future<void> load({required String projectId, DateTime? date}) async {
    _projectId = projectId;
    _date = date;
    await refresh();
  }

  Future<void> refresh() async {
    final hasToken = await ref
        .read(storageServiceProvider)
        .hasValidAccessToken();
    final role = ref.read(userRoleProvider);
    final pid = _projectId;
    if (!hasToken ||
        role != UserRole.siteManager ||
        pid == null ||
        pid.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(mobileTimeTrackingRepositoryProvider)
          .getCrewTime(projectId: pid, date: _date),
    );
  }
}

final mobileCrewTimeProvider =
    AsyncNotifierProvider<MobileCrewTimeNotifier, MobileCrewTimeEntity?>(
      MobileCrewTimeNotifier.new,
    );
