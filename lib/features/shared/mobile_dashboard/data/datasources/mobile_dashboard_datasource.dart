import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../site_manager/offline_sync/services/site_manager_cache_service.dart';
import '../../domain/entities/mobile_dashboard_entity.dart';
import '../../domain/entities/mobile_profile_entity.dart';
import '../../domain/entities/mobile_project_entity.dart';
import '../../domain/entities/mobile_schedule_entity.dart';
import '../models/mobile_dashboard_models.dart';

abstract class MobileDashboardRemoteDataSource {
  Future<MobileDashboardEntity> getDashboard({int page = 1, int limit = 10});

  Future<List<MobileProjectEntity>> getProjects({int page = 1, int limit = 50});

  Future<MobileProfileEntity> getProfile();
  Future<MobileProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? language,
  });

  Future<List<MobileScheduleDayEntity>> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<MobileMapPinEntity>> getMapPins({String? type});
}

class MobileDashboardRemoteDataSourceImpl
    implements MobileDashboardRemoteDataSource {
  MobileDashboardRemoteDataSourceImpl({
    required this.apiClient,
    this.cacheService,
  });

  final ApiClient apiClient;
  final SiteManagerCacheService? cacheService;

  @override
  Future<MobileDashboardEntity> getDashboard({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.mobileDashboard,
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = response.data ?? const <String, dynamic>{};
      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body;
      await cacheService?.cacheDashboard(data);
      return MobileDashboardModel.fromJson(data);
    } catch (_) {
      final cached = cacheService?.getCachedDashboard();
      if (cached != null) {
        return MobileDashboardModel.fromJson(cached);
      }
      rethrow;
    }
  }

  @override
  Future<List<MobileProjectEntity>> getProjects({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileProjects,
      queryParameters: {'page': page, 'limit': limit},
    );
    final body = response.data ?? const <String, dynamic>{};
    return MobileProjectModel.fromList(body['data']);
  }

  @override
  Future<MobileProfileEntity> getProfile() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.mobileProfile,
      );
      final body = response.data ?? const <String, dynamic>{};
      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body;
      await cacheService?.cacheProfile(data);
      return MobileProfileModel.fromJson(data);
    } catch (_) {
      final cached = cacheService?.getCachedProfile();
      if (cached is Map) {
        return MobileProfileModel.fromJson(Map<String, dynamic>.from(cached));
      }
      rethrow;
    }
  }

  @override
  Future<MobileProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? language,
  }) async {
    final payload = <String, dynamic>{
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (language != null) 'language': language,
    };
    final response = await apiClient.patch<Map<String, dynamic>>(
      ApiConstants.mobileProfile,
      data: payload,
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    await cacheService?.cacheProfile(data);
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
        'limit': 50,
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
