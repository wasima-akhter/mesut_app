import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:construction_app/core/constants/api_constants.dart';
import 'package:construction_app/core/network/api_client.dart';
import 'package:construction_app/core/network/network_providers.dart';
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
  EmployeeTimeTrackingDatasourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<EmployeeTimeSummaryEntity> getSummary() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileEmployeeTimeTrackingSummary,
    );
    final data = _extractData(response.data);
    return EmployeeTimeTrackingModels.summaryFromJson(data);
  }

  @override
  Future<List<EmployeeAssignedProjectEntity>> getProjects({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileEmployeeTimeTrackingProjects,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = _extractData(response.data);
    final list = data['data'] is List ? data['data'] : data;
    return EmployeeTimeTrackingModels.projectListFromJson(list);
  }

  @override
  Future<EmployeeActiveTimerEntity?> startTimer({
    required String projectId,
    required String activityType,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.mobileEmployeeTimerStart,
      data: {'projectId': projectId, 'activityType': activityType},
    );
    final data = _extractData(response.data);
    final timeLogMap = data['timeLog'] ?? data;
    return EmployeeTimeTrackingModels.parseActiveTimer(timeLogMap);
  }

  @override
  Future<void> stopTimer({
    required String timeLogId,
    double? gpsEndLat,
    double? gpsEndLng,
  }) async {
    await apiClient.post<Map<String, dynamic>>(
      ApiConstants.mobileEmployeeTimerStop,
      data: {
        'timeLogId': timeLogId,
        'gpsEndLat': gpsEndLat ?? 0,
        'gpsEndLng': gpsEndLng ?? 0,
      },
    );
  }

  @override
  Future<void> addManualTime({
    required String projectId,
    required String activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
  }) async {
    await apiClient.post<Map<String, dynamic>>(
      ApiConstants.mobileEmployeeTimerManual,
      data: {
        'projectId': projectId,
        'activityType': activityType,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'breakMinutes': breakMinutes,
      },
    );
  }

  @override
  Future<List<EmployeeRecentLogEntity>> getTimeLogs({
    String period = 'WEEK',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileEmployeeTimeLogs,
      queryParameters: {'period': period, 'page': page, 'limit': limit},
    );
    final data = _extractData(response.data);
    final list = data['data'] is List ? data['data'] : data;
    return EmployeeTimeTrackingModels.logListFromJson(list);
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
      return EmployeeTimeTrackingDatasourceImpl(apiClient: client);
    });
