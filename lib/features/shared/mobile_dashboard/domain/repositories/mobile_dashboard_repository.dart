import '../entities/mobile_dashboard_entity.dart';
import '../entities/mobile_profile_entity.dart';
import '../entities/mobile_project_entity.dart';
import '../entities/mobile_schedule_entity.dart';

abstract class MobileDashboardRepository {
  Future<MobileDashboardEntity> getDashboard();

  Future<List<MobileProjectEntity>> getProjects();

  Future<MobileProfileEntity> getProfile();

  Future<List<MobileScheduleDayEntity>> getSchedule({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<MobileMapPinEntity>> getMapPins({String? type});
}
