import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/mobile_phase_entity.dart';
import '../models/mobile_phase_model.dart';

abstract class MobilePhaseRemoteDataSource {
  Future<List<MobilePhaseEntity>> getManagedPhases();

  Future<MobilePhaseEntity> updatePhaseStatus(String phaseId, String status);
}

class MobilePhaseRemoteDataSourceImpl implements MobilePhaseRemoteDataSource {
  MobilePhaseRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<MobilePhaseEntity>> getManagedPhases() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobilePhases,
    );
    final body = response.data ?? const <String, dynamic>{};
    return MobilePhaseModel.fromList(body['data']);
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
