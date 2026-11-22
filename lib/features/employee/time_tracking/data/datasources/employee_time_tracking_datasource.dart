import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:construction_app/core/constants/api_constants.dart';
import 'package:construction_app/core/network/api_client.dart';
import 'package:construction_app/core/network/network_providers.dart';
import '../../../offline_sync/models/employee_sync_action.dart';
import '../../../offline_sync/providers/employee_sync_provider.dart';
import '../../../offline_sync/services/employee_cache_service.dart';
import '../../../offline_sync/services/employee_sync_queue.dart';
import '../../domain/entities/employee_time_tracking_entities.dart';
import '../models/employee_time_tracking_models.dart';

abstract class EmployeeTimeTrackingDatasource {
  Future<EmployeeTimeSummaryEntity> getSummary();
  Future<List<EmployeeAssignedProjectEntity>> getProjects({
    int page = 1,
    int limit = 50,
  });
  Future<EmployeeActiveTimerEntity?> startTimer({
    required String projectId,
    required String activityType,
  });
  Future<void> stopTimer({
    required String timeLogId,
    double? gpsEndLat,
    double? gpsEndLng,
  });
  Future<void> addManualTime({
    required String projectId,
    required String activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
  });
  Future<List<EmployeeRecentLogEntity>> getTimeLogs({
    String period = 'WEEK',
    int page = 1,
    int limit = 20,
  });
}

class EmployeeTimeTrackingDatasourceImpl
    implements EmployeeTimeTrackingDatasource {
  EmployeeTimeTrackingDatasourceImpl({
    required this.apiClient,
    this.cacheService,
    this.syncQueue,
  });

  final ApiClient apiClient;
  final EmployeeCacheService? cacheService;
  final EmployeeSyncQueue? syncQueue;

  @override
  Future<EmployeeTimeSummaryEntity> getSummary() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.mobileEmployeeTimeTrackingSummary,
      );
      final data = _extractData(response.data);
      await cacheService?.cacheTimeSummary(data);
      return EmployeeTimeTrackingModels.summaryFromJson(data);
    } catch (e) {
      final cached = cacheService?.getCachedTimeSummary();
      if (cached != null) {
        return EmployeeTimeTrackingModels.summaryFromJson(cached);
      }
      if (e is DioException && e.response?.statusCode == 404) {
        return const EmployeeTimeSummaryEntity();
      }
      rethrow;
    }
  }

  @override
  Future<List<EmployeeAssignedProjectEntity>> getProjects({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.mobileEmployeeTimeTrackingProjects,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = _extractData(response.data);
      final list = data['data'] is List ? data['data'] : data;
      if (list is List && page == 1) {
        await cacheService?.cacheProjects(list);
      }
      return EmployeeTimeTrackingModels.projectListFromJson(list);
    } catch (_) {
      final cached = cacheService?.getCachedProjects();
      if (cached != null) {
        return EmployeeTimeTrackingModels.projectListFromJson(cached);
      }
      rethrow;
    }
  }

  @override
  Future<EmployeeActiveTimerEntity?> startTimer({
    required String projectId,
    required String activityType,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiConstants.mobileTimerStart,
        data: {
          'phaseId': projectId,
          'activityType': activityType,
        },
      );
      final data = _extractData(response.data);
      final timeLogMap = data['timeLog'] ?? data;
      return EmployeeTimeTrackingModels.parseActiveTimer(timeLogMap);
    } catch (e) {
      if (syncQueue != null) {
        final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
        final action = EmployeeSyncAction(
          id: localId,
          actionType: EmployeeSyncActionType.startTimer,
          endpoint: ApiConstants.mobileTimerStart,
          httpMethod: 'POST',
          payload: {
            'phaseId': projectId,
            'activityType': activityType,
          },
          projectId: projectId,
          displayTitle: 'Start Timer ($activityType)',
          createdAt: DateTime.now(),
        );
        await syncQueue!.enqueue(action);

        return EmployeeActiveTimerEntity(
          id: localId,
          phaseId: '',
          activityType: activityType,
          startTime: DateTime.now(),
          isManual: false,
          status: 'IN_PROGRESS',
          projectId: projectId,
          projectName: 'Active Timer',
          synced: false,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> stopTimer({
    required String timeLogId,
    double? gpsEndLat,
    double? gpsEndLng,
  }) async {
    final payload = <String, dynamic>{
      'timeLogId': timeLogId,
      if (gpsEndLat != null) 'gpsEndLat': gpsEndLat,
      if (gpsEndLng != null) 'gpsEndLng': gpsEndLng,
    };
    try {
      await apiClient.post<Map<String, dynamic>>(
        ApiConstants.mobileTimerStop,
        data: payload,
      );
      await cacheService?.save('time_summary', null);
    } catch (e) {
      if (syncQueue != null) {
        final action = EmployeeSyncAction(
          id: 'stop_${DateTime.now().millisecondsSinceEpoch}',
          actionType: EmployeeSyncActionType.stopTimer,
          endpoint: ApiConstants.mobileTimerStop,
          httpMethod: 'POST',
          payload: payload,
          displayTitle: 'Stop Timer',
          createdAt: DateTime.now(),
        );
        await syncQueue!.enqueue(action);
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> addManualTime({
    required String projectId,
    required String activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
  }) async {
    final payload = {
      'projectId': projectId,
      'activityType': activityType,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'breakMinutes': breakMinutes,
    };
    try {
      await apiClient.post<Map<String, dynamic>>(
        ApiConstants.mobileEmployeeTimerManual,
        data: payload,
      );
    } catch (e) {
      if (syncQueue != null) {
        final action = EmployeeSyncAction(
          id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
          actionType: EmployeeSyncActionType.manualTimeLog,
          endpoint: ApiConstants.mobileEmployeeTimerManual,
          httpMethod: 'POST',
          payload: payload,
          projectId: projectId,
          displayTitle: 'Manual Log ($activityType)',
          createdAt: DateTime.now(),
        );
        await syncQueue!.enqueue(action);
        return;
      }
      rethrow;
    }
  }

  @override
  Future<List<EmployeeRecentLogEntity>> getTimeLogs({
    String period = 'WEEK',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.mobileEmployeeTimeLogs,
        queryParameters: {'period': period, 'page': page, 'limit': limit},
      );
      final data = _extractData(response.data);
      final list = data['data'] is List ? data['data'] : data;
      if (list is List && page == 1) {
        await cacheService?.cacheTimeLogs(period, list);
      }
      return EmployeeTimeTrackingModels.logListFromJson(list);
    } catch (e) {
      final cached = cacheService?.getCachedTimeLogs(period);
      if (cached != null) {
        return EmployeeTimeTrackingModels.logListFromJson(cached);
      }
      if (e is DioException && e.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }

  Map<String, dynamic> _extractData(Map<String, dynamic>? body) {
    if (body == null) return const {};
    final data = body['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List) return {'data': data};
    return body;
  }
}

final employeeTimeTrackingDatasourceProvider =
    Provider<EmployeeTimeTrackingDatasource>((ref) {
      final client = ref.watch(apiClientProvider);
      final cache = ref.watch(employeeCacheServiceProvider);
      final queue = ref.watch(employeeSyncQueueProvider);
      return EmployeeTimeTrackingDatasourceImpl(
        apiClient: client,
        cacheService: cache,
        syncQueue: queue,
      );
    });
