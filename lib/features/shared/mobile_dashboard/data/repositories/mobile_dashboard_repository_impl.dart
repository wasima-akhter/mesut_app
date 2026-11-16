import '../../domain/entities/mobile_dashboard_entity.dart';
import '../../domain/entities/mobile_profile_entity.dart';
import '../../domain/entities/mobile_project_entity.dart';
import '../../domain/entities/mobile_schedule_entity.dart';
import '../../domain/repositories/mobile_dashboard_repository.dart';
import '../datasources/mobile_dashboard_datasource.dart';

class MobileDashboardRepositoryImpl implements MobileDashboardRepository {
  MobileDashboardRepositoryImpl(this.remoteDataSource);

  final MobileDashboardRemoteDataSource remoteDataSource;

  @override
  Future<MobileDashboardEntity> getDashboard({int page = 1, int limit = 10}) =>
      remoteDataSource.getDashboard(page: page, limit: limit);

  @override
  Future<List<MobileProjectEntity>> getProjects({
    int page = 1,
    int limit = 50,
  }) =>
      remoteDataSource.getProjects(page: page, limit: limit);

  @override
  Future<MobileProfileEntity> getProfile() => remoteDataSource.getProfile();

  @override
  Future<List<MobileScheduleDayEntity>> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
  }) =>
      remoteDataSource.getSchedule(startDate: startDate, endDate: endDate);

  @override
  Future<List<MobileMapPinEntity>> getMapPins({String? type}) =>
      remoteDataSource.getMapPins(type: type);
}
