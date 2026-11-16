import '../../../../core/constants/api_constants.dart';
import '../../../../core/enums/backend_enums.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/offline_time_log.dart';

abstract class MobileTimerRemoteDataSource {
  Future<MobileSyncResult> syncOfflineLogs(List<OfflineTimeLog> logs);

  Future<Map<String, dynamic>> startTimer({
    required String phaseId,
    required BackendActivityType activityType,
    double? lat,
    double? lng,
  });

  Future<Map<String, dynamic>> stopTimer({
    required String timeLogId,
    double? lat,
    double? lng,
  });

  Future<Map<String, dynamic>> logManualTime({
    required String phaseId,
    required BackendActivityType activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
  });

  Future<List<Map<String, dynamic>>> getTimeLogs({String period = 'WEEK'});
}

class MobileTimerRemoteDataSourceImpl implements MobileTimerRemoteDataSource {
  MobileTimerRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<MobileSyncResult> syncOfflineLogs(List<OfflineTimeLog> logs) async {
    if (logs.isEmpty) {
      return const MobileSyncResult(created: 0, skipped: 0);
    }

    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.mobileSync,
      data: {'logs': logs.map((log) => log.toApiPayload()).toList()},
    );

    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;

    return MobileSyncResult.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> startTimer({
    required String phaseId,
    required BackendActivityType activityType,
    double? lat,
    double? lng,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.mobileTimerStart,
      data: {
        'phaseId': phaseId,
        'activityType': activityType.serializedName,
        if (lat != null) 'gpsStartLat': lat,
        if (lng != null) 'gpsStartLng': lng,
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    return body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
  }

  @override
  Future<Map<String, dynamic>> stopTimer({
    required String timeLogId,
    double? lat,
    double? lng,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.mobileTimerStop,
      data: {
        'timeLogId': timeLogId,
        if (lat != null) 'gpsEndLat': lat,
        if (lng != null) 'gpsEndLng': lng,
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    return body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
  }

  @override
  Future<Map<String, dynamic>> logManualTime({
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
    return body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
  }

  @override
  Future<List<Map<String, dynamic>>> getTimeLogs({
    String period = 'WEEK',
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileTimeLogs,
      queryParameters: {'period': period},
    );
    final body = response.data ?? const <String, dynamic>{};
    final rawList = body['data'] is List
        ? body['data'] as List
        : (body['items'] is List ? body['items'] as List : const []);
    return rawList
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }
}
