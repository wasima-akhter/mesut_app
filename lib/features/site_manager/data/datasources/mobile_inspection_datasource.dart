import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/mobile_inspection_entity.dart';
import '../models/mobile_inspection_model.dart';

abstract class MobileInspectionRemoteDataSource {
  Future<List<MobileInspectionEntity>> getInspections();

  Future<MobileInspectionEntity> getInspectionById(String id);

  Future<MobileInspectionEntity> completeInspection(
    String id, {
    required double scaffoldArea,
    required double scaffoldHeight,
    required String scaffoldType,
  });
}

class MobileInspectionRemoteDataSourceImpl
    implements MobileInspectionRemoteDataSource {
  MobileInspectionRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<MobileInspectionEntity>> getInspections() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileInspections,
    );
    final body = response.data ?? const <String, dynamic>{};
    return MobileInspectionModel.fromList(body['data']);
  }

  @override
  Future<MobileInspectionEntity> getInspectionById(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileInspectionById(id),
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return MobileInspectionModel.fromJson(data);
  }

  @override
  Future<MobileInspectionEntity> completeInspection(
    String id, {
    required double scaffoldArea,
    required double scaffoldHeight,
    required String scaffoldType,
  }) async {
    final response = await apiClient.patch<Map<String, dynamic>>(
      ApiConstants.mobileInspectionComplete(id),
      data: {
        'scaffoldArea': scaffoldArea,
        'scaffoldHeight': scaffoldHeight,
        'scaffoldType': scaffoldType,
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return MobileInspectionModel.fromJson(data);
  }
}
