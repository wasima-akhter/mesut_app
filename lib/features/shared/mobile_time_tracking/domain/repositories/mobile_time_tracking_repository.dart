import '../../../../../core/enums/backend_enums.dart';
import '../entities/mobile_time_log_entity.dart';

abstract class MobileTimeTrackingRepository {
  Future<MobileTimerStartResultEntity> startTimer({
    required String phaseId,
    required BackendActivityType activityType,
    double? gpsStartLat,
    double? gpsStartLng,
  });

  Future<MobileTimeLogEntity> stopTimer({
    required String timeLogId,
    double? gpsEndLat,
    double? gpsEndLng,
  });

  Future<MobileTimeLogEntity> logManualTime({
    required String phaseId,
    required BackendActivityType activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
  });

  Future<List<MobileTimeLogEntity>> getTimeLogs({String period = 'TODAY'});

  Future<MobileCrewTimeEntity> getCrewTime({
    required String projectId,
    DateTime? date,
    int page = 1,
    int limit = 10,
  });
}
