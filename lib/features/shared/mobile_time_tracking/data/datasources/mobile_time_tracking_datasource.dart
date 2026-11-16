import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/enums/backend_enums.dart';
import '../../../../../core/network/api_client.dart';
import '../../domain/entities/mobile_time_log_entity.dart';
import '../models/mobile_time_tracking_models.dart';

abstract class MobileTimeTrackingRemoteDataSource {
  Future<MobileTimerStartResultEntity> startTimer({
    required String phaseId,
    required BackendActivityType activityType,
    double? gpsStartLat,
    double? gpsStartLng,
  });

  Future<MobileTimeLogEntity> stopTimer({
    required String timeLogId,
    double? gpsEndLat,
    double? gpsEndLng,
  });

  Future<MobileTimeLogEntity> logManualTime({
    required String phaseId,
    required BackendActivityType activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
  });

  Future<List<MobileTimeLogEntity>> getTimeLogs({String period = 'TODAY'});

  Future<MobileCrewTimeEntity> getCrewTime({
    required String projectId,
    DateTime? date,
    int page = 1,
    int limit = 10,
  });
}

class MobileTimeTrackingRemoteDataSourceImpl
    implements MobileTimeTrackingRemoteDataSource {
  MobileTimeTrackingRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<MobileTimerStartResultEntity> startTimer({
    required String phaseId,
    required BackendActivityType activityType,
    double? gpsStartLat,
    double? gpsStartLng,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.mobileTimerStart,
      data: {
        'phaseId': phaseId,
        'activityType': activityType.serializedName,
        'gpsStartLat': ?gpsStartLat,
        'gpsStartLng': ?gpsStartLng,
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return MobileTimerStartResultModel.fromJson(data);
  }

  @override
  Future<MobileTimeLogEntity> stopTimer({
    required String timeLogId,
    double? gpsEndLat,
    double? gpsEndLng,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.mobileTimerStop,
      data: {
        'timeLogId': timeLogId,
        'gpsEndLat': ?gpsEndLat,
        'gpsEndLng': ?gpsEndLng,
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return MobileTimeLogModel.fromJson(data);
  }

  @override
  Future<MobileTimeLogEntity> logManualTime({
    required String phaseId,
    required BackendActivityType activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.mobileTimerManual,
      data: {
        'phaseId': phaseId,
        'activityType': activityType.serializedName,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'breakMinutes': breakMinutes,
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return MobileTimeLogModel.fromJson(data);
  }

  @override
  Future<List<MobileTimeLogEntity>> getTimeLogs({
    String period = 'TODAY',
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileTimeLogs,
      queryParameters: {'period': period},
    );
    final body = response.data ?? const <String, dynamic>{};
    return MobileTimeLogModel.fromList(body['data']);
  }

  @override
  Future<MobileCrewTimeEntity> getCrewTime({
    required String projectId,
    DateTime? date,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileCrewTime,
      queryParameters: {
        'projectId': projectId,
        if (date != null) 'date': date.toUtc().toIso8601String(),
        'page': page,
        'limit': limit,
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return MobileCrewTimeModel.fromJson(data);
  }
}
