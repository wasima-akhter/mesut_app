import '../../domain/entities/mobile_config_entity.dart';
import '../../domain/repositories/mobile_config_repository.dart';
import '../datasources/mobile_config_datasource.dart';

class MobileConfigRepositoryImpl implements MobileConfigRepository {
  MobileConfigRepositoryImpl(this._dataSource);

  final MobileConfigDataSource _dataSource;

  @override
  Future<MobileConfigEntity> fetchConfig() async {
    try {
      return await _dataSource.fetchConfig();
    } catch (e) {
      final cached = _dataSource.getCachedConfig();
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  MobileConfigEntity? getCachedConfig() => _dataSource.getCachedConfig();
}
