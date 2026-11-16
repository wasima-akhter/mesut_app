import '../entities/mobile_config_entity.dart';

abstract class MobileConfigRepository {
  Future<MobileConfigEntity> fetchConfig();
  MobileConfigEntity? getCachedConfig();
}
