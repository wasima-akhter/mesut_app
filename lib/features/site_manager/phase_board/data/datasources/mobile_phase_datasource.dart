import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../offline_sync/services/site_manager_cache_service.dart';
import '../../domain/entities/mobile_phase_entity.dart';
import '../models/mobile_phase_model.dart';

abstract class MobilePhaseRemoteDataSource {
  Future<List<MobilePhaseEntity>> getManagedPhases({
    String? column,
    int page = 1,
    int limit = 50,
  });

  Future<MobilePhaseEntity> updatePhaseStatus(String phaseId, String status);
}

class MobilePhaseRemoteDataSourceImpl implements MobilePhaseRemoteDataSource {
  MobilePhaseRemoteDataSourceImpl({required this.apiClient, this.cacheService});

  final ApiClient apiClient;
  final SiteManagerCacheService? cacheService;

  @override
  Future<List<MobilePhaseEntity>> getManagedPhases({
    String? column,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (column != null && column.isNotEmpty && column != 'ALL') {
      queryParams['column'] = column;
    }

    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.mobilePhases,
        queryParameters: queryParams,
      );
      final body = response.data ?? const <String, dynamic>{};
      final data = body['data'];
      if (page == 1 && data != null) {
        await cacheService?.cachePhases(column ?? 'ALL', data);
      }
      return MobilePhaseModel.fromList(data);
    } catch (_) {
      final cached = cacheService?.getCachedPhases(column ?? 'ALL');
      if (cached != null) {
        return MobilePhaseModel.fromList(cached);
      }
      rethrow;
    }
  }

  @override
  Future<MobilePhaseEntity> updatePhaseStatus(
    String phaseId,
    String status,
  ) async {
    final response = await apiClient.patch<Map<String, dynamic>>(
      ApiConstants.mobilePhaseStatus(phaseId),
      data: {'status': status},
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return MobilePhaseModel.fromJson(data);
  }
}
