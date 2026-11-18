import 'package:construction_app/core/constants/api_constants.dart';
import 'package:construction_app/core/network/api_client.dart';
import '../../../offline_sync/services/employee_cache_service.dart';
import '../../domain/entities/employee_schedule_entity.dart';
import '../models/employee_schedule_model.dart';

abstract class EmployeeScheduleRemoteDataSource {
  Future<List<EmployeeScheduleDayEntity>> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 50,
  });
}

class EmployeeScheduleRemoteDataSourceImpl
    implements EmployeeScheduleRemoteDataSource {
  EmployeeScheduleRemoteDataSourceImpl({
    required this.apiClient,
    this.cacheService,
  });

  final ApiClient apiClient;
  final EmployeeCacheService? cacheService;

  @override
  Future<List<EmployeeScheduleDayEntity>> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.mobileEmployeeSchedule,
        queryParameters: {
          'startDate': startDate.toUtc().toIso8601String(),
          'endDate': endDate.toUtc().toIso8601String(),
          'page': page,
          'limit': limit,
        },
      );

      final body = response.data ?? const <String, dynamic>{};
      final rawList = body['data'];
      if (rawList is List) {
        await cacheService?.cacheSchedule(rawList);
        return EmployeeScheduleModel.fromList(rawList);
      }
    } catch (_) {
      final cached = cacheService?.getCachedSchedule();
      if (cached != null) {
        return EmployeeScheduleModel.fromList(cached);
      }
      rethrow;
    }
    return const [];
  }
}

