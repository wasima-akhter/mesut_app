import 'package:construction_app/core/constants/api_constants.dart';
import 'package:construction_app/core/network/api_client.dart';
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
  EmployeeScheduleRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<EmployeeScheduleDayEntity>> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 50,
  }) async {
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
    return EmployeeScheduleModel.fromList(body['data']);
  }
}

