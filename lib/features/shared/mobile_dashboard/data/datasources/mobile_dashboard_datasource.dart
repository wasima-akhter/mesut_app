import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../domain/entities/mobile_dashboard_entity.dart';
import '../../domain/entities/mobile_profile_entity.dart';
import '../../domain/entities/mobile_project_entity.dart';
import '../../domain/entities/mobile_schedule_entity.dart';
import '../models/mobile_dashboard_models.dart';

abstract class MobileDashboardRemoteDataSource {
  Future<MobileDashboardEntity> getDashboard();

  Future<List<MobileProjectEntity>> getProjects();

  Future<MobileProfileEntity> getProfile();

  Future<List<MobileScheduleDayEntity>> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<MobileMapPinEntity>> getMapPins({String? type});
}

class MobileDashboardRemoteDataSourceImpl
    implements MobileDashboardRemoteDataSource {
  MobileDashboardRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<MobileDashboardEntity> getDashboard() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileDashboard,
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return MobileDashboardModel.fromJson(data);
  }

  @override
  Future<List<MobileProjectEntity>> getProjects() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileProjects,
    );
    final body = response.data ?? const <String, dynamic>{};
    return MobileProjectModel.fromList(body['data']);
  }

  @override
  Future<MobileProfileEntity> getProfile() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileProfile,
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return MobileProfileModel.fromJson(data);
  }

  @override
  Future<List<MobileScheduleDayEntity>> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileSchedule,
      queryParameters: {
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    return MobileScheduleModel.fromList(body['data']);
  }

  @override
  Future<List<MobileMapPinEntity>> getMapPins({String? type}) async {
    final normalizedType = type?.trim().toUpperCase();
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileMap,
      queryParameters: (normalizedType != null && normalizedType.isNotEmpty)
          ? {'type': normalizedType}
          : null,
    );
    final body = response.data ?? const <String, dynamic>{};
    return MobileMapPinModel.fromList(body['data']);
  }
}
