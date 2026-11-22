import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../models/employee_project_details_model.dart';
import '../models/employee_project_photo_model.dart';
import '../models/employee_project_task_model.dart';
import '../../domain/entities/employee_project_details_entity.dart';

abstract class EmployeeProjectDetailsDataSource {
  Future<EmployeeProjectDetailsEntity> fetchProjectDetail(String projectId);

  Future<List<EmployeeProjectPhotoEntity>> fetchProjectPhotos(
    String projectId, {
    int page = 1,
    int limit = 10,
  });

  Future<List<EmployeeProjectTaskEntity>> fetchProjectTasks(
    String projectId, {
    String? status,
    int page = 1,
    int limit = 10,
  });

  Future<bool> toggleTask(String taskId);
}

class EmployeeProjectDetailsRemoteDataSourceImpl
    implements EmployeeProjectDetailsDataSource {
  final ApiClient _apiClient;

  EmployeeProjectDetailsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<EmployeeProjectDetailsEntity> fetchProjectDetail(
    String projectId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileEmployeeProjectDetail(projectId),
    );

    final payload = response.data ?? const <String, dynamic>{};
    final data = payload['data'] is Map<String, dynamic>
        ? payload['data'] as Map<String, dynamic>
        : (payload['data'] is Map
            ? Map<String, dynamic>.from(payload['data'] as Map)
            : payload);

    return EmployeeProjectDetailsModel.fromJson(data);
  }

  @override
  Future<List<EmployeeProjectPhotoEntity>> fetchProjectPhotos(
    String projectId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileEmployeeProjectPhotos(projectId),
      queryParameters: {'page': page, 'limit': limit},
    );

    final payload = response.data ?? const <String, dynamic>{};
    final list = payload['data'];
    return EmployeeProjectPhotoModel.fromJsonList(list);
  }

  @override
  Future<List<EmployeeProjectTaskEntity>> fetchProjectTasks(
    String projectId, {
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileEmployeeProjectTasks(projectId),
      queryParameters: query,
    );

    final payload = response.data ?? const <String, dynamic>{};
    final list = payload['data'];
    return EmployeeProjectTaskModel.fromJsonList(list);
  }

  @override
  Future<bool> toggleTask(String taskId) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiConstants.mobileTaskToggle(taskId),
      );
      final payload = response.data ?? const <String, dynamic>{};
      return payload['success'] == true;
    } catch (_) {
      return false;
    }
  }
}
