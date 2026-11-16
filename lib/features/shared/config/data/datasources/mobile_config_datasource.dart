import 'dart:convert';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/storage_service.dart';
import '../../domain/entities/mobile_config_entity.dart';

abstract class MobileConfigDataSource {
  Future<MobileConfigEntity> fetchConfig();
  MobileConfigEntity? getCachedConfig();
  Future<void> cacheConfig(MobileConfigEntity config);
}

class MobileConfigRemoteDataSourceImpl implements MobileConfigDataSource {
  MobileConfigRemoteDataSourceImpl({
    required this.apiClient,
    required this.storageService,
  });

  final ApiClient apiClient;
  final StorageService storageService;

  @override
  Future<MobileConfigEntity> fetchConfig() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.mobileConfig,
    );
    final payload = response.data ?? const <String, dynamic>{};
    final configMap = payload['data'] is Map
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : payload;
    final config = MobileConfigEntity.fromJson(configMap);
    await cacheConfig(config);
    return config;
  }

  @override
  MobileConfigEntity? getCachedConfig() {
    final raw = storageService.getMobileConfigJson();
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return MobileConfigEntity.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> cacheConfig(MobileConfigEntity config) async {
    try {
      await storageService.saveMobileConfigJson(jsonEncode(config.toJson()));
    } catch (_) {}
  }
}
